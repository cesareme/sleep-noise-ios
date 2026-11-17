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
    var thunder: ThunderTexture
    var campfire: CampfireTexture
    var brook: BrookTexture
    var wind: WindTexture
    var cabin: CabinTexture

    init(seedSalt: UInt32, sampleRate: Float, thunderSchedule: UInt32 = 0) {
        white = WhiteNoise(seed: 0xA341316C ^ seedSalt)
        pink = PinkNoise(seed: 0xC2B2AE35 ^ seedSalt)
        brown = BrownNoise(seed: 0x27BB2EE6 ^ seedSalt)
        rain = RainTexture(seed: 0x5A1F3B91 ^ seedSalt, sampleRate: sampleRate)
        fan = FanTexture(seed: 0x91E10DA5 ^ seedSalt, sampleRate: sampleRate)
        ocean = OceanTexture(seed: 0x3C6EF35F ^ seedSalt, sampleRate: sampleRate)
        thunder = ThunderTexture(
            seed: 0x7F4A7C15 ^ seedSalt,
            sampleRate: sampleRate,
            scheduleOffset: thunderSchedule
        )
        campfire = CampfireTexture(seed: 0x2D8E4B61 ^ seedSalt, sampleRate: sampleRate)
        brook = BrookTexture(seed: 0xB17C90E3 ^ seedSalt, sampleRate: sampleRate)
        wind = WindTexture(seed: 0x4C0A6F29 ^ seedSalt, sampleRate: sampleRate)
        cabin = CabinTexture(seed: 0xE35B18D7 ^ seedSalt, sampleRate: sampleRate)
    }

    mutating func prepare(sampleRate: Float) {
        rain.prepare(sampleRate: sampleRate)
        fan.prepare(sampleRate: sampleRate)
        ocean.prepare(sampleRate: sampleRate)
        thunder.prepare(sampleRate: sampleRate)
        campfire.prepare(sampleRate: sampleRate)
        brook.prepare(sampleRate: sampleRate)
        wind.prepare(sampleRate: sampleRate)
        cabin.prepare(sampleRate: sampleRate)
    }

    /// Generators whose gain has settled at zero are skipped: they cost CPU and
    /// battery over an eight-hour night and contribute nothing audible.
    ///
    /// `breath` is the current breath value (0 rest … 1 top of the inhale),
    /// `weight` how much the beds follow it and `depth` the bed modulation at
    /// full weight. The ocean swell locks onto the breath; the other beds are
    /// gently amplitude-modulated so rain, fan or plain noise also rise and
    /// fall when the ocean is off.
    @inline(__always)
    mutating func mix(_ gains: SoundGains, breath: Float, weight: Float, depth: Float) -> Float {
        let threshold: Float = 1e-4
        var bed: Float = 0
        if gains.white > threshold { bed += white.next() * gains.white }
        if gains.pink > threshold { bed += pink.next() * gains.pink }
        if gains.brown > threshold { bed += brown.next() * gains.brown }
        if gains.rain > threshold { bed += rain.next() * gains.rain }
        if gains.fan > threshold { bed += fan.next() * gains.fan }
        if gains.thunder > threshold { bed += thunder.next() * gains.thunder }
        if gains.campfire > threshold { bed += campfire.next() * gains.campfire }
        if gains.brook > threshold { bed += brook.next() * gains.brook }
        if gains.wind > threshold { bed += wind.next() * gains.wind }
        if gains.cabin > threshold { bed += cabin.next() * gains.cabin }
        if weight > threshold {
            bed *= 1 - depth * weight * (1 - breath)
        }
        var sum = bed
        if gains.ocean > threshold { sum += ocean.next(breath: breath, weight: weight) * gains.ocean }
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
    /// Curve of the fade in progress: a `FadeShape`.
    var fadeShape: Int32 = FadeShape.smooth
    var appliedEnvelopeGeneration: UInt32 = 0
    var gainCoefficient: Float = 0.002
    var sampleRate: Float = 48_000
    var lastCommand = EngineCommand.silence

    /// Breathing tide. One oscillator shared by both channels so the swell
    /// stays centred. The phase is a sample count, not an accumulated float,
    /// so it keeps time with the wall clock the on-screen disc follows.
    var breathEpoch: UInt32 = 0
    var breathSample: UInt32 = 0
    var breathPeriod: UInt32 = 0
    var breathRate: Float = 0
    /// Raw curve value and its 250 ms smoothed copy; the smoothed one drives
    /// the beds so a restart or rate change never steps the sound.
    var breathValue: Float = 0
    var breathValueSmoothed: Float = 0
    var breathValueCoefficient: Float = 0.0001
    /// Target weight (ramped linearly over the command's dissolve) and the
    /// 1.5 s smoothed weight actually applied.
    var breathWeightTarget: Float = 0
    var breathWeight: Float = 0
    var breathWeightCoefficient: Float = 0.00001
    /// Bed modulation depth, smoothed like the weight so a settings change
    /// (0.4 ⇄ 0.2) never steps the beds.
    var breathDepth: Float = 0.4
    /// Level of what actually leaves `processStereo`, for the interface.
    var outputMeter = OutputMeter()
    /// `thunderSchedule` goes to both channels unchanged: it moves the
    /// thunder rumbles in time, never one channel against the other.
    init(sampleRate: Float = 48_000, thunderSchedule: UInt32 = 0) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        left = ChannelGenerators(seedSalt: 0, sampleRate: rate, thunderSchedule: thunderSchedule)
        right = ChannelGenerators(seedSalt: 0x6B8B4567, sampleRate: rate, thunderSchedule: thunderSchedule)
        prepare(sampleRate: rate)
    }

    mutating func prepare(sampleRate: Float) {
        let rate = sampleRate > 1 ? sampleRate : 48_000
        self.sampleRate = rate
        gainCoefficient = 1 - expf(-1 / (rate * 0.02))
        breathWeightCoefficient = 1 - expf(-1 / (rate * 1.5))
        breathValueCoefficient = 1 - expf(-1 / (rate * 0.25))
        outputMeter.prepare(sampleRate: rate)
        // A running breath keeps its place in the cycle across a rate change.
        if breathPeriod > 0, breathRate > 0 {
            let fraction = Float(breathSample) / Float(breathPeriod)
            breathPeriod = UInt32(max(1, (rate / breathRate).rounded()))
            breathSample = min(breathPeriod - 1, UInt32(fraction * Float(breathPeriod)))
        }
        left.prepare(sampleRate: rate)
        right.prepare(sampleRate: rate)
    }

    /// Silence everything so the next Play fades in from nothing. Only called
    /// while the engine is stopped, so the render thread is not running.
    mutating func resetForFreshStart() {
        envelope = 0
        fadeFrom = 0
        fadeTo = 0
        fadeProgress = 1
        fadeStep = 0
        fadeShape = FadeShape.smooth
        breathWeight = 0
        breathWeightTarget = 0
        breathValue = 0
        breathValueSmoothed = 0
        outputMeter.reset()
    }

    /// Stereo frame. Both channels share the envelope and smoothed gains.
    @inline(__always)
    mutating func processStereo(_ command: EngineCommand) -> (left: Float, right: Float) {
        if command.envelopeGeneration != appliedEnvelopeGeneration {
            appliedEnvelopeGeneration = command.envelopeGeneration
            if command.rampSamples >= 0 {
                beginFade(
                    to: command.envelopeTarget,
                    samples: command.rampSamples,
                    shape: command.envelopeShape
                )
            }
        }
        advanceFade()
        smoothed.approach(command.gains, coefficient: gainCoefficient)
        advanceBreath(command.breath)

        let l = left.mix(smoothed, breath: breathValueSmoothed, weight: breathWeight, depth: breathDepth)
        let r = right.mix(smoothed, breath: breathValueSmoothed, weight: breathWeight, depth: breathDepth)
        let outLeft = softClip(l * envelope)
        let outRight = softClip(r * envelope)
        // Measured after the soft clip: the level of what is really heard.
        outputMeter.add(left: outLeft, right: outRight)
        return (outLeft, outRight)
    }

    /// One sample of the breath oscillator.
    ///
    /// A new epoch restarts the cycle at the top of an inhale. When that
    /// happens before anything is audible (fresh Play, envelope still at
    /// zero or fading in from zero) the weight is seeded directly so the sea
    /// rises with the first inhale instead of dipping after the fade-in.
    @inline(__always)
    private mutating func advanceBreath(_ breath: BreathParameters) {
        if breath.epoch != breathEpoch {
            breathEpoch = breath.epoch
            breathSample = 0
            breathPeriod = 0
            // Seed while nothing is audible yet, or while the fade-in from
            // silence is still under way (large IO buffers can deliver the
            // epoch one buffer after the fade began).
            let fadingInFromSilence = fadeStep > 0 && fadeFrom == 0 && fadeTo > 0
            if envelope < 1e-3 || fadingInFromSilence {
                breathWeightTarget = breath.weight
                breathWeight = breath.weight
                breathValue = 0
                breathValueSmoothed = 0
            }
        }

        // Weight: linear ramp toward the command over its dissolve, then smoothed.
        if breath.dissolveSeconds > 0 {
            let step = 1 / (breath.dissolveSeconds * sampleRate)
            if breathWeightTarget < breath.weight {
                breathWeightTarget = min(breath.weight, breathWeightTarget + step)
            } else if breathWeightTarget > breath.weight {
                breathWeightTarget = max(breath.weight, breathWeightTarget - step)
            }
        } else {
            breathWeightTarget = breath.weight
        }
        breathWeight += (breathWeightTarget - breathWeight) * breathWeightCoefficient
        if breathWeight < 1e-4, breathWeightTarget <= 0 {
            breathWeight = 0
        }
        if breath.rate > 0 {
            breathDepth += (breath.bedDepth - breathDepth) * breathWeightCoefficient
        }

        // Phase: a sample counter over the period for the current rate.
        if breath.rate > 0 {
            if breath.rate != breathRate || breathPeriod == 0 {
                let period = (sampleRate / breath.rate).rounded()
                let newPeriod = UInt32(max(1, period))
                if breathPeriod > 0 {
                    // Keep the fraction of the cycle across a rate change.
                    let fraction = Float(breathSample) / Float(breathPeriod)
                    breathSample = UInt32(fraction * Float(newPeriod))
                }
                breathPeriod = newPeriod
                breathRate = breath.rate
            }
            if breathWeight > 0 {
                let phase = Float(breathSample) / Float(breathPeriod)
                breathValue = BreathCurve.value(phase: phase, inhale: breath.inhale, exhale: breath.exhale)
            }
            breathSample += 1
            if breathSample >= breathPeriod { breathSample = 0 }
        } else {
            breathPeriod = 0
            breathRate = 0
        }
        // Held (not reset) when the rate drops to zero: the weight carries the
        // beds back to neutral without a step.
        breathValueSmoothed += (breathValue - breathValueSmoothed) * breathValueCoefficient
        breathValueSmoothed = flushDenormal(breathValueSmoothed)
    }

    /// Mono frame: a power-preserving sum of both channels. The meter reads
    /// the stereo pair before the sum, which carries the same power.
    mutating func process(_ command: EngineCommand) -> Float {
        let frame = processStereo(command)
        return softClip((frame.left + frame.right) * 0.7071)
    }

    private mutating func beginFade(to target: Float, samples: Int32, shape: Int32) {
        fadeShape = shape
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
        let shaped = FadeCurve.shaped(fadeProgress, shape: fadeShape)
        envelope = fadeFrom + (fadeTo - fadeFrom) * shaped
    }
}
