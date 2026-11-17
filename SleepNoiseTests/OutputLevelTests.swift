import AVFoundation
import XCTest
@testable import SleepNoise

/// The level the Horizon draws: measured on the render side after the soft
/// clip, carried over in one atomic word, smoothed on the main thread.
final class OutputLevelTests: XCTestCase {
    private func command(
        _ gains: SoundGains,
        target: Float = 1,
        ramp: Int32 = 1,
        envelopeGeneration: UInt32 = 1
    ) -> EngineCommand {
        EngineCommand(
            gains: gains,
            envelopeTarget: target,
            rampSamples: ramp,
            generation: envelopeGeneration,
            envelopeGeneration: envelopeGeneration
        )
    }

    private func gains(_ pairs: [(SoundID, Float)]) -> SoundGains {
        var gains = SoundGains.zero
        for (sound, value) in pairs {
            gains.set(sound, value)
        }
        return gains
    }

    /// Renders `frames` and returns the plain RMS of the last `tail` frames.
    @discardableResult
    private func render(
        _ state: inout RenderState,
        _ command: EngineCommand,
        frames: Int,
        tail: Int = 0
    ) -> Float {
        var sum: Double = 0
        for index in 0..<frames {
            let frame = state.processStereo(command)
            if index >= frames - tail {
                sum += Double(frame.left * frame.left + frame.right * frame.right) * 0.5
            }
        }
        return tail > 0 ? Float((sum / Double(tail)).squareRoot()) : 0
    }

    func testSilenceReadsExactlyZero() {
        // Envelope open, nothing raised.
        var open = RenderState(sampleRate: 48_000)
        render(&open, command(.zero), frames: 48_000)
        XCTAssertEqual(open.outputMeter.meanSquare, 0)
        XCTAssertEqual(open.outputMeter.rms, 0)

        // Layers raised, envelope closed.
        var closed = RenderState(sampleRate: 48_000)
        render(&closed, command(.uniform(1), target: 0), frames: 48_000)
        XCTAssertEqual(closed.outputMeter.meanSquare, 0)
    }

    func testKnownMixReadsInsideItsBand() {
        for rate in [Float(44_100), 48_000, 96_000] {
            var state = RenderState(sampleRate: rate)
            let mix = command(gains([(.white, 0.5)]))
            // White noise is stationary, so the pole and a plain RMS over a
            // long window must agree. Uniform noise at ±0.5 has an RMS of
            // 0.5 / √3 ≈ 0.289 before any shaping; the generator's own level
            // decides the band, the comparison with the tail decides the test.
            let tail = render(&state, mix, frames: Int(rate) * 2, tail: Int(rate))
            let metered = state.outputMeter.rms
            XCTAssertGreaterThan(metered, 0.07, "rate \(rate)")
            XCTAssertLessThan(metered, 0.14, "rate \(rate)")
            XCTAssertEqual(metered, tail, accuracy: tail * 0.1, "rate \(rate)")
        }
    }

    func testDefaultMixAndFullMixKeepTheirOrder() {
        // The band the interface scale is built on: one layer at the default
        // level sits near −18 dBFS, every layer at full sits near −6 dBFS.
        var single = RenderState(sampleRate: 48_000)
        render(&single, command(gains([(.pink, 0.65)])), frames: 96_000)
        var full = RenderState(sampleRate: 48_000)
        render(&full, command(.uniform(1)), frames: 96_000)

        XCTAssertGreaterThan(single.outputMeter.rms, 0.07)
        XCTAssertLessThan(single.outputMeter.rms, 0.22)
        XCTAssertGreaterThan(full.outputMeter.rms, 0.3)
        XCTAssertLessThan(full.outputMeter.rms, 0.75)
        XCTAssertGreaterThan(full.outputMeter.rms, single.outputMeter.rms * 2)
    }

    func testLevelFollowsTheFadeOutBackToZero() {
        var state = RenderState(sampleRate: 48_000)
        let mix = gains([(.rain, 0.78), (.pink, 0.24)])
        render(&state, command(mix), frames: 48_000)
        let playing = state.outputMeter.rms
        XCTAssertGreaterThan(playing, 0.05)

        // Half-second fade to silence, then the tail of the pole.
        let fade = command(mix, target: 0, ramp: 24_000, envelopeGeneration: 2)
        render(&state, fade, frames: 12_000)
        XCTAssertLessThan(state.outputMeter.rms, playing)
        XCTAssertGreaterThan(state.outputMeter.rms, 0)
        render(&state, fade, frames: 12_000)
        XCTAssertEqual(state.envelope, 0)

        // Nothing is coming in any more: within a second the reading is an
        // exact zero, not a denormal tail.
        render(&state, fade, frames: 48_000)
        XCTAssertEqual(state.outputMeter.meanSquare, 0)
    }

    func testFreshStartClearsTheMeter() {
        var state = RenderState(sampleRate: 48_000)
        render(&state, command(.uniform(0.5)), frames: 24_000)
        XCTAssertGreaterThan(state.outputMeter.meanSquare, 0)
        state.resetForFreshStart()
        XCTAssertEqual(state.outputMeter.meanSquare, 0)
    }

    func testQuietSignalStillRegisters() {
        // The silence threshold only cuts a tail with nothing coming in: a
        // layer at one percent must still read above zero.
        var state = RenderState(sampleRate: 48_000)
        render(&state, command(gains([(.pink, 0.01)])), frames: 48_000)
        XCTAssertGreaterThan(state.outputMeter.rms, 0)
        XCTAssertLessThan(state.outputMeter.rms, 0.01)
    }

    func testMeterWindowDoesNotDependOnTheSampleRate() {
        // Same step, two rates: after one window the pole sits at 1 − 1/e.
        for rate in [Float(44_100), 96_000] {
            var meter = OutputMeter()
            meter.prepare(sampleRate: rate)
            for _ in 0..<Int(rate * OutputMeter.window) {
                meter.add(left: 0.5, right: 0.5)
            }
            XCTAssertEqual(meter.meanSquare, 0.25 * (1 - exp(-1)), accuracy: 0.002, "rate \(rate)")
        }
    }

    func testCellCarriesTheValueBitForBit() {
        let cell = OutputLevelCell()
        XCTAssertEqual(cell.meanSquare, 0)
        XCTAssertEqual(cell.rms, 0)

        publishOutputLevel(0.0625, to: cell.storage)
        XCTAssertEqual(cell.meanSquare, 0.0625)
        XCTAssertEqual(cell.rms, 0.25)

        // A reader never trusts the word: NaN and negatives are silence.
        publishOutputLevel(.nan, to: cell.storage)
        XCTAssertEqual(cell.rms, 0)
        publishOutputLevel(-1, to: cell.storage)
        XCTAssertEqual(cell.rms, 0)

        publishOutputLevel(0.5, to: cell.storage)
        cell.clear()
        XCTAssertEqual(cell.meanSquare, 0)
    }

    func testCellConcurrencySmoke() {
        // A smoke test, not a proof of atomicity: one aligned 32-bit word
        // does not tear on these machines whatever the access. It keeps a
        // writer and a reader on the cell at the same time, which is what
        // the thread sanitizer needs to see, and checks that the reader only
        // ever gets a value that was stored.
        let cell = OutputLevelCell()
        let storage = cell.storage
        let stop = OutputLevelCell()
        let stopFlag = stop.storage
        let started = expectation(description: "writer running")
        let done = expectation(description: "writer finished")
        DispatchQueue(label: "level.writer").async {
            var index = 0
            var announced = false
            // Runs until the reader is done, so the two always overlap.
            while stop.meanSquare == 0 {
                publishOutputLevel(index % 2 == 0 ? 0.25 : 0.0625, to: storage)
                index += 1
                if !announced {
                    announced = true
                    started.fulfill()
                }
            }
            done.fulfill()
        }
        wait(for: [started], timeout: 10)
        var seen = Set<Float>()
        for _ in 0..<200_000 {
            seen.insert(cell.meanSquare)
        }
        publishOutputLevel(1, to: stopFlag)
        wait(for: [done], timeout: 10)
        XCTAssertTrue(seen.isSubset(of: [0.25, 0.0625]), "\(seen)")
        XCTAssertFalse(seen.isEmpty)
    }

    // MARK: The callback itself

    /// Runs the body of the render callback offline, on a plain buffer.
    private func renderOffline(
        _ buffer: AVAudioPCMBuffer,
        frames: Int,
        state: UnsafeMutablePointer<RenderState>,
        mailbox: ParameterMailbox,
        cell: OutputLevelCell
    ) {
        renderOutput(
            state: state,
            command: UnsafePointer(mailbox.storage),
            sequence: mailbox.sequence,
            level: cell.storage,
            frameCount: frames,
            bufferList: buffer.mutableAudioBufferList
        )
    }

    func testRenderCallbackFillsEveryLayoutAndPublishesItsLevel() throws {
        let layouts: [(name: String, format: AVAudioFormat?, channels: Int)] = [
            ("deinterleaved", AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2), 2),
            (
                "interleaved",
                AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48_000, channels: 2, interleaved: true),
                2
            ),
            ("mono", AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1), 1),
        ]
        let frames = 4_800
        for layout in layouts {
            let format = try XCTUnwrap(layout.format, layout.name)
            let buffer = try XCTUnwrap(
                AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)),
                layout.name
            )
            buffer.frameLength = AVAudioFrameCount(frames)

            let mailbox = ParameterMailbox()
            mailbox.publish(command(gains([(.white, 0.5)])))
            let state = UnsafeMutablePointer<RenderState>.allocate(capacity: 1)
            state.initialize(to: RenderState(sampleRate: 48_000))
            defer {
                state.deinitialize(count: 1)
                state.deallocate()
            }
            let cell = OutputLevelCell()
            // Something old in the cell, to tell "not published" from zero.
            publishOutputLevel(0.9, to: cell.storage)

            // An empty buffer changes nothing: no state, no level.
            renderOffline(buffer, frames: 0, state: state, mailbox: mailbox, cell: cell)
            XCTAssertEqual(cell.meanSquare, 0.9, layout.name)
            XCTAssertEqual(state.pointee.outputMeter.meanSquare, 0, layout.name)
            XCTAssertEqual(state.pointee.lastCommand.gains.white, 0, layout.name)

            renderOffline(buffer, frames: frames, state: state, mailbox: mailbox, cell: cell)
            // The command crossed the mailbox, the state was written back
            // and the level on show is the one the meter holds.
            XCTAssertEqual(state.pointee.lastCommand.gains.white, 0.5, layout.name)
            XCTAssertGreaterThan(cell.meanSquare, 0, layout.name)
            XCTAssertNotEqual(cell.meanSquare, 0.9, layout.name)
            XCTAssertEqual(cell.meanSquare, state.pointee.outputMeter.meanSquare, layout.name)
            XCTAssertEqual(cell.rms, state.pointee.outputMeter.rms, layout.name)

            // Every channel of the buffer carries sound.
            let list = UnsafeMutableAudioBufferListPointer(buffer.mutableAudioBufferList)
            var loud = [Int](repeating: 0, count: layout.channels)
            if list.count == 1 {
                let stride = Int(list[0].mNumberChannels)
                XCTAssertEqual(stride, layout.channels, layout.name)
                let data = try XCTUnwrap(list[0].mData?.assumingMemoryBound(to: Float.self), layout.name)
                for index in 0..<(frames * stride) where abs(data[index]) > 1e-6 {
                    loud[index % stride] += 1
                }
            } else {
                XCTAssertEqual(list.count, layout.channels, layout.name)
                for channel in 0..<list.count {
                    let data = try XCTUnwrap(list[channel].mData?.assumingMemoryBound(to: Float.self), layout.name)
                    for index in 0..<frames where abs(data[index]) > 1e-6 {
                        loud[channel] += 1
                    }
                }
            }
            for count in loud {
                XCTAssertGreaterThan(count, frames / 2, layout.name)
            }

            // A second empty call leaves the published level alone.
            let published = cell.meanSquare
            renderOffline(buffer, frames: 0, state: state, mailbox: mailbox, cell: cell)
            XCTAssertEqual(cell.meanSquare, published, layout.name)
        }
    }

    func testRenderCallbackKeepsTheLastCommandWhileTheMailboxIsBeingWritten() throws {
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2))
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512))
        buffer.frameLength = 512
        let mailbox = ParameterMailbox()
        mailbox.publish(command(gains([(.pink, 0.4)])))
        let state = UnsafeMutablePointer<RenderState>.allocate(capacity: 1)
        state.initialize(to: RenderState(sampleRate: 48_000))
        defer {
            state.deinitialize(count: 1)
            state.deallocate()
        }
        let cell = OutputLevelCell()
        renderOffline(buffer, frames: 512, state: state, mailbox: mailbox, cell: cell)
        XCTAssertEqual(state.pointee.lastCommand.gains.pink, 0.4)

        // A writer caught halfway (odd sequence): the reader does not wait,
        // it renders on with the command it had, and still publishes.
        // (Nothing else touches this mailbox, so plain accesses will do.)
        XCTAssertEqual(mailbox.sequence.pointee % 2, 0)
        mailbox.sequence.pointee &+= 1
        mailbox.storage.pointee.gains.pink = 1
        publishOutputLevel(0, to: cell.storage)
        renderOffline(buffer, frames: 512, state: state, mailbox: mailbox, cell: cell)
        XCTAssertEqual(state.pointee.lastCommand.gains.pink, 0.4)
        XCTAssertGreaterThan(cell.meanSquare, 0)
    }

    func testFollowerReachesTheLevelWithItsTimeConstant() {
        var follower = OutputLevelFollower()
        // The first read has no history: it lands on the level.
        XCTAssertEqual(follower.follow(0, at: 100, tau: 0.5), 0)

        // One time constant later, in 20 Hz steps, it is at 1 − 1/e.
        var value: Float = 0
        for step in 1...10 {
            value = follower.follow(1, at: 100 + Double(step) * 0.05, tau: 0.5)
        }
        XCTAssertEqual(value, 1 - exp(-1), accuracy: 0.001)

        // The same span in one read gives the same answer: the smoothing is a
        // function of time, not of how often somebody asks.
        var coarse = OutputLevelFollower()
        _ = coarse.follow(0, at: 100, tau: 0.5)
        XCTAssertEqual(coarse.follow(1, at: 100.5, tau: 0.5), value, accuracy: 0.001)
    }

    func testFollowerFallsToAnExactZero() {
        var follower = OutputLevelFollower()
        _ = follower.follow(0.2, at: 0, tau: 0.5)
        var time = 0.0
        var value: Float = 0.2
        while time < 6 {
            time += 0.05
            value = follower.follow(0, at: time, tau: 0.5)
        }
        XCTAssertEqual(value, 0)
    }

    func testFollowerFallsFasterOnceTheEngineStops() {
        // While the engine renders the caller's constant stands; after it
        // stops the fall is never slower than `stopTau`, Reduce Motion or not.
        XCTAssertEqual(OutputLevelFollower.tau(requested: 0.5, isRendering: true), 0.5)
        XCTAssertEqual(OutputLevelFollower.tau(requested: 1.5, isRendering: true), 1.5)
        XCTAssertEqual(OutputLevelFollower.tau(requested: 0.5, isRendering: false), OutputLevelFollower.stopTau)
        XCTAssertEqual(OutputLevelFollower.tau(requested: 1.5, isRendering: false), OutputLevelFollower.stopTau)
        XCTAssertEqual(OutputLevelFollower.tau(requested: 0, isRendering: false), 0)
        XCTAssertLessThan(OutputLevelFollower.stopTau, 0.5)
    }

    func testFollowerIgnoresBadInput() {
        var follower = OutputLevelFollower()
        XCTAssertEqual(follower.follow(.nan, at: 1, tau: 0.5), 0)
        XCTAssertEqual(follower.follow(-3, at: 2, tau: 0.5), 0)
        // The clock going backwards changes nothing.
        _ = follower.follow(0.5, at: 3, tau: 0.5)
        let held = follower.value
        XCTAssertEqual(follower.follow(1, at: 2.5, tau: 0.5), held)
        // No time constant means no smoothing.
        XCTAssertEqual(follower.follow(0.7, at: 4, tau: 0), 0.7)
    }
}
