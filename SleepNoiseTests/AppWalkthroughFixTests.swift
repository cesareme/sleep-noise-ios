import XCTest
@testable import SleepNoise

// What the walk through the whole app found, pinned down: each test here
// failed, or could not be written, before its correction.

@MainActor
final class WalkthroughModelTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func freshDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // MARK: Every layer taken to zero while it plays

    /// The first-use mix is rain and pink. Dragged to zero and let go,
    /// nothing is left to sound: the night ends as "Clear" ends it, instead
    /// of an engine and a timer running on silence under "Playing".
    func testTheNightEndsWhenTheLastLayerIsLetGoAtZero() throws {
        let night = try NightHarness(at: time(12))
        night.model.play()
        night.engine.render(seconds: 1)
        XCTAssertTrue(night.model.timer.hasCount, "the timer of the first use counts")

        night.model.beginLevelGesture()
        night.model.setLevel(.rain, 0)
        night.model.endLevelGesture()
        XCTAssertTrue(night.model.isPlaying, "pink still sounds")

        night.engine.forgetCalls()
        night.model.beginLevelGesture()
        night.model.setLevel(.pink, 0)
        XCTAssertTrue(night.model.isPlaying, "the finger is still down: the level may come back")
        night.model.endLevelGesture()

        XCTAssertFalse(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause, "silent, not paused")
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: PlaybackFade.pause)], "it leaves like a pause")
        XCTAssertFalse(night.model.timer.hasCount, "no timer runs on silence")
        XCTAssertFalse(night.nowPlaying.isPlaying)
        let status = PageStatus.resolve(.init(
            isPlaying: night.model.isPlaying,
            pauseCause: night.model.pauseCause,
            isSilent: night.model.isSilent
        ))
        XCTAssertEqual(status, .silent)
    }

    func testALevelThatComesBackUnderTheSameFingerEndsNothing() throws {
        let night = try NightHarness(at: time(12))
        night.model.play()
        night.model.beginLevelGesture()
        night.model.setLevel(.rain, 0)
        night.model.setLevel(.pink, 0)
        night.model.setLevel(.pink, 0.3)
        night.model.endLevelGesture()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.timer.hasCount)
    }

    /// VoiceOver sets a level in steps, with no finger to lift.
    func testALevelSetWithoutAFingerEndsTheNightAtZeroToo() throws {
        let night = try NightHarness(at: time(12))
        night.model.play()
        night.model.setLevel(.rain, 0)
        XCTAssertTrue(night.model.isPlaying)
        night.model.setLevel(.pink, 0)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause)
    }

    // MARK: A blanket whose hour passed in silence

    /// Earbuds out at 06:50 and back at 07:05 with the app in front: the
    /// output it played on is there again, but seven o'clock has passed.
    /// Resumed, the timer would take the hour for tomorrow's.
    func testEarbudsBackAfterTheBlanketsHourDoNotStartAnotherDay() throws {
        let night = try NightHarness(at: time(23))
        night.session.currentRoute = ScriptedSession.airPods
        night.model.chooseTimer(.blanket(hour: 7))
        night.model.play()
        night.engine.render(seconds: 1)
        XCTAssertEqual(night.model.timer.fixedEnd, time(day: 18, 7))

        night.jump(to: time(day: 18, 6, 50))
        night.model.timer.tick()
        night.session.loseOutput()
        XCTAssertEqual(night.model.pauseCause, .lostOutput)

        night.engine.forgetCalls()
        night.jump(to: time(day: 18, 7, 5))
        night.session.connect(ScriptedSession.airPods)
        XCTAssertFalse(night.model.isPlaying, "the night ended at seven")
        XCTAssertTrue(night.engine.starts.isEmpty)
        XCTAssertNil(night.model.pauseCause, "over, not paused")
        XCTAssertEqual(night.model.sessionEndedAt, time(day: 18, 7))
        XCTAssertNil(night.model.timer.fixedEnd, "no blanket until tomorrow")
    }

    func testEarbudsBackBeforeTheBlanketsHourStillResume() throws {
        let night = try NightHarness(at: time(23))
        night.session.currentRoute = ScriptedSession.airPods
        night.model.chooseTimer(.blanket(hour: 7))
        night.model.play()
        night.jump(to: time(day: 18, 6, 30))
        night.model.timer.tick()
        night.session.loseOutput()
        night.jump(to: time(day: 18, 6, 40))
        night.session.connect(ScriptedSession.airPods)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.timer.fixedEnd, time(day: 18, 7))
    }

    /// The dip of the blanket that came due during a pause is not taken on
    /// a resume inside the final fade, where a night that never paused
    /// would not take it either.
    func testAResumeInsideTheFinalFadeDoesNotDipTheBlanket() {
        let clock = TestClock(time(23))
        let timer = SleepTimerController(
            choice: .blanket(hour: 7),
            now: { clock.now },
            calendar: NightHarness.utc,
            ticks: false
        )
        timer.start()
        clock.now = time(23, 10)
        timer.pause()
        clock.now = time(day: 18, 6, 50)
        timer.start()
        XCTAssertEqual(timer.blanketGain, 1, "inside the last fifteen minutes there is no dip")

        // Outside the fade the dip that came due is simply there.
        let other = SleepTimerController(
            choice: .blanket(hour: 7),
            now: { clock.now },
            calendar: NightHarness.utc,
            ticks: false
        )
        clock.now = time(23)
        other.start()
        clock.now = time(23, 10)
        other.pause()
        clock.now = time(day: 18, 2)
        other.start()
        XCTAssertEqual(other.blanketGain, TimerMath.blanketDipGain)
    }

    // MARK: Small Hours behind a locked screen

    /// With the app in front the figure moves by the minute. Behind a
    /// locked screen nobody reads it: the session wakes only for the tide,
    /// the closing fade and its end, and the figure is right again as soon
    /// as the app comes back.
    func testSmallHoursDoesNotWakeByTheMinuteWithTheScreenOff() throws {
        let night = try NightHarness(at: time(day: 18, 3, 41))
        XCTAssertEqual(night.model.startSmallHours(), .started)
        let session = night.model.smallHours
        XCTAssertEqual(try XCTUnwrap(session.secondsToNextEvent()), 60, accuracy: 0.001)

        night.model.appDidResignActive()
        let recipe = session.recipe
        XCTAssertEqual(
            try XCTUnwrap(session.secondsToNextEvent()),
            recipe.tideGuideEnd,
            accuracy: 0.001,
            "the next thing that happens is the tide letting go"
        )

        // Seven minutes on, nothing ticked in between.
        night.jump(to: time(day: 18, 3, 48))
        XCTAssertEqual(session.minutesLeft, 20, "nothing was published behind the screen")
        night.model.appDidBecomeActive()
        XCTAssertEqual(session.minutesLeft, 13)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(try XCTUnwrap(session.secondsToNextEvent()), 60, accuracy: 0.001)
    }

    // MARK: The tide and the ocean it raises

    func testTheOceanTheTideRaisesIsToldToThePageOnce() throws {
        let night = try NightHarness(at: time(12))
        XCTAssertEqual(night.model.tideOceanRaises, 0)
        night.model.setBreathingEnabled(true)
        XCTAssertEqual(night.model.tideOceanRaises, 1)
        XCTAssertEqual(night.model.levels[.ocean], MixerModel.tideOceanLevel)
        XCTAssertNotNil(night.model.loadedMixName, "the mix keeps its name")
        // The page gives it the row that is free.
        XCTAssertEqual(PageLayers.adding(.ocean, to: [.rain, .pink], capacity: 3), [.rain, .pink, .ocean])
        XCTAssertEqual(PageLayers.adding(.ocean, to: [.rain, .wind, .pink], capacity: 3), [.rain, .wind, .pink])

        // With the ocean already up nothing is raised, so nothing is told.
        night.model.setBreathingEnabled(false)
        night.model.setBreathingEnabled(true)
        XCTAssertEqual(night.model.tideOceanRaises, 1)
    }

    // MARK: A reinstall over a trial that ended long ago

    /// The record lives in the Keychain and outlives the app; the defaults
    /// that say its end was already told do not. The end is not news: no
    /// paragraph on the first screen and no "always free" above the name.
    func testAReinstallOverATrialUsedUpSaysNothingAboutItsEnd() throws {
        let defaults = try freshDefaults()
        let start = NightHarness.trialStart
        let storage = InMemoryTrialStorage(record: TrialRecord(
            startedAt: start,
            lastSeen: start.addingTimeInterval(30 * 86_400),
            consumed: NightTrial.length + 86_400
        ))
        let purchases = PurchaseManager(
            defaults: defaults,
            trialStorage: storage,
            store: ScriptedProStore(),
            calendar: NightHarness.utc,
            now: start.addingTimeInterval(60 * 86_400)
        )
        XCTAssertEqual(purchases.trialState, .ended)
        XCTAssertNil(purchases.trialNote)
        XCTAssertFalse(purchases.showsAlwaysFree)
        XCTAssertFalse(purchases.canStartTrial, "and it does not run twice")
        XCTAssertFalse(defaults.bool(forKey: PurchaseManager.endNoteKey))
        XCTAssertTrue(defaults.bool(forKey: PurchaseManager.endEvaluatedKey))
    }

    /// A trial this install found running is one it knows: when it ends,
    /// that is said, reinstalled halfway or not.
    func testATrialFoundRunningStillSaysItsEnd() throws {
        let defaults = try freshDefaults()
        let start = NightHarness.trialStart
        let purchases = PurchaseManager.onDoubles(defaults: defaults, access: .trial, now: start)
        XCTAssertNotNil(defaults.object(forKey: PurchaseManager.endEvaluatedKey), "seen running")
        XCTAssertFalse(defaults.bool(forKey: PurchaseManager.endEvaluatedKey))
        purchases.expireTrial(startedAt: start)
        XCTAssertEqual(purchases.trialState, .ended)
        XCTAssertEqual(purchases.trialNote, .ended)
        XCTAssertTrue(purchases.showsAlwaysFree)
    }
}

/// The pure rules behind what the walk through found in the views.
@MainActor
final class WalkthroughRuleTests: XCTestCase {
    private let ten = Date(timeIntervalSinceReferenceDate: 800_000_000)

    func testTheTideNeverRecedesLaterThanTheNightEnds() {
        let guideEnd = ten.addingTimeInterval(15 * 60)
        XCTAssertEqual(TideSheetText.recedesAt(guideEnd: guideEnd, timerEnd: nil), guideEnd)
        XCTAssertEqual(
            TideSheetText.recedesAt(guideEnd: guideEnd, timerEnd: ten.addingTimeInterval(45 * 60)),
            guideEnd
        )
        let timerEnd = ten.addingTimeInterval(5 * 60)
        XCTAssertEqual(TideSheetText.recedesAt(guideEnd: guideEnd, timerEnd: timerEnd), timerEnd)
        XCTAssertNil(
            TideSheetText.recedesAt(guideEnd: nil, timerEnd: timerEnd),
            "a guide without an end of its own gives no hour"
        )
    }

    func testTheFieldOfANameStopsWhereAStoredNameDoes() {
        let long = "Lluvia de las tres de la madrugada con viento"
        XCTAssertEqual(MixNaming.bounded(long).count, MixCodec.maxNameLength)
        XCTAssertEqual(MixNaming.bounded(long), MixCodec.cleanName(long), "what is typed is what is stored")
        XCTAssertEqual(MixNaming.bounded("Hotel"), "Hotel")
        XCTAssertEqual(MixNaming.bounded(""), "")
    }

    func testOnlySettingsLeavesWithTheProSheetWhenTheTrialStarts() {
        let started = TrialState.active(nightsLeft: 7)
        XCTAssertTrue(PageSheet.settings.closesWhenTrialStarts(from: .notStarted, to: started))
        XCTAssertFalse(PageSheet.layers.closesWhenTrialStarts(from: .notStarted, to: started))
        XCTAssertFalse(PageSheet.settings.closesWhenTrialStarts(from: started, to: .active(nightsLeft: 6)))
        XCTAssertFalse(PageSheet.settings.closesWhenTrialStarts(from: started, to: .ended))
        XCTAssertFalse(PageSheet.settings.closesWhenTrialStarts(from: .notStarted, to: .notStarted))
    }

    func testThePaceInItsMenuIsTheShortName() {
        let spanish = ["marea.ritmo.tranquilo.corto": "Tranquilo · %lld", "marea.ritmo.exacto": "%lld por minuto"]
        let lookup: (String) -> String = { spanish[$0] ?? "?\($0)?" }
        let locale = Locale(identifier: "es_ES")
        XCTAssertEqual(
            TideSheetText.paceValue(BreathingSettings.calmRate, localized: lookup, locale: locale),
            "Tranquilo · 6"
        )
    }

    #if DEBUG
    func testTheClockOfADebugLaunchIsAnHourOfToday() throws {
        let calendar = NightHarness.utc
        let day = NightHarness.time(14, 30)
        XCTAssertEqual(PageArguments.clockStart("23:05", on: day, calendar: calendar), NightHarness.time(23, 5))
        XCTAssertEqual(PageArguments.clockStart("6:00", on: day, calendar: calendar), NightHarness.time(6))
        for wrong in ["", "23", "24:00", "12:60", "a:b", "12:00:00", "-1:10"] {
            XCTAssertNil(PageArguments.clockStart(wrong, on: day, calendar: calendar), wrong)
        }
    }
    #endif
}
