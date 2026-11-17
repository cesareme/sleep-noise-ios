import Darwin
import Foundation

/// Wind: broadband air whose cutoff and level follow two slow, incommensurate
/// gusts. There is no motor tone, which is what separates it from the fan.
/// Gust phases start at fixed values so the swells stay centred in stereo
/// while the noise itself is decorrelated.
struct WindTexture {
    /// Output trim. At unity the top of a gust reached full scale and the
    /// wind was the loudest of the new beds. `softClip` then keeps the peak of
    /// the strongest gust under full scale at every sample rate.
    static let outputGain: Float = 0.75

    var rng: XorShift32
    private var whoosh = StateVariableFilter()
    private var air: Float = 0
    private var airCoefficient: Float = 0.3
    private var gustA: Float = 0.2
    private var gustB: Float = 2.1
    private var incrementA: Float = 0
    private var incrementB: Float = 0

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        whoosh.prepare(sampleRate: rate, cutoff: 700, resonance: 0.7)
        airCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 3_000)
        incrementA = (2 * Float.pi * 0.05) / rate
        incrementB = (2 * Float.pi * 0.13) / rate
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        gustA = wrapPhase(gustA + incrementA)
        gustB = wrapPhase(gustB + incrementB)
        let primary = 0.5 + 0.5 * sinf(gustA)
        let secondary = 0.5 + 0.5 * sinf(gustB)
        let gust = 0.35 + 0.65 * primary * (0.55 + 0.45 * secondary)

        whoosh.setCutoff(380 + 900 * gust)
        let body = whoosh.process(white).low * (0.55 + 0.9 * gust)

        air = flushDenormal(air + airCoefficient * (white - air))
        let hiss = (white - air) * 0.12 * gust

        return softClip((body * 1.35 + hiss) * Self.outputGain)
    }
}
