import Darwin
import Foundation

/// Fan: a broadband whoosh (resonant lowpass whose cutoff drifts slowly), a quiet
/// motor hum with its second harmonic, a shallow blade-rate flutter, and a slow
/// level wobble. The flutter is kept to a few percent: deep amplitude modulation
/// around 15–20 Hz reads as a helicopter, not a bedroom fan.
struct FanTexture {
    var rng: XorShift32
    private var whoosh = StateVariableFilter()
    private var hiss: Float = 0
    private var hissCoefficient: Float = 0.3
    private var humPhase: Float = 0
    private var humIncrement: Float = 0
    private var bladePhase: Float = 0.2
    private var bladeIncrement: Float = 0
    private var driftPhase: Float = 0.4
    private var driftIncrement: Float = 0
    private var wobblePhase: Float = 1.1
    private var wobbleIncrement: Float = 0
    private var sampleRate: Float = 48_000

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        whoosh.prepare(sampleRate: rate, cutoff: 1_500, resonance: 0.9)
        hissCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 4_000)
        humIncrement = (2 * Float.pi * 58) / rate
        bladeIncrement = (2 * Float.pi * 21) / rate
        driftIncrement = (2 * Float.pi * 0.11) / rate
        wobbleIncrement = (2 * Float.pi * 0.23) / rate
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()

        driftPhase = wrapPhase(driftPhase + driftIncrement)
        wobblePhase = wrapPhase(wobblePhase + wobbleIncrement)
        bladePhase = wrapPhase(bladePhase + bladeIncrement)
        humPhase = wrapPhase(humPhase + humIncrement)

        whoosh.setCutoff(1_500 + 220 * sinf(driftPhase))
        let body = whoosh.process(white).low

        hiss = flushDenormal(hiss + hissCoefficient * (white - hiss))
        let air = (white - hiss) * 0.05

        let hum = (sinf(humPhase) + 0.35 * sinf(2 * humPhase)) * 0.045

        let flutter = 0.955 + 0.045 * sinf(bladePhase)
        let wobble = 0.97 + 0.03 * sinf(wobblePhase)

        let sample = (body * 1.05 + air) * flutter * wobble + hum
        return clipUnit(sample)
    }
}

@inline(__always)
func wrapPhase(_ phase: Float) -> Float {
    phase > 2 * Float.pi ? phase - 2 * Float.pi : phase
}
