import Darwin
import Foundation

/// One droplet voice: a decaying envelope on resonant bandpassed noise. Each new
/// drop picks its own pitch, decay and loudness, so a shower of them has variety
/// instead of a tick.
struct DropVoice {
    var filter = StateVariableFilter()
    var envelope: Float = 0
    var decay: Float = 0.99
    var samplesUntilDrop: Int = 1
    var pan: Float = 0

    mutating func prepare(sampleRate: Float) {
        filter.prepare(sampleRate: sampleRate, cutoff: 3_000, resonance: 4)
    }

    @inline(__always)
    mutating func next(rng: inout XorShift32, sampleRate: Float, meanGapSeconds: Float) -> Float {
        if samplesUntilDrop <= 0 {
            let loudness = rng.nextUnit()
            envelope = 0.12 + 0.88 * loudness * loudness
            let decaySeconds = 0.006 + 0.03 * rng.nextUnit()
            decay = expf(-1 / (sampleRate * decaySeconds))
            filter.setCutoff(1_400 + 4_200 * rng.nextUnit())
            // Exponential gaps approximate a Poisson arrival process.
            let gap = -logf(max(1e-4, rng.nextUnit())) * meanGapSeconds
            samplesUntilDrop = max(1, Int(gap * sampleRate))
        } else {
            samplesUntilDrop -= 1
        }
        envelope = flushDenormal(envelope * decay)
        let excitation = rng.nextBipolar() * envelope
        // The bandpass rings with gain near Q, so scale back towards unity.
        return filter.process(excitation).band * 0.28
    }
}

/// Rain: a highpassed hiss bed, a soft low body, five overlapping droplet voices,
/// and a slow gust LFO that moves both the bed level and how often drops fall.
struct RainTexture {
    var rng: XorShift32
    private var bed: Float = 0
    private var bedCoefficient: Float = 0.2
    private var bodyA: Float = 0
    private var bodyB: Float = 0
    private var bodyCoefficient: Float = 0.05
    private var drop0 = DropVoice()
    private var drop1 = DropVoice()
    private var drop2 = DropVoice()
    private var drop3 = DropVoice()
    private var drop4 = DropVoice()
    private var gustPhase: Float = 0
    private var gustIncrement: Float = 0
    private var sampleRate: Float = 48_000

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        bedCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 1_300)
        bodyCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 500)
        gustIncrement = (2 * Float.pi * 0.045) / rate
        drop0.prepare(sampleRate: rate)
        drop1.prepare(sampleRate: rate)
        drop2.prepare(sampleRate: rate)
        drop3.prepare(sampleRate: rate)
        drop4.prepare(sampleRate: rate)
    }

    mutating func next() -> Float {
        gustPhase = wrapPhase(gustPhase + gustIncrement)
        let gust = 0.5 + 0.5 * sinf(gustPhase)
        let intensity = 0.72 + 0.28 * gust

        let white = rng.nextBipolar()
        bed = flushDenormal(bed + bedCoefficient * (white - bed))
        let hiss = (white - bed) * 0.30

        bodyA = flushDenormal(bodyA + bodyCoefficient * (white - bodyA))
        bodyB = flushDenormal(bodyB + bodyCoefficient * (bodyA - bodyB))
        let body = bodyB * 0.5

        // Roughly 35 drops per second in a lull, 55 in a gust.
        let meanGap = 0.17 - 0.06 * gust
        var drops: Float = 0
        drops += drop0.next(rng: &rng, sampleRate: sampleRate, meanGapSeconds: meanGap)
        drops += drop1.next(rng: &rng, sampleRate: sampleRate, meanGapSeconds: meanGap)
        drops += drop2.next(rng: &rng, sampleRate: sampleRate, meanGapSeconds: meanGap)
        drops += drop3.next(rng: &rng, sampleRate: sampleRate, meanGapSeconds: meanGap)
        drops += drop4.next(rng: &rng, sampleRate: sampleRate, meanGapSeconds: meanGap)

        return clipUnit((hiss + body) * intensity + drops * 0.75)
    }
}
