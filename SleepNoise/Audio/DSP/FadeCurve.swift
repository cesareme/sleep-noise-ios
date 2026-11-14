import Foundation

/// Equal-slope smoothstep used for the sleep-timer fade.
/// `unity(0) == 0`, `unity(1) == 1`, `unity(0.5) == 0.5`, and the slope is 0 at both ends.
enum FadeCurve {
    @inline(__always)
    static func unity(_ progress: Float) -> Float {
        let t = progress < 0 ? 0 : (progress > 1 ? 1 : progress)
        return t * t * (3 - 2 * t)
    }

    /// 1 at the start of a fade-out, 0 at the end.
    @inline(__always)
    static func outputGain(progress: Float) -> Float {
        1 - unity(progress)
    }
}
