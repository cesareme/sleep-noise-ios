import XCTest
@testable import SleepNoise

/// The catalog keys come back as themselves, so a test reads which string
/// was chosen and with what figures.
private let keys: (String) -> String = { $0 }
private let hour: (Date) -> String = { date in
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
    let parts = calendar.dateComponents([.hour, .minute], from: date)
    return String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
}
private let posix = Locale(identifier: "en_US_POSIX")

// MARK: - The word of Night

@MainActor
final class NightStatusTests: XCTestCase {
    private let end = NightHarness.time(day: 18, 3, 42)

    func testPlayingSaysWhenItEndsAsAnHour() {
        var input = NightStatus.Input(isPlaying: true)
        XCTAssertEqual(NightStatus.resolve(input), .playing, "no timer: one word")

        input.timerEndsAt = end
        XCTAssertEqual(NightStatus.resolve(input), .fadesAt(end))

        input.timerEndsAtAnHour = true
        XCTAssertEqual(NightStatus.resolve(input), .until(end), "a blanket ends at its hour")
    }

    func testTheFinalFadeCountsWholeMinutes() {
        var input = NightStatus.Input(isPlaying: true, timerEndsAt: end, timerIsFading: true)
        input.fadingMinutes = 8
        XCTAssertEqual(NightStatus.resolve(input), .fading(minutes: 8))

        // Without the timer's own figure, the minutes left, rounded up.
        input.fadingMinutes = nil
        input.timerRemaining = 7 * 60 + 1
        XCTAssertEqual(NightStatus.resolve(input), .fading(minutes: 8))
        input.timerRemaining = 0
        XCTAssertEqual(NightStatus.resolve(input), .fading(minutes: 1), "never zero while it still fades")
    }

    func testTheLevelNoteWinsWhileItLastsAndOnlyWhilePlaying() {
        var input = NightStatus.Input(isPlaying: true, timerEndsAt: end, levelNote: 40)
        XCTAssertEqual(NightStatus.resolve(input), .level(percent: 40))
        input.isPlaying = false
        input.pauseCause = .person
        XCTAssertEqual(NightStatus.resolve(input), .paused, "a paused night does not say it plays")
    }

    func testAPauseSaysItsCauseWhenThereIsOneToSay() {
        func paused(_ cause: PauseCause) -> NightStatus {
            NightStatus.resolve(NightStatus.Input(pauseCause: cause, timerEndsAt: nil))
        }
        XCTAssertEqual(paused(.person), .paused)
        XCTAssertEqual(paused(.system), .paused, "the system does not say what interrupted")
        XCTAssertEqual(paused(.headphones), .pausedHeadphones)
        XCTAssertEqual(paused(.lostOutput), .pausedHeadphones)
        XCTAssertEqual(paused(.call), .pausedCall)
    }

    func testANightThatEndedSaysWhenAndAFailedStartSaysNoSound() {
        let ended = NightStatus.Input(endedAt: end)
        XCTAssertEqual(NightStatus.resolve(ended), .ended(at: end))

        var failed = NightStatus.Input(pauseCause: .person, startFailures: 1)
        XCTAssertEqual(NightStatus.resolve(failed), .noSound, "the error is said before the pause")
        failed.isPlaying = true
        XCTAssertEqual(NightStatus.resolve(failed), .playing)

        XCTAssertEqual(NightStatus.resolve(NightStatus.Input()), .paused, "never a state without a word")
    }

    func testWhatATouchDoesInEachState() {
        let sounding: [NightStatus] = [.playing, .fadesAt(end), .until(end), .fading(minutes: 3), .level(percent: 40)]
        for status in sounding {
            XCTAssertEqual(status.touch, .pause, "\(status)")
            XCTAssertTrue(status.isSounding, "\(status)")
            XCTAssertFalse(status.isOver)
        }
        for status in [NightStatus.paused, .pausedHeadphones, .pausedCall] {
            XCTAssertEqual(status.touch, .resume, "\(status)")
            XCTAssertFalse(status.isSounding, "the Horizon is absent while it is paused")
        }
        XCTAssertEqual(NightStatus.noSound.touch, .retry)
        XCTAssertFalse(NightStatus.noSound.isSounding)

        // Ended: a cheek on the glass starts nothing.
        let over = NightStatus.ended(at: end)
        XCTAssertEqual(over.touch, .nothing)
        XCTAssertTrue(over.isOver)
        XCTAssertNil(over.hintKey)
        XCTAssertNil(over.announcementKey)
    }

    func testTheWordsComeFromTheCatalogWithTheFiguresOfTheNight() {
        func text(_ status: NightStatus) -> String {
            status.text(localized: keys, time: hour, locale: posix)
        }
        XCTAssertEqual(text(.playing), "noche.estado.sonando")
        XCTAssertEqual(text(.paused), "noche.estado.pausa")
        XCTAssertEqual(text(.pausedHeadphones), "estado.pausa.auriculares")
        XCTAssertEqual(text(.pausedCall), "pagina.estado.pausa.llamada")
        XCTAssertEqual(text(.noSound), "noche.estado.sin_sonido")

        let formats: (String) -> String = { key in
            switch key {
            case "noche.estado.funde": return "fades %@"
            case "noche.estado.hasta": return "until %@"
            case "noche.estado.fundiendo": return "fading %lld"
            case "estado.volumen": return "at %lld"
            case "noche.estado.termino": return "ended %@"
            case "ax.noche.valor": return "%1$@. %2$@"
            default: return key
            }
        }
        func formatted(_ status: NightStatus) -> String {
            status.text(localized: formats, time: hour, locale: posix)
        }
        XCTAssertEqual(formatted(.fadesAt(end)), "fades 03:42")
        XCTAssertEqual(formatted(.until(end)), "until 03:42")
        XCTAssertEqual(formatted(.fading(minutes: 8)), "fading 8")
        XCTAssertEqual(formatted(.level(percent: 40)), "at 40")
        XCTAssertEqual(formatted(.ended(at: end)), "ended 03:42")

        // VoiceOver: the hour of the clock, then the word.
        XCTAssertEqual(
            NightStatus.fadesAt(end).spoken(clock: "03:07", localized: formats, time: hour, locale: posix),
            "03:07. fades 03:42"
        )
    }

    func testTheHintAndTheAnnouncementFollowTheState() {
        XCTAssertEqual(NightStatus.playing.hintKey, "ax.noche.pista")
        XCTAssertEqual(NightStatus.paused.hintKey, "ax.noche.pista.reanudar")
        XCTAssertEqual(NightStatus.noSound.hintKey, "ax.noche.pista.error")
        XCTAssertEqual(NightStatus.fadesAt(end).announcementKey, "noche.estado.sonando")
        XCTAssertEqual(NightStatus.pausedHeadphones.announcementKey, "noche.estado.pausa")
    }
}

// MARK: - The vertical axis (C51)

final class NightAxisTests: XCTestCase {
    func testUpIsMoreAndTheRuleIsTheWholeRange() {
        XCTAssertEqual(NightAxis.level(from: 1, translation: 120), 0.4, accuracy: 0.0001, "120 pt down from the top")
        XCTAssertEqual(NightAxis.level(from: 0.4, translation: -60), 0.7, accuracy: 0.0001, "60 pt up")
        XCTAssertEqual(NightAxis.level(from: 0.5, translation: 0), 0.5)
        XCTAssertEqual(NightAxis.level(from: 1, translation: NightAxis.travel), MixerModel.minimumSessionLevel)
    }

    func testItNeverLeavesTheRangeAndNeverSwitchesTheNightOff() {
        XCTAssertEqual(NightAxis.level(from: 0.9, translation: -500), 1)
        XCTAssertEqual(NightAxis.level(from: 0.2, translation: 500), MixerModel.minimumSessionLevel)
        XCTAssertGreaterThan(NightAxis.level(from: 0.2, translation: 5_000), 0, "a drag turns the night down, not off")
    }

    func testVoiceOverMovesItByStepsOnAGrid() {
        XCTAssertEqual(NightAxis.stepped(0.4, up: true), 0.45, accuracy: 0.0001)
        XCTAssertEqual(NightAxis.stepped(0.4, up: false), 0.35, accuracy: 0.0001)
        XCTAssertEqual(NightAxis.stepped(0.42, up: true), 0.45, accuracy: 0.0001, "an odd level lands on the grid")
        XCTAssertEqual(NightAxis.stepped(1, up: true), 1)
        XCTAssertEqual(NightAxis.stepped(MixerModel.minimumSessionLevel, up: false), MixerModel.minimumSessionLevel)
    }

    func testTheFigureAndTheRuleAreTheLevel() {
        XCTAssertEqual(NightAxis.percent(0.4), 40)
        XCTAssertEqual(NightAxis.percent(1), 100)
        XCTAssertEqual(NightAxis.percent(0), 5, "what is said is what sounds")
        XCTAssertEqual(NightAxis.ruleLength(1), NightAxis.travel)
        XCTAssertEqual(NightAxis.ruleLength(0.4), 80, accuracy: 0.001)
    }

    /// The finger on the screen ends up as the gain of the engine.
    @MainActor
    func testADragOnNightIsTheMasterGainOfTheEngine() throws {
        let night = try NightHarness(at: NightHarness.time(23))
        night.model.enterBedtime()
        night.engine.render(seconds: 1)

        var touch = NightTouch()
        touch.begin(at: night.clock.now, level: night.model.sessionLevel)
        XCTAssertNil(touch.move(translation: CGSize(width: 0, height: 6)), "inside the slop nothing moves")
        let level = try XCTUnwrap(touch.move(translation: CGSize(width: 2, height: 120)))
        night.model.setSessionLevel(level)
        night.engine.render(seconds: 0.2)
        XCTAssertEqual(night.model.sessionLevel, 0.4, accuracy: 0.0001)
        XCTAssertEqual(night.engine.master, 0.4, accuracy: 0.001)
        XCTAssertEqual(touch.end(at: night.clock.now.addingTimeInterval(1), allowsBack: true), .nothing)
        XCTAssertTrue(night.model.isPlaying, "a drag is not a touch: nothing pauses")
        XCTAssertTrue(night.model.isBedtime, "and it does not go back")

        // The mix is untouched and the system volume is nobody's business.
        XCTAssertEqual(night.model.levels, HouseMix.pinkAndRain.levelsBySound())
    }
}

// MARK: - One finger on the screen

final class NightTouchTests: XCTestCase {
    private let down = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func touch(liftedAfter seconds: TimeInterval, allowsBack: Bool = true) -> NightTouch.Outcome {
        var touch = NightTouch()
        touch.begin(at: down, level: 1)
        return touch.end(at: down.addingTimeInterval(seconds), allowsBack: allowsBack)
    }

    func testAShortTouchIsTheButton() {
        XCTAssertEqual(touch(liftedAfter: 0.05), .tap)
        XCTAssertEqual(touch(liftedAfter: 0.59), .tap)
    }

    func testAFingerThatStaysAndLiftsGoesBack() {
        XCTAssertEqual(touch(liftedAfter: 0.6), .back)
        XCTAssertEqual(touch(liftedAfter: 2), .back)
    }

    func testAHandRestingOnTheGlassDoesNothing() {
        XCTAssertEqual(touch(liftedAfter: 2.01), .nothing)
        XCTAssertEqual(touch(liftedAfter: 40), .nothing)
    }

    func testSmallHoursHasNoWayBack() {
        XCTAssertEqual(touch(liftedAfter: 1, allowsBack: false), .nothing)
        XCTAssertEqual(touch(liftedAfter: 0.1, allowsBack: false), .tap)
    }

    func testAThumbThatSettlesIsStillATouch() {
        var touch = NightTouch()
        touch.begin(at: down, level: 0.8)
        XCTAssertNil(touch.move(translation: CGSize(width: 4, height: -7)))
        XCTAssertFalse(touch.isAdjustingLevel)
        XCTAssertEqual(touch.end(at: down.addingTimeInterval(0.2), allowsBack: true), .tap)
    }

    func testAVerticalDragIsTheLevelAndNothingElse() {
        var touch = NightTouch()
        touch.begin(at: down, level: 0.8)
        XCTAssertEqual(try XCTUnwrap(touch.move(translation: CGSize(width: 3, height: -20))), 0.9, accuracy: 0.0001)
        XCTAssertTrue(touch.isAdjustingLevel)
        // Once it is the level it stays the level, wherever the finger goes.
        XCTAssertEqual(try XCTUnwrap(touch.move(translation: CGSize(width: 80, height: 40))), 0.6, accuracy: 0.0001)
        XCTAssertEqual(touch.end(at: down.addingTimeInterval(1), allowsBack: true), .nothing)
        XCTAssertFalse(touch.isDown)
    }

    func testThereIsNoSidewaysGesture() {
        var touch = NightTouch()
        touch.begin(at: down, level: 0.8)
        XCTAssertNil(touch.move(translation: CGSize(width: 40, height: 6)))
        XCTAssertNil(touch.move(translation: CGSize(width: 40, height: 90)), "it does not turn into a level drag")
        XCTAssertFalse(touch.isAdjustingLevel)
        XCTAssertEqual(touch.end(at: down.addingTimeInterval(1), allowsBack: true), .nothing)
    }

    func testADiagonalBeyondThirtyDegreesIsNotVertical() {
        var steep = NightTouch()
        steep.begin(at: down, level: 1)
        XCTAssertNotNil(steep.move(translation: CGSize(width: 10, height: 20)))
        var shallow = NightTouch()
        shallow.begin(at: down, level: 1)
        XCTAssertNil(shallow.move(translation: CGSize(width: 15, height: 20)))
    }

    func testNothingCountsWithoutAFingerDownAndACancelForgetsTheTouch() {
        var touch = NightTouch()
        XCTAssertNil(touch.move(translation: CGSize(width: 0, height: 50)))
        XCTAssertEqual(touch.end(at: down, allowsBack: true), .nothing)
        touch.begin(at: down, level: 1)
        touch.cancel()
        XCTAssertEqual(touch.end(at: down.addingTimeInterval(0.1), allowsBack: true), .nothing)
    }

    func testTheThumbThatUnlocksIsNotCounted() {
        XCTAssertFalse(NightTouch.isGuarded(wokeAt: nil, touchAt: down))
        XCTAssertTrue(NightTouch.isGuarded(wokeAt: down, touchAt: down))
        XCTAssertTrue(NightTouch.isGuarded(wokeAt: down, touchAt: down.addingTimeInterval(0.29)))
        XCTAssertFalse(NightTouch.isGuarded(wokeAt: down, touchAt: down.addingTimeInterval(0.31)))
        XCTAssertFalse(NightTouch.isGuarded(wokeAt: down, touchAt: down.addingTimeInterval(-5)), "a touch from before")
        XCTAssertEqual(BedtimeScreenPolicy.wakeGuard, 0.3)
    }
}

// MARK: - Where things sit, and what covers the page

final class NightLayoutTests: XCTestCase {
    func testEverythingHangsFromTheHorizonAtAThird() {
        let layout = NightLayout(fullHeight: 852)
        XCTAssertEqual(layout.horizonY, 284)
        XCTAssertEqual(layout.clockTop, 340)
        XCTAssertEqual(layout.figureTop, 396, "the figure of Small Hours clears the band of the water line")
        XCTAssertEqual(layout.ruleTop, 184, "the rule of the level is centred on the Horizon")
        XCTAssertGreaterThanOrEqual(layout.figureTop, layout.horizonY + TideLine.band / 2)

        // A short screen keeps the proportion, never the absolute figure.
        XCTAssertEqual(NightLayout(fullHeight: 667).horizonY, 224)
        XCTAssertEqual(NightLayout.channel, 24, "dead channel between two borderless targets")
    }

    func testSmallHoursCoversNightAndNothingCoversByItself() {
        XCTAssertNil(NightCover.Surface.resolve(isBedtime: false, isSmallHours: false))
        XCTAssertEqual(NightCover.Surface.resolve(isBedtime: true, isSmallHours: false), .night)
        XCTAssertEqual(NightCover.Surface.resolve(isBedtime: false, isSmallHours: true), .smallHours)
        XCTAssertEqual(NightCover.Surface.resolve(isBedtime: true, isSmallHours: true), .smallHours)
    }

    func testThePageFadesOverTwoSecondsAndReduceMotionShortensIt() {
        XCTAssertEqual(NightCover.fade(from: nil, to: .night, reduceMotion: false), 2)
        XCTAssertEqual(NightCover.fade(from: .night, to: nil, reduceMotion: false), 2)
        XCTAssertEqual(NightCover.fade(from: .smallHours, to: nil, reduceMotion: false), 2)
        XCTAssertEqual(NightCover.fade(from: nil, to: .night, reduceMotion: true), 0.25)
        // Black to black: only the content changes.
        XCTAssertEqual(NightCover.fade(from: .night, to: .smallHours, reduceMotion: false), 0.25)
        XCTAssertLessThanOrEqual(NightCover.fade(from: nil, to: .smallHours, reduceMotion: false), Motion.longest)
    }

    func testANightActionIsALargeTarget() {
        XCTAssertEqual(NightAction.height(dynamicType: .large), 64)
        XCTAssertEqual(NightAction.height(dynamicType: .accessibility2), 64)
        XCTAssertEqual(NightAction.height(dynamicType: .accessibility3), 96)
    }
}

// MARK: - Night as the person goes through it

@MainActor
final class NightScreenFlowTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func status(_ night: NightHarness, levelNote: Int? = nil) -> NightStatus {
        NightStatus.resolve(NightStatus.Input(night.model, levelNote: levelNote))
    }

    private func surface(_ night: NightHarness) -> NightCover.Surface? {
        NightCover.Surface.resolve(isBedtime: night.model.isBedtime, isSmallHours: night.model.isSmallHours)
    }

    /// What the screen does with a touch, as the view does it.
    private func touch(_ night: NightHarness) {
        switch status(night).touch {
        case .pause: night.model.pause()
        case .resume, .retry: night.model.play()
        case .nothing: break
        }
    }

    func testFromTheBarThroughAPauseToTheNightPage() throws {
        let night = try NightHarness(at: time(23))
        XCTAssertNil(surface(night))
        XCTAssertEqual(night.model.enterBedtime(), .entered)
        XCTAssertEqual(surface(night), .night)
        XCTAssertEqual(status(night), .fadesAt(time(23, 45)), "the timer of the first use: 45 minutes")
        XCTAssertTrue(night.model.canExtendTimer)

        touch(night)
        XCTAssertEqual(status(night), .paused)
        XCTAssertFalse(status(night).isSounding)
        night.advance(seconds: 120)
        touch(night)
        XCTAssertEqual(status(night), .fadesAt(time(23, 47)), "what was left waited through the pause")

        // "+15 min" moves the hour of the word.
        XCTAssertTrue(night.model.extendTimer())
        XCTAssertEqual(status(night), .fadesAt(time(day: 18, 0, 2)))

        // Back: the page behind is the night page, and nothing sells.
        night.model.leaveBedtime()
        XCTAssertNil(surface(night))
        XCTAssertTrue(night.model.isNightSession)
        XCTAssertTrue(night.model.isPlaying, "leaving Night does not stop the night")
        XCTAssertFalse(night.model.canSell)
    }

    func testWithoutATimerThePlaceOfPlusFifteenIsEmpty() throws {
        let night = try NightHarness(at: time(23))
        night.model.chooseTimer(.firstUse.with(mode: .off))
        night.model.enterBedtime()
        XCTAssertEqual(status(night), .playing)
        XCTAssertFalse(night.model.canExtendTimer, "Night never creates a timer (C47)")
        XCTAssertFalse(night.model.extendTimer())
        XCTAssertEqual(night.model.timer.choice.mode, .off)
    }

    func testABlanketSaysItsHour() throws {
        let night = try NightHarness(at: time(23))
        night.model.chooseTimer(.blanket(hour: 7))
        night.model.enterBedtime()
        XCTAssertEqual(status(night), .until(time(day: 18, 7)))
    }

    func testTheFinalFadeIsSaidInMinutesAndTheLevelNoteForAMoment() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        night.advance(seconds: 37 * 60)
        XCTAssertEqual(status(night), .fading(minutes: 8))
        XCTAssertTrue(status(night).isSounding, "the Horizon stays while it fades: the word says it")

        night.model.setSessionLevel(NightAxis.level(from: night.model.sessionLevel, translation: 120))
        XCTAssertEqual(status(night, levelNote: NightAxis.percent(night.model.sessionLevel)), .level(percent: 40))
        XCTAssertEqual(status(night), .fading(minutes: 8), "and the word comes back")
    }

    func testEarbudsOutSayItAndOfferTheSpeaker() throws {
        let night = try NightHarness(at: time(23))
        night.session.currentRoute = ScriptedSession.airPods
        night.model.enterBedtime()
        night.session.loseOutput()
        XCTAssertEqual(status(night), .pausedHeadphones)
        XCTAssertNotNil(night.model.speakerOfferUntil)
        XCTAssertEqual(status(night).touch, .resume, "a touch anywhere does what the word offers")
        touch(night)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertNil(night.model.speakerOfferUntil)
        XCTAssertLessThanOrEqual(night.model.sessionLevel, RoutePolicy.speakerMasterCap)
    }

    /// When the timer runs out, Night says when and offers Small Hours in
    /// the place of "+15 min". From there to the end, nothing sells.
    func testTheNightEndsAndSmallHoursTakesTheSlot() throws {
        let night = try NightHarness(at: time(23), free: true)
        night.model.enterBedtime()
        night.advance(seconds: 45 * 60)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(surface(night), .night, "Night stays: it says when it ended")
        XCTAssertEqual(status(night), .ended(at: time(23, 45)))
        XCTAssertTrue(status(night).isOver)
        XCTAssertFalse(night.model.canExtendTimer, "\"+15 min\" means nothing now")

        // A touch does nothing: the screen is not a button any more.
        touch(night)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(status(night), .ended(at: time(23, 45)))

        // The button, hours later.
        night.jump(to: time(day: 18, 3, 41))
        XCTAssertEqual(night.model.startSmallHours(), .started)
        XCTAssertEqual(surface(night), .smallHours)
        XCTAssertTrue(night.model.isPlaying, "the recipe plays for everyone, without Pro")
        XCTAssertEqual(night.model.smallHours.minutesLeft, 20)
        XCTAssertFalse(night.model.canSell)
        night.model.offerPro()
        XCTAssertFalse(night.model.showPaywall, "Small Hours never opens the Pro sheet")
        XCTAssertEqual(night.purchases.trialState, .ended, "and starts no trial")

        // Twenty minutes later nothing happens: the night page is there.
        night.advance(seconds: 20 * 60)
        XCTAssertNil(surface(night))
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertTrue(night.model.isNightSession)
        XCTAssertNil(night.model.sessionEndedAt, "nothing is said about it")
        XCTAssertFalse(night.model.showPaywall)
    }

    func testStoppingSmallHoursLeavesTheNightPage() throws {
        let night = try NightHarness(at: time(day: 18, 3, 41))
        night.model.startSmallHours()
        XCTAssertEqual(surface(night), .smallHours)
        night.advance(seconds: 90)
        night.model.endSmallHours()
        XCTAssertNil(surface(night))
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertTrue(night.model.isNightSession)
    }

    func testAFailedResumeSaysNoSoundAndATouchTriesAgain() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        touch(night)
        night.engine.failsToStart = true
        touch(night)
        XCTAssertEqual(status(night), .noSound)
        XCTAssertEqual(surface(night), .night, "Night stays in front")
        night.engine.failsToStart = false
        touch(night)
        XCTAssertEqual(status(night), .fadesAt(time(23, 45)))
    }

    // MARK: The two sentences of the first time (C65)

    func testTheFirstNightShowsItsTwoSentencesOnce() throws {
        let night = try NightHarness(at: time(23))
        XCTAssertFalse(night.model.showsNightIntro)
        night.model.enterBedtime()
        XCTAssertTrue(night.model.showsNightIntro)
        XCTAssertFalse(night.defaults.bool(forKey: MixerModel.nightIntroKey), "not seen until they have been on screen")

        night.model.nightIntroDidShow()
        XCTAssertFalse(night.model.showsNightIntro)
        XCTAssertTrue(night.defaults.bool(forKey: MixerModel.nightIntroKey))

        night.model.leaveBedtime()
        night.model.enterBedtime()
        XCTAssertFalse(night.model.showsNightIntro, "never again on this install")
    }

    func testSentencesNobodyReadAreShownTheNextTime() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        night.model.leaveBedtime()
        XCTAssertFalse(night.model.showsNightIntro, "they do not follow to the page")
        night.model.enterBedtime()
        XCTAssertTrue(night.model.showsNightIntro)
    }

    // MARK: Locking the iPhone (C47)

    func testLockingWhileTheNightPlaysLeavesNightInFront() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        XCTAssertTrue(night.model.enterBedtimeOnLock(sheetIsOpen: false))
        XCTAssertEqual(surface(night), .night)
        XCTAssertFalse(night.model.enterBedtimeOnLock(sheetIsOpen: false), "already there")
    }

    func testALockIsOnlyALockByDayAtRestOrUnderASheet() throws {
        let day = try NightHarness(at: time(15))
        day.model.play()
        XCTAssertFalse(day.model.enterBedtimeOnLock(sheetIsOpen: false), "by day a lock is not \"in bed\"")
        XCTAssertFalse(day.model.isBedtime)

        let rest = try NightHarness(at: time(23))
        XCTAssertFalse(rest.model.enterBedtimeOnLock(sheetIsOpen: false), "a lock never starts the sound")
        XCTAssertFalse(rest.model.isPlaying)

        let sheet = try NightHarness(at: time(23))
        sheet.model.play()
        XCTAssertFalse(sheet.model.enterBedtimeOnLock(sheetIsOpen: true), "the sheet rules")

        let smallHours = try NightHarness(at: time(day: 18, 3))
        smallHours.model.startSmallHours()
        XCTAssertFalse(smallHours.model.enterBedtimeOnLock(sheetIsOpen: false))
        XCTAssertFalse(smallHours.model.isBedtime)
    }

    func testTheRuleOfTheLockIsOneFunction() {
        XCTAssertTrue(BedtimeScreenPolicy.entersOnLock(isPlaying: true, isCovered: false, sheetIsOpen: false, isNight: true))
        XCTAssertFalse(BedtimeScreenPolicy.entersOnLock(isPlaying: false, isCovered: false, sheetIsOpen: false, isNight: true))
        XCTAssertFalse(BedtimeScreenPolicy.entersOnLock(isPlaying: true, isCovered: true, sheetIsOpen: false, isNight: true))
        XCTAssertFalse(BedtimeScreenPolicy.entersOnLock(isPlaying: true, isCovered: false, sheetIsOpen: true, isNight: true))
        XCTAssertFalse(BedtimeScreenPolicy.entersOnLock(isPlaying: true, isCovered: false, sheetIsOpen: false, isNight: false))
    }

    // MARK: Dimming and the screen (C46)

    func testEveryKindOfTouchBringsTheInkBack() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        night.advance(seconds: 60)
        XCTAssertTrue(night.model.isBedtimeDimmed)
        // Dimmed is not a state: the word is the same and the touch pauses.
        XCTAssertEqual(status(night), .fadesAt(time(23, 45)))
        night.model.noteBedtimeTouch()
        touch(night)
        XCTAssertFalse(night.model.isBedtimeDimmed)
        XCTAssertEqual(status(night), .paused)

        // A paused Night dims too, and so does one that has ended.
        night.advance(seconds: 60)
        XCTAssertTrue(night.model.isBedtimeDimmed)
        XCTAssertEqual(BedtimeScreenPolicy.dimmedOpacity, 0.6, "the floor of 03 §3.7: 3.3:1 on black")
    }

    func testTheScreenIsHeldAwakeOnlyAsTheSettingSaysAndOnlyOnNight() throws {
        let night = try NightHarness(at: time(23))
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: true), "the page never holds the screen")
        night.model.enterBedtime()
        XCTAssertTrue(night.model.bedtimeKeepsScreenAwake(isCharging: true), "by default, while it charges")
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: false))
        night.model.setKeepScreenOn(.always)
        XCTAssertTrue(night.model.bedtimeKeepsScreenAwake(isCharging: false))
        night.model.setKeepScreenOn(.never)
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: true))
        night.model.setKeepScreenOn(.always)
        night.model.leaveBedtime()
        XCTAssertFalse(night.model.bedtimeKeepsScreenAwake(isCharging: true), "back on the page the iPhone sleeps as usual")
    }
}

// MARK: - Small Hours

final class SmallHoursStatusTests: XCTestCase {
    func testAFigureAndAWordOnlyForTheLastMinutes() {
        let playing = SmallHoursStatus.resolve(.init(isPlaying: true, minutesLeft: 14))
        XCTAssertEqual(playing, .playing(minutes: 14))
        XCTAssertNil(playing.word(localized: keys, locale: posix), "no word: the figure is enough")
        XCTAssertTrue(playing.isSounding)

        let winding = SmallHoursStatus.resolve(.init(isPlaying: true, minutesLeft: 4, windingDownMinutes: 4))
        XCTAssertEqual(winding, .windingDown(minutes: 4))
        // The minutes are the figure: the words under it do not repeat them.
        XCTAssertEqual(winding.word(localized: keys, locale: posix), "madrugada.retirada.palabra")
        XCTAssertEqual(
            winding.figure(localized: { $0 == "madrugada.quedan" ? "%lld min" : $0 }, locale: posix),
            "4 min"
        )
    }

    func testPausedThereIsNoWordAndTheFigureStands() {
        let paused = SmallHoursStatus.resolve(.init(isPlaying: false, minutesLeft: 14, windingDownMinutes: nil))
        XCTAssertEqual(paused, .paused(minutes: 14))
        XCTAssertNil(paused.word(localized: keys, locale: posix))
        XCTAssertFalse(paused.isSounding)
        XCTAssertEqual(paused.minutes, 14)
        XCTAssertEqual(paused.hintKey, "ax.madrugada.pista.reanudar")

        // Paused inside the last minutes: still no word.
        let late = SmallHoursStatus.resolve(.init(isPlaying: false, minutesLeft: 3, windingDownMinutes: 3))
        XCTAssertEqual(late, .paused(minutes: 3))
    }

    func testAFailedResumeSaysNoSound() {
        let failed = SmallHoursStatus.resolve(.init(isPlaying: false, minutesLeft: 9, startFailures: 1))
        XCTAssertEqual(failed, .noSound(minutes: 9))
        XCTAssertEqual(failed.word(localized: keys, locale: posix), "noche.estado.sin_sonido")
        XCTAssertEqual(failed.hintKey, "ax.noche.pista.error")
    }

    func testVoiceOverSaysTheMinutesAndTheState() {
        let formats: (String) -> String = { key in
            switch key {
            case "ax.madrugada.valor": return "%1$lld left. %2$@"
            case "ax.madrugada.retirada": return "winding, %lld left"
            default: return key
            }
        }
        XCTAssertEqual(SmallHoursStatus.playing(minutes: 20).spoken(localized: formats), "20 left. noche.estado.sonando")
        XCTAssertEqual(SmallHoursStatus.paused(minutes: 14).spoken(localized: formats), "14 left. noche.estado.pausa")
        XCTAssertEqual(SmallHoursStatus.windingDown(minutes: 4).spoken(localized: formats), "winding, 4 left")
        XCTAssertEqual(SmallHoursStatus.playing(minutes: 1).hintKey, "ax.madrugada.pista")
    }

    func testTheWaterLineLosesItsCourseAsTheTideDissolves() {
        let recipe = SmallHoursRecipe.standard
        XCTAssertEqual(SmallHoursWater.amplitude(elapsed: 0, recipe: recipe), 1)
        XCTAssertEqual(SmallHoursWater.amplitude(elapsed: recipe.tideGuideEnd, recipe: recipe), 1)
        let middle = (recipe.tideGuideEnd + recipe.tideDissolveEnd) / 2
        XCTAssertEqual(SmallHoursWater.amplitude(elapsed: middle, recipe: recipe), 0.5, accuracy: 0.001)
        XCTAssertEqual(SmallHoursWater.amplitude(elapsed: recipe.tideDissolveEnd, recipe: recipe), 0)
        XCTAssertEqual(SmallHoursWater.amplitude(elapsed: recipe.duration, recipe: recipe), 0)
    }

    func testTheWaterLineIsTheBreathOfTheRecipeFromTheAnchorOfTheAudio() {
        let recipe = SmallHoursRecipe.standard
        let anchor = Date(timeIntervalSinceReferenceDate: 800_000_000)
        XCTAssertEqual(SmallHoursWater.level(at: anchor, anchor: nil, elapsed: 0, recipe: recipe), 0, "no tide, no water")
        XCTAssertEqual(SmallHoursWater.level(at: anchor, anchor: anchor, elapsed: 0, recipe: recipe), 0, accuracy: 0.001)

        // Eight breaths a minute: 7.5 s a cycle, high water at the end of
        // the inhale.
        let parameters = BreathParameters.guided(breathsPerMinute: recipe.breathsPerMinute)
        let top = Double(parameters.inhale) * 7.5
        XCTAssertEqual(
            SmallHoursWater.level(at: anchor.addingTimeInterval(top), anchor: anchor, elapsed: top, recipe: recipe),
            1,
            accuracy: 0.001
        )
        // The same instant of a later breath, half dissolved: half the height.
        let middle = (recipe.tideGuideEnd + recipe.tideDissolveEnd) / 2
        XCTAssertEqual(
            SmallHoursWater.level(at: anchor.addingTimeInterval(top), anchor: anchor, elapsed: middle, recipe: recipe),
            0.5,
            accuracy: 0.001
        )
    }

    /// The screen reads the session: the figure goes down by the minute,
    /// the word arrives for the last five, a touch pauses the clock.
    @MainActor
    func testTheScreenFollowsTheSession() throws {
        let night = try NightHarness(at: NightHarness.time(day: 18, 3, 41))
        night.model.startSmallHours()
        func status() -> SmallHoursStatus {
            SmallHoursStatus.resolve(.init(
                isPlaying: night.model.isPlaying,
                minutesLeft: night.model.smallHours.minutesLeft,
                windingDownMinutes: night.model.smallHours.windingDownMinutes,
                startFailures: night.model.startFailures
            ))
        }
        XCTAssertEqual(status(), .playing(minutes: 20))
        XCTAssertNotNil(night.model.smallHours.tideAnchor, "the tide guides: the line is water")
        night.advance(seconds: 6 * 60)
        XCTAssertEqual(status(), .playing(minutes: 14))

        night.model.pause()
        XCTAssertEqual(status(), .paused(minutes: 14))
        night.advance(seconds: 300)
        XCTAssertEqual(status(), .paused(minutes: 14), "the figure stands still")
        night.model.play()
        XCTAssertEqual(status(), .playing(minutes: 14))

        night.advance(seconds: 8 * 60)
        XCTAssertNil(night.model.smallHours.tideAnchor, "the tide has gone: the Horizon")
        night.advance(seconds: 2 * 60)
        XCTAssertEqual(status(), .windingDown(minutes: 4))
    }
}

// MARK: - The catalog of the night

/// Nothing is sold at night: the strings of Night and Small Hours exist in
/// both languages and none of them says Pro, trial or a price.
final class NightCatalogTests: XCTestCase {
    static let keys = [
        "barra.noche", "barra.noche.ax",
        "noche.estado.sonando", "noche.estado.funde", "noche.estado.hasta", "noche.estado.fundiendo",
        "noche.estado.pausa", "noche.estado.sin_sonido", "noche.estado.termino", "noche.primera",
        "noche.volver", "estado.volumen", "estado.pausa.auriculares", "pagina.estado.pausa.llamada",
        "ruta.seguir_altavoz", "comun.mas15", "comun.parar",
        "madrugada.titulo", "madrugada.estado", "madrugada.quedan", "madrugada.retirada.palabra",
        "ax.noche.pantalla", "ax.noche.valor", "ax.noche.pista", "ax.noche.pista.reanudar",
        "ax.noche.pista.error", "ax.accion.pausar", "ax.accion.reanudar", "ax.accion.volver",
        "ax.anuncio.pagina", "ax.volumen", "ax.altavoz.pista", "ax.mas15", "ax.la.madrugada",
        "ax.madrugada.valor", "ax.madrugada.pista", "ax.madrugada.pista.reanudar", "ax.madrugada.retirada"
    ]

    func testEveryNightStringExistsInBothLanguages() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in Self.keys {
            for language in ["en", "es"] {
                let found = TimerCatalogTests.values(key, language, in: strings)
                XCTAssertFalse(found.isEmpty, "\(key) [\(language)] is missing")
                XCTAssertFalse(found.contains { $0.isEmpty }, "\(key) [\(language)] is empty")
            }
        }
    }

    func testNothingOnNightOrSmallHoursSells() throws {
        let strings = try TimerCatalogTests.catalog()
        // Whole words, and the stems of the verbs of a sale.
        let words = ["pro", "prueba", "trial", "buy"]
        let stems = ["compr", "purchas", "desbloque", "unlock"]
        for key in Self.keys {
            for language in ["en", "es"] {
                for value in TimerCatalogTests.values(key, language, in: strings) {
                    XCTAssertFalse(value.contains("€") || value.contains("$ "), "\(key) [\(language)] has a price")
                    let said = value.lowercased().components(separatedBy: CharacterSet.letters.inverted)
                    for word in words {
                        XCTAssertFalse(said.contains(word), "\(key) [\(language)] says \"\(word)\": \(value)")
                    }
                    for stem in stems {
                        XCTAssertFalse(
                            said.contains { $0.hasPrefix(stem) },
                            "\(key) [\(language)] says \"\(stem)…\": \(value)"
                        )
                    }
                }
            }
        }
    }

    func testTheNightHasNoExclamationsAndNoVetoedWords() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in Self.keys {
            for language in ["en", "es"] {
                for value in TimerCatalogTests.values(key, language, in: strings) {
                    XCTAssertFalse(value.contains("!") || value.contains("¡"), "\(key) [\(language)]")
                }
            }
            for value in TimerCatalogTests.values(key, "es", in: strings) {
                let text = value.lowercased()
                for word in ["timer", "mix", "preset"] {
                    XCTAssertFalse(text.contains(word), "\(key) [es] contains \"\(word)\"")
                }
            }
        }
    }
}
