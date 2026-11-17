import Combine
import Foundation

struct BreathingSettings: Codable, Equatable {
    static let rateRange = 4...8
    /// "Recedes after": five to thirty minutes (03 §5 #6).
    static let durationChoices = [5, 10, 15, 20, 30]
    /// The two paces with a name: "Calm · 6" and "Gentle · 8".
    static let calmRate = 6
    static let gentleRate = 8
    /// "Descent" starts here, a fixed parameter (C34), and comes down one
    /// breath a minute every forty seconds to the pace chosen (C14, C24).
    static let descentStartRate = 12
    static let descentStepSeconds: TimeInterval = 40

    var isEnabled = false
    var breathsPerMinute = 6
    /// Minutes of guided breathing before the beds drift back to their own
    /// rhythm. `0` keeps the tide all night, at a subtler depth: no screen
    /// offers it in 1.0, and a stored 0 is read as the longest choice.
    var guideMinutes = 15
    /// "Descent", the ritual of the tide: the guide begins at twelve a
    /// minute and comes down to the pace, stays there, then dissolves.
    var descends = false

    var guidesAllNight: Bool { guideMinutes == 0 }

    /// Depth of the bed modulation. All night is kept subtle: a 4 dB swell
    /// every ten seconds for eight hours is what light sleepers call pulsing.
    var bedDepth: Float { guidesAllNight ? 0.2 : 0.4 }

    /// The pace the guide holds `elapsed` seconds into a descent. Without
    /// the ritual, or once it has come down, the pace chosen.
    func rate(descentElapsed elapsed: TimeInterval?) -> Int {
        guard descends, let elapsed, breathsPerMinute < Self.descentStartRate else {
            return breathsPerMinute
        }
        let steps = Int((max(0, elapsed) / Self.descentStepSeconds).rounded(.down))
        return max(breathsPerMinute, Self.descentStartRate - steps)
    }

    /// Seconds into the descent at which the pace next comes down, or nil
    /// once it is on its plateau.
    func nextDescentStep(after elapsed: TimeInterval) -> TimeInterval? {
        guard descends, rate(descentElapsed: elapsed) > breathsPerMinute else { return nil }
        let steps = (max(0, elapsed) / Self.descentStepSeconds).rounded(.down) + 1
        return steps * Self.descentStepSeconds
    }
}

extension BreathingSettings {
    /// Settings stored before a field existed keep everything else: a
    /// missing key takes its default instead of failing the whole value.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? isEnabled
        breathsPerMinute = try container.decodeIfPresent(Int.self, forKey: .breathsPerMinute) ?? breathsPerMinute
        guideMinutes = try container.decodeIfPresent(Int.self, forKey: .guideMinutes) ?? guideMinutes
        descends = try container.decodeIfPresent(Bool.self, forKey: .descends) ?? descends
    }
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
    /// Breaths a minute the guide holds right now: the pace chosen, or the
    /// step of the descent it is on. Nil while idle.
    @Published private(set) var guidingRate: Int?
    /// When the guide lets go and the dissolve begins ("Recedes at"). Nil
    /// while idle and when it guides all night.
    @Published private(set) var guideEndsAt: Date?

    var onChange: (@MainActor (BreathParameters) -> Void)?

    /// The session's window: when the guide began. It ends at `guideEndsAt`.
    private(set) var windowStart: Date?
    /// When the descent of this window began, if it has one.
    private var descentStart: Date?
    /// When the dissolve the guide began by itself is over.
    private var dissolveEndsAt: Date?
    /// The guide's clock minus the wall clock, when the anchor was set.
    private var displayOffset: TimeInterval = 0
    private var epoch: UInt32 = 0
    private var ticker: Timer?
    private let defaults: UserDefaults
    private let clock: () -> Date
    private let usesTimers: Bool
    private(set) var lastPublished = BreathParameters.off

    /// The clock is passed in, like the timer's and Small Hours': the model
    /// gives all three the same one. `ticks: false` leaves the run loop
    /// alone: a test moves the clock and calls `advance()` itself.
    init(defaults: UserDefaults = .standard, now: @escaping () -> Date = { Date() }, ticks: Bool = true) {
        self.defaults = defaults
        clock = now
        usesTimers = ticks
        if let data = defaults.data(forKey: Self.storageKey),
           var decoded = try? JSONDecoder().decode(BreathingSettings.self, from: data) {
            // "All night" is not offered in 1.0: it is read as the longest
            // of the lengths that are.
            if decoded.guidesAllNight {
                decoded.guideMinutes = BreathingSettings.durationChoices.last ?? decoded.guideMinutes
            }
            settings = decoded
        } else {
            settings = BreathingSettings()
        }
    }

    var isActive: Bool { phase != .idle }

    /// The guide stopped with its window still open (a pause): Play goes on
    /// with it instead of guiding again.
    func hasOpenWindow(now given: Date? = nil) -> Bool {
        let now = given ?? clock()
        guard windowStart != nil else { return false }
        return guideEndsAt.map { now < $0 } ?? true
    }

    /// Whether the disc should move at `now`.
    func isVisuallyActive(now given: Date? = nil) -> Bool {
        let now = given ?? clock()
        guard phase == .guiding, let windowStart else { return false }
        return now.timeIntervalSince(windowStart) < Self.visualSeconds
    }

    /// Play pressed: a new window from the top of an inhale.
    func begin(now given: Date? = nil) {
        let now = given ?? clock()
        stopTicking()
        windowStart = now
        descentStart = settings.descends ? now : nil
        guideEndsAt = settings.guidesAllNight ? nil : now.addingTimeInterval(TimeInterval(settings.guideMinutes) * 60)
        startEpoch(now: now)
    }

    /// Playback came back after an interruption or a media-services reset:
    /// continue the existing window instead of guiding again. Inside the guide
    /// the tide resumes at full weight, re-anchored so audio and disc agree;
    /// once the guide is over nothing comes back.
    func resume(now given: Date? = nil) {
        let now = given ?? clock()
        stopTicking()
        guard windowStart != nil else {
            begin(now: now)
            return
        }
        if let guideEndsAt, now >= guideEndsAt {
            self.windowStart = nil
            self.descentStart = nil
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
    func settingsDidChange(now given: Date? = nil) {
        let now = given ?? clock()
        guard isActive, let windowStart else { return }
        // "Descent" switched on while guiding begins its way down now;
        // switched off, the guide goes to the pace chosen.
        if !settings.descends {
            descentStart = nil
        } else if descentStart == nil, phase == .guiding {
            descentStart = now
        }
        let rate = scheduledRate(now: now)
        let rateChanged = abs(BreathParameters.guided(breathsPerMinute: rate).rate - lastPublished.rate) > 1e-6
        switch phase {
        case .idle:
            return
        case .dissolving:
            if rateChanged {
                guidingRate = rate
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
            if rateChanged { rebase(to: rate, now: now) }
            stopTicking()
            publish(parameters(weight: 1, dissolve: 0))
            scheduleNext(now: now)
        }
    }

    /// Applies what came due at `now`: the next step of the descent, or the
    /// end of the guide. Internal so that a test can move the clock.
    func advance(now given: Date? = nil) {
        let now = given ?? clock()
        if phase == .dissolving, let dissolveEndsAt, now >= dissolveEndsAt {
            finish()
            return
        }
        guard phase == .guiding else { return }
        if let guideEndsAt, now >= guideEndsAt {
            stopTicking()
            dissolve(now: now)
            return
        }
        let rate = scheduledRate(now: now)
        if rate != guidingRate {
            rebase(to: rate, now: now)
            publish(parameters(weight: 1, dissolve: 0))
        }
        scheduleNext(now: now)
    }

    /// The pace the settings call for at `now`.
    private func scheduledRate(now: Date) -> Int {
        settings.rate(descentElapsed: descentStart.map { now.timeIntervalSince($0) })
    }

    /// A new pace keeps the fraction of the cycle: the anchor moves so the
    /// line on screen stays with the audio, which does the same.
    private func rebase(to rate: Int, now: Date) {
        if let anchor, lastPublished.rate > 0 {
            let newRate = Double(BreathParameters.guided(breathsPerMinute: rate).rate)
            let elapsedCycles = now.timeIntervalSince(anchor) * Double(lastPublished.rate)
            let fraction = elapsedCycles - elapsedCycles.rounded(.down)
            self.anchor = now.addingTimeInterval(-fraction / newRate)
            displayOffset = clock().timeIntervalSince(Date())
        }
        guidingRate = rate
    }

    /// A date of the display's own clock (a `TimelineView`) on the clock of
    /// the guide. The same instant in the app. They are apart only when a
    /// staged launch pins the clock: the breath then runs from the anchor
    /// in real time, so the line of a capture still moves.
    func onGuideClock(_ date: Date) -> Date {
        date.addingTimeInterval(displayOffset)
    }

    /// The sleep timer is fading the whole bed out: let the tide go with it so
    /// the last seconds are the natural sea, not a guided inhale.
    func release(over seconds: TimeInterval) {
        guard isActive else { return }
        stopTicking()
        dissolveEndsAt = nil
        phase = .dissolving
        publish(parameters(weight: 0, dissolve: Float(max(1, seconds))))
    }

    /// Stops the tide. The window is kept so a system resume can continue it.
    func end() {
        stopTicking()
        dissolveEndsAt = nil
        guard isActive || lastPublished != .off else { return }
        phase = .idle
        anchor = nil
        guidingRate = nil
        publish(.off)
    }

    /// Weight the schedule calls for at `now`, for tests and the indicator.
    func scheduledWeight(now given: Date? = nil) -> Float? {
        let now = given ?? clock()
        guard windowStart != nil else { return nil }
        guard let guideEndsAt else { return 1 }
        let elapsed = now.timeIntervalSince(guideEndsAt)
        if elapsed < 0 { return 1 }
        if elapsed >= TimeInterval(Self.dissolveSeconds) { return 0 }
        return Float(1 - elapsed / TimeInterval(Self.dissolveSeconds))
    }

    private func startEpoch(now: Date) {
        dissolveEndsAt = nil
        epoch &+= 1
        if epoch == 0 { epoch = 1 }
        anchor = now
        displayOffset = clock().timeIntervalSince(Date())
        phase = .guiding
        guidingRate = scheduledRate(now: now)
        publish(parameters(weight: 1, dissolve: 0))
        scheduleNext(now: now)
    }

    private func parameters(weight: Float, dissolve: Float) -> BreathParameters {
        var parameters = BreathParameters.guided(
            breathsPerMinute: guidingRate ?? settings.breathsPerMinute,
            weight: weight,
            epoch: epoch
        )
        parameters.dissolveSeconds = dissolve
        parameters.bedDepth = settings.bedDepth
        return parameters
    }

    /// One timer for whatever comes first: the next step of the descent
    /// or the end of the guide.
    private func scheduleNext(now: Date) {
        var next = guideEndsAt
        if let descentStart,
           let step = settings.nextDescentStep(after: now.timeIntervalSince(descentStart)) {
            let date = descentStart.addingTimeInterval(step)
            next = next.map { min($0, date) } ?? date
        }
        guard let next else { return }
        schedule(at: next) { [weak self] in
            self?.advance()
        }
    }

    private func dissolve(now: Date) {
        phase = .dissolving
        publish(parameters(weight: 0, dissolve: Self.dissolveSeconds))
        let end = now.addingTimeInterval(TimeInterval(Self.dissolveSeconds) + 3)
        dissolveEndsAt = end
        schedule(at: end) { [weak self] in
            self?.advance()
        }
    }

    private func finish() {
        stopTicking()
        dissolveEndsAt = nil
        phase = .idle
        anchor = nil
        guidingRate = nil
        publish(.off)
    }

    /// One-shot timer on the main run loop. What it does is read from the
    /// clock again, so a late fire still lands on the right state.
    /// Background audio keeps the process running, so it fires with the
    /// screen locked. The wait is measured on the clock passed in: with a
    /// pinned clock nothing fires at once.
    private func schedule(at date: Date, _ action: @escaping @MainActor () -> Void) {
        stopTicking()
        guard usesTimers else { return }
        let timer = Timer(timeInterval: max(0, date.timeIntervalSince(clock())) + 0.05, repeats: false) { _ in
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
