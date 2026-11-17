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

    /// Time constant of the fall once the engine has stopped rendering.
    ///
    /// Colour means sound, so the level must not outlive the sound: 1.5 s at
    /// most (03 §3.7), from any level and at any refresh rate. A one-pole
    /// fall is a straight line in decibels, 8.69 / tau dB per second. At
    /// 0.15 s it crosses the 72 dB between full scale and what the Horizon
    /// calls silence in 1.24 s, which leaves room for one 4 Hz read, and the
    /// default mix is gone in under a second.
    static let stopTau: TimeInterval = 0.15

    /// The constant to follow with: the caller's while the engine renders;
    /// after it stops, never slower than `stopTau`. Reduce Motion asks for a
    /// slow line, not for colour that lingers over silence.
    static func tau(requested: TimeInterval, isRendering: Bool) -> TimeInterval {
        isRendering ? requested : min(requested, stopTau)
    }

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
