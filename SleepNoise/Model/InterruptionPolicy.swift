import Foundation

/// The hours in which an interruption is taken for the morning alarm.
///
/// The system does not say that an interruption was the alarm, so the clock
/// stands in for it: from 05:00 to 11:00, or from one hour before the end of
/// the night when the night has a fixed end (Manto). With a fixed end that
/// hour replaces the 05:00 to 11:00 rule; it does not add to it: someone who
/// set the night to end at 13:00 is asleep at 08:00.
///
/// This is its own rule, not a second `NightWindow`.
enum MorningWindow {
    /// First hour inside the window.
    static let startHour = 5
    /// First hour after the window.
    static let endHour = 11
    /// With a fixed end, the window opens this long before it.
    static let leadBeforeFixedEnd: TimeInterval = 60 * 60

    static func contains(_ date: Date, fixedEnd: Date? = nil, calendar: Calendar) -> Bool {
        if let fixedEnd {
            return date >= fixedEnd.addingTimeInterval(-leadBeforeFixedEnd)
        }
        let hour = calendar.component(.hour, from: date)
        return hour >= startHour && hour < endHour
    }

    /// True when any instant from `start` to `end` is inside the window, so
    /// a pause that began at 04:50 and ended at 05:10 counts, and so does one
    /// that covered the whole morning.
    static func touches(from start: Date, to end: Date, fixedEnd: Date? = nil, calendar: Calendar) -> Bool {
        let (first, last) = start <= end ? (start, end) : (end, start)
        if contains(first, fixedEnd: fixedEnd, calendar: calendar)
            || contains(last, fixedEnd: fixedEnd, calendar: calendar) {
            return true
        }
        guard fixedEnd == nil else { return false }
        let opening = DateComponents(hour: startHour, minute: 0, second: 0)
        guard let next = calendar.nextDate(after: first, matching: opening, matchingPolicy: .nextTime) else {
            return false
        }
        return next <= last
    }
}

/// What stopped the sound.
enum InterruptionKind: Equatable, CaseIterable {
    /// A phone or FaceTime call, as `CXCallObserver` reports it.
    case call
    /// Anything else the system interrupts with: Siri, an alarm, another
    /// app. The system does not say which.
    case system
    /// The output went away (interruption reason `.routeDisconnected`).
    /// When it plays again is for `RoutePolicy` to say.
    case routeDisconnected
}

/// One interruption, from the system's `.began` to its `.ended` (or to the
/// next time the app runs, when no `.ended` arrives).
struct Interruption: Equatable {
    var kind: InterruptionKind
    var beganAt: Date
    var endedAt: Date
    /// The night was playing when it began. A night the person had already
    /// paused is not this policy's to resume or to end.
    var wasPlaying: Bool
    /// The end of the night when it has a fixed one (Manto), else nil.
    var fixedEnd: Date?

    var duration: TimeInterval { max(0, endedAt.timeIntervalSince(beganAt)) }
}

enum InterruptionOutcome: Equatable {
    /// Play again, fading in over this many seconds. It is the same night:
    /// the trial is not evaluated and the tide continues its window.
    case resume(fadeIn: TimeInterval)
    /// The night is over. Nothing resumes.
    case endSession
    /// Stay as it is: paused, with the night still open.
    case stayPaused
}

/// What to do when an interruption ends. One table for every mode.
///
/// - Inside the morning window no interruption resumes: the night ends. The
///   alarm must always win, also over a long timer set at one in the morning,
///   and a call in those hours ends the night too.
/// - Outside it every interruption resumes with a three second fade in. A
///   call never ends the night, however long it was. Anything else that kept
///   the night paused for twenty minutes has ended it.
/// - A lost output never resumes from here.
///
/// The system's `shouldResume` hint is deliberately not an input: outside the
/// window every interruption resumes.
enum InterruptionPolicy {
    static let resumeFadeIn: TimeInterval = 3
    /// A night paused this long is over.
    static let longestPause: TimeInterval = 20 * 60

    static func outcome(of interruption: Interruption, calendar: Calendar) -> InterruptionOutcome {
        guard interruption.wasPlaying else { return .stayPaused }
        let inMorning = MorningWindow.touches(
            from: interruption.beganAt,
            to: interruption.endedAt,
            fixedEnd: interruption.fixedEnd,
            calendar: calendar
        )
        if inMorning { return .endSession }
        let tooLong = interruption.duration >= longestPause
        switch interruption.kind {
        case .call:
            return .resume(fadeIn: resumeFadeIn)
        case .system:
            return tooLong ? .endSession : .resume(fadeIn: resumeFadeIn)
        case .routeDisconnected:
            return tooLong ? .endSession : .stayPaused
        }
    }
}

/// Keeps the interruption that is open and resolves it when it ends. The
/// clock and the calendar are passed in; nothing here reads the system's.
///
/// Wiring: `began` on the system's `.began`, `note(.call)` when the call
/// observer reports a call, `note(.routeDisconnected)` when the output goes
/// away meanwhile, `ended` on `.ended` or the next time the app runs with an
/// interruption still open. An outcome of `.resume` still has to pass
/// `RoutePolicy.mayResumeUnasked` before anything plays.
struct InterruptionTracker {
    let calendar: Calendar
    let now: () -> Date

    private(set) var kind: InterruptionKind?
    private(set) var beganAt: Date?
    private var wasPlaying = false

    init(calendar: Calendar, now: @escaping () -> Date) {
        self.calendar = calendar
        self.now = now
    }

    var isOpen: Bool { beganAt != nil }

    /// A second `.began` before an `.ended` is the same interruption: it
    /// keeps its start and only adds what is known about its kind.
    mutating func began(_ kind: InterruptionKind, wasPlaying: Bool) {
        guard isOpen else {
            self.kind = kind
            self.wasPlaying = wasPlaying
            beganAt = now()
            return
        }
        note(kind)
    }

    /// Something learned after the interruption began: the call observer
    /// may speak late, and the output may go away during a call. A lost
    /// output outranks a call, and a call outranks the rest, so the kind
    /// only ever moves towards resuming less.
    mutating func note(_ kind: InterruptionKind) {
        guard let current = self.kind else { return }
        if current == .routeDisconnected || kind == .routeDisconnected {
            self.kind = .routeDisconnected
        } else if current == .call || kind == .call {
            self.kind = .call
        }
    }

    /// Closes the open interruption and says what to do. With none open
    /// there is nothing to do.
    mutating func ended(fixedEnd: Date? = nil) -> InterruptionOutcome {
        guard let kind, let beganAt else { return .stayPaused }
        let interruption = Interruption(
            kind: kind,
            beganAt: beganAt,
            endedAt: now(),
            wasPlaying: wasPlaying,
            fixedEnd: fixedEnd
        )
        self.kind = nil
        self.beganAt = nil
        wasPlaying = false
        return InterruptionPolicy.outcome(of: interruption, calendar: calendar)
    }
}
