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
    /// Play, Pause and the final fade of the timer: 0 to 1, counted in whole
    /// samples so a fifteen minute fade is as exact as a short one (C31).
    var envelopeRamp = SampleRamp(0)
    var appliedEnvelopeGeneration: UInt32 = 0
    /// The session level (C51): Manto, the vertical axis of Night and the
    /// speaker cap. Applied after the soft clip, so turning the night down
    /// changes how loud it is and never how it sounds. It survives a fresh
    /// start: the level belongs to the session, not to one Play.
    var masterRamp = SampleRamp(1)
    var appliedMasterGeneration: UInt32 = 0
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
    /// Where the weight is heading: a straight ramp over the command's
    /// dissolve, counted in whole samples like the two gains (rule 5; a
    /// fifteen minute dissolve added in float steps never left 1), and the
    /// 1.5 s smoothed weight actually applied.
    var breathWeightRamp = SampleRamp(0)
    /// The dissolve of the ramp in course, to tell a new request apart.
    var breathDissolveSeconds: Float = 0
    var breathWeight: Float = 0
    var breathWeightCoefficient: Float = 0.00001
    /// Bed modulation depth, smoothed like the weight so a settings change
    /// (0.4 ⇄ 0.2) never steps the beds.
    var breathDepth: Float = 0.4
    /// Level of what actually leaves `processStereo`, for the interface.
    var outputMeter = OutputMeter()

    /// The envelope right now. Setting it drops any fade in progress.
    var envelope: Float {
        get { envelopeRamp.value }
        set { envelopeRamp.set(newValue) }
    }

    /// Curve of the envelope fade in progress: a `FadeShape`.
    var fadeShape: Int32 { envelopeRamp.shape }

    /// The master level right now.
    var master: Float { masterRamp.value }

    /// The weight the tide is at on its way to the command's, before the
    /// smoothing. Setting it drops any dissolve in progress.
    var breathWeightTarget: Float {
        get { breathWeightRamp.value }
        set { breathWeightRamp.set(newValue) }
    }

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
        // A fade in course keeps its place and what is left of it lasts the
        // same seconds at the new rate (rule 8).
        if rate != self.sampleRate {
            let ratio = Double(rate) / Double(self.sampleRate)
            envelopeRamp.rescale(by: ratio)
            masterRamp.rescale(by: ratio)
            breathWeightRamp.rescale(by: ratio)
        }
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
        envelopeRamp.reset(to: 0)
        // A master ramp caught half way by the stop lands where it was
        // going: nothing is audible, and the next Play starts at the level
        // the session asked for.
        masterRamp.set(masterRamp.to)
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
                envelopeRamp.begin(
                    to: command.envelopeTarget,
                    samples: command.rampSamples,
                    shape: command.envelopeShape
                )
            }
        }
        if command.masterGeneration != appliedMasterGeneration {
            appliedMasterGeneration = command.masterGeneration
            if command.masterRampSamples >= 0 {
                masterRamp.begin(to: unitGain(command.masterTarget), samples: command.masterRampSamples)
            }
        }
        envelopeRamp.advance()
        masterRamp.advance()
        smoothed.approach(command.gains, coefficient: gainCoefficient)
        advanceBreath(command.breath)

        let envelope = envelopeRamp.value
        let master = masterRamp.value
        let l = left.mix(smoothed, breath: breathValueSmoothed, weight: breathWeight, depth: breathDepth)
        let r = right.mix(smoothed, breath: breathValueSmoothed, weight: breathWeight, depth: breathDepth)
        // The master multiplies what the soft clip already bounded: with a
        // gain of 1 at most the output stays inside full scale, and a mix
        // that leans on the knee keeps the same colour at any level.
        let outLeft = softClip(l * envelope) * master
        let outRight = softClip(r * envelope) * master
        // Measured last: the level of what is really heard.
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
    mutating func advanceBreath(_ breath: BreathParameters) {
        if breath.epoch != breathEpoch {
            breathEpoch = breath.epoch
            breathSample = 0
            breathPeriod = 0
            // Seed while nothing is audible yet, or while the fade-in from
            // silence is still under way (large IO buffers can deliver the
            // epoch one buffer after the fade began).
            let fadingInFromSilence = envelopeRamp.isRunning && envelopeRamp.from == 0 && envelopeRamp.to > 0
            if envelopeRamp.value < 1e-3 || fadingInFromSilence {
                breathWeightTarget = breath.weight
                breathWeight = breath.weight
                breathValue = 0
                breathValueSmoothed = 0
            }
        }

        // Weight: a straight ramp toward the command, then smoothed. The
        // dissolve is the time the whole range takes, so a part of the way
        // takes that part of it. Counted in samples: a float step for a
        // long dissolve is lost to rounding near 1 (C31).
        if breath.weight != breathWeightRamp.to || breath.dissolveSeconds != breathDissolveSeconds {
            breathDissolveSeconds = breath.dissolveSeconds
            if breath.dissolveSeconds > 0 {
                let distance = abs(Double(breath.weight) - Double(breathWeightRamp.value))
                let samples = (Double(breath.dissolveSeconds) * Double(sampleRate) * distance).rounded()
                breathWeightRamp.begin(
                    to: breath.weight,
                    samples: Int32(min(samples, Double(Int32.max))),
                    shape: FadeShape.linear
                )
            } else {
                breathWeightRamp.set(breath.weight)
            }
        }
        breathWeightRamp.advance()
        let breathWeightTarget = breathWeightRamp.value
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
}

/// A gain inside 0...1. Anything else, a NaN included, is silence or unity:
/// a bad level can turn the night down, never up.
@inline(__always)
func unitGain(_ x: Float) -> Float {
    if x >= 1 { return 1 }
    if x > 0 { return x }
    return 0
}
