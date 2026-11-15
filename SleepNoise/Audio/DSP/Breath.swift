import Darwin
import Foundation

/// Breathing-tide parameters carried inside `EngineCommand`. Plain floats and
/// integers only: the struct is copied under the seqlock by the render thread.
///
/// - `rate`: cycles per second (6 breaths/min = 0.1). 0 means off.
/// - `inhale`, `exhale`: fractions of the cycle; the remainder is a rest.
/// - `weight`: how much the beds follow the breath, 0…1. The render state
///   moves toward it linearly over `dissolveSeconds` (0 = at once), then
///   smooths the result, so no publish can ever step the sound.
/// - `bedDepth`: peak-to-trough of the amplitude modulation on the non-ocean
///   beds at full weight. 0.4 is about 4.4 dB: a swell, not pumping.
/// - `epoch`: changes when a guide (re)starts. The render state resets its
///   phase to the top of an inhale, so the audio and the on-screen disc share
///   one anchor.
struct BreathParameters: Equatable {
    var rate: Float = 0
    var inhale: Float = 0.4
    var exhale: Float = 0.45
    var weight: Float = 0
    var dissolveSeconds: Float = 0
    var bedDepth: Float = 0.4
    var epoch: UInt32 = 0

    static let off = BreathParameters()

    static func guided(breathsPerMinute: Int, weight: Float = 1, epoch: UInt32 = 0) -> BreathParameters {
        let perMinute = max(2, min(12, breathsPerMinute))
        var parameters = BreathParameters()
        parameters.rate = Float(perMinute) / 60
        parameters.weight = min(1, max(0, weight))
        parameters.epoch = epoch
        return parameters
    }
}

/// Shape of one breath: a raised cosine up over the inhale, a raised cosine
/// down over the exhale, then flat at zero for the rest. Continuous, with zero
/// slope at every joint, so the modulation it drives has no corners.
enum BreathCurve {
    @inline(__always)
    static func value(phase: Float, inhale: Float, exhale: Float) -> Float {
        let p = phase - floorf(phase)
        let inLength = max(0.05, min(0.9, inhale))
        let outLength = max(0.05, min(0.95 - inLength, exhale))
        if p < inLength {
            let t = p / inLength
            return 0.5 - 0.5 * cosf(Float.pi * t)
        }
        let q = p - inLength
        if q < outLength {
            let t = q / outLength
            return 0.5 + 0.5 * cosf(Float.pi * t)
        }
        return 0
    }

    /// Breath value at a wall-clock offset from the start of the guide. Used by
    /// the on-screen indicator so it moves with the audio.
    static func value(secondsSinceStart: Double, parameters: BreathParameters) -> Float {
        guard parameters.rate > 0 else { return 0 }
        let phase = Float(secondsSinceStart * Double(parameters.rate))
        return value(phase: phase, inhale: parameters.inhale, exhale: parameters.exhale)
    }
}
