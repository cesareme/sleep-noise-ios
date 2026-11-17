import Darwin
import Foundation

/// The two ways a night ends by itself, and none (C03, C11, C22).
enum TimerMode: String, Codable, CaseIterable {
    case off
    /// "Until I sleep": a length in minutes, with a fade at the end.
    case untilAsleep
    /// "Blanket" (Manto): it sounds until an hour of the clock.
    case blanket
}

/// What the person chose in the timer sheet. The whole timer is free: no
/// mode, length or hour asks for Pro (C03).
///
/// The length and the hour are both kept whatever the mode, so that going
/// from one mode to the other and back finds each as it was left.
struct TimerChoice: Codable, Equatable {
    var mode: TimerMode
    /// Length of "Until I sleep", 1 to `AccessPolicy.maxTimerMinutes`.
    var minutes: Int
    /// When the blanket ends: an hour of the clock, the next one to come.
    var endHour: Int
    var endMinute: Int

    static let defaultMinutes = 45
    static let defaultEndHour = 7

    /// The timer of the first night (03 §5 #8): "Until I sleep", 45 minutes.
    /// Nothing is stored until the person chooses, so this is never mistaken
    /// for a choice of "Off".
    static let firstUse = TimerChoice(mode: .untilAsleep)

    init(
        mode: TimerMode,
        minutes: Int = TimerChoice.defaultMinutes,
        endHour: Int = TimerChoice.defaultEndHour,
        endMinute: Int = 0
    ) {
        self.mode = mode
        self.minutes = min(AccessPolicy.maxTimerMinutes, max(1, minutes))
        self.endHour = min(23, max(0, endHour))
        self.endMinute = min(59, max(0, endMinute))
    }

    /// The same choice in another mode.
    func with(mode: TimerMode) -> TimerChoice {
        TimerChoice(mode: mode, minutes: minutes, endHour: endHour, endMinute: endMinute)
    }

    static func untilAsleep(_ minutes: Int) -> TimerChoice {
        TimerChoice(mode: .untilAsleep, minutes: minutes)
    }

    static func blanket(hour: Int, minute: Int = 0) -> TimerChoice {
        TimerChoice(mode: .blanket, endHour: hour, endMinute: minute)
    }

    static let off = TimerChoice(mode: .off)

    /// The length while the mode is "Until I sleep", else nil.
    var untilAsleepMinutes: Int? { mode == .untilAsleep ? minutes : nil }
}

/// The arithmetic of the timer, without a clock of its own.
enum TimerMath {
    /// The final fade is a quarter of the night and fifteen minutes at
    /// most: ten minutes for forty, fifteen from an hour up (C31, "10 to 15
    /// minutes"). A night shorter than forty minutes cannot spend ten of
    /// them fading, so its fade is the same quarter.
    static let longestFade: TimeInterval = 15 * 60
    static let fadeShare = 0.25

    static func fadeDuration(totalSeconds: TimeInterval) -> TimeInterval {
        min(longestFade, max(0, totalSeconds) * fadeShare)
    }

    /// "+15 min".
    static let extensionSeconds: TimeInterval = 15 * 60

    /// The blanket eases down once: 6 dB, 45 minutes after it began, over a
    /// minute (C22). The sound that helped to fall asleep is more than the
    /// rest of the night needs.
    static let blanketDipAfter: TimeInterval = 45 * 60
    static let blanketDipDecibels: Float = -6
    static let blanketDipRamp: TimeInterval = 60
    /// -6 dB as a gain: 0.501.
    static let blanketDipGain: Float = powf(10, blanketDipDecibels / 20)

    /// The next time the clock reads `hour`:`minute` after `start`. A
    /// blanket has no length in minutes (C22): it ends at an hour.
    static func blanketEnd(after start: Date, hour: Int, minute: Int, calendar: Calendar) -> Date {
        let components = DateComponents(hour: hour, minute: minute, second: 0)
        return calendar.nextDate(after: start, matching: components, matchingPolicy: .nextTime)
            ?? start.addingTimeInterval(24 * 60 * 60)
    }

    /// The figure of "Fading · n min": whole minutes left, never under one.
    static func fadingMinutes(remaining: TimeInterval) -> Int {
        max(1, Int((max(0, remaining) / 60).rounded(.up)))
    }

    /// Where a fade of `fade` seconds stands with `remaining` seconds to go:
    /// 1 before it begins, 0 at its end, on the smooth curve the engine
    /// renders. What a night that resumes inside its final fade rises to.
    static func fadeLevel(remaining: TimeInterval, fade: TimeInterval) -> Float {
        guard fade > 0 else { return remaining > 0 ? 1 : 0 }
        return FadeCurve.unity(Float(max(0, min(1, remaining / fade))))
    }
}
