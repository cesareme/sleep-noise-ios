import Foundation

/// Leaky integrator. The pole at 0.995 is a random walk with a slow leak,
/// which is the discrete form of brown (Brownian) noise: about −6 dB/octave.
struct BrownNoise {
    var rng: XorShift32
    private var state: Float = 0
    var leak: Float = 0.995
    var drive: Float = 0.02
    var gain: Float = 1.45

    init(seed: UInt32) {
        rng = XorShift32(seed: seed)
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        state = flushDenormal(state * leak + white * drive)
        return clipUnit(state * gain)
    }
}
