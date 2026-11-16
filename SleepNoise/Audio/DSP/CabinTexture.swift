import Darwin
import Foundation

/// Airplane and train cabin: a low broadband roar with a quiet, slowly beating
/// engine hum. Partials and the beat use shared phases so the drone sits in
/// the centre; the air noise is independent per channel. No clicks — a cabin
/// someone can leave on all night.
struct CabinTexture {
    var rng: XorShift32
    private var airA: Float = 0
    private var airB: Float = 0
    private var airCoefficient: Float = 0.05
    private var phase1: Float = 0.3
    private var phase2: Float = 1.1
    private var phase3: Float = 0.7
    private var beatPhase: Float = 0.4
    private var pulsePhase: Float = 0.9
    private var driftPhase: Float = 0.2
    private var increment1: Float = 0
    private var increment2: Float = 0
    private var increment3: Float = 0
    private var beatIncrement: Float = 0
    private var pulseIncrement: Float = 0
    private var driftIncrement: Float = 0

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        airCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 450)
        increment1 = (2 * Float.pi * 74) / rate
        increment2 = (2 * Float.pi * 148) / rate
        increment3 = (2 * Float.pi * 222) / rate
        beatIncrement = (2 * Float.pi * 0.22) / rate
        pulseIncrement = (2 * Float.pi * 1.05) / rate
        driftIncrement = (2 * Float.pi * 0.04) / rate
    }

    mutating func next() -> Float {
        let white = rng.nextBipolar()
        phase1 = wrapPhase(phase1 + increment1)
        phase2 = wrapPhase(phase2 + increment2)
        phase3 = wrapPhase(phase3 + increment3)
        beatPhase = wrapPhase(beatPhase + beatIncrement)
        pulsePhase = wrapPhase(pulsePhase + pulseIncrement)
        driftPhase = wrapPhase(driftPhase + driftIncrement)

        airA = flushDenormal(airA + airCoefficient * (white - airA))
        airB = flushDenormal(airB + airCoefficient * (airA - airB))
        let roar = airB * 2.15

        let beat = 0.75 + 0.25 * sinf(beatPhase)
        let hum = (sinf(phase1) + 0.4 * sinf(phase2) + 0.18 * sinf(phase3)) * 0.045 * beat
        let level = (0.94 + 0.06 * sinf(driftPhase)) * (0.97 + 0.03 * sinf(pulsePhase))

        return clipUnit((roar + hum) * level)
    }
}
