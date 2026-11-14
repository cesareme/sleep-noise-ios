import Darwin
import Foundation

/// Ocean: lowpassed noise under two slow, incommensurate swells.
struct OceanTexture {
    var rng: XorShift32
    private var lowpassA: Float = 0
    private var lowpassB: Float = 0
    private var coefficient: Float = 0.02
    private var phaseA: Float = 0
    private var phaseB: Float = 2
    private var incrementA: Float = 0
    private var incrementB: Float = 0

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        coefficient = OnePole.coefficient(sampleRate: rate, hertz: 180)
        incrementA = (2 * Float.pi * 0.07) / rate
        incrementB = (2 * Float.pi * 0.11) / rate
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        lowpassA = flushDenormal(lowpassA + coefficient * (white - lowpassA))
        lowpassB = flushDenormal(lowpassB + coefficient * (lowpassA - lowpassB))

        phaseA += incrementA
        phaseB += incrementB
        if phaseA > 2 * Float.pi { phaseA -= 2 * Float.pi }
        if phaseB > 2 * Float.pi { phaseB -= 2 * Float.pi }

        let swellA = 0.5 + 0.5 * sinf(phaseA)
        let swellB = 0.5 + 0.5 * sinf(phaseB)
        let crest = powf(swellA, 1.6) * (0.45 + 0.55 * swellB)
        let level = 0.08 + 0.92 * crest
        return clipUnit(lowpassB * level * 5.5)
    }
}

enum OnePole {
    /// One-pole smoothing coefficient for a cutoff in hertz.
    static func coefficient(sampleRate: Float, hertz: Float) -> Float {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        let hz = max(1, hertz)
        return 1 - expf((-2 * Float.pi * hz) / rate)
    }
}
