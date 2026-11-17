import XCTest
@testable import SleepNoise

// What the review of the night package (S-06) found, pinned down: each test
// here failed, or could not be written, before its correction.

// MARK: - The engine's own decisions

final class EngineControlTests: XCTestCase {
    func testAStartThatFailsAtRestLeavesNoRestartPending() {
        var control = EngineControl()
        XCTAssertEqual(control.startFailed(isRendering: false), .releaseSession)
        XCTAssertFalse(control.wantsRunning)
        XCTAssertFalse(control.shouldRestart(isRendering: false), "a configuration change starts nothing")
    }

    func testAStartThatFailsDuringTheTailOfAStopLetsTheStopFinish() {
        var control = EngineControl()
        control.started()
        let token = control.stopRequested()
        XCTAssertTrue(control.isStopping(isRendering: true))
        XCTAssertEqual(control.startFailed(isRendering: true), .waitForStop)
        XCTAssertTrue(control.stopIsDue(token), "the stop that was waiting still pauses the engine")
        XCTAssertFalse(control.shouldRestart(isRendering: false))
    }

    func testAStartThatFailsOverSomethingThatSoundsStopsIt() {
        var control = EngineControl()
        control.started()
        XCTAssertEqual(control.startFailed(isRendering: true), .stopWhatSounds)
        XCTAssertFalse(control.wantsRunning)
    }

    func testAStartCallsOffTheStopThatWasWaiting() {
        var control = EngineControl()
        control.started()
        let token = control.stopRequested()
        control.started()
        XCTAssertFalse(control.stopIsDue(token))
        XCTAssertTrue(control.shouldRestart(isRendering: false), "the system stopped it: it comes back")
        XCTAssertFalse(control.shouldRestart(isRendering: true))
        control.invalidated()
        XCTAssertFalse(control.shouldRestart(isRendering: false))
    }

    func testTheMasterIsOnlyEverSimplyThereWhenNothingCanBeHeard() {
        var control = EngineControl()
        XCTAssertEqual(control.masterRamp(over: 60, sampleRate: 48_000, isRendering: false), 1)
        control.started()
        // Wanted, and the system has the engine stopped for a moment: the
        // level must not be a step when it restarts.
        XCTAssertEqual(control.masterRamp(over: 0, sampleRate: 48_000, isRendering: false), 2_400)
        XCTAssertEqual(control.masterRamp(over: 0, sampleRate: 48_000, isRendering: true), 2_400)
        XCTAssertEqual(control.masterRamp(over: 60, sampleRate: 48_000, isRendering: true), 2_880_000)
        _ = control.stopRequested()
        XCTAssertEqual(control.masterRamp(over: 0, sampleRate: 48_000, isRendering: true), 2_400, "the tail of a stop")
        XCTAssertEqual(control.masterRamp(over: 0, sampleRate: 48_000, isRendering: false), 1)
    }

    func testAStartRisesOverThirtyMillisecondsAtLeast() {
        XCTAssertEqual(EngineControl.startRamp(fadeIn: 0, sampleRate: 48_000), 1_440)
        XCTAssertEqual(EngineControl.startRamp(fadeIn: 0.8, sampleRate: 44_100), 35_280)
        XCTAssertTrue(EngineControl().startsFromSilence(isRendering: false))
        XCTAssertFalse(EngineControl().startsFromSilence(isRendering: true))
    }

    /// The offline engine takes its decisions with the same value: a session
    /// that refuses leaves nothing for a configuration change to start.
    func testTheEngineOfTheTestsFollowsTheSameRules() throws {
        let engine = OfflineEngine()
        engine.failsToStart = true
        XCTAssertThrowsError(try engine.start(gains: .zero, fadeIn: 0.8, level: 1))
        XCTAssertFalse(engine.isRunning)
        XCTAssertFalse(engine.sessionIsActive)
        engine.configurationChanged()
        XCTAssertFalse(engine.isRunning, "nothing was left wanted")

        engine.failsToStart = false
        try engine.start(gains: .zero, fadeIn: 0.8, level: 1)
        engine.systemStops()
        engine.setMaster(0.5, over: 0)
        XCTAssertEqual(engine.desk.command.masterRampSamples, 2_400, "a ramp, though nothing renders this instant")
        engine.configurationChanged()
        XCTAssertTrue(engine.isRunning, "a night that plays comes back")
    }
}

// MARK: - Rule 4.8: a change of rate does not restart a fade

final class SampleRateChangeTests: XCTestCase {
    func testARampKeepsItsPlaceAndItsSecondsAcrossARateChange() {
        var ramp = SampleRamp(1)
        ramp.begin(to: 0, samples: 480_000)
        for _ in 0..<240_000 { ramp.advance() }
        let value = ramp.value
        XCTAssertEqual(value, 0.5, accuracy: 0.000_01)

        ramp.rescale(by: 44_100.0 / 48_000.0)
        XCTAssertEqual(ramp.value, value, "the value does not move")
        XCTAssertEqual(ramp.to, 0)
        XCTAssertEqual(ramp.total, 441_000, "ten seconds at the new rate")
        XCTAssertEqual(ramp.done, 220_500, "half of it done")
        for _ in 0..<220_499 { ramp.advance() }
        XCTAssertTrue(ramp.isRunning)
        ramp.advance()
        XCTAssertEqual(ramp.value, 0)
        XCTAssertFalse(ramp.isRunning, "five seconds of the new samples later")

        // A ramp that is not running has nothing to keep.
        var still = SampleRamp(0.4)
        still.rescale(by: 2)
        XCTAssertEqual(still, SampleRamp(0.4))
    }

    func testPrepareKeepsTheEnvelopeAndTheMasterWhereTheyWere() {
        var state = RenderState(sampleRate: 48_000)
        var desk = CommandDesk()
        desk.fadeEnvelope(to: 1, samples: 1)
        desk.rampMaster(to: 1, samples: 1)
        _ = state.processStereo(desk.command)
        desk.fadeEnvelope(to: 0, samples: 480_000)
        desk.rampMaster(to: 0.5, samples: 480_000)
        let command = desk.command
        for _ in 0..<240_000 { _ = state.processStereo(command) }
        let (envelope, master) = (state.envelope, state.master)

        state.prepare(sampleRate: 44_100)
        XCTAssertEqual(state.envelope, envelope)
        XCTAssertEqual(state.master, master)
        XCTAssertEqual(state.envelopeRamp.to, 0)
        XCTAssertEqual(state.masterRamp.to, 0.5)
        XCTAssertEqual(state.envelopeRamp.total - state.envelopeRamp.done, 220_500, "five seconds left")
        XCTAssertEqual(state.masterRamp.total - state.masterRamp.done, 220_500)
        // The same command again: nothing is asked for a second time.
        for _ in 0..<220_500 { _ = state.processStereo(command) }
        XCTAssertEqual(state.envelope, 0)
        XCTAssertEqual(state.master, 0.5)
    }

    func testARouteChangeInsideAFadeNeitherRestartsNorStretchesIt() throws {
        let engine = OfflineEngine()
        try engine.start(gains: .zero, fadeIn: 0.03, level: 1)
        engine.render(seconds: 0.1)
        engine.fade(to: 0, over: 10)
        engine.render(seconds: 5)
        let half = engine.envelope
        let asked = engine.desk.command.envelopeGeneration

        engine.hardwareRate = 44_100
        try engine.retargetSampleRateIfNeeded(gains: .zero)
        XCTAssertEqual(engine.sampleRate, 44_100)
        XCTAssertTrue(engine.isRunning, "the night goes on, on the new rate")
        XCTAssertEqual(engine.desk.command.envelopeGeneration, asked, "no fade was asked for again")
        XCTAssertEqual(engine.envelope, half)

        engine.render(seconds: 4.9)
        XCTAssertGreaterThan(engine.envelope, 0, "not early")
        engine.render(seconds: 0.11)
        XCTAssertEqual(engine.envelope, 0, "and on time: the clock of the timer and the audio agree")
    }
}

// MARK: - The tide lets go over a whole number of samples

final class LongDissolveTests: XCTestCase {
    /// The dissolve of the tide follows the final fade of the timer, up to
    /// fifteen minutes. Added as a float step it never left 1 from 700 s up
    /// at 48 kHz: the tide guided at full depth while the page said it was
    /// letting go.
    func testAFifteenMinuteDissolveFallsAllTheWayAndEndsOnItsLastSample() {
        for rate in [Float(44_100), 48_000] {
            var state = RenderState(sampleRate: rate)
            var breath = BreathParameters()
            breath.weight = 1
            state.advanceBreath(breath)
            XCTAssertEqual(state.breathWeightTarget, 1)

            let step = 1 / (Float(900) * rate)
            XCTAssertEqual(Float(1) - step, 1, "the step the old dissolve subtracted is lost to rounding")

            breath.weight = 0
            breath.dissolveSeconds = 900
            let samples = Int(900 * rate)
            var previous = state.breathWeightTarget
            var rises = 0
            for index in 0..<(samples - 1) {
                state.advanceBreath(breath)
                let value = state.breathWeightTarget
                if value > previous { rises += 1 }
                previous = value
                if index == samples / 2 - 1 {
                    XCTAssertEqual(value, 0.5, accuracy: 0.000_01, "half way at half time, \(rate)")
                }
            }
            XCTAssertEqual(rises, 0, "\(rate)")
            XCTAssertGreaterThan(previous, 0, "one sample from the end it is still letting go, \(rate)")
            state.advanceBreath(breath)
            XCTAssertEqual(state.breathWeightTarget, 0, "\(rate)")
            XCTAssertFalse(state.breathWeightRamp.isRunning)
        }
    }

    func testAPartOfTheWayTakesThatPartOfTheDissolve() {
        var state = RenderState(sampleRate: 48_000)
        var breath = BreathParameters()
        breath.weight = 0.5
        state.advanceBreath(breath)
        breath.weight = 0
        breath.dissolveSeconds = 10
        state.advanceBreath(breath)
        XCTAssertEqual(state.breathWeightRamp.total, 240_000, "half the range, half the time")
        // A rate change in the middle keeps the place and the seconds.
        for _ in 0..<119_999 { state.advanceBreath(breath) }
        let value = state.breathWeightTarget
        state.prepare(sampleRate: 44_100)
        XCTAssertEqual(state.breathWeightTarget, value)
        XCTAssertEqual(state.breathWeightRamp.total, 220_500)
    }
}

// MARK: - The night, corrected

@MainActor
final class NightCorrectionTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func freshDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // MARK: Starts that fail

    /// C48: a call never ends the night. A touch on Play during the call
    /// fails, and must not cost the night the resume that call owes it.
    func testAPlayThatFailsDuringACallKeepsTheInterruptionOpen() throws {
        let night = try NightHarness(at: time(2))
        night.model.play()
        night.engine.render(seconds: 1)
        night.session.call(true)
        night.session.interrupt()
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.model.pauseCause, .call)

        night.engine.failsToStart = true
        night.model.play()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.startFailures, 1)
        // The engine was left with nothing pending either.
        night.engine.configurationChanged()
        XCTAssertFalse(night.engine.isRunning)

        // Twenty minutes later it is still the same night: the call holds it.
        night.advance(seconds: 25 * 60)
        XCTAssertEqual(night.model.pauseCause, .call, "not closed by the long pause")

        night.engine.failsToStart = false
        night.session.call(false)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying, "the call still owed the night its resume")
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 1))
        XCTAssertEqual(night.model.startFailures, 0)
    }

    func testAResumeNobodyAskedForNeverBeginsTheTrial() throws {
        let night = try NightHarness(at: time(2))
        XCTAssertEqual(night.model.playFromShortcut(), .started)
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.purchases.trialState, .notStarted)

        night.session.interrupt()
        night.engine.render(seconds: 1)
        night.advance(seconds: 60)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.purchases.trialState, .notStarted, "asleep, after a call: no trial begins")

        // The Disc is the person: that one does.
        night.model.pause()
        night.engine.render(seconds: 2)
        night.model.play()
        XCTAssertNotEqual(night.purchases.trialState, .notStarted)
    }

    // MARK: "+15 min" inside the fade

    /// A night that resumed inside its final fade stands below 1 until the
    /// fade is asked for again. "+15 min" in that second must bring the
    /// level back all the same.
    func testFifteenMoreBringsTheLevelBackBeforeTheFadeWasAskedForAgain() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.engine.render(seconds: 1)
        night.advance(seconds: 40 * 60)
        XCTAssertTrue(night.model.timer.isFading)
        night.model.pause()
        night.engine.render(seconds: 2)

        night.model.play()
        guard case .start(_, let level)? = night.engine.starts.last else { return XCTFail("no start") }
        XCTAssertLessThan(level, 0.6, "it rises to where the fade stands")
        XCTAssertTrue(night.model.timer.isFading)
        night.engine.forgetCalls()

        // No tick in between: the fade has not been asked for again.
        XCTAssertTrue(night.model.extendTimer())
        XCTAssertFalse(night.model.timer.isFading)
        XCTAssertEqual(night.engine.fades, [.fade(level: 1, seconds: 3)])
        night.engine.render(seconds: 3.1)
        XCTAssertEqual(night.engine.envelope, 1, "the fifteen minutes are heard at full level")
    }

    // MARK: Small Hours

    /// Paused past its twenty minutes while nothing ran to end it: the next
    /// Play, from the lock screen, is the mix in a new night.
    func testPlayAfterALongPauseOfSmallHoursIsTheMix() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        night.engine.render(seconds: 4)
        night.model.pause()
        night.engine.render(seconds: 2)

        // The app was suspended: nothing expired the night.
        night.jump(to: time(day: 18, 23))
        night.nowPlaying.pressPlay()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertEqual(night.engine.gains.ocean, 0, "not what was left of the recipe")
        XCTAssertGreaterThan(night.engine.gains.pink, 0)
        XCTAssertEqual(night.nowPlaying.title, HouseMix.pinkAndRain.localizedName)
        XCTAssertEqual(night.model.timer.endsAt, time(day: 18, 23, 45), "with the timer of the mix")
    }

    func testAShortPauseOfSmallHoursStillResumesIt() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        night.engine.render(seconds: 4)
        night.model.pause()
        night.jump(to: time(4, 10))
        night.nowPlaying.pressPlay()
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertTrue(night.model.isPlaying)
    }

    /// From a mix turned down in Night, Small Hours comes in at the level of
    /// a new night: over its three seconds, never in 50 ms.
    func testSmallHoursTakesOverWithoutAJumpOfLevel() throws {
        let night = try NightHarness(at: time(4))
        night.model.play()
        night.engine.render(seconds: 1)
        night.model.setSessionLevel(0.3)
        night.engine.render(seconds: 0.2)
        XCTAssertEqual(night.engine.master, 0.3, accuracy: 0.001)
        night.engine.forgetCalls()

        XCTAssertEqual(night.model.startSmallHours(), .started)
        XCTAssertEqual(night.model.sessionLevel, 1)
        XCTAssertEqual(night.engine.masters, [.master(level: 1, seconds: 3)])
        XCTAssertEqual(night.engine.desk.command.masterRampSamples, 144_000)
        night.engine.render(seconds: 0.05)
        XCTAssertLessThan(night.engine.master, 0.31, "50 ms in, nothing has jumped")
        night.engine.render(seconds: 3)
        XCTAssertEqual(night.engine.master, 1)
    }

    // MARK: The speaker cap

    private func lostEarbuds(at start: Date) throws -> NightHarness {
        let night = try NightHarness(at: start)
        night.session.currentRoute = ScriptedSession.airPods
        night.model.play()
        night.engine.render(seconds: 1)
        night.session.loseOutput()
        night.engine.render(seconds: 1)
        return night
    }

    func testTheCapOfALostOutputBelongsToThatNight() throws {
        // Later the same night, with that night already over: still capped.
        let late = try lostEarbuds(at: time(23))
        late.advance(seconds: 80 * 60)
        XCTAssertNil(late.model.pauseCause, "the night is over")
        late.model.play()
        XCTAssertEqual(late.model.sessionLevel, RoutePolicy.speakerMasterCap)

        // The next night it is a new night at full level.
        let next = try lostEarbuds(at: time(23))
        next.advance(seconds: 21 * 60)
        next.jump(to: time(day: 18, 22))
        next.model.play()
        XCTAssertEqual(next.model.sessionLevel, 1, "last night's earbuds say nothing about tonight")
        XCTAssertNil(next.model.cappedLevelNote)

        // Opened by day with the night over: forgotten at once.
        let morning = try lostEarbuds(at: time(6))
        morning.advance(seconds: 21 * 60)
        morning.jump(to: time(8))
        morning.model.appDidBecomeActive()
        morning.model.play()
        XCTAssertEqual(morning.model.sessionLevel, 1)
    }

    /// C49 on the page: the offer for a minute, and after a capped resume
    /// the level in words until the next touch.
    func testThePageSaysTheCappedLevelUntilTheNextTouch() throws {
        let night = try lostEarbuds(at: time(2))
        XCTAssertNotNil(night.model.speakerOfferUntil)
        XCTAssertNil(night.model.cappedLevelNote)

        night.model.continueOnSpeaker()
        XCTAssertEqual(night.model.sessionLevel, RoutePolicy.speakerMasterCap)
        XCTAssertEqual(night.model.cappedLevelNote, 40)
        let status = PageStatus.resolve(PageStatus.Input(
            isPlaying: true,
            timerEndsAt: night.model.timer.endsAt,
            cappedLevelNote: night.model.cappedLevelNote
        ))
        XCTAssertEqual(status, .playingAt(percent: 40))
        XCTAssertEqual(
            status.text(localized: { $0 == "estado.volumen" ? "Sonando · al %lld" : "?" }, locale: Locale(identifier: "es_ES")),
            "Sonando · al 40"
        )
        // Night says it too, without a drag.
        XCTAssertEqual(NightStatus.resolve(NightStatus.Input(night.model)), .level(percent: 40))

        night.model.beginLevelGesture()
        night.model.endLevelGesture()
        XCTAssertNil(night.model.cappedLevelNote, "a touch takes the note away")
        XCTAssertEqual(night.model.sessionLevel, RoutePolicy.speakerMasterCap, "not the level")

        // A resume that is not capped has nothing to say.
        night.model.pause()
        night.engine.render(seconds: 2)
        night.model.play()
        XCTAssertNil(night.model.cappedLevelNote)
        // The final fade outranks the note.
        XCTAssertEqual(
            PageStatus.resolve(.init(isPlaying: true, timerIsFading: true, timerRemaining: 300, cappedLevelNote: 40)),
            .fading(minutes: 5)
        )
    }

    // MARK: "Headphones" only when they are

    func testOnlyHeadphonesAreCalledHeadphones() throws {
        XCTAssertTrue(ScriptedSession.airPods.isHeadphones)
        XCTAssertFalse(OutputRoute.builtInSpeaker.isHeadphones)
        let room = OutputRoute.external(id: "living room", isHeadphones: false)
        XCTAssertFalse(room.isHeadphones)

        let night = try NightHarness(at: time(2))
        night.session.currentRoute = room
        night.model.play()
        night.engine.render(seconds: 1)

        // The lock screen pauses a speaker in the room: a pause like any other.
        night.nowPlaying.pressPause()
        XCTAssertEqual(night.model.pauseCause, .person)
        night.engine.render(seconds: 2)
        night.model.play()
        night.engine.render(seconds: 1)

        // AirPlay goes away: paused, and nothing says "headphones".
        night.session.loseOutput()
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        XCTAssertFalse(night.model.lostOutputWasHeadphones)
        XCTAssertEqual(NightStatus.resolve(NightStatus.Input(night.model)), .paused)
        XCTAssertEqual(
            PageStatus.resolve(.init(pauseCause: .lostOutput, lostOutputWasHeadphones: false)),
            .paused
        )
        XCTAssertNotNil(night.model.speakerOfferUntil, "the offer is the same")

        XCTAssertEqual(PageStatus.resolve(.init(pauseCause: .lostOutput)), .pausedHeadphones)
        XCTAssertEqual(PageStatus.resolve(.init(pauseCause: .headphones)), .pausedHeadphones)

        let earbuds = try lostEarbuds(at: time(2))
        XCTAssertTrue(earbuds.model.lostOutputWasHeadphones)
        XCTAssertEqual(NightStatus.resolve(NightStatus.Input(earbuds.model)), .pausedHeadphones)
    }

    // MARK: What a launch finds

    func testTheFirstMixKeepsItsNameAcrossARestart() throws {
        let defaults = try freshDefaults()
        let first = try NightHarness(at: time(23), defaults: defaults)
        XCTAssertEqual(first.model.activeHouseMix, .pinkAndRain)
        // A row touched and let go without moving: only the levels are written.
        first.model.beginLevelGesture()
        first.model.endLevelGesture()

        let second = try NightHarness(at: time(23), defaults: defaults)
        XCTAssertEqual(second.model.activeHouseMix, .pinkAndRain)
        XCTAssertEqual(second.model.loadedMixName, first.model.loadedMixName)
        XCTAssertNotNil(second.model.loadedMixName)
        XCTAssertEqual(second.model.timer.choice, .firstUse, "and the timer of the first night stands")
        XCTAssertNil(MixerModel.storedTimer(defaults: defaults), "still not a choice")
    }

    /// Before this version no timer meant "Off". Whoever updates must not
    /// find a night that fades by itself after 45 minutes.
    func testAnInstallThatHadNoTimerStaysOff() throws {
        let defaults = try freshDefaults()
        // The levels of an earlier version, and nothing about a timer.
        _ = try NightHarness(at: time(23), defaults: defaults)
        defaults.removeObject(forKey: MixerModel.timerFirstUseKey)
        defaults.removeObject(forKey: MixerModel.timerKey)

        let updated = try NightHarness(at: time(23), defaults: defaults)
        XCTAssertEqual(updated.model.timer.choice, .off)
        XCTAssertEqual(MixerModel.storedTimer(defaults: defaults), .off, "kept as the choice it was")
        updated.model.play()
        XCTAssertNil(updated.model.timer.endsAt)
        XCTAssertFalse(updated.model.canExtendTimer)

        // A length chosen there is still read.
        let legacy = try freshDefaults()
        _ = try NightHarness(at: time(23), defaults: legacy)
        legacy.removeObject(forKey: MixerModel.timerFirstUseKey)
        legacy.set(90, forKey: MixerModel.legacyTimerKey)
        XCTAssertEqual(try NightHarness(at: time(23), defaults: legacy).model.timer.choice, .untilAsleep(90))

        // And a new install gets the timer of the first night, every launch.
        let new = try freshDefaults()
        XCTAssertEqual(try NightHarness(at: time(23), defaults: new).model.timer.choice, .firstUse)
        XCTAssertEqual(try NightHarness(at: time(23), defaults: new).model.timer.choice, .firstUse)
    }

    // MARK: The screen sleeps once the night is over

    func testNightOnlyHoldsTheScreenWhileANightIsOpen() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        XCTAssertTrue(night.model.bedtimeKeepsScreenAwake(isCharging: true))
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: false), "the default: only while it charges")

        night.model.pause()
        XCTAssertTrue(night.model.bedtimeKeepsScreenAwake(isCharging: true), "paused, the night is still open")
        night.model.play()

        // The timer runs out. Night is still in front, saying "Ended at".
        night.advance(seconds: 45 * 60 + 1)
        XCTAssertTrue(night.model.isBedtime)
        XCTAssertNotNil(night.model.sessionEndedAt)
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: true), "on its charger all morning: it sleeps")
        night.model.setKeepScreenOn(.always)
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: false), "\"Always\" is while the night lasts")
    }

    // MARK: The tide on the model's clock

    func testAnInterruptionInsideTheWindowOfTheTideGoesOnWithIt() throws {
        let night = try NightHarness(at: time(2))
        night.model.setBreathingEnabled(true)
        night.model.play()
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.model.breathing.guideEndsAt, time(2, 15))
        XCTAssertEqual(night.model.breathing.phase, .guiding)

        night.advance(seconds: 5 * 60)
        night.session.interrupt()
        XCTAssertEqual(night.model.breathing.phase, .idle)
        night.engine.render(seconds: 1)
        night.advance(seconds: 60)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.breathing.phase, .guiding, "the same window")
        XCTAssertEqual(night.model.breathing.guideEndsAt, time(2, 15), "not fifteen minutes more")
        XCTAssertEqual(night.engine.breath.weight, 1)

        // The window runs out on the same clock: it lets go, and it is gone.
        night.advance(seconds: 9 * 60)
        XCTAssertEqual(night.model.breathing.phase, .dissolving)
        XCTAssertEqual(night.engine.breath.weight, 0)
        XCTAssertEqual(night.engine.breath.dissolveSeconds, BreathingGuideController.dissolveSeconds)
        night.advance(seconds: 3 * 60)
        XCTAssertEqual(night.model.breathing.phase, .idle)
    }

    func testAnInterruptionThatOutlastsTheWindowDoesNotGuideAgain() throws {
        let night = try NightHarness(at: time(2))
        night.model.setBreathingEnabled(true)
        night.model.play()
        night.engine.render(seconds: 1)
        night.advance(seconds: 10 * 60)
        night.session.interrupt()
        night.engine.render(seconds: 1)
        night.advance(seconds: 10 * 60)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.breathing.phase, .idle, "a sleeper is not guided again")
        XCTAssertEqual(night.engine.breath, .off)
    }

    func testTheFinalFadeTakesTheTideWithItAndFifteenMoreBringsItBack() throws {
        let night = try NightHarness(at: time(2))
        var settings = night.model.breathing.settings
        settings.guideMinutes = 30
        night.model.updateBreathing(settings)
        night.model.setBreathingEnabled(true)
        night.model.chooseTimer(.untilAsleep(20))
        night.model.play()
        night.engine.render(seconds: 1)

        // A quarter of twenty minutes: the fade begins at minute fifteen.
        night.advance(seconds: 15 * 60)
        XCTAssertTrue(night.model.timer.isFading)
        XCTAssertEqual(night.model.breathing.phase, .dissolving)
        XCTAssertEqual(night.engine.breath.weight, 0)
        XCTAssertEqual(night.engine.breath.dissolveSeconds, 300, "over what is left of the night")

        XCTAssertTrue(night.model.extendTimer())
        XCTAssertEqual(night.model.breathing.phase, .guiding, "its window is still open")
        XCTAssertEqual(night.model.breathing.guideEndsAt, time(2, 30))
        XCTAssertEqual(night.engine.breath.weight, 1)
    }
}

// MARK: - Small things with a rule of their own

@MainActor
final class NightDetailTests: XCTestCase {
    func testSmallHoursWaitsForWhateverComesNextAndNeverTicks() throws {
        let clock = TestClock(NightHarness.time(4))
        let session = SmallHoursController(now: { clock.now }, ticks: false)
        XCTAssertNil(session.secondsToNextEvent())
        session.begin()
        XCTAssertEqual(try XCTUnwrap(session.secondsToNextEvent()), 60, accuracy: 0.001, "the figure, by the minute")
        clock.now += 600
        session.tick()
        XCTAssertEqual(try XCTUnwrap(session.secondsToNextEvent()), 30, accuracy: 0.001, "the tide lets go at 10:30")
        clock.now += 30
        session.tick()
        XCTAssertEqual(session.tide.weight, 0)
        clock.now = NightHarness.time(4, 14).addingTimeInterval(50)
        session.tick()
        XCTAssertEqual(try XCTUnwrap(session.secondsToNextEvent()), 10, accuracy: 0.001, "the closing fade at 15:00")
        session.pause()
        XCTAssertNil(session.secondsToNextEvent(), "paused, it waits for nothing")
    }

    func testTheBlanketOnlyPromisesADipThatIsStillToCome() {
        let clock = TestClock(NightHarness.time(23))
        let timer = SleepTimerController(
            choice: .blanket(hour: 7), now: { clock.now }, calendar: NightHarness.utc, ticks: false
        )
        XCTAssertFalse(timer.blanketDipIsAhead, "nothing counts yet")
        timer.start()
        XCTAssertTrue(timer.blanketDipIsAhead)
        clock.now += TimerMath.blanketDipAfter
        timer.tick()
        XCTAssertFalse(timer.blanketDipIsAhead, "it has come")

        // Half an hour to the hour: the dip would never come.
        let late = TestClock(NightHarness.time(day: 18, 6, 30))
        let short = SleepTimerController(
            choice: .blanket(hour: 7), now: { late.now }, calendar: NightHarness.utc, ticks: false
        )
        short.start()
        XCTAssertFalse(short.blanketDipIsAhead)
        XCTAssertNotEqual(TimerSheetText.Input(short).blanketDipIsAhead, true)
    }

    func testAFingerOnTheEdgeOfTheScreenBelongsToTheSystem() {
        XCTAssertTrue(NightTouch.isAtEdge(y: 10, height: 874))
        XCTAssertTrue(NightTouch.isAtEdge(y: 860, height: 874))
        XCTAssertFalse(NightTouch.isAtEdge(y: 40, height: 874))
        XCTAssertFalse(NightTouch.isAtEdge(y: 437, height: 874))

        let start = Date(timeIntervalSinceReferenceDate: 0)
        var touch = NightTouch()
        touch.begin(at: start, level: 0.4, isAtEdge: true)
        XCTAssertNil(touch.move(translation: CGSize(width: 0, height: 120)), "the shade coming down is not the level")
        XCTAssertFalse(touch.isAdjustingLevel)
        XCTAssertEqual(touch.end(at: start.addingTimeInterval(0.1), allowsBack: true), .nothing, "nor a touch")

        // Anywhere else it is the level, and remembers where it started:
        // what a gesture the system takes away goes back to.
        touch.begin(at: start, level: 0.4)
        XCTAssertNotNil(touch.move(translation: CGSize(width: 0, height: 120)))
        XCTAssertTrue(touch.isAdjustingLevel)
        XCTAssertEqual(touch.startLevel, 0.4)
    }

    /// 03 §3.7 set this floor for the Horizon: under 3:1 the hour and the
    /// state cannot be read with the brightness at its lowest.
    func testTheDimmedNightScreenKeepsThreeToOne() {
        func luminance(_ hex: UInt32, opacity: Double) -> Double {
            func channel(_ value: UInt32) -> Double {
                // Drawn over black: the opacity scales the channel.
                let c = Double(value) / 255 * opacity
                return c <= 0.040_45 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * channel((hex >> 16) & 0xFF) + 0.7152 * channel((hex >> 8) & 0xFF)
                + 0.0722 * channel(hex & 0xFF)
        }
        func contrast(_ hex: UInt32, opacity: Double) -> Double {
            (luminance(hex, opacity: opacity) + 0.05) / 0.05
        }
        let regular = contrast(InkTokens.textNight.hex, opacity: BedtimeScreenPolicy.dimmedOpacity(increasedContrast: false))
        XCTAssertGreaterThanOrEqual(regular, 3, "\(regular)")
        let high = contrast(
            InkTokens.textNight.highContrastHex,
            opacity: BedtimeScreenPolicy.dimmedOpacity(increasedContrast: true)
        )
        XCTAssertGreaterThanOrEqual(high, 4.5, "\(high)")
        XCTAssertLessThan(BedtimeScreenPolicy.dimmedOpacity, 1, "and it is still dimmed")
    }

    func testARecipeNeverSaysProOnTheNightPage() {
        let recipe = MixRecipe(levels: [.rain: 0.5, .ocean: 0.4], hasFullAccess: false)
        XCTAssertEqual(recipe.needsPro, [.ocean])
        func lookup(_ key: String) -> String {
            switch key {
            case MixRecipe.proKey: return "%@ es Pro"
            case MixRecipe.spokenProKey: return "%@ requiere Pro"
            case MixRecipe.layerKey: return "%1$@ %2$lld"
            default: return "·"
            }
        }
        let locale = Locale(identifier: "es_ES")
        let name: (SoundID) -> String = { $0.rawValue }
        XCTAssertTrue(recipe.text(soundName: name, localized: lookup, locale: locale).contains("es Pro"))
        XCTAssertTrue(recipe.spoken(soundName: name, localized: lookup, locale: locale).contains("requiere Pro"))
        let night = recipe.text(namesPro: false, soundName: name, localized: lookup, locale: locale)
        XCTAssertFalse(night.contains("Pro"))
        XCTAssertTrue(night.contains("ocean 40"), "the layer and its level stay")
        XCTAssertEqual(recipe.segments(namesPro: false, soundName: name, localized: lookup, locale: locale).count, 2)
        XCTAssertFalse(recipe.spoken(namesPro: false, soundName: name, localized: lookup, locale: locale).contains("Pro"))
    }

    func testTheBandOfTheWaterLineIsShorterOnAShortScreen() {
        XCTAssertEqual(PageMetrics(fullHeight: 874, topInset: 62).tideBand, 120)
        XCTAssertEqual(PageMetrics(fullHeight: 667, topInset: 20).tideBand, 96, "120 would reach the state line")
        // Low water is the Horizon; the offsets are the sheet's own rule.
        XCTAssertEqual(TideLine.offset(level: 0, band: 100, thickness: 2), 98)
        XCTAssertEqual(TideLine.offset(level: 1, band: 100, thickness: 2), 0)
    }

    /// One minute is "1 min left", in the app's own tables.
    func testOneMinuteIsSingularInBothLanguages() throws {
        let expected: [(language: String, key: String, one: String, many: String)] = [
            ("es", "comun.min.quedan", "queda 1 min", "quedan 5 min"),
            ("en", "comun.min.quedan", "1 min left", "5 min left"),
            ("es", "ax.anuncio.quedan", "Queda 1 minuto", "Quedan 5 minutos"),
            ("en", "ax.anuncio.quedan", "1 minute left", "5 minutes left"),
        ]
        for item in expected {
            let path = try XCTUnwrap(Bundle.main.path(forResource: item.language, ofType: "lproj"))
            let bundle = try XCTUnwrap(Bundle(path: path))
            let format = Localized.string(item.key, bundle: bundle)
            XCTAssertEqual(String.localizedStringWithFormat(format, 1), item.one, "\(item.language) \(item.key)")
            XCTAssertEqual(String.localizedStringWithFormat(format, 5), item.many, "\(item.language) \(item.key)")
        }
    }

    func testTheHintOfTheNameSaysRenameToo() throws {
        let strings = try TimerCatalogTests.catalog()
        XCTAssertEqual(TimerCatalogTests.values("ax.nombre.pista", "es", in: strings), ["Mantén para guardar o renombrar."])
        XCTAssertEqual(TimerCatalogTests.values("ax.nombre.pista", "en", in: strings), ["Hold to save or rename."])
        XCTAssertTrue(TimerCatalogTests.values("ax.agua.valor", "es", in: strings).isEmpty, "retired: it went stale")
    }
}
