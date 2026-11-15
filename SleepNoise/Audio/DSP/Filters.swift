import Darwin
import Foundation

enum OnePole {
    /// One-pole smoothing coefficient for a cutoff in hertz.
    static func coefficient(sampleRate: Float, hertz: Float) -> Float {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        let hz = max(1, hertz)
        return 1 - expf((-2 * Float.pi * hz) / rate)
    }
}

/// Chamberlin state-variable filter. One multiply-add per output, resonant,
/// and cheap enough to run several per sample. Stable for cutoffs below
/// roughly a sixth of the sample rate, which `setCutoff` enforces.
struct StateVariableFilter {
    private var low: Float = 0
    private var band: Float = 0
    private var f: Float = 0.1
    private var q: Float = 1
    private var sampleRate: Float = 48_000

    init(sampleRate: Float = 48_000, cutoff: Float = 1_000, resonance: Float = 0.7) {
        prepare(sampleRate: sampleRate, cutoff: cutoff, resonance: resonance)
    }

    mutating func prepare(sampleRate: Float, cutoff: Float, resonance: Float) {
        self.sampleRate = sampleRate > 1 ? sampleRate : 48_000
        setResonance(resonance)
        setCutoff(cutoff)
        low = 0
        band = 0
    }

    /// `resonance` is Q; 0.5 is heavily damped, 4 rings.
    mutating func setResonance(_ resonance: Float) {
        q = 1 / max(0.5, min(8, resonance))
    }

    mutating func setCutoff(_ hertz: Float) {
        let limited = max(10, min(hertz, sampleRate / 6.5))
        f = 2 * sinf(Float.pi * limited / sampleRate)
    }

    /// Advances the filter and returns (lowpass, bandpass, highpass).
    @inline(__always)
    mutating func process(_ input: Float) -> (low: Float, band: Float, high: Float) {
        low = flushDenormal(low + f * band)
        let high = input - low - q * band
        band = flushDenormal(band + f * high)
        return (low, band, high)
    }
}
