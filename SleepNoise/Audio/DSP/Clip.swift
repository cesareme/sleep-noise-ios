import Foundation

/// Hard bound used by every generator. NaNs become silence so a bad
/// coefficient can never poison the output buffer.
@inline(__always)
func clipUnit(_ x: Float) -> Float {
    if x < -1 { return -1 }
    if x > 1 { return 1 }
    if x != x { return 0 }
    return x
}

/// Smooth saturation. Slope is 1 at zero, so quiet mixes stay linear,
/// and a stack of layers compresses instead of hard-clipping.
@inline(__always)
func softClip(_ x: Float) -> Float {
    let limited = x / (1 + abs(x) * 0.25)
    return clipUnit(limited)
}

@inline(__always)
func flushDenormal(_ x: Float) -> Float {
    abs(x) < 1e-15 ? 0 : x
}
