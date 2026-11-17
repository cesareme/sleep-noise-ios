import XCTest
@testable import SleepNoise

/// The two ramps the page is built on (03 §3.7): Play rises in 0.8 s easing
/// out, Pause leaves in 1.5 s. Rendered offline, sample by sample, on the
/// same `RenderState` the render callback runs.
final class EnvelopeRampTests: XCTestCase {
    private func command(
        target: Float,
        ramp: Int32,
        shape: Int32,
        generation: UInt32,
        gains: SoundGains = .uniform(0.3)
    ) -> EngineCommand {
        EngineCommand(
            gains: gains,
            envelopeTarget: target,
            rampSamples: ramp,
            envelopeShape: shape,
            generation: generation,
            envelopeGeneration: generation
        )
    }

    // MARK: Lengths

    func testFadeLengthsAreWholeSamples() {
        XCTAssertEqual(SleepAudioEngine.defaultFadeIn, 0.8)
        XCTAssertEqual(PlaybackFade.start, 0.8)
        XCTAssertEqual(PlaybackFade.pause, 1.5)
        XCTAssertEqual(PlaybackFade.interruption, 0.3)
        XCTAssertEqual(PlaybackFade.lostOutput, RoutePolicy.lostOutputFadeOut)

        XCTAssertEqual(PlaybackFade.samples(PlaybackFade.start, sampleRate: 48_000), 38_400)
        XCTAssertEqual(PlaybackFade.samples(PlaybackFade.start, sampleRate: 44_100), 35_280)
        XCTAssertEqual(PlaybackFade.samples(PlaybackFade.pause, sampleRate: 48_000), 72_000)
        XCTAssertEqual(PlaybackFade.samples(PlaybackFade.pause, sampleRate: 44_100), 66_150)
        XCTAssertEqual(PlaybackFade.samples(PlaybackFade.interruption, sampleRate: 48_000), 14_400)
        XCTAssertEqual(PlaybackFade.samples(PlaybackFade.lostOutput, sampleRate: 48_000), 1_920)
        // Never zero or negative: a negative ramp means "leave the envelope".
        XCTAssertEqual(PlaybackFade.samples(0, sampleRate: 48_000), 1)
        XCTAssertEqual(PlaybackFade.samples(-1, sampleRate: 48_000), 1)
    }

    // MARK: Curves

    func testEaseOutCurve() {
        XCTAssertEqual(FadeCurve.easeOut(0), 0)
        XCTAssertEqual(FadeCurve.easeOut(1), 1)
        XCTAssertEqual(FadeCurve.easeOut(0.5), 0.75, accuracy: 0.000_1)
        XCTAssertEqual(FadeCurve.easeOut(-3), 0)
        XCTAssertEqual(FadeCurve.easeOut(3), 1)
        var previous: Float = 0
        var cursor: Float = 0
        while cursor <= 1 {
            let value = FadeCurve.easeOut(cursor)
            XCTAssertGreaterThanOrEqual(value, previous)
            // Always ahead of the smooth curve: the bed is there sooner.
            XCTAssertGreaterThanOrEqual(value, FadeCurve.unity(cursor) - 0.000_01)
            previous = value
            cursor += 0.01
        }
        XCTAssertEqual(FadeCurve.shaped(0.5, shape: FadeShape.easeOut), 0.75, accuracy: 0.000_1)
        XCTAssertEqual(FadeCurve.shaped(0.5, shape: FadeShape.smooth), 0.5, accuracy: 0.000_1)
        XCTAssertEqual(FadeCurve.shaped(0.5, shape: 99), 0.5, accuracy: 0.000_1, "an unknown shape is the smooth one")
    }

    // MARK: Play

    func testPlayRisesInEightTenthsOfASecondEasingOut() {
        for rate in [Double(44_100), 48_000] {
            var state = RenderState(sampleRate: Float(rate))
            let ramp = PlaybackFade.samples(PlaybackFade.start, sampleRate: rate)
            let start = command(target: 1, ramp: ramp, shape: FadeShape.easeOut, generation: 1)
            // The steepest the curve ever is: its first sample.
            let steepest = 2 / Float(ramp) + 0.000_001
            let slack = Int(ramp) / 200

            var previous: Float = 0
            for index in 0..<Int(ramp) {
                let frame = state.processStereo(start)
                XCTAssertFalse(frame.left.isNaN || frame.right.isNaN)
                let step = state.envelope - previous
                XCTAssertGreaterThanOrEqual(step, -0.000_001, "rate \(rate), sample \(index): it only rises")
                XCTAssertLessThanOrEqual(step, steepest, "rate \(rate), sample \(index): no step")
                previous = state.envelope
                if index == Int(ramp) / 2 - 1 {
                    XCTAssertEqual(state.envelope, 0.75, accuracy: 0.001, "rate \(rate): three quarters at half time")
                }
                if index == Int(ramp) - slack {
                    XCTAssertLessThan(state.envelope, 1, "rate \(rate): not there early")
                }
            }
            // The progress is a sum of float steps, so the last sample of the
            // fade may fall a few samples either side of the count.
            for _ in 0..<slack { _ = state.processStereo(start) }
            XCTAssertEqual(state.envelope, 1, "rate \(rate): full at the end of the ramp")
            // It stays there.
            for _ in 0..<1_000 { _ = state.processStereo(start) }
            XCTAssertEqual(state.envelope, 1)
        }
    }

    func testTheStartIsHeardInTheFirstTenthOfASecond() {
        // One touch and it sounds: after 100 ms the smooth curve the engine
        // used before would still be under 5 % of the level.
        var state = RenderState(sampleRate: 48_000)
        let start = command(target: 1, ramp: 38_400, shape: FadeShape.easeOut, generation: 1)
        for _ in 0..<4_800 { _ = state.processStereo(start) }
        XCTAssertGreaterThan(state.envelope, 0.2)
        XCTAssertGreaterThan(state.outputMeter.rms, 0)
    }

    // MARK: Pause

    func testPauseLeavesInOneAndAHalfSecondsWithoutAStep() {
        for rate in [Double(44_100), 48_000] {
            var state = RenderState(sampleRate: Float(rate))
            let playing = command(target: 1, ramp: 1, shape: FadeShape.smooth, generation: 1)
            for _ in 0..<Int(rate) { _ = state.processStereo(playing) }
            XCTAssertEqual(state.envelope, 1)
            let level = state.outputMeter.rms
            XCTAssertGreaterThan(level, 0.01)

            let ramp = PlaybackFade.samples(PlaybackFade.pause, sampleRate: rate)
            let pause = command(target: 0, ramp: ramp, shape: FadeShape.smooth, generation: 2)
            // Smoothstep is steepest in the middle: 1.5 / samples.
            let steepest = 1.5 / Float(ramp) + 0.000_001
            let oldCut = PlaybackFade.samples(0.04, sampleRate: rate)
            let slack = Int(ramp) / 200

            var previous = state.envelope
            for index in 0..<Int(ramp) {
                _ = state.processStereo(pause)
                let step = previous - state.envelope
                XCTAssertGreaterThanOrEqual(step, -0.000_001, "rate \(rate), sample \(index): it only falls")
                XCTAssertLessThanOrEqual(step, steepest, "rate \(rate), sample \(index): no step")
                previous = state.envelope
                if index == Int(oldCut) - 1 {
                    XCTAssertGreaterThan(state.envelope, 0.99, "rate \(rate): 40 ms in, the bed is still whole")
                }
                if index == Int(ramp) / 2 - 1 {
                    XCTAssertEqual(state.envelope, 0.5, accuracy: 0.001, "rate \(rate): half way at half time")
                    XCTAssertGreaterThan(state.outputMeter.rms, level * 0.2, "rate \(rate): still heard")
                }
                if index == Int(ramp) - slack {
                    XCTAssertGreaterThan(state.envelope, 0, "rate \(rate): not silent early")
                }
            }
            for _ in 0..<slack { _ = state.processStereo(pause) }
            XCTAssertEqual(state.envelope, 0, "rate \(rate): silent at the end of the ramp")
            let frame = state.processStereo(pause)
            XCTAssertEqual(frame.left, 0)
            XCTAssertEqual(frame.right, 0)
        }
    }

    func testPlayDuringAPauseRisesFromWhereTheBedWas() {
        var state = RenderState(sampleRate: 48_000)
        let playing = command(target: 1, ramp: 1, shape: FadeShape.smooth, generation: 1)
        for _ in 0..<4_800 { _ = state.processStereo(playing) }

        let pause = command(target: 0, ramp: 72_000, shape: FadeShape.smooth, generation: 2)
        for _ in 0..<36_000 { _ = state.processStereo(pause) }
        let reached = state.envelope
        XCTAssertEqual(reached, 0.5, accuracy: 0.001)

        // Play again half way down: the new fade starts at that level.
        let again = command(target: 1, ramp: 38_400, shape: FadeShape.easeOut, generation: 3)
        _ = state.processStereo(again)
        XCTAssertEqual(state.envelope, reached, accuracy: 0.001, "no jump at the turn")
        var previous = state.envelope
        for _ in 1..<38_600 {
            _ = state.processStereo(again)
            XCTAssertGreaterThanOrEqual(state.envelope, previous - 0.000_001)
            previous = state.envelope
        }
        XCTAssertEqual(state.envelope, 1)
    }

    func testALostOutputCutsTheTailOfAPauseShort() {
        // The person pauses (1.5 s) and takes the earbuds out 0.3 s later:
        // the rest of the tail must not be heard from the speaker. The short
        // fade starts where the bed is and reaches silence in 40 ms.
        var state = RenderState(sampleRate: 48_000)
        let playing = command(target: 1, ramp: 1, shape: FadeShape.smooth, generation: 1)
        for _ in 0..<4_800 { _ = state.processStereo(playing) }

        let pause = command(
            target: 0, ramp: PlaybackFade.samples(PlaybackFade.pause, sampleRate: 48_000),
            shape: FadeShape.smooth, generation: 2
        )
        for _ in 0..<14_400 { _ = state.processStereo(pause) }
        let reached = state.envelope
        XCTAssertGreaterThan(reached, 0.85, "0.3 s into the pause the bed is nearly whole")

        let ramp = PlaybackFade.samples(PlaybackFade.lostOutput, sampleRate: 48_000)
        XCTAssertEqual(ramp, 1_920)
        let cut = command(target: 0, ramp: ramp, shape: FadeShape.smooth, generation: 3)
        // Smoothstep from `reached`: steepest in the middle.
        let steepest = 1.5 * reached / Float(ramp) + 0.000_001
        var previous = reached
        for index in 0..<Int(ramp) {
            _ = state.processStereo(cut)
            let step = previous - state.envelope
            XCTAssertGreaterThanOrEqual(step, -0.000_001, "sample \(index): it only falls")
            XCTAssertLessThanOrEqual(step, steepest, "sample \(index): no step")
            previous = state.envelope
        }
        for _ in 0..<Int(ramp) / 200 + 1 { _ = state.processStereo(cut) }
        XCTAssertEqual(state.envelope, 0, "silent 40 ms after the output went away")
        let frame = state.processStereo(cut)
        XCTAssertEqual(frame.left, 0)
        XCTAssertEqual(frame.right, 0)
    }

    func testAGainUpdateCarriesTheFadeAndItsShapeUnchanged() {
        // Every other publish repeats the last envelope request. The render
        // state must not start it again, whatever shape it names.
        var state = RenderState(sampleRate: 48_000)
        let start = command(target: 1, ramp: 38_400, shape: FadeShape.easeOut, generation: 1)
        for _ in 0..<19_200 { _ = state.processStereo(start) }
        XCTAssertEqual(state.envelope, 0.75, accuracy: 0.001)

        var louder = start
        louder.gains = .uniform(0.6)
        louder.generation = 2
        _ = state.processStereo(louder)
        XCTAssertEqual(state.envelope, 0.75, accuracy: 0.001)
        XCTAssertEqual(state.fadeShape, FadeShape.easeOut)
        for _ in 0..<19_400 { _ = state.processStereo(louder) }
        XCTAssertEqual(state.envelope, 1)
    }

    func testAFreshStartForgetsTheShapeOfTheLastFade() {
        var state = RenderState(sampleRate: 48_000)
        let start = command(target: 1, ramp: 100, shape: FadeShape.easeOut, generation: 1)
        for _ in 0..<50 { _ = state.processStereo(start) }
        state.resetForFreshStart()
        XCTAssertEqual(state.envelope, 0)
        XCTAssertEqual(state.fadeShape, FadeShape.smooth)
    }
}
