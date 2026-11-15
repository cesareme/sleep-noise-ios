import Darwin
import Foundation

/// Ocean: a low rumble under two slow, incommensurate swells, plus a surf layer
/// of highpassed foam whose level crests just ahead of the rumble and washes out
/// slowly. The surf band is what makes it read as water instead of thunder.
///
/// With the breathing tide (`weight` > 0) the swell is blended toward the
/// breath value: the wave builds through the inhale, breaks at its top, and the
/// foam washes out over the exhale.
struct OceanTexture {
    var rng: XorShift32
    private var rumbleA: Float = 0
    private var rumbleB: Float = 0
    private var rumbleCoefficient: Float = 0.02
    private var surfHighpassState: Float = 0
    private var surfHighpassCoefficient: Float = 0.1
    private var surfLowpass: Float = 0
    private var surfLowpassCoefficient: Float = 0.5
    private var surfEnvelope: Float = 0
    private var surfAttack: Float = 0.001
    private var surfRelease: Float = 0.0001
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
        rumbleCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 160)
        surfHighpassCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 700)
        surfLowpassCoefficient = OnePole.coefficient(sampleRate: rate, hertz: 5_500)
        surfAttack = 1 - expf(-1 / (rate * 0.35))
        surfRelease = 1 - expf(-1 / (rate * 2.2))
        incrementA = (2 * Float.pi * 0.075) / rate
        incrementB = (2 * Float.pi * 0.047) / rate
    }

    mutating func next() -> Float {
        next(breath: 0, weight: 0)
    }

    mutating func next(breath: Float, weight: Float) -> Float {
        let white = rng.nextBipolar()

        phaseA = wrapPhase(phaseA + incrementA)
        phaseB = wrapPhase(phaseB + incrementB)
        let swellA = 0.5 + 0.5 * sinf(phaseA)
        let swellB = 0.5 + 0.5 * sinf(phaseB)
        let naturalSwell = 0.6 * swellA + 0.4 * swellB
        // Under the breath the trough stays at 0.35 so the rest between
        // breaths is a hush, not a hole (about 10 dB below the top of the
        // inhale, the range the natural swell already covers), and a fifth of
        // the natural, incommensurate swell always rides underneath so the sea
        // never turns into a metronome.
        let blend = weight * 0.8
        let breathSwell = 0.35 + 0.65 * breath
        let swell = naturalSwell + (breathSwell - naturalSwell) * blend

        // Rumble: two one-pole lowpasses, level follows the swell above a floor.
        rumbleA = flushDenormal(rumbleA + rumbleCoefficient * (white - rumbleA))
        rumbleB = flushDenormal(rumbleB + rumbleCoefficient * (rumbleA - rumbleB))
        let rumbleLevel = 0.22 + 0.78 * swell * swell
        let rumble = rumbleB * rumbleLevel * 4.6

        // Surf: band 700 Hz – 5.5 kHz. The crest leads the rumble so the break is heard
        // before the body of the wave arrives, then the foam washes out over seconds.
        let leading = 0.5 + 0.5 * sinf(phaseA + 0.55)
        let naturalCrest = powf(leading, 3) * (0.5 + 0.5 * swellB)
        let breathCrest = breath * breath * breath
        let crest = naturalCrest + (breathCrest - naturalCrest) * blend
        let coefficient = crest > surfEnvelope ? surfAttack : surfRelease
        surfEnvelope = flushDenormal(surfEnvelope + (crest - surfEnvelope) * coefficient)

        let surfNoise = rng.nextBipolar()
        surfHighpassState = flushDenormal(surfHighpassState + surfHighpassCoefficient * (surfNoise - surfHighpassState))
        let highpassed = surfNoise - surfHighpassState
        surfLowpass = flushDenormal(surfLowpass + surfLowpassCoefficient * (highpassed - surfLowpass))
        let surf = surfLowpass * (0.04 + 0.96 * surfEnvelope) * 0.55

        return clipUnit(rumble + surf)
    }
}
