import Combine
import Foundation

/// One Small Hours session: the fixed recipe played against a clock (C05,
/// C60, `SmallHoursRecipe`).
///
/// Low ocean with the tide at 8 breaths a minute, for everyone. The bed
/// rises in 3 s, the tide guides until minute 10.5 and has dissolved by
/// minute 13, the sea fades over the last 5 minutes and then nothing
/// happens: no sound, no notice, no screen.
///
/// It owns no sound and knows nothing of the person's mix, timer or tide
/// settings: it reads the recipe and says what should happen through its
/// callbacks. Times are anchored to a date, so a tick that fires late still
/// lands on the right state; a pause stops the session's clock. The clock
/// is passed in. Nothing is periodic: one one-shot timer waits for the next
/// thing to happen (the tide letting go, the closing fade, the next minute
/// of the figure, the end).
@MainActor
final class SmallHoursController: ObservableObject {
    let recipe: SmallHoursRecipe

    /// A session exists, playing or paused.
    @Published private(set) var isActive = false
    @Published private(set) var isPaused = false
    /// Whole minutes left, rounded up: the one figure of the screen.
    @Published private(set) var minutesLeft = 0
    /// The figure of "Winding down · n min" during the closing fade.
    @Published private(set) var windingDownMinutes: Int?
    /// Top of the first inhale of the tide that is guiding, for the water
    /// line. Nil once the tide has gone.
    @Published private(set) var tideAnchor: Date?

    /// The tide as it was last asked for.
    private(set) var tide = BreathParameters.off

    /// The tide changes: the engine takes these parameters.
    var onTide: (@MainActor (BreathParameters) -> Void)?
    /// The closing fade begins: silence in this many seconds.
    var onFade: (@MainActor (TimeInterval) -> Void)?
    /// The session ran its length. Nothing else is said about it.
    var onComplete: (@MainActor () -> Void)?

    /// Seconds the render side takes to settle the tide after its dissolve.
    static let tideTail: TimeInterval = 6
    /// The guide of the mixer counts its epochs from 1. These start far
    /// away, so the two never share one and the audio phase always restarts
    /// with the session.
    private static let firstEpoch: UInt32 = 0x4000_0000

    private enum TideStage {
        case off
        case guiding
        case dissolving
    }

    private let now: () -> Date
    private let usesTicker: Bool
    private var ticker: Timer?
    /// The start of the session, moved forward by every pause.
    private var startedAt: Date?
    private var pausedElapsed: TimeInterval?
    private var stage = TideStage.off
    private var epoch = SmallHoursController.firstEpoch
    private var fadeRequested = false
    private var fadeNotBefore: Date?

    /// `ticks: false` leaves the run loop alone: a test moves the clock and
    /// calls `tick()` itself.
    init(
        recipe: SmallHoursRecipe = .standard,
        now: @escaping () -> Date = { Date() },
        ticks: Bool = true
    ) {
        self.recipe = recipe
        self.now = now
        usesTicker = ticks
    }

    /// Seconds of the session played so far.
    var elapsed: TimeInterval {
        if let pausedElapsed { return pausedElapsed }
        guard let startedAt else { return 0 }
        return max(0, now().timeIntervalSince(startedAt))
    }

    var phase: SmallHoursRecipe.Phase { recipe.phase(at: elapsed) }

    /// Where the closing fade stands: 1 before it, 0 at its end. What a
    /// session that resumes inside it rises to.
    var fadeLevel: Float {
        TimerMath.fadeLevel(remaining: recipe.duration - elapsed, fade: recipe.finalFade)
    }

    /// What sounds: the sound of the recipe at its level and nothing else.
    /// It plays at every access level (`inSmallHours`), so nobody hears
    /// silence here for want of Pro.
    func gains(hasFullAccess: Bool) -> SoundGains {
        var gains = SoundGains.zero
        if AccessPolicy.soundIsIncluded(recipe.sound, hasFullAccess: hasFullAccess, inSmallHours: true) {
            gains.set(recipe.sound, recipe.level)
        }
        return gains
    }

    /// A new session, from its first second.
    func begin() {
        stopTicking()
        startedAt = now()
        pausedElapsed = nil
        fadeRequested = false
        fadeNotBefore = nil
        isActive = true
        isPaused = false
        guideTide()
        publishFigures()
        scheduleNext()
    }

    func pause() {
        guard isActive, !isPaused else { return }
        stopTicking()
        pausedElapsed = elapsed
        startedAt = nil
        isPaused = true
        fadeRequested = false
        fadeNotBefore = nil
    }

    /// Continues where the session was. `risingOver` is how long the engine
    /// takes to bring the bed up: inside the closing fade the session waits
    /// that long before it asks for the fade again.
    func resume(risingOver fadeIn: TimeInterval) {
        guard isActive, isPaused, let pausedElapsed else { return }
        let now = now()
        startedAt = now.addingTimeInterval(-pausedElapsed)
        self.pausedElapsed = nil
        isPaused = false
        switch recipe.phase(at: pausedElapsed) {
        case .tideGuiding:
            guideTide()
        case .tideDissolving, .plainSea, .windingDown, .finished:
            // The tide was leaving or had left: it does not come back for
            // what remained of its dissolve.
            dropTide()
        }
        fadeRequested = false
        fadeNotBefore = pausedElapsed >= recipe.finalFadeStart ? now.addingTimeInterval(fadeIn + 0.2) : nil
        publishFigures()
        scheduleNext()
    }

    /// The session is over before its time: the person left, or something
    /// else took its place. Nothing is called back.
    func end() {
        stopTicking()
        startedAt = nil
        pausedElapsed = nil
        fadeRequested = false
        fadeNotBefore = nil
        stage = .off
        tide = .off
        if tideAnchor != nil { tideAnchor = nil }
        if isActive { isActive = false }
        if isPaused { isPaused = false }
        if minutesLeft != 0 { minutesLeft = 0 }
        if windingDownMinutes != nil { windingDownMinutes = nil }
    }

    /// Applies whatever came due. Called by the one-shot timer and safe to
    /// call at any time. Internal so that a test can drive the clock.
    func tick() {
        guard isActive, !isPaused else { return }
        let time = elapsed
        if time >= recipe.duration {
            end()
            onComplete?()
            return
        }
        if stage == .guiding, time >= recipe.tideGuideEnd {
            stage = .dissolving
            var parameters = tide
            parameters.weight = 0
            parameters.dissolveSeconds = Float(max(1, recipe.tideDissolveEnd - time))
            sendTide(parameters)
        } else if stage == .dissolving, time >= recipe.tideDissolveEnd + Self.tideTail {
            dropTide()
        }
        if time >= recipe.finalFadeStart, !fadeRequested, fadeNotBefore.map({ now() >= $0 }) ?? true {
            fadeRequested = true
            fadeNotBefore = nil
            onFade?(recipe.duration - time)
        }
        publishFigures()
        scheduleNext()
    }

    /// Seconds until something next has to happen. Nil when no session
    /// runs.
    func secondsToNextEvent() -> TimeInterval? {
        guard isActive, !isPaused else { return nil }
        let time = elapsed
        let left = recipe.duration - time
        guard left > 0 else { return 0 }
        var next = left
        // The figure moves when a whole minute is left.
        let toMinute = left - (left / 60).rounded(.down) * 60
        next = min(next, toMinute > 0 ? toMinute : 60)
        switch stage {
        case .guiding: next = min(next, max(0, recipe.tideGuideEnd - time))
        case .dissolving: next = min(next, max(0, recipe.tideDissolveEnd + Self.tideTail - time))
        case .off: break
        }
        if !fadeRequested {
            var fadeAt = max(0, recipe.finalFadeStart - time)
            if let fadeNotBefore { fadeAt = max(fadeAt, fadeNotBefore.timeIntervalSince(now())) }
            next = min(next, max(0, fadeAt))
        }
        return next
    }

    private func guideTide() {
        epoch &+= 1
        stage = .guiding
        tideAnchor = now()
        sendTide(.guided(breathsPerMinute: recipe.breathsPerMinute, weight: 1, epoch: epoch))
    }

    private func dropTide() {
        stage = .off
        if tideAnchor != nil { tideAnchor = nil }
        sendTide(.off)
    }

    private func sendTide(_ parameters: BreathParameters) {
        tide = parameters
        onTide?(parameters)
    }

    /// Only what changed is published: the figures move by the minute.
    private func publishFigures() {
        let time = elapsed
        let minutes = recipe.minutesLeft(at: time)
        if minutesLeft != minutes { minutesLeft = minutes }
        let winding = recipe.windingDownMinutes(at: time)
        if windingDownMinutes != winding { windingDownMinutes = winding }
    }

    private func scheduleNext() {
        ticker?.invalidate()
        ticker = nil
        guard usesTicker, let wait = secondsToNextEvent() else { return }
        // A hair late rather than early: `tick` must find the event due.
        let timer = Timer(timeInterval: wait + 0.05, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func stopTicking() {
        ticker?.invalidate()
        ticker = nil
    }
}
