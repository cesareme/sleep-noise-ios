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

    func testCellSurvivesAWriterAndAReaderAtOnce() {
        // The render thread stores while the main thread loads: every value
        // read must be one that was written, never a mix of two.
        let cell = OutputLevelCell()
        let storage = cell.storage
        let writer = DispatchQueue(label: "level.writer")
        let done = expectation(description: "writer finished")
        writer.async {
            for index in 0..<200_000 {
                publishOutputLevel(index % 2 == 0 ? 0.25 : 0.0625, to: storage)
            }
            done.fulfill()
        }
        for _ in 0..<200_000 {
            let value = cell.meanSquare
            XCTAssertTrue(value == 0 || value == 0.25 || value == 0.0625)
        }
        wait(for: [done], timeout: 10)
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
