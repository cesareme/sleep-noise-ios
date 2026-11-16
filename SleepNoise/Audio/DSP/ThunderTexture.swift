import Darwin
import Foundation

/// Thunder: a quiet rain bed with sparse, slow rumbles.
///
/// The rumble schedule is a deterministic function of the rumble index, not of
/// the noise generator, so the left and right channels (different noise seeds,
/// same index) strike together and the image stays centred. Gaps land between
/// about 4.5 and 12.5 seconds. The first rumble arrives before a second has
/// passed, then the storm settles into those long gaps.
struct ThunderTexture {
    var rng: XorShift32
    private var sampleRate: Float = 0
    private var rendered: Int = 0
    private var rumbleIndex: Int = 0
    private var nextRumbleSample: Int = 0
    private var attackUntil: Int = 0
    private var rumbleTarget: Float = 0
    private var rumbleEnvelope: Float = 0
    private var rumbleAttack: Float = 0.001
    private var rumbleRelease: Float = 0.0001
    private var rumbleA: Float = 0
    private var rumbleB: Float = 0
    private var rumbleCoefficient: Float = 0.02
    private var crackEnvelope: Float = 0
    private var crackDecay: Float = 0.9
    private var hiss: Float = 0
    private var hissCoefficient: Float = 0.2
    private var body: Float = 0
    private var bodyCoefficient: Float = 0.05
    private var drop0 = BurstVoice()
    private var drop1 = BurstVoice()

    init(seed: UInt32, sampleRate: Float = 48_000) {
        rng = XorShift32(seed: seed)
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate newRate: Float) {
        let rate = newRate > 1 ? newRate : 48_000
        if self.sampleRate > 1 {
            let scale = rate / self.sampleRate
            rendered = Int((Float(rendered) * scale).rounded())
            nextRumbleSample = Int((Float(nextRumbleSample) * scale).rounded())
            attackUntil = Int((Float(attackUntil) * scale).rounded())
        } else {
            nextRumbleSample = Int(0.7 * rate)
        }
        self.sampleRate = rate
        rumbleCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 140)
        hissCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 1_200)
        bodyCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 400)
        rumbleAttack = 1 - expf(-1 / (rate * 0.45))
        rumbleRelease = 1 - expf(-1 / (rate * 2.6))
        crackDecay = expf(-1 / (rate * 0.06))
        drop0.prepare(sampleRate: rate, cutoff: 2_400, resonance: 3.2)
        drop1.prepare(sampleRate: rate, cutoff: 3_200, resonance: 3.2)
    }

    mutating func next() -> Float {
        if rendered >= nextRumbleSample {
            let roll = unit(rumbleIndex)
            rumbleTarget = 0.62 + 0.38 * roll
            let attack = 0.28 + 0.45 * unit(rumbleIndex &+ 3)
            attackUntil = rendered + max(1, Int(attack * sampleRate))
            crackEnvelope = 0.25 + 0.55 * unit(rumbleIndex &+ 7)
            rumbleIndex += 1
            let gap = 4.5 + 8 * unit(rumbleIndex &+ 11)
            nextRumbleSample = rendered + max(1, Int(gap * sampleRate))
        }
        if rendered > attackUntil {
            rumbleTarget = 0
        }
        rendered += 1

        let coefficient = rumbleTarget > rumbleEnvelope ? rumbleAttack : rumbleRelease
        rumbleEnvelope = flushDenormal(rumbleEnvelope + (rumbleTarget - rumbleEnvelope) * coefficient)

        let white = rng.nextBipolar()
        rumbleA = flushDenormal(rumbleA + rumbleCoefficient * (white - rumbleA))
        rumbleB = flushDenormal(rumbleB + rumbleCoefficient * (rumbleA - rumbleB))
        let rumble = rumbleB * rumbleEnvelope * 5.2

        crackEnvelope = flushDenormal(crackEnvelope * crackDecay)
        let crack = (white - rumbleA) * crackEnvelope * 0.55

        hiss = flushDenormal(hiss + hissCoefficient * (white - hiss))
        let rainHiss = (white - hiss) * 0.16
        body = flushDenormal(body + bodyCoefficient * (white - body))
        let rainBody = body * 0.22
        let drops = drop0.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.22,
            pitchMin: 1_600, pitchSpan: 3_200, decaySecondsMin: 0.008, decaySecondsSpan: 0.02, loudness: 0.55
        ) + drop1.next(
            rng: &rng, sampleRate: sampleRate, meanGapSeconds: 0.22,
            pitchMin: 1_800, pitchSpan: 3_400, decaySecondsMin: 0.008, decaySecondsSpan: 0.02, loudness: 0.55
        )

        return clipUnit(rainHiss + rainBody + drops * 0.45 + rumble + crack)
    }

    /// Stable in 0..<1 for a given index. Shared by both channels.
    private func unit(_ index: Int) -> Float {
        let mixed = UInt32(bitPattern: Int32(index)) &* 1_664_525 &+ 1_013_904_223
        return Float(mixed % 10_000) / 10_000
    }
}
