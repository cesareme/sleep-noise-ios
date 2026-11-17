import XCTest
@testable import SleepNoise

final class AccessPolicyTests: XCTestCase {
    /// The free tier is exactly these five (C04); everything else is Pro.
    func testFreeSounds() {
        let free = Set(SoundID.allCases.filter { AccessPolicy.soundIsIncluded($0, hasFullAccess: false) })
        XCTAssertEqual(free, [.white, .pink, .brown, .rain, .wind])
        for sound in SoundID.allCases {
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: true))
        }
    }

    /// The free list only grows: taking one of these out is a broken promise.
    func testFreeListOnlyGrows() {
        XCTAssertTrue(AccessPolicy.freeSounds.isSuperset(of: [.white, .pink, .brown, .rain, .wind]))
    }

    /// The whole timer is free (C03): the gate only checks the range.
    func testTimerGate() {
        for hasFullAccess in [false, true] {
            for minutes in [1, 15, 45, 90, 360] {
                XCTAssertTrue(
                    AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: hasFullAccess),
                    "\(minutes) min, full access \(hasFullAccess)"
                )
            }
            XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 0, hasFullAccess: hasFullAccess))
            XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 361, hasFullAccess: hasFullAccess))
        }
        XCTAssertFalse(AccessPolicy.breathingIsIncluded(hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.breathingIsIncluded(hasFullAccess: true))
    }

    /// The tide is Pro, but in Small Hours it plays for everyone (C05).
    func testTideIsOpenInSmallHours() {
        XCTAssertTrue(AccessPolicy.breathingIsIncluded(hasFullAccess: false, inSmallHours: true))
        XCTAssertTrue(AccessPolicy.breathingIsIncluded(hasFullAccess: true, inSmallHours: true))
        XCTAssertFalse(AccessPolicy.breathingIsIncluded(hasFullAccess: false, inSmallHours: false))
        XCTAssertTrue(AccessPolicy.breathingIsIncluded(hasFullAccess: true, inSmallHours: false))
        XCTAssertFalse(AccessPolicy.breathingIsIncluded(hasFullAccess: false))
    }

    /// Small Hours plays its fixed recipe for everyone (C05): the sound of
    /// the recipe is open there, and only that sound, and only there.
    func testSmallHoursRecipeSoundIsOpenInSmallHours() {
        let recipeSound = SmallHoursRecipe.standard.sound
        XCTAssertFalse(AccessPolicy.freeSounds.contains(recipeSound), "otherwise there is no carve-out to test")
        XCTAssertTrue(AccessPolicy.soundIsIncluded(recipeSound, hasFullAccess: false, inSmallHours: true))
        XCTAssertFalse(AccessPolicy.soundIsIncluded(recipeSound, hasFullAccess: false, inSmallHours: false))
        XCTAssertFalse(AccessPolicy.soundIsIncluded(recipeSound, hasFullAccess: false))

        let openInSmallHours = Set(SoundID.allCases.filter {
            AccessPolicy.soundIsIncluded($0, hasFullAccess: false, inSmallHours: true)
        })
        XCTAssertEqual(openInSmallHours, AccessPolicy.freeSounds.union([recipeSound]))
        for sound in SoundID.allCases {
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: true, inSmallHours: true))
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: true, inSmallHours: false))
        }
    }

    /// Saved mixes, the last levels and Shortcuts store these raw values.
    /// Renaming a case makes that data fail to decode and it is lost.
    func testSoundRawValuesAreFrozen() {
        XCTAssertEqual(
            SoundID.allCases.map(\.rawValue),
            ["white", "pink", "brown", "rain", "fan", "ocean", "thunder", "campfire", "brook", "wind", "cabin"]
        )
    }

    func testSavedMixGate() {
        XCTAssertEqual(AccessPolicy.freeSavedMixLimit, 3)
        for count in 0...2 {
            XCTAssertTrue(AccessPolicy.canSave(existingCount: count, hasFullAccess: false), "\(count)")
        }
        XCTAssertFalse(AccessPolicy.canSave(existingCount: 3, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.canSave(existingCount: 40, hasFullAccess: true))
    }
}

final class TimerFormatTests: XCTestCase {
    /// The final fade is a gain fade of 10 to 15 minutes (C31): a quarter
    /// of the night, fifteen minutes at most. It used to be 5 to 20 seconds.
    func testFadeWindow() {
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 40 * 60), 10 * 60, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 45 * 60), 11.25 * 60, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 60 * 60), 15 * 60, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 360 * 60), 15 * 60, accuracy: 0.001)
        // A short night cannot spend ten minutes fading: the same quarter.
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 15 * 60), 225, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 60), 15, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 0), 0)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: -5), 0)
    }

    /// The timer is never shown in seconds: a length is whole minutes.
    func testMinutesFormat() {
        XCTAssertEqual(TimeFormat.minutes(45), Localized.format("comun.min", Int64(45)))
        XCTAssertTrue(TimeFormat.minutes(360).contains("360"))
    }
}

final class MixStoreTests: XCTestCase {
    func testFreeTierKeepsThreeMixesAndProDoesNot() throws {
        let defaults = try makeDefaults()
        let store = MixStore(defaults: defaults)
        let first = store.save(name: "  Night  ", levels: [.pink: 0.4, .fan: 1.5], hasFullAccess: false)
        guard case .saved(let mix) = first else {
            return XCTFail("Expected the first mix to save")
        }
        XCTAssertEqual(mix.name, "Night")
        XCTAssertEqual(mix.value(for: .pink), 0.4, accuracy: 0.000_1)
        XCTAssertEqual(mix.value(for: .fan), 1, accuracy: 0.000_1)

        for name in ["Second", "Third"] {
            guard case .saved = store.save(name: name, levels: [.rain: 0.2], hasFullAccess: false) else {
                return XCTFail("The free tier should save \(name)")
            }
        }
        XCTAssertEqual(store.mixes.count, 3)

        XCTAssertEqual(store.save(name: "Fourth", levels: [.rain: 0.2], hasFullAccess: false), .needsPro)
        XCTAssertEqual(store.mixes.count, 3)

        guard case .saved = store.save(name: "Fourth", levels: [.brown: -3], hasFullAccess: true) else {
            return XCTFail("Pro should save another mix")
        }
        XCTAssertEqual(store.mixes[0].value(for: .brown), 0, accuracy: 0.000_1)

        let reloaded = MixStore(defaults: defaults)
        XCTAssertEqual(reloaded.mixes.map(\.name), ["Fourth", "Third", "Second", "Night"])

        // Back on the free tier with four stored: nothing is deleted, and
        // saving opens again only below the limit.
        reloaded.delete(reloaded.mixes[0].id)
        XCTAssertEqual(reloaded.save(name: "Again", levels: [.white: 0.2], hasFullAccess: false), .needsPro)
        reloaded.delete(reloaded.mixes[0].id)
        XCTAssertEqual(reloaded.mixes.map(\.name), ["Second", "Night"])

        let fresh = MixStore(defaults: defaults)
        guard case .saved = fresh.save(name: "Again", levels: [.white: 0.2], hasFullAccess: false) else {
            return XCTFail("Deleting a free mix should open a slot")
        }
        XCTAssertEqual(fresh.mixes.count, 3)
    }

    func testEmptyNameIsRejected() throws {
        let store = MixStore(defaults: try makeDefaults())
        XCTAssertEqual(store.save(name: "   ", levels: [.pink: 1], hasFullAccess: true), .emptyName)
        XCTAssertTrue(store.mixes.isEmpty)
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}

/// The Night model and the Shortcut entry points of the mixer. Every path
/// exercised here returns before the audio engine would start.
@MainActor
final class NightAndShortcutTests: XCTestCase {
    private let day0 = Date(timeIntervalSinceReferenceDate: 700_000_000)

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    /// The trial ran out days ago and nothing was bought.
    private func expire(_ purchases: PurchaseManager) {
        purchases.startTrialIfNeeded(now: day0)
        purchases.refreshAccess(now: day0.addingTimeInterval(8 * 86_400), canDowngrade: true)
    }

    private func makeFreeTierModel(defaults: UserDefaults? = nil) throws -> MixerModel {
        let defaults = try defaults ?? makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        expire(purchases)
        XCTAssertFalse(purchases.hasFullAccess)
        return MixerModel(purchases: purchases, defaults: defaults)
    }

    /// A timer length the free tier does not include, or nil when every
    /// length is free and there is nothing to refuse.
    private var lengthThatNeedsPro: Int? {
        AccessPolicy.timerIsIncluded(minutes: 45, hasFullAccess: false) ? nil : 45
    }

    func testNightEntryPlan() {
        XCTAssertTrue(BedtimeScreenPolicy.startsPlayback(isPlaying: false), "Night starts the mix that was at rest")
        XCTAssertFalse(BedtimeScreenPolicy.startsPlayback(isPlaying: true))
    }

    /// "Night" on the bar always works: a mix where nothing would sound
    /// comes up the way Play brings it up, and Night still chooses no timer.
    func testNightStartsASilentMixLikePlayAndNeverCreatesATimer() throws {
        let night = try NightHarness(at: NightHarness.time(23))
        for sound in SoundID.allCases {
            night.model.levels[sound] = 0
        }
        XCTAssertTrue(night.model.isSilent)
        XCTAssertEqual(night.model.enterBedtime(), .entered)
        XCTAssertTrue(night.model.isBedtime)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.isPlayingFallback, "the instrument always sounds")
        XCTAssertEqual(night.model.levels[MixerModel.fallbackSound], MixerModel.fallbackLevel)
        XCTAssertEqual(night.model.timer.choice, .firstUse, "Night does not choose a timer: the first-use one stands")
        XCTAssertNil(MixerModel.storedTimer(defaults: night.defaults), "and does not store one")
    }

    func testShortcutsRefuseProRequestsInWordsWithoutThePaywall() throws {
        let model = try makeFreeTierModel()
        let before = model.levels
        let houseMixBefore = model.activeHouseMix

        XCTAssertEqual(model.playSound(.thunder), .needsPro)
        if let minutes = lengthThatNeedsPro {
            XCTAssertEqual(model.startTimer(minutes: minutes), .needsPro)
        }
        XCTAssertEqual(model.startTimer(minutes: 0), .outOfRange)
        XCTAssertEqual(model.startTimer(minutes: AccessPolicy.maxTimerMinutes + 1), .outOfRange)

        XCTAssertFalse(model.showPaywall)
        XCTAssertFalse(model.isPlaying)
        XCTAssertEqual(model.levels, before)
        XCTAssertEqual(model.activeHouseMix, houseMixBefore)
        XCTAssertEqual(model.timer.choice, .firstUse, "a refused request leaves the timer alone")
    }

    /// The whole timer is free (C03): red if a paid length, or a cap below
    /// the technical ceiling, comes back in the model.
    func testFreeTierSetsAnyTimerLengthWithoutThePaywall() throws {
        let defaults = try makeDefaults()
        let model = try makeFreeTierModel(defaults: defaults)

        XCTAssertNil(model.armTimer(minutes: 90))
        XCTAssertEqual(model.timer.selectedMinutes, 90)
        XCTAssertEqual(MixerModel.storedTimer(defaults: defaults), .untilAsleep(90))

        model.selectTimer(minutes: AccessPolicy.maxTimerMinutes)
        XCTAssertEqual(model.timer.selectedMinutes, AccessPolicy.maxTimerMinutes)
        XCTAssertEqual(MixerModel.storedTimer(defaults: defaults), .untilAsleep(AccessPolicy.maxTimerMinutes))

        model.clampTimerToEntitlement()
        XCTAssertEqual(model.timer.selectedMinutes, AccessPolicy.maxTimerMinutes)
        XCTAssertFalse(model.showPaywall)
        XCTAssertFalse(model.isPlaying)
    }

    func testShortcutsReadTheTrialClockBeforeDeciding() throws {
        // The trial ran out while the app was suspended and nothing has
        // looked at the clock since: access still reads as full.
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        purchases.startTrialIfNeeded(now: day0)
        XCTAssertTrue(purchases.hasFullAccess)
        let model = MixerModel(purchases: purchases, defaults: defaults)

        XCTAssertEqual(model.playSound(.thunder), .needsPro)
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertFalse(model.isPlaying)

        for entry in ["house mix", "timer"] {
            let stale = try makeDefaults()
            let clock = PurchaseManager(defaults: stale, now: day0)
            clock.startTrialIfNeeded(now: day0)
            let other = MixerModel(purchases: clock, defaults: stale)
            if entry == "house mix" {
                let withPro = try XCTUnwrap(HouseMix.allCases.first { $0.load(hasFullAccess: false).isTrimmed })
                XCTAssertTrue(other.loadHouseMix(withPro).isTrimmed, "loaded with the access the clock gives now")
            } else {
                for sound in SoundID.allCases {
                    other.levels[sound] = 0
                }
                XCTAssertEqual(other.startTimer(minutes: 30), .nothingToPlay)
            }
            XCTAssertFalse(clock.hasFullAccess, entry)
            XCTAssertFalse(other.isPlaying, entry)
        }
    }

    func testTheTimerShortcutDoesNotStartASilentNight() throws {
        let defaults = try makeDefaults()
        let model = try makeFreeTierModel(defaults: defaults)
        for sound in SoundID.allCases {
            model.levels[sound] = 0
        }
        XCTAssertEqual(model.startTimer(minutes: 30), .nothingToPlay)
        XCTAssertEqual(model.startTimer(minutes: nil), .nothingToPlay)
        XCTAssertFalse(model.isPlaying)
        XCTAssertEqual(model.timer.choice, .firstUse)
        XCTAssertNil(MixerModel.storedTimer(defaults: defaults))

        // Pro layers that are muted without access do not count as sound.
        model.levels[.ocean] = 0.65
        XCTAssertEqual(model.startTimer(minutes: 30), .nothingToPlay)
    }

    func testTheTimerShortcutWithoutALengthKeepsTheStoredChoice() throws {
        let defaults = try makeDefaults()
        let model = try makeFreeTierModel(defaults: defaults)

        // Nothing chosen: the timer of the first night runs (03 §5 #8), and
        // nothing is stored for it.
        XCTAssertEqual(model.timerMinutes(requested: nil), TimerChoice.defaultMinutes)
        XCTAssertNil(model.armTimer(minutes: nil))
        XCTAssertEqual(model.timer.selectedMinutes, TimerChoice.defaultMinutes)
        XCTAssertNil(MixerModel.storedTimer(defaults: defaults))

        // The timer chosen in the app is not a length (Off, or a blanket):
        // the fallback runs tonight and the stored choice is not touched.
        for chosen in [TimerChoice.off, .blanket(hour: 7)] {
            model.chooseTimer(chosen)
            XCTAssertEqual(model.timerMinutes(requested: nil), MixerModel.fallbackTimerMinutes)
            XCTAssertNil(model.armTimer(minutes: nil))
            XCTAssertEqual(model.timer.selectedMinutes, MixerModel.fallbackTimerMinutes)
            XCTAssertEqual(MixerModel.storedTimer(defaults: defaults), chosen)
        }

        // A length chosen in the app is the one that runs, and it stays.
        model.selectTimer(minutes: 30)
        XCTAssertEqual(MixerModel.storedTimer(defaults: defaults)?.untilAsleepMinutes, 30)
        XCTAssertEqual(model.timerMinutes(requested: nil), 30)
        XCTAssertNil(model.armTimer(minutes: nil))
        XCTAssertEqual(model.timer.selectedMinutes, 30)
        XCTAssertEqual(MixerModel.storedTimer(defaults: defaults)?.untilAsleepMinutes, 30)

        // Only a length written into the Shortcut replaces it.
        XCTAssertNil(model.armTimer(minutes: 15))
        XCTAssertEqual(model.timer.selectedMinutes, 15)
        XCTAssertEqual(MixerModel.storedTimer(defaults: defaults)?.untilAsleepMinutes, 15)
        XCTAssertFalse(model.isPlaying)
    }

    func testStopWithNothingPlayingSaysSoAndStaysInTheBackground() throws {
        let model = try makeFreeTierModel()
        XCTAssertEqual(model.stopFromShortcut(), .nothingPlaying)
        XCTAssertFalse(StopPlaybackIntent.openAppWhenRun)
    }

    func testRepliesNameWhatIsFree() {
        let sound = IntentReply.soundNeedsPro(.thunder)
        XCTAssertTrue(sound.contains(SoundID.thunder.localizedName))
        for free in SoundID.allCases where AccessPolicy.soundIsIncluded(free, hasFullAccess: false) {
            XCTAssertTrue(sound.contains(free.localizedName), "\(sound) should name \(free.rawValue)")
        }

        // The reply reads the gate, not a list of its own.
        let timer = IntentReply.timerNeedsPro(minutes: 45)
        XCTAssertTrue(timer.contains("45"))
        for minutes in [15, 30, 60] where AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: false) {
            XCTAssertTrue(timer.contains(String(minutes)), "\(timer) should name \(minutes)")
        }

        XCTAssertTrue(IntentReply.timerOutOfRange().contains(String(AccessPolicy.maxTimerMinutes)))
    }

    func testEverySoundCanBeAskedFor() {
        let sounds = IntentSound.caseDisplayRepresentations.keys
        XCTAssertEqual(Set(sounds.map(\.soundID)), Set(SoundID.allCases))
        XCTAssertEqual(sounds.count, SoundID.allCases.count)
        for sound in sounds {
            XCTAssertEqual(sound.rawValue, sound.soundID.rawValue)
        }
    }

    func testAMixLoadedDuringTheTrialIsMarkedStrippedWhenItEnds() throws {
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        let model = MixerModel(purchases: purchases, defaults: defaults)
        let mix = SavedMix(
            id: UUID(),
            name: "Storm",
            levels: [MixLevel(sound: .rain, value: 0.5), MixLevel(sound: .thunder, value: 0.6)],
            createdAt: day0
        )
        XCTAssertFalse(model.apply(mix), "whole while the trial is open")
        XCTAssertFalse(model.loadedMixWasStripped)

        expire(purchases)
        model.refreshEntitledAudio()
        XCTAssertTrue(model.loadedMixWasStripped, "thunder is muted now and the mixer should say so")

        XCTAssertTrue(MixerModel.hasMutedLayers([.thunder: 0.6], hasFullAccess: false))
        XCTAssertFalse(MixerModel.hasMutedLayers([.thunder: 0.6], hasFullAccess: true))
        XCTAssertFalse(MixerModel.hasMutedLayers([.rain: 0.6, .thunder: 0], hasFullAccess: false))
    }
}
