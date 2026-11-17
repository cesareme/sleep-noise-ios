import Darwin
import Foundation

/// Thunder: a quiet rain bed with sparse, slow rumbles. Distant: a rumble
/// swells and rolls away, with no strike at its start.
///
/// The rumble schedule is a deterministic function of the rumble index, not of
/// the noise generator, so the left and right channels (different noise seeds,
/// same index) strike together and the image stays centred. Gaps land between
/// 4.5 and 12.5 seconds. The first rumble arrives before a second has passed,
/// then the storm settles into those long gaps.
///
/// `scheduleOffset` shifts the index the schedule is read at. The engine
/// picks one per launch and hands the same value to both channels, so the
/// rumbles do not fall on the same seconds every night and the channels
/// still strike together.
struct ThunderTexture {
    /// Seconds from a fresh start to the first rumble.
    static let firstRumbleSeconds: Float = 0.7

    var rng: XorShift32
    private var sampleRate: Float = 0
    private var rendered: Int = 0
    private var rumbleIndex: Int = 0
    private var scheduleOffset: Int = 0
    private var nextRumbleSample: Int = 0
    private var attackUntil: Int = 0
    private var rumbleTarget: Float = 0
    private var rumbleEnvelope: Float = 0
    private var rumbleAttack: Float = 0.001
    private var rumbleRelease: Float = 0.0001
    private var rumbleA: Float = 0
    private var rumbleB: Float = 0
    private var rumbleCoefficient: Float = 0.02
    private var hiss: Float = 0
    private var hissCoefficient: Float = 0.2
    private var body: Float = 0
    private var bodyCoefficient: Float = 0.05
    private var drop0 = BurstVoice()
    private var drop1 = BurstVoice()

    init(seed: UInt32, sampleRate: Float = 48_000, scheduleOffset: UInt32 = 0) {
        rng = XorShift32(seed: seed)
        self.scheduleOffset = Int(scheduleOffset)
        prepare(sampleRate: sampleRate)
    }

    /// Time to the start of the next rumble. Not used by the render path.
    var secondsUntilNextRumble: Float {
        Float(nextRumbleSample - rendered) / sampleRate
    }

    mutating func prepare(sampleRate newRate: Float) {
        let rate = newRate > 1 ? newRate : 48_000
        if self.sampleRate > 1 {
            let scale = rate / self.sampleRate
            rendered = Int((Float(rendered) * scale).rounded())
            nextRumbleSample = Int((Float(nextRumbleSample) * scale).rounded())
            attackUntil = Int((Float(attackUntil) * scale).rounded())
        } else {
            nextRumbleSample = Int(Self.firstRumbleSeconds * rate)
        }
        self.sampleRate = rate
        rumbleCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 140)
        hissCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 1_200)
        bodyCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 400)
        rumbleAttack = 1 - expf(-1 / (rate * 0.45))
        rumbleRelease = 1 - expf(-1 / (rate * 2.6))
        drop0.prepare(sampleRate: rate, cutoff: 2_400, resonance: 3.2)
        drop1.prepare(sampleRate: rate, cutoff: 3_200, resonance: 3.2)
    }

    mutating func next() -> Float {
        if rendered >= nextRumbleSample {
            let index = rumbleIndex &+ scheduleOffset
            rumbleTarget = 0.62 + 0.38 * Self.unit(index, salt: 1)
            let attack = 0.28 + 0.45 * Self.unit(index, salt: 2)
            attackUntil = rendered + max(1, Int(attack * sampleRate))
            let gap = Self.gapSeconds(after: index)
            nextRumbleSample = rendered + max(1, Int(gap * sampleRate))
            rumbleIndex += 1
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

        return clipUnit(rainHiss + rainBody + drops * 0.45 + rumble)
    }

    /// Seconds between rumble `index` (zero-based, plus the schedule offset)
    /// and the one after it.
    static func gapSeconds(after index: Int) -> Float {
        4.5 + 8 * unit(index, salt: 3)
    }

    /// Stable in 0..<1 for a given rumble and salt, shared by both channels.
    ///
    /// An integer hash with full avalanche, so neighbouring rumbles are
    /// unrelated. One multiply-add of the index is not a hash: it walks the
    /// unit interval in constant steps and the gaps repeat. Integer arithmetic
    /// only, so it is safe on the render thread.
    static func unit(_ index: Int, salt: UInt32) -> Float {
        var x = UInt32(truncatingIfNeeded: index) &* 0x9E37_79B1
        x = x &+ salt &* 0x85EB_CA77
        x ^= x >> 16
        x = x &* 0x7FEB_352D
        x ^= x >> 15
        x = x &* 0x846C_A68B
        x ^= x >> 16
        return Float(x >> 8) / 16_777_216
    }
}
