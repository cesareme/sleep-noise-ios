import Foundation

/// How an envelope fade moves between its two ends. Carried in the engine
/// command as a plain integer, so the command stays a POD.
enum FadeShape {
    /// Smoothstep: no slope at either end. Every fade to silence.
    static let smooth: Int32 = 0
    /// Ease out: quick at first, settling into the target. The start of
    /// playback, so the bed is there at once and arrives without a bump.
    static let easeOut: Int32 = 1
    /// A straight line: the weight of the tide as it lets go.
    static let linear: Int32 = 2
}

/// Equal-slope smoothstep used for the sleep-timer fade.
/// `unity(0) == 0`, `unity(1) == 1`, `unity(0.5) == 0.5`, and the slope is 0 at both ends.
enum FadeCurve {
    @inline(__always)
    static func unity(_ progress: Float) -> Float {
        let t = progress < 0 ? 0 : (progress > 1 ? 1 : progress)
        return t * t * (3 - 2 * t)
    }

    /// Quadratic ease out: `easeOut(0) == 0`, `easeOut(1) == 1`, three
    /// quarters of the way at half time, and the slope is 0 at the end.
    @inline(__always)
    static func easeOut(_ progress: Float) -> Float {
        let t = progress < 0 ? 0 : (progress > 1 ? 1 : progress)
        let rest = 1 - t
        return 1 - rest * rest
    }

    /// The curve for a `FadeShape`. An unknown shape is the smooth one.
    @inline(__always)
    static func shaped(_ progress: Float, shape: Int32) -> Float {
        if shape == FadeShape.easeOut { return easeOut(progress) }
        if shape == FadeShape.linear { return progress < 0 ? 0 : (progress > 1 ? 1 : progress) }
        return unity(progress)
    }

    /// 1 at the start of a fade-out, 0 at the end.
    @inline(__always)
    static func outputGain(progress: Float) -> Float {
        1 - unity(progress)
    }
}
