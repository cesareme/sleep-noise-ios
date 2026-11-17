import Combine
import Foundation

/// The timer of the night, in its two modes (C03, C22).
///
/// - "Until I sleep" counts a length in minutes and ends with a fade
///   (`TimerMath.fadeDuration`). A pause stops the count; the same night
///   picks it up where it was.
/// - "Blanket" sounds until an hour of the clock. 45 minutes in, the level
///   eases down 6 dB once; the final fade ends at that hour. A pause does
///   not move the hour.
///
/// Everything is anchored to dates: the count does not depend on the app
/// being in front, and a tick that fires late still lands on the right
/// state. The clock and the calendar are passed in.
///
/// Nothing here is periodic (03 §3.7: with the screen off, nothing but the
/// audio runs on a period). One one-shot timer waits for whatever comes
/// next: the blanket's dip, the start of the final fade, the next minute of
/// "Fading · n min" while it fades, or the end. It publishes only when one
/// of those moves; the seconds left are worked out when somebody asks.
///
/// The timer owns no sound. It says what should happen through its
/// callbacks, and where the night stands through `fadeLevel` and
/// `blanketGain`, which whoever starts the engine reads first.
@MainActor
final class SleepTimerController: ObservableObject {
    /// Tonight's timer. Usually the stored choice; a Shortcut may run
    /// another one for one night without storing it.
    @Published private(set) var choice: TimerChoice
    /// When the night ends, while it counts. Nil at rest and while paused.
    @Published private(set) var endsAt: Date?
    /// Seconds left right now. While paused it holds what is left of
    /// "Until I sleep". Nil when nothing was started. Not published: a view
    /// that shows minutes reads it on its own schedule; every change of
    /// state (start, pause, "+15 min", the end) publishes something else.
    var remaining: TimeInterval? {
        if let frozen { return frozen }
        guard isCounting, let endDate else { return nil }
        return max(0, endDate.timeIntervalSince(now()))
    }
    /// The final fade is under way.
    @Published private(set) var isFading = false
    /// The figure of "Fading · n min" while it is. It changes by the minute.
    @Published private(set) var fadingMinutes: Int?

    /// The final fade begins: silence in this many seconds.
    var onFade: (@MainActor (TimeInterval) -> Void)?
    /// "+15 min" called the final fade off: the level comes back.
    var onFadeCancelled: (@MainActor () -> Void)?
    /// The blanket eases down: this gain, over this many seconds.
    var onBlanketDip: (@MainActor (Float, TimeInterval) -> Void)?
    /// The night is over.
    var onComplete: (@MainActor () -> Void)?

    private let now: () -> Date
    private let calendar: Calendar
    private let usesTicker: Bool
    private var ticker: Timer?
    /// Bumped when something that is not published changes what the views
    /// say (a paused count that grew by fifteen minutes).
    @Published private var revision = 0

    private var isCounting = false
    /// The end of the night. A blanket keeps it through a pause.
    private var endDate: Date?
    /// What is left of "Until I sleep" while it is paused.
    private var frozen: TimeInterval?
    /// Length of the final fade of this night.
    private var fade: TimeInterval = 0
    /// When this blanket began, for its one dip.
    private var blanketBegan: Date?
    private var hasDipped = false
    private var fadeRequested = false
    /// A night that resumes inside its final fade rises to where the fade
    /// stands first; the fade is asked for again once it is there.
    private var fadeNotBefore: Date?

    /// `ticks: false` leaves the run loop alone: a test moves the clock and
    /// calls `tick()` itself.
    init(
        choice: TimerChoice = .firstUse,
        now: @escaping () -> Date = { Date() },
        calendar: Calendar = .autoupdatingCurrent,
        ticks: Bool = true
    ) {
        self.choice = choice
        self.now = now
        self.calendar = calendar
        usesTicker = ticks
    }

    // MARK: What the old views read

    /// The length of "Until I sleep", or nil in any other mode.
    var selectedMinutes: Int? { choice.untilAsleepMinutes }

    // MARK: Where the night stands

    /// A count exists: running, or paused with time left.
    var hasCount: Bool { isCounting || frozen != nil || endDate != nil }

    /// The end of the night when it has a fixed one (the blanket), for the
    /// morning window of `InterruptionPolicy`.
    var fixedEnd: Date? { choice.mode == .blanket ? endDate : nil }

    /// Where the final fade stands: 1 outside it, 0 at its end.
    var fadeLevel: Float {
        guard let left = secondsLeft() else { return 1 }
        return TimerMath.fadeLevel(remaining: left, fade: fade)
    }

    /// The share of the session level the blanket leaves: 1 until its dip.
    var blanketGain: Float {
        choice.mode == .blanket && hasDipped ? TimerMath.blanketDipGain : 1
    }

    /// The blanket has not eased the level down yet and will before its
    /// final fade: what the timer sheet may still promise.
    var blanketDipIsAhead: Bool {
        guard choice.mode == .blanket, !hasDipped, let blanketBegan, let endDate else { return false }
        return blanketBegan.addingTimeInterval(TimerMath.blanketDipAfter) < endDate.addingTimeInterval(-fade)
    }

    private func secondsLeft() -> TimeInterval? {
        if let frozen { return frozen }
        if let endDate { return max(0, endDate.timeIntervalSince(now())) }
        return nil
    }

    // MARK: Choosing

    /// A new choice ends whatever was counting. The caller starts it again
    /// if the night is playing.
    func choose(_ choice: TimerChoice) {
        reset()
        if self.choice != choice { self.choice = choice }
    }

    // MARK: The night

    /// Play. Continues the count of this night, or begins a new one.
    /// `risingOver` is how long the engine takes to bring the bed up: a
    /// night that resumes inside its final fade waits that long before it
    /// asks for the fade again.
    func start(risingOver fadeIn: TimeInterval = PlaybackFade.start) {
        guard choice.mode != .off, !isCounting else { return }
        let now = now()
        switch choice.mode {
        case .off:
            return
        case .untilAsleep:
            let full = TimeInterval(choice.minutes * 60)
            var left = frozen ?? full
            if frozen == nil || left <= 1 {
                // A new night, or one paused on its last second.
                left = full
                fade = TimerMath.fadeDuration(totalSeconds: full)
            }
            frozen = nil
            endDate = now.addingTimeInterval(left)
        case .blanket:
            if endDate.map({ $0.timeIntervalSince(now) <= 1 }) ?? true {
                // A new night: the hour is the next one to come.
                let end = TimerMath.blanketEnd(
                    after: now,
                    hour: choice.endHour,
                    minute: choice.endMinute,
                    calendar: calendar
                )
                endDate = end
                blanketBegan = now
                hasDipped = false
                fade = TimerMath.fadeDuration(totalSeconds: end.timeIntervalSince(now))
            } else if !hasDipped, dipIsDue(at: now) {
                // It came due while the night was paused: the level is
                // simply there when the bed rises, without a ramp.
                hasDipped = true
            }
        }
        guard let endDate else { return }
        isCounting = true
        fadeRequested = false
        let left = endDate.timeIntervalSince(now)
        let fading = left <= fade
        fadeNotBefore = fading ? now.addingTimeInterval(fadeIn + 0.2) : nil
        publish(left: left, fading: fading)
        endsAt = endDate
        scheduleNext()
    }

    /// Pause. "Until I sleep" keeps what is left; a blanket keeps its hour.
    func pause() {
        guard isCounting else { return }
        stopTicking()
        isCounting = false
        if choice.mode == .untilAsleep, let endDate {
            let left = max(0, endDate.timeIntervalSince(now()))
            frozen = left
            self.endDate = nil
        }
        endsAt = nil
        fadeRequested = false
        fadeNotBefore = nil
        if isFading { isFading = false }
        if fadingMinutes != nil { fadingMinutes = nil }
    }

    /// The night is over: the next start is a new one. The choice stays.
    func reset() {
        stopTicking()
        isCounting = false
        endDate = nil
        frozen = nil
        fade = 0
        blanketBegan = nil
        hasDipped = false
        fadeRequested = false
        fadeNotBefore = nil
        if endsAt != nil { endsAt = nil }
        if isFading { isFading = false }
        if fadingMinutes != nil { fadingMinutes = nil }
    }

    /// "+15 min": the night ends that much later. It never creates a timer
    /// (C47): with none chosen, or with no count to add to, nothing happens
    /// and the answer is false. Inside the final fade it calls the fade off.
    @discardableResult
    func extend(by seconds: TimeInterval = TimerMath.extensionSeconds) -> Bool {
        guard choice.mode != .off, seconds > 0 else { return false }
        if let frozen {
            self.frozen = frozen + seconds
            revision += 1
            return true
        }
        guard let end = endDate else { return false }
        let later = end.addingTimeInterval(seconds)
        endDate = later
        guard isCounting else { return true }
        endsAt = later
        let left = later.timeIntervalSince(now())
        let stillFading = left <= fade
        if isFading, !stillFading {
            // Whether or not the fade had been asked for yet: a night that
            // resumed inside it stands below 1 until it is, and the level
            // comes back from wherever the envelope is.
            onFadeCancelled?()
        }
        // Still inside the fade (a short extension): it is asked for again,
        // from where the level is, over the time that is left now.
        fadeRequested = false
        fadeNotBefore = nil
        publish(left: left, fading: stillFading)
        scheduleNext()
        return true
    }

    /// Applies whatever came due. Called by the one-shot timer and safe to
    /// call at any time: everything is read from the clock. Internal so
    /// that a test can drive it.
    func tick() {
        guard isCounting, let endDate else { return }
        let now = now()
        let left = endDate.timeIntervalSince(now)
        if left <= 0 {
            finish()
            return
        }
        if !hasDipped, dipIsDue(at: now), left > fade {
            hasDipped = true
            onBlanketDip?(TimerMath.blanketDipGain, TimerMath.blanketDipRamp)
        }
        let fading = left <= fade
        publish(left: left, fading: fading)
        if fading, !fadeRequested, fadeNotBefore.map({ now >= $0 }) ?? true {
            fadeRequested = true
            fadeNotBefore = nil
            onFade?(left)
        }
        scheduleNext()
    }

    /// Seconds until something next has to happen, from where the count
    /// stands: the dip, the start of the fade (or the moment a resumed
    /// night may ask for it), the next minute of the fade, the end. Nil
    /// when nothing counts.
    func secondsToNextEvent() -> TimeInterval? {
        guard isCounting, let endDate else { return nil }
        let now = now()
        let left = endDate.timeIntervalSince(now)
        guard left > 0 else { return 0 }
        var next = left
        if left > fade {
            next = min(next, left - fade)
            if !hasDipped, choice.mode == .blanket, let blanketBegan {
                let dip = TimerMath.blanketDipAfter - now.timeIntervalSince(blanketBegan)
                // A dip that would land inside the final fade never comes.
                if dip < left - fade { next = min(next, max(0, dip)) }
            }
        } else {
            if !fadeRequested, let fadeNotBefore {
                next = min(next, max(0, fadeNotBefore.timeIntervalSince(now)))
            }
            // "Fading · n min" moves when a whole minute is left.
            let toMinute = left - (left / 60).rounded(.down) * 60
            next = min(next, toMinute > 0 ? toMinute : 60)
        }
        return next
    }

    private func dipIsDue(at now: Date) -> Bool {
        guard choice.mode == .blanket, let blanketBegan else { return false }
        return now.timeIntervalSince(blanketBegan) >= TimerMath.blanketDipAfter
    }

    /// Only what changed is published: the fade, and its figure by the
    /// minute. Outside the fade nothing is published between two events.
    private func publish(left: TimeInterval, fading: Bool) {
        if isFading != fading { isFading = fading }
        let minutes = fading ? TimerMath.fadingMinutes(remaining: left) : nil
        if fadingMinutes != minutes { fadingMinutes = minutes }
    }

    private func finish() {
        reset()
        onComplete?()
    }

    /// One one-shot for whatever comes next. Background audio keeps the
    /// process running, so it fires with the screen locked. The delay is
    /// read from the clock passed in, so a pinned clock schedules nothing
    /// that fires at once.
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
