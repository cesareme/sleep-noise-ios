import Combine
import Foundation

struct BreathingSettings: Codable, Equatable {
    static let rateRange = 4...8
    static let durationChoices = [5, 10, 15, 20, 30, 0]

    var isEnabled = false
    var breathsPerMinute = 6
    /// Minutes of guided breathing before the beds drift back to their own
    /// rhythm. `0` keeps the tide all night, at a subtler depth.
    var guideMinutes = 15

    var guidesAllNight: Bool { guideMinutes == 0 }

    /// Depth of the bed modulation. All night is kept subtle: a 4 dB swell
    /// every ten seconds for eight hours is what light sleepers call pulsing.
    var bedDepth: Float { guidesAllNight ? 0.2 : 0.4 }
}

enum BreathingPhase: Equatable {
    case idle
    case guiding
    case dissolving
}

/// Main-thread owner of the breathing tide. It publishes `BreathParameters`
/// through `onChange` (the engine) and keeps the schedule: full weight for
/// `guideMinutes`, then a two-minute dissolve that the render thread performs
/// on the audio clock from a single command.
///
/// Every (re)start bumps the epoch, which resets the audio phase to the top of
/// an inhale at the same instant `anchor` is recorded, so the on-screen disc
/// and the waves share one clock.
@MainActor
final class BreathingGuideController: ObservableObject {
    static let dissolveSeconds: Float = 120
    /// The disc is shown for this long at most, even when the tide runs all night.
    static let visualSeconds: TimeInterval = 20 * 60
    static let storageKey = "sleepnoise.breath.v1"

    @Published var settings: BreathingSettings {
        didSet { persist() }
    }
    @Published private(set) var phase: BreathingPhase = .idle
    /// Start of the current epoch; drives the on-screen indicator.
    @Published private(set) var anchor: Date?

    var onChange: (@MainActor (BreathParameters) -> Void)?

    /// The session's window: when the guide began and when it ends (nil = all night).
    private(set) var windowStart: Date?
    private(set) var guideEndsAt: Date?
    private var epoch: UInt32 = 0
    private var ticker: Timer?
    private let defaults: UserDefaults
    private(set) var lastPublished = BreathParameters.off

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(BreathingSettings.self, from: data) {
            settings = decoded
        } else {
            settings = BreathingSettings()
        }
    }

    var isActive: Bool { phase != .idle }

    /// Whether the disc should move at `now`.
    func isVisuallyActive(now: Date = Date()) -> Bool {
        guard phase == .guiding, let windowStart else { return false }
        return now.timeIntervalSince(windowStart) < Self.visualSeconds
    }

    /// Play pressed: a new window from the top of an inhale.
    func begin(now: Date = Date()) {
        stopTicking()
        windowStart = now
        guideEndsAt = settings.guidesAllNight ? nil : now.addingTimeInterval(TimeInterval(settings.guideMinutes) * 60)
        startEpoch(now: now)
    }

    /// Playback came back after an interruption or a media-services reset:
    /// continue the existing window instead of guiding again. Inside the guide
    /// the tide resumes at full weight, re-anchored so audio and disc agree;
    /// once the guide is over nothing comes back.
    func resume(now: Date = Date()) {
        stopTicking()
        guard windowStart != nil else {
            begin(now: now)
            return
        }
        if let guideEndsAt, now >= guideEndsAt {
            self.windowStart = nil
            self.guideEndsAt = nil
            finish()
            return
        }
        startEpoch(now: now)
    }

    /// Applies new settings to a running guide. The window keeps its start.
    /// A new rate keeps the audio continuous (the render side preserves the
    /// fraction of the cycle) and rebases the anchor so the disc keeps the
    /// same fraction too. During a dissolve only the rate is refreshed and
    /// the finish timer is left alone.
    func settingsDidChange(now: Date = Date()) {
        guard isActive, let windowStart else { return }
        let rateChanged = abs(BreathParameters.guided(breathsPerMinute: settings.breathsPerMinute).rate - lastPublished.rate) > 1e-6
        switch phase {
        case .idle:
            return
        case .dissolving:
            if rateChanged {
                var parameters = parameters(weight: 0, dissolve: lastPublished.dissolveSeconds)
                parameters.bedDepth = lastPublished.bedDepth
                publish(parameters)
            }
            return
        case .guiding:
            guideEndsAt = settings.guidesAllNight ? nil : windowStart.addingTimeInterval(TimeInterval(settings.guideMinutes) * 60)
            if let guideEndsAt, now >= guideEndsAt {
                stopTicking()
                dissolve(now: now)
                return
            }
            if rateChanged, let anchor, lastPublished.rate > 0 {
                let newRate = Double(BreathParameters.guided(breathsPerMinute: settings.breathsPerMinute).rate)
                let elapsedCycles = now.timeIntervalSince(anchor) * Double(lastPublished.rate)
                let fraction = elapsedCycles - elapsedCycles.rounded(.down)
                self.anchor = now.addingTimeInterval(-fraction / newRate)
            }
            stopTicking()
            publish(parameters(weight: 1, dissolve: 0))
            scheduleGuideEnd()
        }
    }

    /// The sleep timer is fading the whole bed out: let the tide go with it so
    /// the last seconds are the natural sea, not a guided inhale.
    func release(over seconds: TimeInterval) {
        guard isActive else { return }
        stopTicking()
        phase = .dissolving
        publish(parameters(weight: 0, dissolve: Float(max(1, seconds))))
    }

    /// Stops the tide. The window is kept so a system resume can continue it.
    func end() {
        stopTicking()
        guard isActive || lastPublished != .off else { return }
        phase = .idle
        anchor = nil
        publish(.off)
    }

    /// Weight the schedule calls for at `now`, for tests and the indicator.
    func scheduledWeight(now: Date = Date()) -> Float? {
        guard windowStart != nil else { return nil }
        guard let guideEndsAt else { return 1 }
        let elapsed = now.timeIntervalSince(guideEndsAt)
        if elapsed < 0 { return 1 }
        if elapsed >= TimeInterval(Self.dissolveSeconds) { return 0 }
        return Float(1 - elapsed / TimeInterval(Self.dissolveSeconds))
    }

    private func startEpoch(now: Date) {
        epoch &+= 1
        if epoch == 0 { epoch = 1 }
        anchor = now
        phase = .guiding
        publish(parameters(weight: 1, dissolve: 0))
        scheduleGuideEnd()
    }

    private func parameters(weight: Float, dissolve: Float) -> BreathParameters {
        var parameters = BreathParameters.guided(breathsPerMinute: settings.breathsPerMinute, weight: weight, epoch: epoch)
        parameters.dissolveSeconds = dissolve
        parameters.bedDepth = settings.bedDepth
        return parameters
    }

    private func scheduleGuideEnd() {
        guard let guideEndsAt else { return }
        schedule(at: guideEndsAt) { [weak self] in
            self?.dissolve()
        }
    }

    private func dissolve(now: Date = Date()) {
        phase = .dissolving
        publish(parameters(weight: 0, dissolve: Self.dissolveSeconds))
        schedule(at: now.addingTimeInterval(TimeInterval(Self.dissolveSeconds) + 3)) { [weak self] in
            self?.finish()
        }
    }

    private func finish() {
        stopTicking()
        phase = .idle
        anchor = nil
        publish(.off)
    }

    /// One-shot timer on the main run loop, computed from a date so a late
    /// fire still lands on the right state. Background audio keeps the process
    /// running, so it fires with the screen locked.
    private func schedule(at date: Date, _ action: @escaping @MainActor () -> Void) {
        stopTicking()
        let timer = Timer(fire: date, interval: 0, repeats: false) { _ in
            MainActor.assumeIsolated {
                action()
            }
        }
        timer.tolerance = 2
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func stopTicking() {
        ticker?.invalidate()
        ticker = nil
    }

    private func publish(_ parameters: BreathParameters) {
        lastPublished = parameters
        onChange?(parameters)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
