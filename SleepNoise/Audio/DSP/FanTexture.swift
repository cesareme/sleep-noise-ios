import Darwin
import Foundation

/// Fan: lowpassed noise with a blade-rate amplitude LFO and a slower speed drift.
struct FanTexture {
    var rng: XorShift32
    private var lowpassA: Float = 0
    private var lowpassB: Float = 0
    private var coefficient: Float = 0.05
    private var bladePhase: Float = 0.2
    private var driftPhase: Float = 0.4
    private var driftIncrement: Float = 0
    private var sampleRate: Float = 48_000

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        coefficient = OnePole.coefficient(sampleRate: rate, hertz: 450)
        driftIncrement = (2 * Float.pi * 0.05) / rate
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        lowpassA = flushDenormal(lowpassA + coefficient * (white - lowpassA))
        lowpassB = flushDenormal(lowpassB + coefficient * (lowpassA - lowpassB))

        driftPhase += driftIncrement
        if driftPhase > 2 * Float.pi { driftPhase -= 2 * Float.pi }
        let rate = 18 + 5 * sinf(driftPhase)
        bladePhase += (2 * Float.pi * rate) / sampleRate
        if bladePhase > 2 * Float.pi { bladePhase -= 2 * Float.pi }

        let blade = 0.5 + 0.5 * sinf(bladePhase)
        let level = 0.48 + 0.52 * blade
        return clipUnit(lowpassB * level * 3.3)
    }
}
