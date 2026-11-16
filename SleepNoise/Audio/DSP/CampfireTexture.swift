import Darwin
import Foundation

/// Campfire: a low flame body whose level flickers, plus a handful of short
/// crackles. The flicker is a pair of slow oscillators so both channels swell
/// together; the cracks are independent noise bursts, which is what spreads
/// the fire across the stereo image.
struct CampfireTexture {
    /// Output trim. The flame body sits below 300 Hz, where the ear is least
    /// sensitive, so at unity the fire read about 11 dB(A) under rain at the
    /// same slider position. The flicker gives the body a high crest factor;
    /// the output therefore goes through `softClip`, which is transparent
    /// below its knee and rounds the few peaks above it instead of clipping.
    static let outputGain: Float = 2.5

    var rng: XorShift32
    private var sampleRate: Float = 48_000
    private var bodyA: Float = 0
    private var bodyB: Float = 0
    private var bodyCoefficient: Float = 0.02
    private var hiss: Float = 0
    private var hissCoefficient: Float = 0.2
    private var flickerA: Float = 0.4
    private var flickerB: Float = 1.7
    private var flickerIncrementA: Float = 0
    private var flickerIncrementB: Float = 0
    private var crack0 = BurstVoice()
    private var crack1 = BurstVoice()
    private var crack2 = BurstVoice()

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        bodyCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 280)
        hissCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 2_400)
        flickerIncrementA = (2 * Float.pi * 0.13) / rate
        flickerIncrementB = (2 * Float.pi * 0.31) / rate
        crack0.prepare(sampleRate: rate, cutoff: 1_800, resonance: 4)
        crack1.prepare(sampleRate: rate, cutoff: 2_600, resonance: 4.5)
        crack2.prepare(sampleRate: rate, cutoff: 1_400, resonance: 3.5)
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        flickerA = wrapPhase(flickerA + flickerIncrementA)
        flickerB = wrapPhase(flickerB + flickerIncrementB)
        let flicker = (0.55 + 0.45 * (0.5 + 0.5 * sinf(flickerA))) * (0.75 + 0.25 * sinf(flickerB))

        bodyA = flushDenormal(bodyA + bodyCoefficient * (white - bodyA))
        bodyB = flushDenormal(bodyB + bodyCoefficient * (bodyA - bodyB))
        let flame = bodyB * flicker * 2.4

        hiss = flushDenormal(hiss + hissCoefficient * (white - hiss))
        let air = (white - hiss) * 0.04 * flicker

        let cracks = crack0.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.28,
            pitchMin: 900, pitchSpan: 2_800, decaySecondsMin: 0.004, decaySecondsSpan: 0.012, loudness: 0.9
        ) + crack1.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.36,
            pitchMin: 1_400, pitchSpan: 3_200, decaySecondsMin: 0.003, decaySecondsSpan: 0.01, loudness: 1
        ) + crack2.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.5,
            pitchMin: 700, pitchSpan: 1_800, decaySecondsMin: 0.006, decaySecondsSpan: 0.016, loudness: 0.7
        )

        return softClip((flame + air + cracks * 0.85) * Self.outputGain)
    }
}
