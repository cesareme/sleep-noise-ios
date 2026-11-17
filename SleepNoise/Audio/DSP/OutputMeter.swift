import Darwin
import Foundation

/// Running mean square of the stereo output, measured after the soft clip.
///
/// One pole per frame: two multiplies, three adds and a compare. It lives in
/// `RenderState`, so it is plain data like everything else the callback
/// touches. The render thread publishes `meanSquare` once per buffer through
/// `OutputLevelCell`; the square root is taken on the main thread.
struct OutputMeter {
    /// Integration time of the mean square, in seconds. Long enough to read a
    /// level instead of single samples, short enough to follow a fade.
    static let window: Float = 0.05
    /// Mean square below this (−100 dBFS RMS) with nothing coming in is
    /// silence. It keeps the tail of the pole out of denormal range and makes
    /// "the engine went quiet" an exact zero.
    static let silence: Float = 1e-10

    var meanSquare: Float = 0
    var coefficient: Float = 0

    /// Only while the engine is stopped, like every other `prepare`.
    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        coefficient = 1 - expf(-1 / (rate * Self.window))
    }

    mutating func reset() {
        meanSquare = 0
    }

    @inline(__always)
    mutating func add(left: Float, right: Float) {
        let power = 0.5 * (left * left + right * right)
        meanSquare += (power - meanSquare) * coefficient
        if meanSquare < Self.silence, power < Self.silence {
            meanSquare = 0
        }
    }

    /// 0 for silence; about 0.707 for a full-scale sine in both channels.
    var rms: Float {
        sqrtf(max(0, meanSquare))
    }
}
