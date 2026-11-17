import Darwin
import Foundation

/// A short resonant burst: bandpassed noise with its own pitch, decay and
/// loudness, scheduled as a Poisson process. Used by the crackling and
/// bubbling textures. `next` does not allocate.
struct BurstVoice {
    var filter = StateVariableFilter()
    var envelope: Float = 0
    var decay: Float = 0.99
    var samplesUntil: Int = 1

    mutating func prepare(sampleRate: Float, cutoff: Float, resonance: Float) {
        filter.prepare(sampleRate: sampleRate, cutoff: cutoff, resonance: resonance)
        if samplesUntil < 1 { samplesUntil = 1 }
    }

    @inline(__always)
    mutating func next(
        rng: inout XorShift32,
        sampleRate: Float,
        meanGapSeconds: Float,
        pitchMin: Float,
        pitchSpan: Float,
        decaySecondsMin: Float,
        decaySecondsSpan: Float,
        loudness: Float
    ) -> Float {
        if samplesUntil <= 0 {
            let unit = rng.nextUnit()
            envelope = loudness * (0.3 + 0.7 * unit * unit)
            let decaySeconds = max(0.002, decaySecondsMin + decaySecondsSpan * rng.nextUnit())
            decay = expf(-1 / (sampleRate * decaySeconds))
            filter.setCutoff(pitchMin + pitchSpan * rng.nextUnit())
            let gap = -logf(max(1e-4, rng.nextUnit())) * max(0.01, meanGapSeconds)
            samplesUntil = max(1, Int(gap * sampleRate))
        } else {
            samplesUntil -= 1
        }
        envelope = flushDenormal(envelope * decay)
        return filter.process(rng.nextBipolar() * envelope).band * 0.22
    }
}
