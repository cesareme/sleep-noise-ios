import Foundation

/// How long a night may stay paused and still be the same night.
///
/// One rule for every pause, whatever caused it: an interruption, a lost
/// output or the person's own pause. `InterruptionPolicy` and `RoutePolicy`
/// both ask here, and so does whoever wakes the app with a night still
/// paused. After this long the night is over: nothing resumes it, and the
/// next play starts a new one.
enum SessionPause {
    static let longest: TimeInterval = 20 * 60

    /// A clock set back meanwhile never ends the night early.
    static func isOver(pausedAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(pausedAt) >= longest
    }
}
