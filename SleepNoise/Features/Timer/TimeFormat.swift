import Foundation

enum TimerMath {
    /// Fade window: a quarter of the timer, clamped to 5...20 seconds.
    static func fadeDuration(totalSeconds: TimeInterval) -> TimeInterval {
        min(20, max(5, totalSeconds * 0.25))
    }
}

enum TimeFormat {
    static func clock(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded(.up)))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    static func minutes(_ minutes: Int) -> String {
        String(format: String(localized: "timer.minutesFormat"), Int64(minutes))
    }

    static func percentSpoken(_ percent: Int) -> String {
        String(format: String(localized: "a11y.percentFormat"), Int64(percent))
    }
}
