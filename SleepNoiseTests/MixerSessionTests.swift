import XCTest
@testable import SleepNoise

/// The night as the mixer runs it, on doubles: an engine that renders
/// offline, a session whose events the test raises, a clock the test moves.

// MARK: - Play, pause and the timer

@MainActor
final class NightSessionTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    func testPlayStartsANightAtFullLevelWithTheTimerOfTheFirstNight() throws {
        let night = try NightHarness(at: time(23))
        XCTAssertEqual(night.model.timer.choice, .firstUse)
        XCTAssertFalse(night.model.canExtendTimer, "nothing counts yet")

        night.model.play()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.session.started)
        // The level first, then the bed: 0.8 s to a whole envelope.
        // With the engine stopped the level is simply there: the seconds
        // only count when something is still sounding.
        XCTAssertEqual(night.engine.calls, [.master(level: 1, seconds: 0.8), .start(fadeIn: 0.8, level: 1)])
        XCTAssertEqual(night.engine.desk.command.masterRampSamples, 1, "not a ramp: nothing was audible")
        XCTAssertEqual(night.model.sessionLevel, 1)
        XCTAssertEqual(night.model.timer.endsAt, time(23, 45), "Until I sleep, 45 minutes")
        XCTAssertTrue(night.model.canExtendTimer)
        XCTAssertTrue(night.nowPlaying.isPlaying)
        XCTAssertNil(night.model.sessionEndedAt)
        XCTAssertNil(MixerModel.storedTimer(defaults: night.defaults), "the first-use timer is never stored")

        night.engine.render(seconds: 0.8)
        XCTAssertEqual(night.engine.envelope, 1)
        XCTAssertEqual(night.engine.master, 1)

        // Play again while it plays changes nothing.
        night.model.play()
        XCTAssertEqual(night.engine.starts.count, 1)
    }

    func testAPauseKeepsTheNightAndItsCount() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 600)
        night.model.pause()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .person)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 1.5)], "never a cut")
        XCTAssertEqual(night.model.timer.remaining, 2_100)
        XCTAssertFalse(night.nowPlaying.isPlaying)

        // Five minutes later it is the same night: the count goes on.
        night.engine.render(seconds: 2)
        night.advance(seconds: 300)
        XCTAssertEqual(night.model.pauseCause, .person)
        night.model.play()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertEqual(night.model.timer.remaining, 2_100)
        XCTAssertEqual(night.model.timer.endsAt, night.clock.now.addingTimeInterval(2_100))
        XCTAssertEqual(night.nowPlaying.elapsedResets, 1, "one night so far")
    }

    func testANightPausedForTwentyMinutesIsOver() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 600)
        night.model.setSessionLevel(0.5)
        night.model.pause()
        let pausedAt = night.clock.now
        night.advance(seconds: 1_199)
        XCTAssertEqual(night.model.pauseCause, .person, "19 min 59 s: still the same night")
        XCTAssertNil(night.model.sessionEndedAt)

        night.advance(seconds: 1)
        XCTAssertNil(night.model.pauseCause, "the page is silent again, not paused")
        XCTAssertEqual(night.model.sessionEndedAt, pausedAt, "it ended when the sound stopped")
        XCTAssertFalse(night.model.timer.hasCount)
        XCTAssertFalse(night.model.canExtendTimer)

        // The next Play is a new night: whole timer, full level.
        night.model.play()
        XCTAssertEqual(night.model.timer.remaining, 2_700)
        XCTAssertEqual(night.model.sessionLevel, 1)
        XCTAssertNil(night.model.sessionEndedAt)
        XCTAssertEqual(night.nowPlaying.elapsedResets, 2)
    }

    func testPlayAfterALongPauseIsANewNightEvenIfNothingNoticed() throws {
        // The app was suspended: no timer fired, nobody came to the front.
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 600)
        night.model.pause()
        night.jump(to: time(day: 18, 22))
        night.model.play()
        XCTAssertEqual(night.model.timer.remaining, 2_700, "not the 35 minutes left over from last night")
        XCTAssertEqual(night.model.timer.endsAt, time(day: 18, 22, 45))
    }

    func testTheTimerFadesTheNightOutAndEndsIt() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 2_700 - 676)
        XCTAssertEqual(night.engine.fades, [])
        night.advance(seconds: 1)
        XCTAssertEqual(night.engine.fades, [.fade(level: 0, seconds: 675)], "one request; the engine counts")
        XCTAssertTrue(night.model.timer.isFading)
        XCTAssertEqual(night.model.timer.fadingMinutes, 12)

        // The fade is rendered on the envelope, in whole samples.
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.engine.state.envelopeRamp.total, UInt32(675 * 48_000))
        XCTAssertEqual(night.engine.master, 1, "the session level is not what fades")

        night.advance(seconds: 674)
        XCTAssertTrue(night.model.isPlaying)
        night.advance(seconds: 1)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause, "over, not paused")
        XCTAssertEqual(night.model.sessionEndedAt, time(23, 45))
        XCTAssertEqual(night.engine.stops.count, 1)
        XCTAssertFalse(night.nowPlaying.isPlaying)
        XCTAssertFalse(night.model.canExtendTimer, "the slot of +15 min is free for Small Hours")
        XCTAssertEqual(night.model.timer.choice, .firstUse)
    }

    func testResumingInsideTheFinalFadeRisesToWhereItStands() throws {
        let night = try NightHarness(at: time(23))
        night.model.chooseTimer(.untilAsleep(40))
        night.model.play()
        night.engine.render(seconds: 1)
        night.advance(seconds: 2_100)
        XCTAssertEqual(night.engine.fades, [.fade(level: 0, seconds: 600)])
        night.model.pause()
        night.engine.render(seconds: 2)
        night.advance(seconds: 60)

        night.model.play()
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 0.8, level: 0.5), "half way down its ten minutes")
        XCTAssertEqual(night.engine.fades.count, 1, "the fade is not asked for over a bed that is still rising")
        night.engine.render(seconds: 0.8)
        XCTAssertEqual(night.engine.envelope, 0.5, accuracy: 0.000_1)
        night.advance(seconds: 1)
        XCTAssertEqual(night.engine.fades.count, 2)
        XCTAssertEqual(night.engine.fades.last, .fade(level: 0, seconds: 299))
        // From 0.5 down, never back up.
        night.engine.render(seconds: 1)
        XCTAssertLessThan(night.engine.envelope, 0.5)
        XCTAssertGreaterThan(night.engine.envelope, 0.49)
    }

    func testPlusFifteenInsideTheFinalFadeBringsTheLevelBack() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 2_400)
        XCTAssertTrue(night.model.timer.isFading)
        night.engine.render(seconds: 2)
        XCTAssertLessThan(night.engine.envelope, 1)

        XCTAssertTrue(night.model.extendTimer())
        XCTAssertFalse(night.model.timer.isFading)
        XCTAssertEqual(night.model.timer.endsAt, time(day: 18, 0))
        XCTAssertEqual(night.engine.fades.last, .fade(level: 1, seconds: 3))
        night.engine.render(seconds: 3)
        XCTAssertEqual(night.engine.envelope, 1)
        XCTAssertTrue(night.model.isPlaying)
    }

    func testPlusFifteenNeverCreatesATimer() throws {
        let night = try NightHarness(at: time(23))
        night.model.chooseTimer(.off)
        night.model.play()
        XCTAssertNil(night.model.timer.endsAt, "it plays until it is stopped")
        XCTAssertFalse(night.model.canExtendTimer)
        XCTAssertFalse(night.model.extendTimer())
        XCTAssertEqual(night.model.timer.choice, .off)
        night.advance(seconds: 6 * 3_600)
        XCTAssertTrue(night.model.isPlaying)
    }

    func testTheBlanketEasesTheLevelDownThroughTheMaster() throws {
        let night = try NightHarness(at: time(23, 30))
        night.model.chooseTimer(.blanket(hour: 7))
        night.model.play()
        XCTAssertEqual(night.model.timer.endsAt, time(day: 18, 7))
        night.engine.render(seconds: 1)

        night.advance(seconds: 45 * 60 - 1)
        XCTAssertEqual(night.engine.masters.count, 1)
        night.advance(seconds: 1)
        let dip = TimerMath.blanketDipGain
        XCTAssertEqual(night.engine.masters.last, .master(level: dip, seconds: 60), "-6 dB over a minute")
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.engine.state.masterRamp.total, UInt32(60 * 48_000))
        XCTAssertLessThan(night.engine.master, 1)
        XCTAssertGreaterThan(night.engine.master, 0.99, "a slow ramp: a second in, almost nothing")
        XCTAssertEqual(night.model.sessionLevel, 1, "the person's level is theirs: the dip rides on it")

        // The vertical axis of Night multiplies what the blanket left.
        night.model.setSessionLevel(0.5)
        XCTAssertEqual(night.engine.masters.last, .master(level: 0.5 * dip, seconds: 0))

        // Paused and back: the level is simply there, without a ramp.
        night.model.pause()
        night.engine.render(seconds: 2)
        XCTAssertFalse(night.engine.isRunning)
        night.advance(seconds: 60)
        night.model.play()
        night.engine.render(seconds: 0.1)
        XCTAssertEqual(night.engine.master, 0.5 * dip)

        // Another timer: the blanket's dip goes with the blanket.
        night.model.chooseTimer(.off)
        XCTAssertEqual(night.engine.masters.last, .master(level: 0.5, seconds: 60))
    }

    func testTheSessionLevelIsClampedSmoothedAndNeverStored() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.engine.render(seconds: 1)
        night.engine.forgetCalls()

        night.model.setSessionLevel(0.4)
        XCTAssertEqual(night.model.sessionLevel, 0.4)
        XCTAssertEqual(night.engine.calls, [.master(level: 0.4, seconds: 0)])
        // The engine never steps: 50 ms at least while it renders.
        night.engine.render(seconds: 0.025)
        XCTAssertLessThan(night.engine.master, 1)
        XCTAssertGreaterThan(night.engine.master, 0.4)
        night.engine.render(seconds: 0.025)
        XCTAssertEqual(night.engine.master, 0.4)

        night.model.setSessionLevel(0.4)
        XCTAssertEqual(night.engine.calls.count, 1, "nothing is sent for a level that did not move")
        night.model.setSessionLevel(-3)
        XCTAssertEqual(night.model.sessionLevel, MixerModel.minimumSessionLevel, "turned down, not switched off")
        night.model.setSessionLevel(7)
        XCTAssertEqual(night.model.sessionLevel, 1)

        // It belongs to the night: the next launch knows nothing of it.
        night.model.setSessionLevel(0.3)
        let next = try NightHarness(at: time(23, 30), defaults: night.defaults)
        XCTAssertEqual(next.model.sessionLevel, 1)
    }

    func testAStartThatFailsLeavesThePausedNightAsItWas() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 600)
        night.model.pause()
        night.engine.failsToStart = true
        night.model.play()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.startFailures, 1)
        XCTAssertNotNil(night.model.audioError)
        XCTAssertEqual(night.model.timer.remaining, 2_100, "the count is not lost to a failed start")

        night.engine.failsToStart = false
        night.model.play()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.startFailures, 0)
        XCTAssertEqual(night.model.timer.remaining, 2_100)
    }
}

// MARK: - The timer as the person chooses it

@MainActor
final class TimerChoiceModelTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    func testTheFirstNightHasATimerAndOffIsAChoice() throws {
        let night = try NightHarness(at: time(22))
        XCTAssertEqual(night.model.timer.choice, TimerChoice(mode: .untilAsleep, minutes: 45))
        XCTAssertNil(MixerModel.storedTimer(defaults: night.defaults))

        // "Off" chosen by the person is stored, and is not the first use.
        night.model.chooseTimer(.off)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults), .off)
        let next = try NightHarness(at: time(22), defaults: night.defaults)
        XCTAssertEqual(next.model.timer.choice, .off)
        next.model.play()
        XCTAssertNil(next.model.timer.endsAt)
    }

    func testBothModesAreStoredWithWhatEachWasLeftAt() throws {
        let night = try NightHarness(at: time(22))
        night.model.chooseTimer(TimerChoice(mode: .blanket, minutes: 90, endHour: 6, endMinute: 30))
        let next = try NightHarness(at: time(22), defaults: night.defaults)
        XCTAssertEqual(next.model.timer.choice.mode, .blanket)
        XCTAssertEqual(next.model.timer.choice.endHour, 6)
        XCTAssertEqual(next.model.timer.choice.endMinute, 30)
        XCTAssertEqual(next.model.timer.choice.minutes, 90, "the length waits for the other mode")

        // The old sheet only knows lengths: it keeps the hour as it was.
        next.model.selectTimer(minutes: 30)
        XCTAssertEqual(next.model.timer.choice, TimerChoice(mode: .untilAsleep, minutes: 30, endHour: 6, endMinute: 30))
        next.model.selectTimer(minutes: nil)
        XCTAssertEqual(next.model.timer.choice.mode, .off)
        XCTAssertEqual(next.model.timer.choice.minutes, 30)
    }

    func testALengthStoredByAnOlderVersionIsRead() throws {
        let night = try NightHarness(at: time(22))
        night.defaults.set(90, forKey: MixerModel.legacyTimerKey)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults), .untilAsleep(90))
        let next = try NightHarness(at: time(22), defaults: night.defaults)
        XCTAssertEqual(next.model.timer.choice, .untilAsleep(90))
        // Out of range, it is not a choice.
        night.defaults.set(9_999, forKey: MixerModel.legacyTimerKey)
        XCTAssertNil(MixerModel.storedTimer(defaults: night.defaults))
        // The first real choice replaces the old key.
        next.model.chooseTimer(.untilAsleep(20))
        XCTAssertNil(night.defaults.object(forKey: MixerModel.legacyTimerKey))
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults), .untilAsleep(20))
    }

    func testNoModeLengthOrHourSellsAnything() throws {
        let night = try NightHarness(at: time(12), free: true)
        let choices: [TimerChoice] = [
            .off, .untilAsleep(1), .untilAsleep(AccessPolicy.maxTimerMinutes), .blanket(hour: 7), .blanket(hour: 13, minute: 30),
        ]
        for choice in choices {
            night.model.chooseTimer(choice)
            XCTAssertEqual(night.model.timer.choice, choice)
            XCTAssertFalse(night.model.showPaywall, "\(choice)")
        }
        night.model.play()
        for _ in 0..<5 { XCTAssertTrue(night.model.extendTimer()) }
        XCTAssertFalse(night.model.showPaywall)
    }

    func testChoosingWhileItPlaysCountsAtOnce() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.advance(seconds: 600)
        night.model.chooseTimer(.untilAsleep(90))
        XCTAssertEqual(night.model.timer.remaining, 5_400)
        XCTAssertEqual(night.model.timer.endsAt, night.clock.now.addingTimeInterval(5_400))
        XCTAssertEqual(night.engine.fades, [], "nothing was fading: the envelope is left alone")

        // Inside the final fade of the old timer, the level comes back.
        night.model.chooseTimer(.untilAsleep(40))
        night.advance(seconds: 2_000)
        XCTAssertTrue(night.model.timer.isFading)
        night.model.chooseTimer(.blanket(hour: 7))
        XCTAssertFalse(night.model.timer.isFading)
        XCTAssertEqual(night.engine.fades.last, .fade(level: 1, seconds: 3))
    }
}

// MARK: - Interruptions (C48)

@MainActor
final class InterruptionWiringTests: XCTestCase {
    private func time(day: Int = 18, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func playing(at start: Date, timer: TimerChoice = .firstUse) throws -> NightHarness {
        let night = try NightHarness(at: start)
        if timer != .firstUse { night.model.chooseTimer(timer) }
        night.model.play()
        night.engine.render(seconds: 1)
        return night
    }

    func testAnInterruptionAtNightResumesWithAThreeSecondFade() throws {
        let night = try playing(at: time(2))
        night.advance(seconds: 60)
        night.session.interrupt()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .system)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 0.3)])
        XCTAssertEqual(night.model.timer.remaining, 2_640, "the count waits")

        night.advance(seconds: 300)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 1))
        XCTAssertEqual(night.model.timer.remaining, 2_640, "the same night, where it was")
        XCTAssertEqual(night.nowPlaying.elapsedResets, 1)
        XCTAssertEqual(night.model.startFailures, 0)

        // A second `.ended` with nothing open does nothing.
        night.session.endInterruption()
        XCTAssertEqual(night.engine.starts.count, 2)
    }

    func testACallNeverEndsTheNightHoweverLongItWas() throws {
        // The call observer speaks first, then the interruption begins.
        let night = try playing(at: time(3))
        night.session.call(true)
        night.session.interrupt()
        XCTAssertEqual(night.model.pauseCause, .call)
        // 45 minutes: past the twenty of any other pause.
        night.advance(seconds: 2_700)
        XCTAssertEqual(night.model.pauseCause, .call, "an open call is not judged by the twenty minutes")
        night.session.call(false)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 1))
        XCTAssertEqual(night.nowPlaying.elapsedResets, 1, "the same night")
        XCTAssertEqual(night.model.sessionLevel, 1)
    }

    func testTheCallObserverMaySpeakAfterTheInterruptionBegan() throws {
        let night = try playing(at: time(3))
        night.session.interrupt()
        XCTAssertEqual(night.model.pauseCause, .system)
        night.session.call(true)
        XCTAssertEqual(night.model.pauseCause, .call)
        night.advance(seconds: 1_500)
        night.session.call(false)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying, "25 minutes, but it was a call")
    }

    func testAnythingElseThatLastsTwentyMinutesEndsTheNight() throws {
        let night = try playing(at: time(2))
        night.session.interrupt()
        night.advance(seconds: 1_260)
        XCTAssertEqual(night.model.pauseCause, .system, "nothing is decided while it is open")
        night.session.endInterruption()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertEqual(night.model.sessionEndedAt, time(2))
        XCTAssertEqual(night.engine.starts.count, 1)
    }

    func testInTheMorningNoInterruptionResumes() throws {
        // The alarm: the system does not say so, the clock stands in for it.
        for call in [false, true] {
            let night = try playing(at: time(6, 30), timer: .untilAsleep(360))
            if call { night.session.call(true) }
            night.session.interrupt()
            night.advance(seconds: 60)
            night.session.endInterruption()
            XCTAssertFalse(night.model.isPlaying, "call: \(call)")
            XCTAssertNil(night.model.pauseCause, "the night is over, not paused")
            XCTAssertEqual(night.model.sessionEndedAt, time(6, 30))
            XCTAssertEqual(night.engine.starts.count, 1)
            XCTAssertFalse(night.model.timer.hasCount, "also over a six hour timer")
        }
    }

    func testWithABlanketTheMorningIsTheHourBeforeItsEnd() throws {
        // A blanket until 13:00: at 08:00 the person is asleep.
        let night = try playing(at: time(2), timer: .blanket(hour: 13))
        night.jump(to: time(8))
        night.session.interrupt()
        night.advance(seconds: 60)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying, "08:00 is not this night's morning")

        night.jump(to: time(12, 10))
        night.session.interrupt()
        night.advance(seconds: 30)
        night.session.endInterruption()
        XCTAssertFalse(night.model.isPlaying, "inside the last hour the alarm wins")
        XCTAssertNil(night.model.pauseCause)
    }

    func testWhatThePersonChoseMeanwhileWins() throws {
        // A pause during the interruption is not undone when it ends.
        let paused = try playing(at: time(2))
        paused.session.interrupt()
        paused.model.pause()
        XCTAssertEqual(paused.model.pauseCause, .person)
        paused.session.endInterruption()
        XCTAssertFalse(paused.model.isPlaying)
        XCTAssertEqual(paused.engine.starts.count, 1)

        // Nor a stop by voice.
        let stopped = try playing(at: time(2))
        stopped.session.interrupt()
        XCTAssertEqual(stopped.model.pauseFromShortcut(), .stopped)
        stopped.session.endInterruption()
        XCTAssertFalse(stopped.model.isPlaying)

        // Nor from the lock screen.
        let remote = try playing(at: time(2))
        remote.session.interrupt()
        remote.nowPlaying.pressPause()
        remote.session.endInterruption()
        XCTAssertFalse(remote.model.isPlaying)

        // A Play during it plays, and the late `.ended` starts nothing more.
        let played = try playing(at: time(2))
        played.session.interrupt()
        played.engine.render(seconds: 1)
        played.model.play()
        XCTAssertTrue(played.model.isPlaying)
        XCTAssertEqual(played.engine.starts.last, .start(fadeIn: 0.8, level: 1), "asked for: the fade of Play")
        played.session.endInterruption()
        XCTAssertEqual(played.engine.starts.count, 2)

        // And an interruption never lends its start to the next one: this
        // one closed by hand at 02:00, the next begins at 02:30.
        played.advance(seconds: 1_800)
        played.session.interrupt()
        played.advance(seconds: 60)
        played.session.endInterruption()
        XCTAssertTrue(played.model.isPlaying, "one minute, not thirty-one")
    }

    func testANightThePersonHadPausedIsNotResumed() throws {
        let night = try playing(at: time(2))
        night.model.pause()
        night.session.interrupt()
        // The tail of the pause is cut to the short fade.
        XCTAssertEqual(night.engine.stops.last, .stop(fadeOut: 0.3))
        night.advance(seconds: 60)
        night.session.endInterruption()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .person)
        XCTAssertEqual(night.engine.starts.count, 1)
    }

    func testAnInterruptionThatNeverEndedIsClosedWhenTheAppComesForward() throws {
        let night = try playing(at: time(2))
        night.session.interrupt()
        night.advance(seconds: 120)
        night.model.appDidResignActive()
        night.model.appDidBecomeActive()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 1))

        // Not while something still holds the output.
        let music = try playing(at: time(2))
        music.session.interrupt()
        music.session.isOtherAudioPlaying = true
        music.model.appDidBecomeActive()
        XCTAssertFalse(music.model.isPlaying, "nothing resumes over another app")
        music.session.isOtherAudioPlaying = false
        music.session.endInterruption()
        XCTAssertTrue(music.model.isPlaying)

        let call = try playing(at: time(2))
        call.session.call(true)
        call.session.interrupt()
        call.model.appDidBecomeActive()
        XCTAssertFalse(call.model.isPlaying, "the call is still on")
        XCTAssertEqual(call.model.pauseCause, .call)
    }

    func testAResumeThatDoesNotStartStaysPausedAndSaysNothing() throws {
        let night = try playing(at: time(2))
        night.session.interrupt()
        night.engine.failsToStart = true
        night.advance(seconds: 60)
        night.session.endInterruption()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .system)
        XCTAssertEqual(night.model.startFailures, 0, "nobody asked: no error line")
        XCTAssertNil(night.model.audioError)
        XCTAssertEqual(night.model.timer.remaining, 2_700)
        // From here it is a pause like any other: twenty minutes.
        night.advance(seconds: 1_200)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertEqual(night.model.sessionEndedAt, time(2))
    }

    func testAMediaServicesResetKeepsTheNight() throws {
        let night = try playing(at: time(2))
        night.advance(seconds: 60)
        night.session.resetMediaServices()
        XCTAssertTrue(night.engine.calls.contains(.invalidate))
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.engine.starts.count, 2)
        XCTAssertEqual(night.model.timer.remaining, 2_640)
        XCTAssertEqual(night.nowPlaying.elapsedResets, 1)

        // If the sound does not come back, the page says it is paused.
        night.engine.failsToStart = true
        night.session.resetMediaServices()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .system)
        XCTAssertEqual(night.model.startFailures, 0)
    }
}

// MARK: - The output comes and goes (C49)

@MainActor
final class RouteWiringTests: XCTestCase {
    private func time(day: Int = 18, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func playing(on route: OutputRoute, at start: Date? = nil) throws -> NightHarness {
        let night = try NightHarness(at: start ?? time(2))
        night.session.currentRoute = route
        night.model.play()
        night.engine.render(seconds: 1)
        return night
    }

    func testEarbudsOutPauseTheNightAndOfferTheSpeaker() throws {
        let night = try playing(on: ScriptedSession.airPods)
        XCTAssertNil(night.model.speakerOfferUntil)
        night.session.loseOutput()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 0.04)], "too short to be heard from the speaker")
        XCTAssertEqual(night.model.speakerOfferUntil, time(2).addingTimeInterval(60))

        // The system may say it twice: nothing changes.
        night.session.interrupt(.routeDisconnected)
        XCTAssertEqual(night.engine.stops.count, 1)
        XCTAssertEqual(night.model.speakerOfferUntil, time(2).addingTimeInterval(60))

        // It never plays again by itself on the speaker.
        night.engine.render(seconds: 1)
        night.advance(seconds: 59)
        XCTAssertEqual(night.engine.starts.count, 1)
        XCTAssertNotNil(night.model.speakerOfferUntil)
        night.advance(seconds: 1)
        XCTAssertNil(night.model.speakerOfferUntil, "the offer lasts a minute")
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        XCTAssertFalse(night.model.isPlaying)
    }

    func testTheSystemSayingItAsAnInterruptionIsTheSameLoss() throws {
        let night = try playing(on: ScriptedSession.airPods)
        night.session.currentRoute = .builtInSpeaker
        night.session.interrupt(.routeDisconnected)
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 0.04)])
        XCTAssertNotNil(night.model.speakerOfferUntil)
        // No interruption is left open by it: the earbuds can come back.
        night.engine.render(seconds: 1)
        night.advance(seconds: 30)
        night.session.connect(ScriptedSession.airPods)
        XCTAssertTrue(night.model.isPlaying)
    }

    func testKeepPlayingOnSpeakerIsExplicitAndCapped() throws {
        let night = try playing(on: ScriptedSession.airPods)
        night.session.loseOutput()
        night.engine.render(seconds: 1)
        night.advance(seconds: 20)

        night.model.continueOnSpeaker()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.sessionLevel, RoutePolicy.speakerMasterCap)
        XCTAssertEqual(night.engine.masters.last, .master(level: 0.4, seconds: 0.8))
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 0.8, level: 1))
        XCTAssertNil(night.model.speakerOfferUntil)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertEqual(night.nowPlaying.elapsedResets, 1, "the same night")
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.engine.master, 0.4)
        XCTAssertEqual(night.engine.envelope, 1)

        // The person may raise it again from Night: the cap is where the
        // night comes back, not a ceiling.
        night.model.setSessionLevel(0.7)
        XCTAssertEqual(night.model.sessionLevel, 0.7)
    }

    func testATouchAnywhereDoesTheSameAndALowerLevelIsKept() throws {
        // The Disc, a minute and a half later: the offer is gone, the cap is not.
        let disc = try playing(on: ScriptedSession.airPods)
        disc.session.loseOutput()
        disc.engine.render(seconds: 1)
        disc.advance(seconds: 90)
        disc.model.togglePlayback()
        XCTAssertTrue(disc.model.isPlaying)
        XCTAssertEqual(disc.model.sessionLevel, 0.4)

        // The lock screen.
        let lock = try playing(on: ScriptedSession.airPods)
        lock.session.loseOutput()
        lock.nowPlaying.pressPlay()
        XCTAssertEqual(lock.model.sessionLevel, 0.4)

        // Already lower than the cap: it stays where the person had it.
        let quiet = try playing(on: ScriptedSession.airPods)
        quiet.model.setSessionLevel(0.25)
        quiet.session.loseOutput()
        quiet.model.play()
        XCTAssertEqual(quiet.model.sessionLevel, 0.25)
    }

    func testTheCapIsOnlyForAChangeToTheSpeaker() throws {
        // Paused by hand and played again on the same earbuds: no cap.
        let same = try playing(on: ScriptedSession.airPods)
        same.model.pause()
        same.engine.render(seconds: 2)
        same.model.play()
        XCTAssertEqual(same.model.sessionLevel, 1)

        // Paused by hand, earbuds put away, Play on the speaker: capped.
        let away = try playing(on: ScriptedSession.airPods)
        away.model.pause()
        away.engine.render(seconds: 2)
        away.session.loseOutput()
        XCTAssertEqual(away.model.pauseCause, .person, "it was not playing: nothing was lost")
        XCTAssertNil(away.model.speakerOfferUntil)
        away.model.play()
        XCTAssertEqual(away.model.sessionLevel, 0.4)

        // From the speaker to earbuds: never capped.
        let toEarbuds = try playing(on: .builtInSpeaker)
        toEarbuds.model.pause()
        toEarbuds.session.connect(ScriptedSession.airPods)
        toEarbuds.model.play()
        XCTAssertEqual(toEarbuds.model.sessionLevel, 1)

        // A night that always was on the speaker: never capped.
        let speaker = try playing(on: .builtInSpeaker)
        speaker.model.pause()
        speaker.model.play()
        XCTAssertEqual(speaker.model.sessionLevel, 1)
    }

    func testTheSameOutputComingBackResumesOnlyWithTheAppInFront() throws {
        let front = try playing(on: ScriptedSession.airPods)
        front.session.loseOutput()
        front.engine.render(seconds: 1)
        front.advance(seconds: 300)
        front.session.connect(ScriptedSession.airPods)
        XCTAssertTrue(front.model.isPlaying)
        XCTAssertEqual(front.engine.starts.last, .start(fadeIn: 0.8, level: 1))
        XCTAssertEqual(front.model.sessionLevel, 1, "the same earbuds: no cap")
        XCTAssertEqual(front.nowPlaying.elapsedResets, 1)
        XCTAssertNil(front.model.speakerOfferUntil)

        let behind = try playing(on: ScriptedSession.airPods)
        behind.session.loseOutput()
        behind.model.appDidResignActive()
        behind.session.connect(ScriptedSession.airPods)
        XCTAssertFalse(behind.model.isPlaying, "the app is not in front")

        let other = try playing(on: ScriptedSession.airPods)
        other.session.loseOutput()
        other.session.connect(ScriptedSession.speakerInTheRoom)
        XCTAssertFalse(other.model.isPlaying, "some other speaker that happened to connect")
        XCTAssertEqual(other.model.pauseCause, .lostOutput)
    }

    func testTwentyMinutesAfterTheLossTheNightIsOver() throws {
        // The earbuds come back too late: nothing resumes.
        let late = try playing(on: ScriptedSession.airPods)
        late.session.loseOutput()
        late.jump(to: time(2, 25))
        late.session.connect(ScriptedSession.airPods)
        XCTAssertFalse(late.model.isPlaying)
        XCTAssertNil(late.model.pauseCause)
        XCTAssertEqual(late.model.sessionEndedAt, time(2))

        // A touch then starts a new night, under the same cap.
        let touch = try playing(on: ScriptedSession.airPods)
        touch.session.loseOutput()
        touch.engine.render(seconds: 1)
        touch.advance(seconds: 1_500)
        XCTAssertNil(touch.model.pauseCause)
        touch.model.play()
        XCTAssertTrue(touch.model.isPlaying)
        XCTAssertEqual(touch.nowPlaying.elapsedResets, 2, "a new night")
        XCTAssertEqual(touch.model.timer.remaining, 2_700)
        XCTAssertEqual(touch.model.sessionLevel, 0.4, "still not at full level on the speaker")
    }

    func testEarbudsThatRunOutDuringACallDoNotBringTheNightToTheSpeaker() throws {
        let night = try playing(on: ScriptedSession.airPods)
        night.session.call(true)
        night.session.interrupt()
        night.advance(seconds: 120)
        night.session.loseOutput()
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        XCTAssertNotNil(night.model.speakerOfferUntil, "the offer is made all the same")
        // While the call is open, nothing plays by itself.
        night.session.connect(ScriptedSession.airPods)
        XCTAssertFalse(night.model.isPlaying)
        night.session.loseOutput()

        night.session.call(false)
        night.session.endInterruption()
        XCTAssertFalse(night.model.isPlaying, "the call ended on the speaker: it stays paused")
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        XCTAssertEqual(night.engine.starts.count, 1)

        // The earbuds back, with the app in front: now it may.
        night.session.connect(ScriptedSession.airPods)
        XCTAssertTrue(night.model.isPlaying)
    }

    func testAnInterruptionOnEarbudsDoesNotResumeOnAnotherOutput() throws {
        // The route changed under the interruption without a loss being
        // reported: the gate of every unasked resume still holds.
        let night = try playing(on: ScriptedSession.airPods)
        night.session.interrupt()
        night.session.currentRoute = .builtInSpeaker
        night.advance(seconds: 60)
        night.session.endInterruption()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .system)
        night.advance(seconds: 1_200)
        XCTAssertNil(night.model.pauseCause, "and twenty minutes later it is over")
    }

    func testAPauseFromTheHeadphonesTakesThreeSeconds() throws {
        let earbuds = try playing(on: ScriptedSession.airPods)
        earbuds.nowPlaying.pressPause()
        XCTAssertEqual(earbuds.engine.stops, [.stop(fadeOut: 3)])
        XCTAssertEqual(earbuds.model.pauseCause, .headphones)
        // It never resumes by itself; the same command the other way does.
        earbuds.engine.render(seconds: 4)
        earbuds.advance(seconds: 600)
        XCTAssertFalse(earbuds.model.isPlaying)
        earbuds.nowPlaying.pressToggle()
        XCTAssertTrue(earbuds.model.isPlaying)
        earbuds.nowPlaying.pressToggle()
        XCTAssertEqual(earbuds.engine.stops.last, .stop(fadeOut: 3))

        let speaker = try playing(on: .builtInSpeaker)
        speaker.nowPlaying.pressPause()
        XCTAssertEqual(speaker.engine.stops, [.stop(fadeOut: 1.5)])
        XCTAssertEqual(speaker.model.pauseCause, .person)
    }

    func testANightThatPlaysFollowsTheRoute() throws {
        let night = try playing(on: .builtInSpeaker)
        night.session.connect(ScriptedSession.airPods)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.engine.calls.contains(.retarget))
        XCTAssertEqual(night.engine.starts.count, 1)
        // It is on the earbuds now: losing them is a lost output.
        night.session.loseOutput()
        XCTAssertEqual(night.model.pauseCause, .lostOutput)
        night.model.play()
        XCTAssertEqual(night.model.sessionLevel, 0.4)
    }

    func testALostOutputCutsTheTailOfAPause() throws {
        let night = try playing(on: ScriptedSession.airPods)
        night.model.pause()
        XCTAssertTrue(night.engine.isStopping)
        night.session.loseOutput()
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 1.5), .stop(fadeOut: 0.04)])
        XCTAssertEqual(night.model.pauseCause, .person)
        XCTAssertNil(night.model.speakerOfferUntil)
    }
}

// MARK: - Night and the night page (C40, C46, C47)

@MainActor
final class BedtimeModelTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    func testNightDimsAfterSixtySecondsWithoutATouch() throws {
        let night = try NightHarness(at: time(23))
        XCTAssertEqual(night.model.enterBedtime(), .entered)
        XCTAssertTrue(night.model.isBedtime)
        XCTAssertTrue(night.model.isPlaying, "Night starts the mix that was at rest")
        XCTAssertFalse(night.model.isBedtimeDimmed)
        night.advance(seconds: 59)
        XCTAssertFalse(night.model.isBedtimeDimmed)
        night.advance(seconds: 1)
        XCTAssertTrue(night.model.isBedtimeDimmed)

        // Any touch brings the ink back and the minute starts over.
        night.model.noteBedtimeTouch()
        XCTAssertFalse(night.model.isBedtimeDimmed)
        night.advance(seconds: 59)
        XCTAssertFalse(night.model.isBedtimeDimmed)
        night.advance(seconds: 1)
        XCTAssertTrue(night.model.isBedtimeDimmed)

        // Dimmed is not a state of the night: it plays as before.
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause)

        night.model.leaveBedtime()
        XCTAssertFalse(night.model.isBedtime)
        XCTAssertFalse(night.model.isBedtimeDimmed)
        XCTAssertTrue(night.model.isNightSession, "the page behind it is the night page")
        night.advance(seconds: 120)
        XCTAssertFalse(night.model.isBedtimeDimmed, "the page does not dim")
    }

    func testKeepScreenOnIsWhileChargingByDefaultAndStored() throws {
        XCTAssertEqual(BedtimeScreenPolicy.dimDelay, 60)
        let table: [(KeepScreenOn, charging: Bool, awake: Bool)] = [
            (.whileCharging, true, true), (.whileCharging, false, false),
            (.always, true, true), (.always, false, true),
            (.never, true, false), (.never, false, false),
        ]
        for row in table {
            XCTAssertEqual(
                BedtimeScreenPolicy.keepsScreenAwake(row.0, isCharging: row.charging), row.awake,
                "\(row.0), charging \(row.charging)"
            )
        }

        let night = try NightHarness(at: time(23))
        XCTAssertEqual(night.model.keepScreenOn, .whileCharging, "Night lets the iPhone sleep (C46)")
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: true), "only the Night screen holds it awake")
        night.model.enterBedtime()
        XCTAssertTrue(night.model.bedtimeKeepsScreenAwake(isCharging: true))
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: false))

        night.model.setKeepScreenOn(.always)
        XCTAssertTrue(night.model.bedtimeKeepsScreenAwake(isCharging: false))
        let next = try NightHarness(at: time(23), defaults: night.defaults)
        XCTAssertEqual(next.model.keepScreenOn, .always)
        next.model.setKeepScreenOn(.never)
        next.model.enterBedtime()
        XCTAssertFalse(next.model.bedtimeKeepsScreenAwake(isCharging: true))
    }

    func testNightShowsTheTimerThatRunsAndNeverMakesOne() throws {
        let off = try NightHarness(at: time(23))
        off.model.chooseTimer(.off)
        XCTAssertEqual(off.model.enterBedtime(), .entered)
        XCTAssertFalse(off.model.canExtendTimer, "the slot of +15 min is empty")
        XCTAssertFalse(off.model.extendTimer())
        XCTAssertEqual(off.model.timer.choice, .off)
        XCTAssertEqual(MixerModel.storedTimer(defaults: off.defaults), .off)
        XCTAssertNil(off.model.timer.endsAt)

        let counting = try NightHarness(at: time(23))
        counting.model.enterBedtime()
        XCTAssertTrue(counting.model.canExtendTimer)
        XCTAssertTrue(counting.model.extendTimer())
        XCTAssertEqual(counting.model.timer.endsAt, time(day: 18, 0))
        XCTAssertNil(MixerModel.storedTimer(defaults: counting.defaults), "and stores nothing")
    }

    func testTheVerticalAxisOfNightIsTheSessionLevel() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        night.engine.render(seconds: 1)
        night.model.setSessionLevel(0.4)
        night.engine.render(seconds: 0.1)
        XCTAssertEqual(night.engine.master, 0.4)
        // Back on the page the level is still the night's.
        night.model.leaveBedtime()
        XCTAssertEqual(night.model.sessionLevel, 0.4)
        // The mix is untouched: the level is not written into the layers.
        XCTAssertEqual(night.model.levels, HouseMix.pinkAndRain.levelsBySound())
    }

    func testNothingIsSoldOnNightOrOnTheNightPage() throws {
        let night = try NightHarness(at: time(12), free: true)
        night.model.offerPro()
        XCTAssertTrue(night.model.showPaywall, "midday: the sheet may go up")
        night.model.enterBedtime()
        XCTAssertFalse(night.model.showPaywall, "it comes down under Night")
        night.model.leaveBedtime()
        XCTAssertFalse(night.model.canSell)
        night.model.offerPro()
        XCTAssertFalse(night.model.showPaywall)
    }

    /// C40: the night page is by provenance and lasts the session. No clock
    /// ends it while it is looked at. It gives way when the app is opened by
    /// day with that night already over.
    func testTheNightPageLastsItsNight() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        night.model.leaveBedtime()
        XCTAssertTrue(night.model.isNightSession)

        // The timer ends at 23:45. At three in the morning it is still night.
        night.advance(seconds: 2_700)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertTrue(night.model.isNightSession, "the end of the timer does not change the page")
        night.jump(to: time(day: 18, 3))
        night.model.appDidBecomeActive()
        XCTAssertTrue(night.model.isNightSession)

        // The clock alone changes nothing; opening the app by day does.
        night.jump(to: time(day: 18, 8))
        XCTAssertTrue(night.model.isNightSession)
        XCTAssertFalse(night.model.canSell)
        night.model.appDidBecomeActive()
        XCTAssertFalse(night.model.isNightSession)
        XCTAssertTrue(night.model.canSell)
    }

    func testTheNightPageStaysWhileItsNightIsAlive() throws {
        let night = try NightHarness(at: time(23))
        night.model.chooseTimer(.off)
        night.model.enterBedtime()
        night.model.leaveBedtime()

        // Still playing at eight: it is the same night.
        night.jump(to: time(day: 18, 8))
        night.model.appDidBecomeActive()
        XCTAssertTrue(night.model.isNightSession)

        // Paused: the night is still open for twenty minutes.
        night.model.pause()
        night.advance(seconds: 600)
        night.model.appDidBecomeActive()
        XCTAssertTrue(night.model.isNightSession)
        night.advance(seconds: 600)
        night.model.appDidBecomeActive()
        XCTAssertFalse(night.model.isNightSession)

        // The Night screen itself is never taken away by the morning.
        let screen = try NightHarness(at: time(23))
        screen.model.enterBedtime()
        screen.advance(seconds: 2_700)
        screen.jump(to: time(day: 18, 8))
        screen.model.appDidBecomeActive()
        XCTAssertTrue(screen.model.isBedtime)
        XCTAssertEqual(screen.model.sessionEndedAt, time(23, 45), "Night says when it ended")
    }
}

// MARK: - Small Hours (C05, C27, C60)

@MainActor
final class SmallHoursModelTests: XCTestCase {
    private func time(day: Int = 18, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    func testItPlaysTheRecipeForEveryoneAndTouchesNothingOfThePerson() throws {
        for free in [true, false] {
            let night = try NightHarness(at: time(4), free: free)
            night.model.chooseTimer(.untilAsleep(90))
            night.model.setLevel(.rain, 0.7)
            let levels = night.model.levels
            let trial = night.purchases.trialState
            let breathing = night.model.breathing.settings

            XCTAssertEqual(night.model.startSmallHours(), .started, "free: \(free)")
            XCTAssertTrue(night.model.isSmallHours)
            XCTAssertTrue(night.model.isPlaying)
            // Low ocean and nothing else, with or without Pro.
            XCTAssertEqual(night.engine.gains.ocean, 0.3, "free: \(free)")
            for sound in SoundID.allCases where sound != .ocean {
                XCTAssertEqual(night.engine.gains.value(for: sound), 0, "\(sound.rawValue)")
            }
            // The tide at 8 a minute, for everyone, from the first second.
            XCTAssertEqual(night.engine.breath.rate, 8.0 / 60, accuracy: 0.000_01)
            XCTAssertEqual(night.engine.breath.weight, 1)
            // A three second entrance, at the level of the night.
            XCTAssertEqual(night.engine.starts, [.start(fadeIn: 3, level: 1)])
            XCTAssertEqual(night.engine.masters, [.master(level: 1, seconds: 3)])
            XCTAssertEqual(night.model.smallHours.minutesLeft, 20)

            // The mix, the timer and the tide of the person: as they were.
            XCTAssertEqual(night.model.levels, levels)
            XCTAssertEqual(night.model.timer.choice, .untilAsleep(90))
            XCTAssertFalse(night.model.timer.hasCount, "its twenty minutes are not the person's timer")
            XCTAssertNil(night.model.timer.endsAt)
            XCTAssertFalse(night.model.canExtendTimer)
            XCTAssertEqual(night.model.breathing.settings, breathing)
            XCTAssertFalse(night.model.breathing.isActive)
            // No trial starts and nothing is sold.
            XCTAssertEqual(night.purchases.trialState, trial)
            XCTAssertFalse(night.model.showPaywall)
            XCTAssertFalse(night.model.canSell)
            // Outside the app it goes by its own name, not the mix's.
            XCTAssertEqual(night.nowPlaying.title, Localized.string("madrugada.titulo"))
        }
    }

    func testItNeverSellsWhateverTheHour() throws {
        let night = try NightHarness(at: NightHarness.time(15), free: true)
        XCTAssertTrue(night.model.canSell, "three in the afternoon")
        night.model.offerPro()
        XCTAssertTrue(night.model.showPaywall)

        night.model.startSmallHours()
        XCTAssertFalse(night.model.showPaywall, "the sheet comes down")
        XCTAssertFalse(night.model.canSell)
        night.model.offerPro()
        XCTAssertEqual(night.model.setLevel(.thunder, 0.5), .needsPro)
        night.model.setBreathingEnabled(true)
        XCTAssertFalse(night.model.showPaywall)
        XCTAssertFalse(night.model.breathing.settings.isEnabled)
    }

    func testTheWholeTwentyMinutesAndTheSilentEnd() throws {
        let night = try NightHarness(at: time(4), free: true)
        let mixTitle = night.model.nowPlayingTitle
        night.model.startSmallHours()
        night.engine.render(seconds: 3)
        XCTAssertEqual(night.engine.envelope, 1)
        XCTAssertEqual(night.engine.state.breathWeight, 1, "guiding from the first inhale")

        // Minute 10.5: the tide starts to leave, over two and a half minutes.
        night.advance(seconds: 629)
        XCTAssertEqual(night.engine.breath.weight, 1)
        night.advance(seconds: 1)
        XCTAssertEqual(night.engine.breath.weight, 0)
        XCTAssertEqual(night.engine.breath.dissolveSeconds, 150)

        // Minute 15: the sea fades over the last five.
        night.advance(seconds: 269)
        XCTAssertEqual(night.engine.fades, [])
        XCTAssertNil(night.model.smallHours.windingDownMinutes)
        night.advance(seconds: 1)
        XCTAssertEqual(night.engine.fades, [.fade(level: 0, seconds: 300)])
        XCTAssertEqual(night.model.smallHours.windingDownMinutes, 5)
        XCTAssertEqual(night.engine.breath, .off)

        // Minute 20: nothing happens.
        night.advance(seconds: 299)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.isSmallHours)
        night.advance(seconds: 1)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertNil(night.model.pauseCause, "not paused: over")
        XCTAssertNil(night.model.sessionEndedAt, "and it does not say when it ended")
        XCTAssertNil(night.model.audioError)
        XCTAssertFalse(night.model.showPaywall)
        XCTAssertEqual(night.engine.stops.count, 1)
        XCTAssertEqual(night.engine.breath, .off)
        XCTAssertFalse(night.nowPlaying.isPlaying)
        XCTAssertEqual(night.nowPlaying.title, mixTitle)
        // What is behind it is the night page.
        XCTAssertTrue(night.model.isNightSession)
        XCTAssertFalse(night.model.isBedtime)
        XCTAssertFalse(night.model.canSell)

        // And the mix plays as the mix again: its gains, its timer.
        night.engine.render(seconds: 1)
        night.model.play()
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertGreaterThan(night.engine.gains.pink, 0)
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 0.8, level: 1))
        XCTAssertEqual(night.model.timer.remaining, 2_700)
    }

    func testAPauseStopsItsClockAndPlayResumesIt() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        night.advance(seconds: 300)
        night.model.togglePlayback()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertTrue(night.model.smallHours.isPaused)
        XCTAssertEqual(night.model.pauseCause, .person)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 1.5)])

        night.engine.render(seconds: 2)
        night.advance(seconds: 300)
        XCTAssertEqual(night.model.smallHours.minutesLeft, 15)
        night.model.togglePlayback()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 1), "at four everything comes in slowly")
        XCTAssertEqual(night.model.smallHours.elapsed, 300, accuracy: 0.001)
        XCTAssertEqual(night.engine.gains.ocean, 0.3)

        // Twenty minutes in pause and it is over, like any night.
        night.model.pause()
        night.advance(seconds: 1_200)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertFalse(night.model.smallHours.isActive)
    }

    func testResumingInsideItsClosingFadeRisesToWhereItStands() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        night.advance(seconds: 1_050)
        night.model.pause()
        night.engine.render(seconds: 2)
        night.model.play()
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 0.5))
        night.advance(seconds: 3)
        XCTAssertEqual(night.engine.fades.count, 1)
        night.advance(seconds: 1)
        XCTAssertEqual(night.engine.fades.last, .fade(level: 0, seconds: 146))
    }

    func testFromAMixThatPlaysTheRecipeTakesOverWithoutASilence() throws {
        let night = try NightHarness(at: time(1))
        night.model.play()
        night.engine.render(seconds: 1)
        night.advance(seconds: 60)
        XCTAssertTrue(night.model.timer.hasCount)

        XCTAssertEqual(night.model.startSmallHours(), .started)
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertEqual(night.engine.stops, [], "the engine is not stopped in between")
        XCTAssertEqual(night.engine.gains.ocean, 0.3)
        XCTAssertEqual(night.engine.gains.pink, 0)
        XCTAssertFalse(night.model.timer.hasCount, "the night that was playing is over")
        XCTAssertEqual(night.model.timer.choice, .firstUse)
        night.engine.render(seconds: 0.5)
        XCTAssertEqual(night.engine.envelope, 1, "the envelope never left")

        // Asked for again while it plays: its twenty minutes start over.
        night.advance(seconds: 600)
        XCTAssertEqual(night.model.smallHours.minutesLeft, 10)
        night.model.startSmallHours()
        XCTAssertEqual(night.model.smallHours.minutesLeft, 20)
        XCTAssertTrue(night.model.isPlaying)
    }

    func testFromNightEndedItTakesTheSlotOfPlusFifteen() throws {
        let night = try NightHarness(at: NightHarness.time(23))
        night.model.enterBedtime()
        night.advance(seconds: 2_700)
        XCTAssertTrue(night.model.isBedtime, "Night stays up after its night ended")
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertNotNil(night.model.sessionEndedAt)
        XCTAssertFalse(night.model.canExtendTimer, "nothing to add to: the slot is for Small Hours")

        night.jump(to: time(4))
        XCTAssertEqual(night.model.startSmallHours(), .started)
        XCTAssertNil(night.model.sessionEndedAt)
        XCTAssertFalse(night.model.isBedtimeDimmed)
        night.advance(seconds: 60)
        XCTAssertTrue(night.model.isBedtimeDimmed, "its screen dims like Night's")
        night.advance(seconds: 1_140)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertFalse(night.model.isBedtime, "it fades to the night page, not back to Night")
        XCTAssertTrue(night.model.isNightSession)
        XCTAssertFalse(night.model.isBedtimeDimmed)
    }

    func testLeavingItEarlyIsAPauseOfTheSeaAndTheNightPage() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        night.advance(seconds: 120)
        night.model.endSmallHours()
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: 1.5)])
        XCTAssertEqual(night.engine.breath, .off, "the tide does not stay behind for the mix")
        XCTAssertNil(night.model.pauseCause)
        XCTAssertTrue(night.model.isNightSession)
        XCTAssertFalse(night.model.smallHours.isActive)
        // Leaving twice does no harm.
        night.model.endSmallHours()
        XCTAssertEqual(night.engine.stops.count, 1)
    }

    func testAnInterruptionAtFourResumesTheRecipe() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        night.engine.render(seconds: 3)
        night.advance(seconds: 60)
        night.session.interrupt()
        XCTAssertTrue(night.model.smallHours.isPaused)
        night.advance(seconds: 120)
        night.session.endInterruption()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertEqual(night.engine.starts.last, .start(fadeIn: 3, level: 1))
        XCTAssertEqual(night.model.smallHours.elapsed, 60, accuracy: 0.001)
        XCTAssertEqual(night.engine.gains.ocean, 0.3)
    }

    func testAShortcutThatAsksForTheMixTakesItBack() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        XCTAssertEqual(night.model.playMixFromShortcut(.house(.pinkAndRain)), .started)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertGreaterThan(night.engine.gains.pink, 0)
        XCTAssertEqual(night.engine.breath, .off)
        XCTAssertTrue(night.model.timer.hasCount, "and the mix has its timer again")
    }

    func testAStartThatFailsLeavesNoSmallHoursBehind() throws {
        let night = try NightHarness(at: time(4))
        night.engine.failsToStart = true
        XCTAssertEqual(night.model.startSmallHours(), .failed)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertFalse(night.model.smallHours.isActive)
        XCTAssertEqual(night.model.startFailures, 1)
    }
}
