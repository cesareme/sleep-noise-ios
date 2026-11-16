import Foundation

struct WhiteNoise {
    var rng: XorShift32
    /// Brings RMS in line with the filtered generators.
    var gain: Float = 0.35

    init(seed: UInt32) {
        rng = XorShift32(seed: seed)
    }

    mutating func next() -> Float {
        clipUnit(rng.nextBipolar() * gain)
    }
}
