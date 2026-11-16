import Foundation

/// Paul Kellet's economy pink filter (approximately −3 dB/octave).
/// The fixed 0.11 scale keeps typical peaks inside the unit interval;
/// `clipUnit` is the hard guarantee.
struct PinkNoise {
    var rng: XorShift32
    private var b0: Float = 0
    private var b1: Float = 0
    private var b2: Float = 0
    private var b3: Float = 0
    private var b4: Float = 0
    private var b5: Float = 0
    private var b6: Float = 0
    var gain: Float = 0.11

    init(seed: UInt32) {
        rng = XorShift32(seed: seed)
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        b0 = 0.99886 * b0 + white * 0.0555179
        b1 = 0.99332 * b1 + white * 0.0750759
        b2 = 0.96900 * b2 + white * 0.1538520
        b3 = 0.86650 * b3 + white * 0.3104856
        b4 = 0.55000 * b4 + white * 0.5329522
        b5 = -0.7616 * b5 - white * 0.0168980
        let pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362
        b6 = white * 0.115926
        b0 = flushDenormal(b0)
        b1 = flushDenormal(b1)
        b2 = flushDenormal(b2)
        b3 = flushDenormal(b3)
        b4 = flushDenormal(b4)
        b5 = flushDenormal(b5)
        b6 = flushDenormal(b6)
        return clipUnit(pink * gain)
    }
}
