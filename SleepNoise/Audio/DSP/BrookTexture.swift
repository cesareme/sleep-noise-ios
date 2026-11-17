import Darwin
import Foundation

/// Brook: mid-band water moving over stones, a softer low gurgle, and a few
/// bubble voices pitched well below raindrops. A slow level drift keeps it
/// from sitting as a static hiss.
struct BrookTexture {
    /// Output trim. At unity the brook read about 7 dB(A) under rain at the
    /// same slider position.
    static let outputGain: Float = 2

    var rng: XorShift32
    private var sampleRate: Float = 48_000
    private var flow = StateVariableFilter()
    private var lowA: Float = 0
    private var lowB: Float = 0
    private var lowCoefficient: Float = 0.05
    private var driftPhase: Float = 0.6
    private var driftIncrement: Float = 0
    private var bubble0 = BurstVoice()
    private var bubble1 = BurstVoice()
    private var bubble2 = BurstVoice()

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        flow.prepare(sampleRate: rate, cutoff: 900, resonance: 0.85)
        lowCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 320)
        driftIncrement = (2 * Float.pi * 0.07) / rate
        bubble0.prepare(sampleRate: rate, cutoff: 600, resonance: 3.5)
        bubble1.prepare(sampleRate: rate, cutoff: 900, resonance: 3.2)
        bubble2.prepare(sampleRate: rate, cutoff: 500, resonance: 2.8)
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        driftPhase = wrapPhase(driftPhase + driftIncrement)
        let drift = 0.78 + 0.22 * sinf(driftPhase)

        flow.setCutoff(780 + 180 * sinf(driftPhase * 0.5))
        let band = flow.process(white).band * 0.42

        lowA = flushDenormal(lowA + lowCoefficient * (white - lowA))
        lowB = flushDenormal(lowB + lowCoefficient * (lowA - lowB))
        let gurgle = lowB * 0.85

        let bubbles = bubble0.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.16,
            pitchMin: 350, pitchSpan: 900, decaySecondsMin: 0.02, decaySecondsSpan: 0.05, loudness: 0.7
        ) + bubble1.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.2,
            pitchMin: 500, pitchSpan: 1_200, decaySecondsMin: 0.015, decaySecondsSpan: 0.04, loudness: 0.65
        ) + bubble2.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.24,
            pitchMin: 280, pitchSpan: 700, decaySecondsMin: 0.025, decaySecondsSpan: 0.05, loudness: 0.6
        )

        return softClip((band + gurgle + bubbles * 0.7) * drift * Self.outputGain)
    }
}
