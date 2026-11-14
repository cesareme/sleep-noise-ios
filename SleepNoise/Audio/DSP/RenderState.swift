import Darwin
import Foundation

/// All generator state touched by the render callback.
///
/// The callback copies this struct once per buffer, mutates the copy, and
/// writes it back. That keeps the hot path off the heap: no allocations, no
/// locks, and no reference-counted objects inside `process`.
struct RenderState {
    var white = WhiteNoise(seed: 0xA341316C)
    var pink = PinkNoise(seed: 0xC2B2AE35)
    var brown = BrownNoise(seed: 0x27BB2EE6)
    var rain = RainTexture(seed: 0x5A1F3B91)
    var fan = FanTexture(seed: 0x91E10DA5)
    var ocean = OceanTexture(seed: 0x3C6EF35F)

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
        prepare(sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        gainCoefficient = 1 - expf(-1 / (rate * 0.02))
        rain.prepare(sampleRate: rate)
        fan.prepare(sampleRate: rate)
        ocean.prepare(sampleRate: rate)
    }

    mutating func process(_ command: EngineCommand) -> Float {
        if command.generation != appliedGeneration {
            appliedGeneration = command.generation
            if command.rampSamples >= 0 {
                beginFade(to: command.envelopeTarget, samples: command.rampSamples)
            }
        }
        advanceFade()
        smoothed.approach(command.gains, coefficient: gainCoefficient)

        let mixed = white.next() * smoothed.white
            + pink.next() * smoothed.pink
            + brown.next() * smoothed.brown
            + rain.next() * smoothed.rain
            + fan.next() * smoothed.fan
            + ocean.next() * smoothed.ocean
        return softClip(mixed * envelope)
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
