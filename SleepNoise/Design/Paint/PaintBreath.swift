import CoreGraphics
import Foundation

/// How the paint answers the sound (lenguaje-pictorico.md §3): it only
/// listens to the smoothed RMS the Horizon already reads and to the tide,
/// and it only moves light and breath. Hue, position, length and number of
/// strokes never move. Pure functions and a follower that bounds the rate
/// of change, so nothing flickers.
enum PaintBreath {
    /// Opacity of the live layer, from the quietest level to the loudest.
    static let liveMin: Double = 0.45
    static let liveMax: Double = 0.85
    /// Nothing changes more than half its range in a second.
    static let maxChangePerSecond: Double = 0.5 * (liveMax - liveMin)
    /// Birth in 2 s, death in 3 s: the global opacity follows presence.
    static let birth: TimeInterval = 2
    static let death: TimeInterval = 3
    /// The live layer with Reduce Motion, when it has not been lit by the
    /// sound yet: still, at the middle of its range. It never breathes.
    static let stillOpacity: Double = (liveMin + liveMax) / 2
    /// A sheet in front or the app at the back.
    static let dimmedOpacity: Double = 0.3
    /// Paused: the paint dries. Pause is not night.
    static let driedOpacity: Double = 0.6
    /// How far the window slides with the tide, along the dominant motif.
    static let tideTravel: CGFloat = 6

    /// The opacity the live layer aims at for a reading: the level between
    /// 0.45 and 0.85, times the presence (0 while silent). Pure.
    static func liveTarget(rms: Float) -> Double {
        let level = Double(SoundLevelScale.level(rms: rms))
        let presence = Double(SoundLevelScale.presence(rms: rms))
        return (liveMin + (liveMax - liveMin) * level) * presence
    }

    /// A step towards `target` that never moves more than `maxDelta`.
    static func step(_ current: Double, toward target: Double, maxDelta: Double) -> Double {
        let delta = target - current
        return current + max(-maxDelta, min(maxDelta, delta))
    }

    /// Where the window sits for the tide: ±6 pt along the direction of
    /// the dominant motif, 0 at mid breath, rounded to the pixel by the
    /// page. Nil tide, no slide.
    static func offset(tide: Float?, direction: Double) -> CGSize {
        guard let tide else { return .zero }
        let k = (Double(min(1, max(0, tide))) - 0.5) * Double(tideTravel) * 2
        return CGSize(width: cos(direction) * k, height: sin(direction) * k)
    }
}

/// Follows the sound with the opacity of the live layer, bounded: the
/// level part moves at most half its range per second, presence is born
/// in 2 s and dies in 3 s. Fed once per tick of the Horizon's timeline
/// with the same smoothed reading.
struct PaintBreathFollower: Equatable {
    /// 0.45 to 0.85, from the level.
    private(set) var level: Double = PaintBreath.liveMin
    /// 0 to 1, from the presence.
    private(set) var presence: Double = 0

    /// What the live layer draws at.
    var liveOpacity: Double { level * presence }

    /// Advances `dt` seconds towards the reading. A frozen phase does not
    /// call this: the layer stays where it was.
    mutating func advance(rms: Float, dt: TimeInterval) {
        let dt = max(0, dt)
        let targetLevel = PaintBreath.liveMin
            + (PaintBreath.liveMax - PaintBreath.liveMin) * Double(SoundLevelScale.level(rms: rms))
        level = PaintBreath.step(level, toward: targetLevel, maxDelta: PaintBreath.maxChangePerSecond * dt)
        let targetPresence = Double(SoundLevelScale.presence(rms: rms))
        let rate = targetPresence >= presence ? 1 / PaintBreath.birth : 1 / PaintBreath.death
        presence = PaintBreath.step(presence, toward: targetPresence, maxDelta: rate * dt)
    }

    /// Back to the start: silent, unlit.
    mutating func reset() {
        self = PaintBreathFollower()
    }

    /// Sits at `opacity`, fully present: the still layer of the frozen
    /// phase, so the first step out of it is a step, not a jump.
    mutating func settle(at opacity: Double) {
        level = min(PaintBreath.liveMax, max(PaintBreath.liveMin, opacity))
        presence = 1
    }
}
