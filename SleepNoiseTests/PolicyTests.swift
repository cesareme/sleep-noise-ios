import XCTest
@testable import SleepNoise

final class AccessPolicyTests: XCTestCase {
    func testFreeSounds() {
        for sound in [SoundID.white, .pink, .brown, .rain] {
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: false))
        }
        XCTAssertFalse(AccessPolicy.soundIsIncluded(.fan, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.soundIsIncluded(.ocean, hasFullAccess: false))
        for sound in [SoundID.thunder, .campfire, .stream, .wind, .cabin] {
            XCTAssertFalse(AccessPolicy.soundIsIncluded(sound, hasFullAccess: false))
        }
        for sound in SoundID.allCases {
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: true))
        }
    }

    func testTimerGate() {
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 15, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 30, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 60, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 90, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 45, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.breathingIsIncluded(hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.breathingIsIncluded(hasFullAccess: true))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 0, hasFullAccess: true))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 361, hasFullAccess: true))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 45, hasFullAccess: true))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 360, hasFullAccess: true))
    }

    func testPresetTiersFollowTheSoundsInsideThem() {
        let free: [SoundPreset] = [.deepSleep, .focus, .steadyRain]
        for preset in free {
            XCTAssertFalse(preset.requiresFullAccess, preset.rawValue)
            guard case .levels(let levels) = PresetLibrary.apply(preset, hasFullAccess: false) else {
                return XCTFail("A free preset should apply without Pro")
            }
            for sound in SoundID.allCases {
                let level = levels[sound] ?? 0
                if level > 0.001 {
                    XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: false))
                }
            }
        }

        let pro: [SoundPreset] = [.baby, .storm, .cabin, .campfire, .brook, .nightWind, .shore]
        for preset in pro {
            XCTAssertTrue(preset.requiresFullAccess, preset.rawValue)
            XCTAssertEqual(PresetLibrary.apply(preset, hasFullAccess: false), .needsPro)
            guard case .levels = PresetLibrary.apply(preset, hasFullAccess: true) else {
                return XCTFail("Full access should apply a Pro preset")
            }
        }

        XCTAssertEqual(SoundPreset.allCases.count, free.count + pro.count)
    }

    func testSavedMixGate() {
        XCTAssertTrue(AccessPolicy.canSave(existingCount: 0, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.canSave(existingCount: 1, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.canSave(existingCount: 40, hasFullAccess: true))
    }
}

final class TimerFormatTests: XCTestCase {
    func testFadeWindow() {
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 15 * 60), 20, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 8 * 60), 20, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 60), 15, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 10), 5, accuracy: 0.001)
    }

    func testClockFormat() {
        XCTAssertEqual(TimeFormat.clock(0), "0:00")
        XCTAssertEqual(TimeFormat.clock(65), "1:05")
        XCTAssertEqual(TimeFormat.clock(3_661), "1:01:01")
    }
}

final class MixStoreTests: XCTestCase {
    func testFreeTierKeepsASingleMixAndProDoesNot() throws {
        let defaults = try makeDefaults()
        let store = MixStore(defaults: defaults)
        let first = store.save(name: "  Night  ", levels: [.pink: 0.4, .fan: 1.5], hasFullAccess: false)
        guard case .saved(let mix) = first else {
            return XCTFail("Expected the first mix to save")
        }
        XCTAssertEqual(mix.name, "Night")
        XCTAssertEqual(mix.value(for: .pink), 0.4, accuracy: 0.000_1)
        XCTAssertEqual(mix.value(for: .fan), 1, accuracy: 0.000_1)

        XCTAssertEqual(store.save(name: "Second", levels: [.rain: 0.2], hasFullAccess: false), .needsPro)
        XCTAssertEqual(store.mixes.count, 1)

        guard case .saved = store.save(name: "Second", levels: [.brown: -3], hasFullAccess: true) else {
            return XCTFail("Pro should save another mix")
        }
        XCTAssertEqual(store.mixes[0].value(for: .brown), 0, accuracy: 0.000_1)

        let reloaded = MixStore(defaults: defaults)
        XCTAssertEqual(reloaded.mixes.map(\.name), ["Second", "Night"])

        reloaded.delete(reloaded.mixes[0].id)
        reloaded.delete(reloaded.mixes[0].id)
        XCTAssertTrue(reloaded.mixes.isEmpty)

        let fresh = MixStore(defaults: defaults)
        guard case .saved = fresh.save(name: "Again", levels: [.white: 0.2], hasFullAccess: false) else {
            return XCTFail("Deleting the free mix should open the slot")
        }
        XCTAssertEqual(fresh.mixes.count, 1)
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
    private let timerKey = "sleepnoise.timerMinutes.v1"
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

    private func makeFreeTierModel() throws -> MixerModel {
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        expire(purchases)
        XCTAssertFalse(purchases.hasFullAccess)
        return MixerModel(purchases: purchases, defaults: defaults)
    }

    func testNightEntryPlan() {
        XCTAssertEqual(BedtimeScreenPolicy.entry(isPlaying: false, isSilent: false), .enter(startsPlayback: true))
        XCTAssertEqual(BedtimeScreenPolicy.entry(isPlaying: true, isSilent: false), .enter(startsPlayback: false))
        XCTAssertEqual(BedtimeScreenPolicy.entry(isPlaying: false, isSilent: true), .nothingToPlay)
        XCTAssertEqual(BedtimeScreenPolicy.entry(isPlaying: true, isSilent: true), .nothingToPlay)
    }

    func testNightRefusesASilentMixAndNeverCreatesATimer() throws {
        let defaults = try makeDefaults()
        let model = MixerModel(purchases: PurchaseManager(defaults: defaults, now: day0), defaults: defaults)
        for sound in SoundID.allCases {
            model.levels[sound] = 0
        }
        XCTAssertTrue(model.isSilent)
        XCTAssertEqual(model.enterBedtime(), .nothingToPlay)
        XCTAssertFalse(model.isBedtime)
        XCTAssertFalse(model.isPlaying)
        XCTAssertNil(model.timer.selectedMinutes, "Night does not choose a timer")
        XCTAssertNil(defaults.object(forKey: timerKey), "and does not store one")
    }

    func testShortcutsRefuseProRequestsInWordsWithoutThePaywall() throws {
        let model = try makeFreeTierModel()
        let before = model.levels

        XCTAssertEqual(model.playSound(.thunder), .needsPro)
        XCTAssertEqual(model.playPreset(.storm), .needsPro)
        XCTAssertEqual(model.startTimer(minutes: 45), .needsPro)
        XCTAssertEqual(model.startTimer(minutes: 0), .outOfRange)
        XCTAssertEqual(model.startTimer(minutes: AccessPolicy.maxTimerMinutes + 1), .outOfRange)

        XCTAssertFalse(model.showPaywall)
        XCTAssertFalse(model.isPlaying)
        XCTAssertEqual(model.levels, before)
        XCTAssertNil(model.activePreset)
        XCTAssertNil(model.timer.selectedMinutes)
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

        let timer = IntentReply.timerNeedsPro(minutes: 45)
        XCTAssertTrue(timer.contains("45"))
        for minutes in AccessPolicy.freeTimerMinutes {
            XCTAssertTrue(timer.contains(String(minutes)), "\(timer) should name \(minutes)")
        }

        XCTAssertTrue(IntentReply.timerOutOfRange().contains(String(AccessPolicy.maxTimerMinutes)))
        XCTAssertTrue(IntentReply.presetNeedsPro(.storm).contains(SoundPreset.storm.localizedName))
    }

    func testEverySoundAndPresetCanBeAskedFor() {
        let sounds = IntentSound.caseDisplayRepresentations.keys
        XCTAssertEqual(Set(sounds.map(\.soundID)), Set(SoundID.allCases))
        XCTAssertEqual(sounds.count, SoundID.allCases.count)
        for sound in sounds {
            XCTAssertEqual(sound.rawValue, sound.soundID.rawValue)
        }

        let presets = IntentPreset.caseDisplayRepresentations.keys
        XCTAssertEqual(Set(presets.map(\.preset)), Set(SoundPreset.allCases))
        XCTAssertEqual(presets.count, SoundPreset.allCases.count)
        for preset in presets {
            XCTAssertEqual(preset.rawValue, preset.preset.rawValue)
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
