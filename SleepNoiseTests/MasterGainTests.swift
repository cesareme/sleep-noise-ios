import AVFoundation
import XCTest
@testable import SleepNoise

/// The ramp both gains of the render state are built on: a count of whole
/// samples, exact at any length (C31).
final class SampleRampTests: XCTestCase {
    func testItStartsWhereItIsToldAndDoesNotMoveByItself() {
        var ramp = SampleRamp(0.7)
        XCTAssertEqual(ramp.value, 0.7)
        XCTAssertFalse(ramp.isRunning)
        for _ in 0..<100 { ramp.advance() }
        XCTAssertEqual(ramp.value, 0.7)
    }

    func testARampEndsExactlyOnItsLastSample() {
        for samples: Int32 in [2, 3, 480, 1_920, 72_000] {
            var ramp = SampleRamp(1)
            ramp.begin(to: 0.25, samples: samples)
            XCTAssertTrue(ramp.isRunning)
            var previous = ramp.value
            for index in 1..<Int(samples) {
                ramp.advance()
                XCTAssertLessThanOrEqual(ramp.value, previous, "\(samples), sample \(index): it only falls")
                XCTAssertGreaterThanOrEqual(ramp.value, 0.25, "\(samples), sample \(index): never past the target")
                XCTAssertTrue(ramp.isRunning, "\(samples), sample \(index): not there early")
                previous = ramp.value
            }
            ramp.advance()
            XCTAssertEqual(ramp.value, 0.25, "\(samples): on the target, bit for bit")
            XCTAssertFalse(ramp.isRunning)
            for _ in 0..<10 { ramp.advance() }
            XCTAssertEqual(ramp.value, 0.25)
        }
    }

    func testOneSampleOrLessIsNotARamp() {
        for samples: Int32 in [1, 0, -1] {
            var ramp = SampleRamp(1)
            ramp.begin(to: 0.4, samples: samples)
            XCTAssertEqual(ramp.value, 0.4, "\(samples)")
            XCTAssertFalse(ramp.isRunning, "\(samples)")
        }
    }

    func testTheCurvesAreTheOnesOfTheFade() {
        var smooth = SampleRamp(0)
        smooth.begin(to: 1, samples: 1_000, shape: FadeShape.smooth)
        var eased = SampleRamp(0)
        eased.begin(to: 1, samples: 1_000, shape: FadeShape.easeOut)
        for _ in 0..<500 {
            smooth.advance()
            eased.advance()
        }
        XCTAssertEqual(smooth.value, 0.5, accuracy: 0.000_1)
        XCTAssertEqual(eased.value, 0.75, accuracy: 0.000_1)
        XCTAssertEqual(eased.shape, FadeShape.easeOut)
    }

    func testANewRampStartsFromWhereTheLastOneWas() {
        var ramp = SampleRamp(1)
        ramp.begin(to: 0, samples: 1_000)
        for _ in 0..<400 { ramp.advance() }
        let reached = ramp.value
        ramp.begin(to: 1, samples: 200)
        XCTAssertEqual(ramp.value, reached, "no jump at the turn")
        ramp.advance()
        XCTAssertEqual(ramp.value, reached, accuracy: 0.001)
        for _ in 0..<199 { ramp.advance() }
        XCTAssertEqual(ramp.value, 1)
    }

    /// The reason for the count (C31): fifteen minutes at 48 kHz are 43.2
    /// million samples. A step of 1/43.2 M added to a `Float` near 1 is
    /// smaller than half its last bit and is lost: that fade never ends.
    /// The count gets there on the last sample.
    func testAFifteenMinuteFadeKeepsItsLength() {
        let samples = PlaybackFade.samples(TimerMath.longestFade, sampleRate: 48_000)
        XCTAssertEqual(samples, 43_200_000)

        // What the float accumulation did: stuck short of 1.
        let step = 1 / Float(samples)
        XCTAssertEqual(Float(0.75) + step, 0.75, "the step the old fade added is lost to rounding")

        var ramp = SampleRamp(1)
        ramp.begin(to: 0, samples: samples)
        var previous = ramp.value
        var steepest: Float = 0
        var rises = 0
        let quarter = samples / 4
        var index: Int32 = 0
        while index < samples - 1 {
            ramp.advance()
            index += 1
            let value = ramp.value
            let fall = previous - value
            if fall > steepest { steepest = fall }
            if fall < 0 { rises += 1 }
            previous = value
            if index == quarter {
                XCTAssertEqual(value, 0.843_75, accuracy: 0.000_01, "a quarter of the way")
            } else if index == quarter * 2 {
                XCTAssertEqual(value, 0.5, accuracy: 0.000_01, "half way at half time")
            } else if index == quarter * 3 {
                XCTAssertEqual(value, 0.156_25, accuracy: 0.000_01, "three quarters of the way")
            }
        }
        XCTAssertEqual(rises, 0, "the fade never goes up")
        XCTAssertTrue(ramp.isRunning, "one sample from the end it is still fading")
        XCTAssertGreaterThanOrEqual(ramp.value, 0)
        ramp.advance()
        XCTAssertEqual(ramp.value, 0)
        XCTAssertFalse(ramp.isRunning)
        // No step: the steepest sample of a smoothstep is 1.5 / samples, and
        // a Float cannot say less than one bit at this level.
        XCTAssertLessThan(steepest, 0.000_001)
    }
}

/// The master level in the render state (C51): its own request in the
/// command, applied after the soft clip, always a ramp.
final class MasterGainTests: XCTestCase {
    private func command(
        gains: SoundGains = .uniform(0.3),
        master: Float = 1,
        ramp: Int32 = -1,
        masterGeneration: UInt32 = 0
    ) -> EngineCommand {
        EngineCommand(
            gains: gains,
            envelopeTarget: 1,
            rampSamples: 1,
            generation: 1,
            envelopeGeneration: 1,
            masterTarget: master,
            masterRampSamples: ramp,
            masterGeneration: masterGeneration
        )
    }

    func testTheMasterIsUnityUntilSomethingAsks() {
        var state = RenderState(sampleRate: 48_000)
        XCTAssertEqual(state.master, 1)
        XCTAssertEqual(EngineCommand.silence.masterTarget, 1)
        XCTAssertLessThan(EngineCommand.silence.masterRampSamples, 0)
        for _ in 0..<1_000 { _ = state.processStereo(command()) }
        XCTAssertEqual(state.master, 1)
    }

    /// The level changes how loud the night is and never how it sounds:
    /// every sample is the same sample, scaled. A mix that leans on the
    /// soft clip is the one that would show a master applied before it.
    func testTheMasterScalesTheOutputWithoutChangingIt() {
        for gains in [SoundGains.uniform(0.3), SoundGains.uniform(1)] {
            var full = RenderState(sampleRate: 48_000)
            var half = RenderState(sampleRate: 48_000)
            let plain = command(gains: gains)
            let turnedDown = command(gains: gains, master: 0.5, ramp: 1, masterGeneration: 1)
            var loudest: Float = 0
            for index in 0..<24_000 {
                let a = full.processStereo(plain)
                let b = half.processStereo(turnedDown)
                XCTAssertEqual(b.left, a.left * 0.5, "sample \(index)")
                XCTAssertEqual(b.right, a.right * 0.5, "sample \(index)")
                loudest = max(loudest, abs(a.left))
            }
            if gains == .uniform(1) {
                XCTAssertGreaterThan(loudest, 0.6, "the full mix does reach the knee of the soft clip")
            }
            // The Horizon draws what is heard: the meter reads after the master.
            XCTAssertEqual(half.outputMeter.rms, full.outputMeter.rms * 0.5, accuracy: full.outputMeter.rms * 0.001)
        }
    }

    func testTheBlanketDipIsARampWithoutAStep() {
        for rate in [Double(44_100), 48_000] {
            var state = RenderState(sampleRate: Float(rate))
            // Two seconds stand in for the minute: the shape is the same.
            let samples = PlaybackFade.samples(2, sampleRate: rate)
            let dip = command(master: TimerMath.blanketDipGain, ramp: samples, masterGeneration: 1)
            let span = 1 - TimerMath.blanketDipGain
            // Smoothstep is steepest in the middle: 1.5 x span / samples.
            let steepest = 1.5 * span / Float(samples) + 0.000_001
            var previous = state.master
            for index in 0..<Int(samples) {
                _ = state.processStereo(dip)
                let fall = previous - state.master
                XCTAssertGreaterThanOrEqual(fall, -0.000_001, "rate \(rate), sample \(index): it only falls")
                XCTAssertLessThanOrEqual(fall, steepest, "rate \(rate), sample \(index): no step")
                previous = state.master
                if index == Int(samples) / 2 - 1 {
                    XCTAssertEqual(state.master, 1 - span / 2, accuracy: 0.001, "rate \(rate): half way at half time")
                }
                // The curve is flat at its end, so the last samples already
                // read as the target in a Float; nine tenths in, it is not.
                if index == Int(samples) * 9 / 10 {
                    XCTAssertGreaterThan(state.master, TimerMath.blanketDipGain, "rate \(rate): not there early")
                }
            }
            XCTAssertEqual(state.master, TimerMath.blanketDipGain, "rate \(rate): on the target at the end")
            for _ in 0..<1_000 { _ = state.processStereo(dip) }
            XCTAssertEqual(state.master, TimerMath.blanketDipGain)
        }
        // -6 dB, as a gain.
        XCTAssertEqual(20 * log10(TimerMath.blanketDipGain), -6, accuracy: 0.000_1)
    }

    func testOnlyAMovedGenerationStartsARamp() {
        var state = RenderState(sampleRate: 48_000)
        let down = command(master: 0.4, ramp: 4_800, masterGeneration: 1)
        for _ in 0..<2_400 { _ = state.processStereo(down) }
        let partway = state.master
        XCTAssertLessThan(partway, 1)
        XCTAssertGreaterThan(partway, 0.4)

        // A gain change carries the same master request: the ramp goes on.
        var gainsChange = down
        gainsChange.gains.pink = 0.9
        gainsChange.generation = 7
        _ = state.processStereo(gainsChange)
        XCTAssertLessThan(state.master, partway)
        XCTAssertEqual(state.masterRamp.total, 4_800)
        XCTAssertEqual(state.masterRamp.done, 2_401)
        for _ in 0..<2_400 { _ = state.processStereo(gainsChange) }
        XCTAssertEqual(state.master, 0.4)

        // A negative ramp means "leave the master alone", whatever the target.
        let ignored = command(master: 1, ramp: -1, masterGeneration: 2)
        for _ in 0..<100 { _ = state.processStereo(ignored) }
        XCTAssertEqual(state.master, 0.4)
        XCTAssertEqual(state.appliedMasterGeneration, 2)
    }

    func testAFingerOnTheLevelNeverSteps() {
        // Night's vertical axis: many small moves, each over 50 ms, each
        // starting from where the last one was.
        var state = RenderState(sampleRate: 48_000)
        let ramp = PlaybackFade.samples(SleepAudioEngine.shortestMasterRamp, sampleRate: 48_000)
        XCTAssertEqual(ramp, 2_400)
        var previous = state.master
        var generation: UInt32 = 0
        for step in 1...16 {
            generation += 1
            let target = 1 - Float(step) * 0.05
            let move = command(master: target, ramp: ramp, masterGeneration: generation)
            // The finger moves on before the ramp is over.
            for _ in 0..<800 {
                _ = state.processStereo(move)
                XCTAssertLessThanOrEqual(abs(state.master - previous), 0.001)
                previous = state.master
            }
        }
        // The finger stops: the level lands on the last target, exactly.
        let last = command(master: 0.2, ramp: ramp, masterGeneration: generation + 1)
        for _ in 0..<Int(ramp) {
            _ = state.processStereo(last)
            XCTAssertLessThanOrEqual(abs(state.master - previous), 0.001)
            previous = state.master
        }
        XCTAssertEqual(state.master, 0.2)
    }

    func testABadLevelCanOnlyTurnTheNightDown() {
        XCTAssertEqual(unitGain(.nan), 0)
        XCTAssertEqual(unitGain(-0.5), 0)
        XCTAssertEqual(unitGain(.infinity), 1)
        XCTAssertEqual(unitGain(3), 1)
        XCTAssertEqual(unitGain(0.4), 0.4)

        var generation: UInt32 = 0
        for (target, expected) in [(Float.nan, Float(0)), (-2, 0), (5, 1), (.infinity, 1)] {
            var state = RenderState(sampleRate: 48_000)
            generation += 1
            let bad = command(gains: .uniform(1), master: target, ramp: 1, masterGeneration: generation)
            for _ in 0..<2_000 {
                let frame = state.processStereo(bad)
                XCTAssertFalse(frame.left.isNaN || frame.right.isNaN)
                XCTAssertLessThanOrEqual(abs(frame.left), 1)
                XCTAssertLessThanOrEqual(abs(frame.right), 1)
            }
            XCTAssertEqual(state.master, expected, "\(target)")
        }
    }

    /// The level belongs to the session, not to one Play: a fresh start
    /// silences the envelope and leaves the master where it was asked to be.
    func testAFreshStartKeepsTheSessionLevel() {
        var state = RenderState(sampleRate: 48_000)
        let capped = command(master: RoutePolicy.speakerMasterCap, ramp: 1, masterGeneration: 1)
        for _ in 0..<100 { _ = state.processStereo(capped) }
        state.resetForFreshStart()
        XCTAssertEqual(state.envelope, 0)
        XCTAssertEqual(state.master, RoutePolicy.speakerMasterCap)

        // A ramp the pause caught half way lands where it was going.
        let dip = command(master: 0.2, ramp: 48_000, masterGeneration: 2)
        for _ in 0..<10_000 { _ = state.processStereo(dip) }
        XCTAssertGreaterThan(state.master, 0.2)
        state.resetForFreshStart()
        XCTAssertEqual(state.master, 0.2)
        XCTAssertFalse(state.masterRamp.isRunning)
    }

    func testTheMasterAndTheEnvelopeAreIndependent() {
        // Pause and Play move the envelope; the session level stays.
        var state = RenderState(sampleRate: 48_000)
        var playing = command(master: 0.5, ramp: 1, masterGeneration: 1)
        for _ in 0..<1_000 { _ = state.processStereo(playing) }
        XCTAssertEqual(state.envelope, 1)
        XCTAssertEqual(state.master, 0.5)

        playing.envelopeTarget = 0
        playing.rampSamples = 2_000
        playing.envelopeGeneration = 2
        for _ in 0..<2_000 { _ = state.processStereo(playing) }
        XCTAssertEqual(state.envelope, 0)
        XCTAssertEqual(state.master, 0.5)

        // And the other way round: the final fade of the timer runs on the
        // envelope while the level is dragged.
        playing.envelopeTarget = 1
        playing.rampSamples = 1
        playing.envelopeGeneration = 3
        _ = state.processStereo(playing)
        playing.envelopeTarget = 0
        playing.rampSamples = 48_000
        playing.envelopeGeneration = 4
        for _ in 0..<12_000 { _ = state.processStereo(playing) }
        let fading = state.envelope
        playing.masterTarget = 0.3
        playing.masterRampSamples = 2_400
        playing.masterGeneration = 2
        for _ in 0..<2_400 { _ = state.processStereo(playing) }
        XCTAssertEqual(state.master, 0.3)
        XCTAssertLessThan(state.envelope, fading, "the fade went on under the drag")
        XCTAssertEqual(state.envelopeRamp.total, 48_000)
        XCTAssertEqual(state.envelopeRamp.done, 14_400)
    }

    /// The whole callback, offline: the master crosses the mailbox like any
    /// other field and scales what reaches the buffer.
    func testTheMasterCrossesTheMailboxIntoTheBuffer() throws {
        let frames = 4_800
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2))
        func render(master: Float?) throws -> (samples: [Float], level: Float) {
            let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)))
            buffer.frameLength = AVAudioFrameCount(frames)
            let mailbox = ParameterMailbox()
            var gains = SoundGains.zero
            gains.white = 0.5
            if let master {
                mailbox.publish(command(gains: gains, master: master, ramp: 1, masterGeneration: 1))
            } else {
                mailbox.publish(command(gains: gains))
            }
            let state = UnsafeMutablePointer<RenderState>.allocate(capacity: 1)
            state.initialize(to: RenderState(sampleRate: 48_000))
            defer {
                state.deinitialize(count: 1)
                state.deallocate()
            }
            let cell = OutputLevelCell()
            renderOutput(
                state: state,
                command: UnsafePointer(mailbox.storage),
                sequence: mailbox.sequence,
                level: cell.storage,
                frameCount: frames,
                bufferList: buffer.mutableAudioBufferList
            )
            let left = try XCTUnwrap(buffer.floatChannelData?[0])
            return (Array(UnsafeBufferPointer(start: left, count: frames)), cell.rms)
        }
        let full = try render(master: nil)
        let quiet = try render(master: 0.25)
        XCTAssertGreaterThan(full.level, 0.05)
        XCTAssertEqual(quiet.level, full.level * 0.25, accuracy: full.level * 0.001)
        for index in 0..<frames {
            XCTAssertEqual(quiet.samples[index], full.samples[index] * 0.25, "sample \(index)")
        }
    }
}
