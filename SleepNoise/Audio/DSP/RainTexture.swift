import Darwin
import Foundation

/// Rain: a highpassed noise bed, a slow level LFO, and short filtered-noise droplets.
struct RainTexture {
    var rng: XorShift32
    private var bed: Float = 0
    private var bedCoefficient: Float = 0.2
    private var dropLowpass: Float = 0
    private var dropCoefficient: Float = 0.3
    private var dropEnvelope: Float = 0
    private var dropDecay: Float = 0.99
    private var samplesUntilDrop: Int = 1
    private var phase: Float = 0
    private var phaseIncrement: Float = 0
    private var sampleRate: Float = 48_000

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        bedCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 1_600)
        dropCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 3_200)
        dropDecay = expf(-1 / (rate * 0.028))
        phaseIncrement = (2 * Float.pi * 0.06) / rate
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        bed = flushDenormal(bed + bedCoefficient * (white - bed))
        let hiss = (white - bed) * 0.38

        if samplesUntilDrop <= 0 {
            dropEnvelope = 0.30 + 0.70 * rng.nextUnit()
            let gap = 0.02 + 0.16 * rng.nextUnit()
            samplesUntilDrop = max(1, Int(gap * sampleRate))
        } else {
            samplesUntilDrop -= 1
        }
        dropEnvelope = flushDenormal(dropEnvelope * dropDecay)
        let dropletNoise = rng.nextBipolar()
        dropLowpass = flushDenormal(dropLowpass + dropCoefficient * (dropletNoise - dropLowpass))
        let drop = dropLowpass * dropEnvelope * 0.85

        phase += phaseIncrement
        if phase > 2 * Float.pi { phase -= 2 * Float.pi }
        let bedLevel = 0.78 + 0.22 * sinf(phase)
        return clipUnit(hiss * bedLevel + drop)
    }
}
