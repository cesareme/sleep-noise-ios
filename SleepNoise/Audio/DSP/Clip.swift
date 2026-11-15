import Darwin
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

/// Bounded saturation with a linear knee.
///
/// Below `knee` the signal passes untouched, so a single bed keeps its
/// character. Above it a tanh segment compresses towards, and never
/// reaches, full scale, so stacking every layer at full volume cannot
/// hard-clip. The curve is continuous with slope 1 at the knee.
@inline(__always)
func softClip(_ x: Float) -> Float {
    let knee: Float = 0.6
    let magnitude = abs(x)
    if magnitude <= knee {
        return clipUnit(x)
    }
    let headroom = 1 - knee
    let shaped = knee + headroom * tanhf((magnitude - knee) / headroom)
    return clipUnit(x < 0 ? -shaped : shaped)
}

@inline(__always)
func flushDenormal(_ x: Float) -> Float {
    abs(x) < 1e-15 ? 0 : x
}
