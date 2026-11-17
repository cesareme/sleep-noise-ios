import XCTest
@testable import SleepNoise

/// One Small Hours session against a clock the test moves (C05, C60).
@MainActor
final class SmallHoursControllerTests: XCTestCase {
    private final class Log {
        var tides: [BreathParameters] = []
        var fades: [TimeInterval] = []
        var completed = 0
    }

    private let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func make(
        _ recipe: SmallHoursRecipe = .standard
    ) -> (SmallHoursController, TestClock, Log) {
        let clock = TestClock(start)
        let log = Log()
        let session = SmallHoursController(recipe: recipe, now: { clock.now }, ticks: false)
        session.onTide = { log.tides.append($0) }
        session.onFade = { log.fades.append($0) }
        session.onComplete = { log.completed += 1 }
        return (session, clock, log)
    }

    private func run(_ session: SmallHoursController, _ clock: TestClock, seconds: Int) {
        for _ in 0..<seconds {
            clock.now += 1
            session.tick()
        }
    }

    func testTheWholeSessionFollowsTheRecipe() {
        let (session, clock, log) = make()
        XCTAssertFalse(session.isActive)
        XCTAssertEqual(session.minutesLeft, 0)

        session.begin()
        XCTAssertTrue(session.isActive)
        XCTAssertFalse(session.isPaused)
        XCTAssertEqual(session.minutesLeft, 20)
        XCTAssertNil(session.windingDownMinutes)
        XCTAssertEqual(session.phase, .tideGuiding)
        XCTAssertEqual(session.fadeLevel, 1)
        // The tide guides from the first second: 8 breaths a minute, at
        // full weight, from the top of an inhale.
        XCTAssertEqual(log.tides.count, 1)
        XCTAssertEqual(log.tides[0].rate, 8.0 / 60, accuracy: 0.000_01)
        XCTAssertEqual(log.tides[0].weight, 1)
        XCTAssertEqual(log.tides[0].dissolveSeconds, 0)
        XCTAssertNotEqual(log.tides[0].epoch, 0)
        XCTAssertEqual(session.tideAnchor, start)

        // Minute 10.5: it starts to leave, and is gone by minute 13.
        run(session, clock, seconds: 629)
        XCTAssertEqual(log.tides.count, 1)
        XCTAssertEqual(session.minutesLeft, 10)
        run(session, clock, seconds: 1)
        XCTAssertEqual(log.tides.count, 2)
        XCTAssertEqual(log.tides[1].weight, 0)
        XCTAssertEqual(log.tides[1].dissolveSeconds, 150, "from minute 10.5 to minute 13")
        XCTAssertEqual(log.tides[1].rate, log.tides[0].rate, "the breath keeps its pace while it leaves")
        XCTAssertEqual(log.tides[1].epoch, log.tides[0].epoch, "and its place in the cycle")
        XCTAssertEqual(session.phase, .tideDissolving)

        run(session, clock, seconds: 150)
        XCTAssertEqual(session.phase, .plainSea)
        XCTAssertNotNil(session.tideAnchor, "the render side is still settling it")
        run(session, clock, seconds: Int(SmallHoursController.tideTail))
        XCTAssertEqual(log.tides.count, 3)
        XCTAssertEqual(log.tides[2], .off)
        XCTAssertNil(session.tideAnchor)

        // The last five minutes: the sea fades, and the screen counts them.
        run(session, clock, seconds: 900 - 786 - 1)
        XCTAssertEqual(log.fades, [])
        XCTAssertNil(session.windingDownMinutes)
        XCTAssertEqual(session.minutesLeft, 6)
        run(session, clock, seconds: 1)
        XCTAssertEqual(log.fades, [300])
        XCTAssertEqual(session.phase, .windingDown)
        XCTAssertEqual(session.windingDownMinutes, 5)
        XCTAssertEqual(session.minutesLeft, 5)
        run(session, clock, seconds: 150)
        XCTAssertEqual(session.fadeLevel, 0.5, accuracy: 0.000_1)
        XCTAssertEqual(session.windingDownMinutes, 3)
        run(session, clock, seconds: 149)
        XCTAssertEqual(session.windingDownMinutes, 1)
        XCTAssertEqual(log.completed, 0)
        XCTAssertEqual(log.fades.count, 1, "the engine counts the fade")

        // Minute 20: it is over, and nothing is said about it.
        run(session, clock, seconds: 1)
        XCTAssertEqual(log.completed, 1)
        XCTAssertFalse(session.isActive)
        XCTAssertEqual(session.minutesLeft, 0)
        XCTAssertNil(session.windingDownMinutes)
        XCTAssertEqual(log.tides.count, 3, "nothing more is asked of the tide")
        // And it does not come back by itself.
        run(session, clock, seconds: 600)
        XCTAssertEqual(log.completed, 1)
        XCTAssertFalse(session.isActive)
    }

    func testTheFiguresMoveByTheMinute() {
        let (session, clock, _) = make()
        var published = 0
        let watch = session.objectWillChange.sink { published += 1 }
        defer { watch.cancel() }
        session.begin()
        let afterBegin = published
        run(session, clock, seconds: 59)
        XCTAssertEqual(published, afterBegin, "a minute without a change publishes nothing")
        XCTAssertEqual(session.minutesLeft, 20)
        run(session, clock, seconds: 1)
        XCTAssertEqual(session.minutesLeft, 19)
        XCTAssertEqual(published, afterBegin + 1)
    }

    func testTheRecipePlaysForEveryone() {
        let (session, _, _) = make()
        for access in [false, true] {
            let gains = session.gains(hasFullAccess: access)
            XCTAssertEqual(gains.ocean, 0.3, "the ocean of the recipe, with or without Pro")
            for sound in SoundID.allCases where sound != .ocean {
                XCTAssertEqual(gains.value(for: sound), 0, "\(sound.rawValue): nothing of the mix")
            }
        }
    }

    func testAPauseStopsTheClockOfTheSession() {
        let (session, clock, log) = make()
        session.begin()
        run(session, clock, seconds: 300)
        session.pause()
        XCTAssertTrue(session.isPaused)
        XCTAssertTrue(session.isActive)
        XCTAssertEqual(session.elapsed, 300)
        // Ten minutes go by: none of them count.
        run(session, clock, seconds: 600)
        XCTAssertEqual(session.elapsed, 300)
        XCTAssertEqual(session.minutesLeft, 15)
        XCTAssertEqual(log.tides.count, 1)

        session.resume(risingOver: 3)
        XCTAssertFalse(session.isPaused)
        XCTAssertEqual(session.elapsed, 300, accuracy: 0.001)
        // Still inside the guide: the tide starts again from an inhale.
        XCTAssertEqual(log.tides.count, 2)
        XCTAssertEqual(log.tides[1].weight, 1)
        XCTAssertNotEqual(log.tides[1].epoch, log.tides[0].epoch)
        XCTAssertEqual(session.tideAnchor, clock.now)
        run(session, clock, seconds: 329)
        XCTAssertEqual(log.tides.count, 2)
        run(session, clock, seconds: 1)
        XCTAssertEqual(log.tides.count, 3, "minute 10.5 of the session, not of the clock")
        XCTAssertEqual(log.tides[2].dissolveSeconds, 150)
    }

    func testResumingWhileTheTideWasLeavingDoesNotBringItBack() {
        let (session, clock, log) = make()
        session.begin()
        run(session, clock, seconds: 700)
        XCTAssertEqual(session.phase, .tideDissolving)
        session.pause()
        session.resume(risingOver: 3)
        XCTAssertEqual(log.tides.last, .off)
        XCTAssertNil(session.tideAnchor)
        let count = log.tides.count
        run(session, clock, seconds: 200)
        XCTAssertEqual(log.tides.count, count, "the plain sea, to the end")
    }

    func testResumingInsideTheClosingFadeRisesToWhereItStands() {
        let (session, clock, log) = make()
        session.begin()
        run(session, clock, seconds: 1_050)
        XCTAssertEqual(log.fades, [300])
        XCTAssertEqual(session.fadeLevel, 0.5, accuracy: 0.000_1)
        session.pause()
        clock.now += 240
        XCTAssertEqual(session.fadeLevel, 0.5, accuracy: 0.000_1)

        session.resume(risingOver: 3)
        XCTAssertEqual(session.windingDownMinutes, 3)
        // The sea takes three seconds to come back: the fade is asked for
        // again only once it is there.
        run(session, clock, seconds: 3)
        XCTAssertEqual(log.fades.count, 1)
        run(session, clock, seconds: 1)
        XCTAssertEqual(log.fades.count, 2)
        XCTAssertEqual(log.fades[1], 146, accuracy: 0.001)
        run(session, clock, seconds: 146)
        XCTAssertEqual(log.completed, 1)
    }

    func testEndingItEarlyCallsNothingBack() {
        let (session, clock, log) = make()
        session.begin()
        run(session, clock, seconds: 100)
        session.end()
        XCTAssertFalse(session.isActive)
        XCTAssertFalse(session.isPaused)
        XCTAssertNil(session.tideAnchor)
        XCTAssertEqual(session.minutesLeft, 0)
        XCTAssertEqual(session.tide, .off)
        run(session, clock, seconds: 2_000)
        XCTAssertEqual(log.completed, 0)
        XCTAssertEqual(log.fades, [])
        XCTAssertEqual(log.tides.count, 1, "whoever ends it silences the tide")

        // Beginning again is a whole new session.
        session.begin()
        XCTAssertEqual(session.minutesLeft, 20)
        XCTAssertEqual(session.elapsed, 0)
        XCTAssertNotEqual(log.tides[1].epoch, log.tides[0].epoch)
    }

    func testItsEpochsNeverMeetThoseOfTheGuide() {
        // The guide of the mixer counts from 1; Small Hours from far away.
        let (session, _, log) = make()
        session.begin()
        XCTAssertGreaterThan(log.tides[0].epoch, 1_000_000)
    }
}

/// The key points of the recipe, rendered offline: the entrance, the tide
/// leaving, the closing fade and the silence after it. A short recipe with
/// the same shape as the real one stands in for the twenty minutes; every
/// command reaches the render state through the session and the engine's
/// own bookkeeping, second by second.
@MainActor
final class SmallHoursRenderTests: XCTestCase {
    /// 60 s: entrance 3 s, tide until 30 s and gone by 40 s, fade from 45 s.
    private let short = SmallHoursRecipe(
        sound: .ocean,
        level: SmallHoursRecipe.standard.level,
        breathsPerMinute: SmallHoursRecipe.standard.breathsPerMinute,
        duration: 60,
        fadeIn: SmallHoursRecipe.standard.fadeIn,
        tideGuideEnd: 30,
        tideDissolveEnd: 40,
        finalFade: 15
    )

    func testTheSessionAsItIsHeard() throws {
        let clock = TestClock(Date(timeIntervalSinceReferenceDate: 800_000_000))
        let engine = OfflineEngine()
        let session = SmallHoursController(recipe: short, now: { clock.now }, ticks: false)
        var finished = false
        session.onTide = { engine.setBreathing($0) }
        session.onFade = { engine.fadeOut(over: $0) }
        session.onComplete = {
            engine.stop(fadeOut: 0.05)
            finished = true
        }

        // What the model does on "Small hours": the tide first, then the
        // engine with the recipe's gains and its three second entrance.
        session.begin()
        try engine.start(gains: session.gains(hasFullAccess: false), fadeIn: short.fadeIn, level: session.fadeLevel)
        XCTAssertEqual(engine.gains.ocean, 0.3)

        var levels: [Float] = []
        var envelopes: [Float] = []
        var weights: [Float] = []
        func second() {
            levels.append(engine.render(seconds: 1))
            envelopes.append(engine.envelope)
            weights.append(engine.state.breathWeight)
            clock.now += 1
            session.tick()
        }

        // The entrance: three seconds, rising all the way, heard at once.
        for _ in 0..<3 { second() }
        XCTAssertGreaterThan(levels[0], 0, "the sea is there in the first second")
        XCTAssertGreaterThan(envelopes[0], 0.5, "easing out: most of it early")
        XCTAssertLessThan(envelopes[0], 1)
        XCTAssertLessThan(envelopes[1], 1, "not a fade of one second")
        XCTAssertEqual(envelopes[2], 1, "whole at three seconds")
        XCTAssertEqual(weights[0], 1, "the tide guides from the first inhale")

        // The tide guides: the sea rises and falls with the breath.
        for _ in 3..<30 { second() }
        XCTAssertEqual(weights[29], 1, accuracy: 0.001)
        let guided = levels[8..<30]
        XCTAssertGreaterThan(try XCTUnwrap(guided.max()) / max(try XCTUnwrap(guided.min()), 0.000_01), 1.5)

        // It leaves between 30 s and 40 s, without a step.
        for _ in 30..<47 { second() }
        for index in 31..<46 {
            XCTAssertLessThanOrEqual(weights[index], weights[index - 1] + 0.000_1, "second \(index)")
        }
        XCTAssertLessThan(weights[35], 0.75)
        XCTAssertGreaterThan(weights[35], 0.25)
        XCTAssertLessThan(weights[46], 0.02, "the plain sea")
        XCTAssertEqual(envelopes[44], 1, "and the sea is still whole")

        // The closing fade: fifteen seconds here, five minutes in the recipe.
        for _ in 47..<52 { second() }
        XCTAssertEqual(engine.state.envelopeRamp.total, UInt32(15 * 48_000), "counted in whole samples")
        XCTAssertEqual(engine.state.envelopeRamp.done, UInt32(7 * 48_000))
        for _ in 52..<60 { second() }
        for index in 46..<60 {
            XCTAssertLessThanOrEqual(envelopes[index], envelopes[index - 1], "second \(index): it only falls")
        }
        XCTAssertEqual(envelopes[52], FadeCurve.outputGain(progress: 8.0 / 15), accuracy: 0.01)
        XCTAssertLessThan(levels[58], levels[44] * 0.25)
        XCTAssertEqual(envelopes[59], 0, "silent at the end of the session")
        XCTAssertTrue(finished)

        // After it: nothing. The engine stops and stays stopped.
        engine.render(seconds: 1)
        XCTAssertFalse(engine.isRunning)
        XCTAssertEqual(engine.breath, .off)
        XCTAssertEqual(engine.smoothedOutputRMS(tau: 0.5), 0)
    }

    /// The level of the real recipe: low. The same ocean at the level the
    /// house mix "Sea and wind" carries it is clearly louder.
    func testTheSeaOfTheRecipeIsLow() throws {
        func level(_ ocean: Float) throws -> Float {
            let engine = OfflineEngine()
            var gains = SoundGains.zero
            gains.ocean = ocean
            try engine.start(gains: gains, fadeIn: 0.03, level: 1)
            engine.render(seconds: 2)
            return engine.render(seconds: 20)
        }
        let recipe = try level(SmallHoursRecipe.standard.level)
        let house = try level(try XCTUnwrap(HouseMix.seaAndWind.levelsBySound()[.ocean]))
        XCTAssertGreaterThan(recipe, 0.001)
        XCTAssertLessThan(recipe, house * 0.75)
    }
}
