import Darwin
import Foundation

/// One channel's worth of generators. Left and right carry independent noise
/// seeds so the beds are decorrelated in stereo; their LFOs start in phase, so
/// swells, gusts and flutter stay centred while the noise itself spreads wide.
struct ChannelGenerators {
    var white: WhiteNoise
    var pink: PinkNoise
    var brown: BrownNoise
    var rain: RainTexture
    var fan: FanTexture
    var ocean: OceanTexture

    init(seedSalt: UInt32, sampleRate: Float) {
        white = WhiteNoise(seed: 0xA341316C ^ seedSalt)
        pink = PinkNoise(seed: 0xC2B2AE35 ^ seedSalt)
        brown = BrownNoise(seed: 0x27BB2EE6 ^ seedSalt)
        rain = RainTexture(seed: 0x5A1F3B91 ^ seedSalt, sampleRate: sampleRate)
        fan = FanTexture(seed: 0x91E10DA5 ^ seedSalt, sampleRate: sampleRate)
        ocean = OceanTexture(seed: 0x3C6EF35F ^ seedSalt, sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        rain.prepare(sampleRate: sampleRate)
        fan.prepare(sampleRate: sampleRate)
        ocean.prepare(sampleRate: sampleRate)
    }

    /// Generators whose gain has settled at zero are skipped: they cost CPU and
    /// battery over an eight-hour night and contribute nothing audible.
    @inline(__always)
    mutating func mix(_ gains: SoundGains) -> Float {
        let threshold: Float = 1e-4
        var sum: Float = 0
        if gains.white > threshold { sum += white.next() * gains.white }
        if gains.pink > threshold { sum += pink.next() * gains.pink }
        if gains.brown > threshold { sum += brown.next() * gains.brown }
        if gains.rain > threshold { sum += rain.next() * gains.rain }
        if gains.fan > threshold { sum += fan.next() * gains.fan }
        if gains.ocean > threshold { sum += ocean.next() * gains.ocean }
        return sum
    }
}

/// All generator state touched by the render callback.
///
/// The callback copies this struct once per buffer, mutates the copy, and
/// writes it back. That keeps the hot path off the heap: no allocations, no
/// locks, and no reference-counted objects inside `process`.
struct RenderState {
    var left: ChannelGenerators
    var right: ChannelGenerators

    var smoothed = SoundGains.zero
    var envelope: Float = 0
    var fadeFrom: Float = 0
    var fadeTo: Float = 0
    var fadeProgress: Float = 1
    var fadeStep: Float = 0
    var appliedGeneration: UInt32 = 0
    var gainCoefficient: Float = 0.002
    var sampleRate: Float = 48_000
    var lastCommand = EngineCommand.silence

    init(sampleRate: Float = 48_000) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        left = ChannelGenerators(seedSalt: 0, sampleRate: rate)
        right = ChannelGenerators(seedSalt: 0x6B8B4567, sampleRate: rate)
        prepare(sampleRate: rate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        gainCoefficient = 1 - expf(-1 / (rate * 0.02))
        left.prepare(sampleRate: rate)
        right.prepare(sampleRate: rate)
    }

    /// Stereo frame. Both channels share the envelope and smoothed gains.
    @inline(__always)
    mutating func processStereo(_ command: EngineCommand) -> (left: Float, right: Float) {
        if command.generation != appliedGeneration {
            appliedGeneration = command.generation
            if command.rampSamples >= 0 {
                beginFade(to: command.envelopeTarget, samples: command.rampSamples)
            }
        }
        advanceFade()
        smoothed.approach(command.gains, coefficient: gainCoefficient)

        let l = left.mix(smoothed)
        let r = right.mix(smoothed)
        return (softClip(l * envelope), softClip(r * envelope))
    }

    /// Mono frame: a power-preserving sum of both channels.
    mutating func process(_ command: EngineCommand) -> Float {
        let frame = processStereo(command)
        return softClip((frame.left + frame.right) * 0.7071)
    }

    private mutating func beginFade(to target: Float, samples: Int32) {
        if samples <= 1 {
            envelope = target
            fadeFrom = target
            fadeTo = target
            fadeProgress = 1
            fadeStep = 0
            return
        }
        fadeFrom = envelope
        fadeTo = target
        fadeProgress = 0
        fadeStep = 1 / Float(samples)
    }

    private mutating func advanceFade() {
        guard fadeStep > 0 else { return }
        fadeProgress += fadeStep
        if fadeProgress >= 1 {
            fadeProgress = 1
            fadeStep = 0
            envelope = fadeTo
            return
        }
        let shaped = FadeCurve.unity(fadeProgress)
        envelope = fadeFrom + (fadeTo - fadeFrom) * shaped
    }
}
