import Darwin
import Foundation

/// Main-thread smoothing of the published output level.
///
/// A one-pole follower advanced by the time between two reads, so it does not
/// need a timer of its own: whoever draws asks for the value and passes the
/// clock. After a long gap (the interface was not drawing) it simply lands on
/// the current level.
struct OutputLevelFollower {
    /// Below this, with a silent target, the tail is cut to an exact zero so
    /// the interface can tell "quiet" from "almost quiet" and stop drawing.
    static let silence: Float = 1e-4

    private(set) var value: Float = 0
    private var lastTime: TimeInterval?

    /// Moves `value` toward `target` and returns it. `tau` is the time
    /// constant in seconds; zero or less means "no smoothing".
    mutating func follow(_ target: Float, at time: TimeInterval, tau: TimeInterval) -> Float {
        let safeTarget = target == target ? max(0, target) : 0
        defer { lastTime = time }
        guard let last = lastTime, tau > 0 else {
            value = safeTarget
            return value
        }
        let elapsed = time - last
        guard elapsed > 0 else { return value }
        let blend = Float(1 - exp(-elapsed / tau))
        value += (safeTarget - value) * blend
        if safeTarget <= 0, value < Self.silence {
            value = 0
        }
        return value
    }

    mutating func reset() {
        value = 0
        lastTime = nil
    }
}
