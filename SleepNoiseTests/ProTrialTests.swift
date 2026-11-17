import XCTest
@testable import SleepNoise

/// The seven-night trial as the app runs it: `PurchaseManager` over
/// `NightTrial`, and the mixer that evaluates it when a night starts.
@MainActor
final class ProTrialTests: XCTestCase {
    private let day: TimeInterval = 86_400
    private let levelsKey = "sleepnoise.levels.v1"

    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // MARK: Starting it

    /// Red if a new install has anything open, if the trial starts anywhere
    /// but the button, or if it can start twice.
    func testANewInstallIsFreeAndTheTrialStartsOnlyFromTheSheet() throws {
        let night = try NightHarness(at: time(12), access: .free)
        XCTAssertFalse(night.purchases.hasFullAccess)
        XCTAssertFalse(night.purchases.isPro)
        XCTAssertEqual(night.purchases.trialState, .notStarted)
        XCTAssertTrue(night.purchases.canStartTrial)
        XCTAssertFalse(night.purchases.showsAlwaysFree, "the first screen says nothing about a trial")

        XCTAssertEqual(night.model.setLevel(.ocean, 0.5), .needsPro)
        XCTAssertTrue(night.model.showPaywall)
        XCTAssertNil(night.trialStorage.record, "asking for Pro starts nothing")

        XCTAssertEqual(night.model.startTrial(), .started)
        XCTAssertFalse(night.model.showPaywall, "the sheet comes down by itself")
        XCTAssertTrue(night.purchases.hasFullAccess)
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 7))
        XCTAssertFalse(night.purchases.canStartTrial)
        XCTAssertEqual(night.trialStorage.record, TrialRecord(startedAt: time(12), lastSeen: time(12), consumed: 0))
        XCTAssertEqual(night.model.setLevel(.ocean, 0.5), .applied)

        night.jump(to: time(day: 18, 12))
        XCTAssertEqual(night.model.startTrial(), .alreadyUsed)
        XCTAssertEqual(night.trialStorage.record?.startedAt, time(12), "it does not start over")
    }

    /// Red if the trial can start inside `NightWindow`, on the night page or
    /// in Small Hours (C08), through the mixer or behind its back.
    func testTheTrialNeverStartsAtNight() throws {
        for hour in [21, 23, 2, 6] {
            let night = try NightHarness(at: time(hour), access: .free)
            XCTAssertEqual(night.model.startTrial(), .closedAtNight, "\(hour)")
            XCTAssertEqual(night.purchases.startTrial(now: time(hour), calendar: NightHarness.utc), .closedAtNight)
            XCTAssertNil(night.trialStorage.record, "\(hour)")
            XCTAssertFalse(night.purchases.hasFullAccess)
        }
        // By day, on the page that came back from Night: one ink, no sale.
        let page = try NightHarness(at: time(8), access: .free)
        page.model.beginNightSession()
        XCTAssertEqual(page.model.startTrial(), .closedAtNight)
        XCTAssertNil(page.trialStorage.record)
        page.model.endNightSession()
        XCTAssertEqual(page.model.startTrial(), .started)

        let smallHours = try NightHarness(at: time(8), access: .free)
        smallHours.model.startSmallHours()
        XCTAssertEqual(smallHours.model.startTrial(), .closedAtNight)
        XCTAssertNil(smallHours.trialStorage.record)
    }

    /// Red if a start with Pro bought writes a record, or if a record that
    /// cannot be written grants anything.
    func testStartNeedsNothingWithProAndGrantsNothingWhenItCannotBeWritten() throws {
        let pro = try NightHarness(at: time(12))
        XCTAssertFalse(pro.purchases.canStartTrial)
        XCTAssertEqual(pro.model.startTrial(), .notNeeded)
        XCTAssertNil(pro.trialStorage.record)

        let storage = FaultyTrialStorage()
        storage.failsToWrite = true
        let purchases = PurchaseManager(
            defaults: try makeDefaults(),
            trialStorage: storage,
            store: ScriptedProStore(),
            calendar: NightHarness.utc,
            now: time(12)
        )
        XCTAssertEqual(purchases.startTrial(now: time(12)), .failed)
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertEqual(purchases.trialState, .notStarted)
        XCTAssertEqual(purchases.notice, .trialNotStarted, "the sheet has a line for it")
        XCTAssertTrue(purchases.canStartTrial, "and the button is still there")
    }

    /// Red if starting the trial with the mix sounding leaves its Pro layers
    /// silent or its name trimmed: the trial is heard at once.
    func testStartingTheTrialIsHeardAtOnce() throws {
        let night = try NightHarness(at: time(12), access: .free)
        night.model.loadHouseMix(.seaAndWind)
        night.model.play()
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertTrue(night.model.loadedMixWasStripped)

        night.model.offerPro()
        XCTAssertEqual(night.model.startTrial(), .started)
        let ocean = try XCTUnwrap(HouseMix.seaAndWind.levelsBySound()[.ocean])
        XCTAssertEqual(night.engine.gains.ocean, ocean)
        XCTAssertEqual(night.model.loadedMixName, HouseMix.seaAndWind.localizedName)
        XCTAssertFalse(night.model.loadedMixWasStripped)
        XCTAssertTrue(night.model.isPlaying)
    }

    // MARK: The figure

    /// Red if the header's figure is not read again when the app comes
    /// forward, or if the day the trial runs out shows a night that is not
    /// there. A session started that day, before its hour, has everything.
    func testTheFigureFollowsTheNightsAndTheLastDayHasNone() throws {
        let night = try NightHarness(at: time(12), access: .free)
        XCTAssertEqual(night.model.startTrial(), .started)
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 7))

        night.jump(to: time(day: 18, 2))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 7), "still the first night")
        night.jump(to: time(day: 18, 8))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 6))
        night.jump(to: time(day: 23, 15))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 1))

        night.jump(to: time(day: 24, 9))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 0), "it runs out today: no figure")
        XCTAssertTrue(night.purchases.hasFullAccess)
        night.model.setLevel(.ocean, 0.5)
        night.model.play()
        XCTAssertEqual(night.engine.gains.ocean, 0.5, "before its hour the trial still has everything")
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 0))
    }

    // MARK: The end

    /// The trial runs out with the bed sounding. Red if anything changes
    /// before the next night starts, if anything stored is rewritten, or if
    /// anything is said at night (C23, 08 §4.4).
    func testTheTrialEndsAtTheNextNightAndWritesNothing() throws {
        let night = try NightHarness(at: time(12), access: .trial)
        let model = night.model
        // What the person made during the trial.
        for index in 1...4 {
            guard case .saved = model.saveCurrent(name: "Mix \(index)") else { return XCTFail("saved \(index)") }
        }
        let storm: [SoundID: Float] = [.rain: 0.5, .thunder: 0.6]
        guard case .saved(let saved) = model.mixStore.save(name: "Storm", levels: storm, hasFullAccess: true) else {
            return XCTFail("saved")
        }
        model.loadHouseMix(.seaAndWind)
        model.setBreathingEnabled(true)
        model.chooseTimer(.untilAsleep(90))
        let levels = model.levels
        let storedLevels = try XCTUnwrap(night.defaults.data(forKey: levelsKey))
        let mixes = model.mixStore.mixes
        let storedMixes = try XCTUnwrap(night.defaults.data(forKey: MixStore.storageKey))
        let ocean = try XCTUnwrap(levels[.ocean])

        // The seventh night, 23:00: the trial ends tomorrow at noon.
        night.jump(to: time(day: 23, 23))
        model.play()
        XCTAssertEqual(night.engine.gains.ocean, ocean)
        XCTAssertTrue(model.breathing.isActive)

        // Noon passes with the bed still sounding. Nothing changes: not
        // when the app comes forward, and not when the person pauses.
        night.jump(to: time(day: 24, 12, 30))
        model.appDidBecomeActive()
        XCTAssertTrue(night.purchases.hasFullAccess)
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 0))
        XCTAssertEqual(night.engine.gains.ocean, ocean)
        XCTAssertEqual(model.loadedMixName, HouseMix.seaAndWind.localizedName)
        model.pause()
        XCTAssertTrue(night.purchases.hasFullAccess, "a pause evaluates nothing")
        XCTAssertNil(model.visibleTrialNote)

        // That night, a new session: the trial is over before it sounds.
        night.jump(to: time(day: 24, 23))
        model.play()
        XCTAssertTrue(model.isPlaying)
        XCTAssertFalse(night.purchases.hasFullAccess)
        XCTAssertEqual(night.purchases.trialState, .ended)
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertGreaterThan(night.engine.gains.wind, 0, "what is free still sounds")

        // The mix is the same mix, trimmed, and says so.
        let trimmed = HouseMix.seaAndWind.load(hasFullAccess: false)
        XCTAssertEqual(model.loadedMixName, trimmed.title(name: HouseMix.seaAndWind.localizedName))
        XCTAssertEqual(model.activeHouseMix, .seaAndWind)
        XCTAssertTrue(model.loadedMixWasStripped)
        // The tide is off in words, and its switch is as the person left it.
        XCTAssertFalse(model.breathingIsIncluded)
        XCTAssertFalse(model.breathing.isActive)
        XCTAssertTrue(model.breathing.settings.isEnabled, "the switch is not rewritten")
        XCTAssertEqual(
            TideStatus.resolve(.init(isEnabled: true, isIncluded: model.breathingIsIncluded)), .off
        )
        // Nothing stored was written.
        XCTAssertEqual(model.levels, levels)
        XCTAssertEqual(night.defaults.data(forKey: levelsKey), storedLevels)
        XCTAssertEqual(model.mixStore.mixes, mixes, "all five mixes are still there, whole")
        XCTAssertEqual(night.defaults.data(forKey: MixStore.storageKey), storedMixes)
        XCTAssertEqual(model.mixStore.mix(saved.id), saved)
        XCTAssertEqual(model.timer.choice, .untilAsleep(90))
        XCTAssertFalse(model.canSaveMix, "a sixth needs Pro")
        // Nothing is said and nothing is sold at night.
        XCTAssertFalse(model.showPaywall)
        XCTAssertEqual(night.purchases.trialNote, .ended)
        XCTAssertNil(model.visibleTrialNote)
        model.pause()
        XCTAssertNil(model.visibleTrialNote, "not even in silence, while it is night")

        // A saved mix with Pro layers loads trimmed, with its title.
        XCTAssertTrue(model.apply(saved))
        XCTAssertEqual(model.loadedMixName, MixLoad(levels: storm, hasFullAccess: false).title(name: "Storm"))
        XCTAssertEqual(model.levels[.thunder], 0.6)

        // The next day, in silence, the page may say it once.
        night.jump(to: time(day: 25, 10))
        model.appDidBecomeActive()
        XCTAssertEqual(model.visibleTrialNote, .ended)
        XCTAssertTrue(night.purchases.showsAlwaysFree)
        night.purchases.dismissTrialNote()
        XCTAssertNil(model.visibleTrialNote)
        XCTAssertNil(night.purchases.trialNote)
        XCTAssertEqual(model.startTrial(), .alreadyUsed, "it does not run twice")
    }

    /// Red if buying after the trial does not bring back, whole and at
    /// their levels, what the end of the trial left waiting.
    func testBuyingBringsBackWhatTheTrialLeftWaiting() async throws {
        let night = try NightHarness(at: time(12), access: .trialEnded)
        night.store.product = ProProduct(displayName: "Pro", displayPrice: "1", isFamilyShareable: true)
        night.store.purchaseResult = .purchased(ProReceipt(purchaseDate: time(12), isFamilyShared: false))
        night.model.loadHouseMix(.seaAndWind)
        night.model.play()
        XCTAssertEqual(night.engine.gains.ocean, 0)

        await night.purchases.purchase()
        XCTAssertTrue(night.purchases.hasFullAccess)
        XCTAssertEqual(night.engine.gains.ocean, HouseMix.seaAndWind.levelsBySound()[.ocean])
        XCTAssertEqual(night.model.loadedMixName, HouseMix.seaAndWind.localizedName)
        XCTAssertNil(night.purchases.trialNote)
        XCTAssertFalse(night.purchases.showsAlwaysFree)
    }

    // MARK: Notes and the header

    /// Red if the last-night paragraph shows at night, survives the Play,
    /// or comes back.
    func testTheLastNightIsSaidOnceByDayUntilThePlay() throws {
        let night = try NightHarness(at: time(12), access: .free)
        night.model.startTrial()
        XCTAssertNil(night.model.visibleTrialNote)

        night.jump(to: time(day: 23, 22))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 1))
        XCTAssertEqual(night.purchases.trialNote, .lastNight)
        XCTAssertNil(night.model.visibleTrialNote, "not at night")

        let day = try NightHarness(at: time(12), access: .free)
        day.model.startTrial()
        day.jump(to: time(day: 23, 15))
        day.model.appDidBecomeActive()
        XCTAssertEqual(day.model.visibleTrialNote, .lastNight)
        day.model.play()
        XCTAssertNil(day.model.visibleTrialNote)
        day.model.pause()
        XCTAssertNil(day.model.visibleTrialNote, "it died with the Play")
        XCTAssertNil(day.purchases.trialNote)
        XCTAssertEqual(day.purchases.trialState, .active(nightsLeft: 1), "the header still says it")
    }

    /// Red if "always free" outlives its seven free sessions, counts a
    /// resume as a session, or shows before a trial was ever used.
    func testAlwaysFreeLastsSevenSessionsAfterTheTrial() throws {
        let night = try NightHarness(at: time(12), access: .trial)
        XCTAssertFalse(night.purchases.showsAlwaysFree)
        night.jump(to: time(day: 25, 12))
        for session in 1...PurchaseManager.alwaysFreeSessions {
            night.model.play()
            XCTAssertEqual(night.purchases.freeSessionsAfterTrial, session)
            // The same night, paused and resumed: not another session.
            night.model.pause()
            night.model.play()
            XCTAssertEqual(night.purchases.freeSessionsAfterTrial, session)
            XCTAssertEqual(night.purchases.showsAlwaysFree, session < PurchaseManager.alwaysFreeSessions)
            night.model.pause()
            night.advance(seconds: Int(SessionPause.longest) + 1)
        }
        XCTAssertFalse(night.purchases.showsAlwaysFree)
        XCTAssertEqual(night.defaults.integer(forKey: PurchaseManager.freeSessionsKey), 7, "it survives a launch")

        let fresh = try NightHarness(at: time(12), access: .free)
        fresh.model.play()
        XCTAssertEqual(fresh.purchases.freeSessionsAfterTrial, 0)
        XCTAssertFalse(fresh.purchases.showsAlwaysFree)
    }

    // MARK: The store takes Pro away

    /// Red if a revocation that arrives with the bed sounding cuts a layer
    /// before the sound stops, or never applies.
    func testARevocationWaitsUntilNothingSounds() async throws {
        let night = try NightHarness(at: time(23))
        night.purchases.start()
        night.model.setLevel(.ocean, 0.5)
        night.model.play()
        XCTAssertEqual(night.engine.gains.ocean, 0.5)

        night.store.send(.revoked)
        try await waitUntil { !night.purchases.isPro }
        XCTAssertTrue(night.purchases.hasFullAccess, "held while it sounds")
        XCTAssertTrue(night.purchases.hasPendingDowngrade)
        XCTAssertEqual(night.engine.gains.ocean, 0.5)

        night.model.pause()
        XCTAssertFalse(night.purchases.hasFullAccess)
        XCTAssertFalse(night.purchases.hasPendingDowngrade)
        XCTAssertEqual(night.model.levels[.ocean], 0.5, "the level is kept")
        night.model.play()
        XCTAssertEqual(night.engine.gains.ocean, 0)
    }

    // MARK: Installs that come from the seven-day trial

    private func legacy(_ defaults: UserDefaults, startedAt: Date, lastSeen: Date, consumed: TimeInterval) {
        defaults.set(startedAt, forKey: LegacyTrial.startedAtKey)
        defaults.set(lastSeen, forKey: LegacyTrial.lastSeenKey)
        defaults.set(consumed, forKey: LegacyTrial.consumedKey)
    }

    private func manager(_ defaults: UserDefaults, _ storage: TrialStorage, now: Date) -> PurchaseManager {
        PurchaseManager(
            defaults: defaults, trialStorage: storage, store: ScriptedProStore(), calendar: NightHarness.utc, now: now
        )
    }

    /// Red if an install with the old trial in progress loses the days it
    /// had left, gets seven new ones, or can start the trial again.
    func testALegacyTrialInProgressKeepsWhatItHadLeft() throws {
        let defaults = try makeDefaults()
        let start = time(day: 10, 12)
        legacy(defaults, startedAt: start, lastSeen: start.addingTimeInterval(2 * day), consumed: 2 * day)
        let storage = InMemoryTrialStorage()

        let purchases = manager(defaults, storage, now: start.addingTimeInterval(3 * day))
        XCTAssertTrue(purchases.hasFullAccess)
        XCTAssertEqual(purchases.trialState, .active(nightsLeft: 4))
        XCTAssertFalse(purchases.canStartTrial)
        XCTAssertEqual(storage.record?.startedAt, start)
        XCTAssertEqual(try XCTUnwrap(storage.record).consumed, 3 * day, accuracy: 0.001)
        XCTAssertNil(defaults.object(forKey: LegacyTrial.startedAtKey), "moved, not copied")
        XCTAssertNil(defaults.object(forKey: LegacyTrial.consumedKey))
        XCTAssertEqual(purchases.startTrial(now: start.addingTimeInterval(3 * day)), .alreadyUsed)

        // It ends at its own end, seven days after it began.
        purchases.evaluateTrialAtSessionStart(now: start.addingTimeInterval(7 * day - 60))
        XCTAssertTrue(purchases.hasFullAccess)
        purchases.evaluateTrialAtSessionStart(now: start.addingTimeInterval(7 * day))
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertEqual(purchases.trialState, .ended)
    }

    /// Red if an install whose old trial ran out gets a new one.
    func testALegacyTrialThatRanOutStaysOver() throws {
        let defaults = try makeDefaults()
        let start = time(day: 1, 12)
        legacy(defaults, startedAt: start, lastSeen: start.addingTimeInterval(8 * day), consumed: 8 * day)
        let storage = InMemoryTrialStorage()

        let purchases = manager(defaults, storage, now: time(12))
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertEqual(purchases.trialState, .ended)
        XCTAssertFalse(purchases.canStartTrial)
        XCTAssertEqual(purchases.startTrial(now: time(12)), .alreadyUsed)
        XCTAssertNil(purchases.trialNote, "it ended long ago: nothing to announce")
        XCTAssertNotNil(storage.record)

        // And the next launch reads the same from the storage alone.
        XCTAssertEqual(manager(defaults, storage, now: time(day: 18, 12)).trialState, .ended)
    }

    /// Red if an old install that never pressed Play is treated as having
    /// used its trial, or if stale keys beat the record that already exists.
    func testALegacyTrialThatNeverBeganIsANewInstall() throws {
        let defaults = try makeDefaults()
        let storage = InMemoryTrialStorage()
        let purchases = manager(defaults, storage, now: time(12))
        XCTAssertEqual(purchases.trialState, .notStarted)
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertNil(storage.record)
        XCTAssertEqual(purchases.startTrial(now: time(12)), .started)

        // A record is already there: the legacy keys do not replace it.
        let start = time(day: 1, 12)
        legacy(defaults, startedAt: start, lastSeen: start, consumed: 9 * day)
        let again = manager(defaults, storage, now: time(13))
        XCTAssertEqual(again.trialState, .active(nightsLeft: 7))
        XCTAssertEqual(storage.record?.startedAt, time(12))
        XCTAssertNil(defaults.object(forKey: LegacyTrial.startedAtKey))
    }

    /// Red if a migration that could not be written forgets the old trial:
    /// the next launch must find it and try again.
    func testAMigrationThatCannotBeWrittenIsTriedAgain() throws {
        let defaults = try makeDefaults()
        let start = time(day: 1, 12)
        legacy(defaults, startedAt: start, lastSeen: start, consumed: 9 * day)
        let storage = FaultyTrialStorage()
        storage.failsToWrite = true

        let blocked = manager(defaults, storage, now: time(12))
        XCTAssertEqual(blocked.trialState, .notStarted)
        XCTAssertFalse(blocked.hasFullAccess)
        XCTAssertNotNil(defaults.object(forKey: LegacyTrial.startedAtKey), "kept for the next launch")
        XCTAssertEqual(blocked.startTrial(now: time(12)), .failed, "and no new trial meanwhile")

        storage.failsToWrite = false
        let next = manager(defaults, storage, now: time(day: 18, 12))
        XCTAssertEqual(next.trialState, .ended)
        XCTAssertFalse(next.canStartTrial)
        XCTAssertNil(defaults.object(forKey: LegacyTrial.startedAtKey))
    }

    // MARK: A Keychain that cannot be read

    /// Red if a running trial that could not be read at launch stays on the
    /// free tier until the app is killed.
    func testATrialThatCouldNotBeReadComesBackWhenItCan() throws {
        let storage = FaultyTrialStorage()
        _ = storage.inner.createTrial(TrialRecord(startedAt: time(12), lastSeen: time(12), consumed: 0))
        storage.failsToRead = true
        let purchases = manager(try makeDefaults(), storage, now: time(13))
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertEqual(purchases.trialState, .notStarted)

        storage.failsToRead = false
        purchases.observeClock(now: time(14))
        XCTAssertTrue(purchases.hasFullAccess)
        XCTAssertEqual(purchases.trialState, .active(nightsLeft: 7))
    }
}

/// Polls until `condition` holds; fails after two seconds.
@MainActor
func waitUntil(
    file: StaticString = #filePath,
    line: UInt = #line,
    _ condition: @MainActor () -> Bool
) async throws {
    for _ in 0..<400 {
        if condition() { return }
        try await Task.sleep(nanoseconds: 5_000_000)
    }
    XCTFail("the condition never held", file: file, line: line)
}
