import AppIntents
import XCTest
@testable import SleepNoise

/// The five Shortcuts of 1.0 (PLAN-SIMPLE §4.3, surface 24): what each one
/// does to the mixer, on doubles. None of them sells, none starts a trial.
@MainActor
final class ShortcutTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    override func tearDown() async throws {
        await MainActor.run { IntentBridge.mixer = nil }
        try await super.tearDown()
    }

    private func silence(_ model: MixerModel) {
        for sound in SoundID.allCases {
            model.levels[sound] = 0
        }
    }

    // MARK: Play the last mix

    func testPlayStartsTheLastMixWithItsTimerAndNoTrial() throws {
        let night = try NightHarness(at: time(23), access: .free)
        XCTAssertEqual(night.purchases.trialState, .notStarted)

        XCTAssertEqual(night.model.playFromShortcut(), .started)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.engine.starts, [.start(fadeIn: PlaybackFade.start, level: 1)])
        XCTAssertEqual(night.model.loadedMix, .house(.pinkAndRain), "the mix that was there")
        XCTAssertTrue(night.model.timer.hasCount, "with the timer the person chose")
        XCTAssertEqual(night.purchases.trialState, .notStarted, "a trial never begins from an intent")
        XCTAssertNil(night.trialStorage.record)
        XCTAssertFalse(night.purchases.hasFullAccess)
        XCTAssertFalse(night.model.showPaywall)

        // Asked for again while it sounds: nothing changes.
        night.engine.forgetCalls()
        XCTAssertEqual(night.model.playFromShortcut(), .started)
        XCTAssertEqual(night.engine.calls, [])
    }

    /// No Play starts the trial (C07): not the Disc, not the lock screen,
    /// not a Shortcut, by night or by day. Red if a start of the sound
    /// writes a trial record.
    func testNoPlayStartsTheTrial() throws {
        for shortcut in ["disc", "remote", "play", "mix", "timer", "small hours"] {
            let night = try NightHarness(at: time(shortcut == "disc" ? 12 : 23), access: .free)
            switch shortcut {
            case "disc": night.model.play()
            case "remote":
                night.model.startIfNeeded()
                night.nowPlaying.pressPlay()
            case "play": night.model.playFromShortcut()
            case "mix": night.model.playMixFromShortcut(.house(.wall))
            case "timer": night.model.setTimerFromShortcut(mode: .blanket)
            default: night.model.startSmallHours()
            }
            XCTAssertTrue(night.model.isPlaying, shortcut)
            XCTAssertEqual(night.purchases.trialState, .notStarted, shortcut)
            XCTAssertNil(night.trialStorage.record, shortcut)
            XCTAssertEqual(night.trialStorage.saveCount, 0, shortcut)
            XCTAssertFalse(night.purchases.hasFullAccess, shortcut)
            XCTAssertFalse(night.model.showPaywall, shortcut)
        }
    }

    func testPlayWithNothingToSoundRaisesTheFallbackLikeTheDisc() throws {
        let night = try NightHarness(at: time(15), free: true)
        silence(night.model)
        // A Pro layer that is muted without access does not count as sound.
        night.model.levels[.ocean] = 0.65
        XCTAssertTrue(night.model.isSilent)

        XCTAssertEqual(night.model.playFromShortcut(), .started)
        XCTAssertTrue(night.model.isPlayingFallback, "the instrument always sounds")
        XCTAssertEqual(night.engine.gains.value(for: MixerModel.fallbackSound), MixerModel.fallbackLevel)
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertEqual(night.model.levels[.ocean], 0.65, "the Pro layer keeps its level")
        XCTAssertFalse(night.model.showPaywall, "by day either: a Shortcut never sells")
    }

    func testPlayThatDoesNotStartSaysSo() throws {
        let night = try NightHarness(at: time(23))
        night.engine.failsToStart = true
        XCTAssertEqual(night.model.playFromShortcut(), .failed)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.startFailures, 1)
    }

    /// "Play my last mix" is the mix, like every other request for it:
    /// Small Hours gives way, paused or playing.
    func testPlayLeavesSmallHoursForTheMix() throws {
        for paused in [true, false] {
            let night = try NightHarness(at: time(4))
            night.model.startSmallHours()
            night.engine.render(seconds: 4)
            if paused { night.model.pause() }
            XCTAssertEqual(night.model.playFromShortcut(), .started, "paused: \(paused)")
            XCTAssertFalse(night.model.isSmallHours, "paused: \(paused)")
            XCTAssertTrue(night.model.isPlaying)
            XCTAssertEqual(night.engine.gains.ocean, 0, "the recipe is gone")
            XCTAssertGreaterThan(night.engine.gains.pink, 0, "the mix plays")
            XCTAssertEqual(night.nowPlaying.title, HouseMix.pinkAndRain.localizedName)
        }
    }

    // MARK: Play a mix by name

    func testAMixWithProLayersPlaysWhatThereIsAndSaysNothing() throws {
        let night = try NightHarness(at: time(15), free: true)
        XCTAssertTrue(night.model.canSell, "three in the afternoon: the sheet could go up")

        XCTAssertEqual(night.model.playMixFromShortcut(.house(.seaAndWind)), .started)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.loadedMix, .house(.seaAndWind))
        XCTAssertTrue(night.model.loadedMixWasStripped)
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertEqual(night.engine.gains.wind, 0.2)
        XCTAssertEqual(night.model.levels[.ocean], 0.5)
        XCTAssertFalse(night.model.showPaywall)
        XCTAssertNotEqual(night.nowPlaying.title, HouseMix.seaAndWind.localizedName, "the title is the honest one")
    }

    func testASavedMixIsPlayedByItsId() throws {
        let night = try NightHarness(at: time(23))
        guard case .saved(let hotel) = night.model.mixStore.save(
            name: "Hotel", levels: [.rain: 0.45, .brown: 0.3], hasFullAccess: true
        ) else { return XCTFail("saved") }
        let timerBefore = night.model.timer.choice

        XCTAssertEqual(night.model.playMixFromShortcut(.saved(hotel.id)), .started)
        XCTAssertEqual(night.model.loadedMixName, "Hotel")
        XCTAssertEqual(night.engine.gains.rain, 0.45)
        XCTAssertEqual(night.engine.gains.pink, 0)
        XCTAssertEqual(night.model.timer.choice, timerBefore, "a mix never changes the timer")

        // Deleted since the Shortcut was written.
        night.model.deleteMix(hotel.id)
        XCTAssertEqual(night.model.playMixFromShortcut(.saved(hotel.id)), .notFound)
        XCTAssertTrue(night.model.isPlaying, "what sounds is not touched")
    }

    /// The trial ran out while the app was suspended and nothing has
    /// evaluated it since: the night a Shortcut starts does, before
    /// anything sounds.
    func testANightStartedByAShortcutEvaluatesTheTrial() throws {
        for shortcut in ["house mix", "saved mix", "play"] {
            let night = try NightHarness(at: time(12), access: .trial)
            night.jump(to: time(12).addingTimeInterval(8 * 86_400 + 11 * 3_600))
            XCTAssertTrue(night.purchases.hasFullAccess, "stale: no session has started since")
            switch shortcut {
            case "house mix":
                night.model.playMixFromShortcut(.house(.seaAndWind))
            case "saved mix":
                guard case .saved(let sea) = night.model.mixStore.save(
                    name: "Sea", levels: [.ocean: 0.5, .wind: 0.2], hasFullAccess: true
                ) else { return XCTFail("saved") }
                night.model.playMixFromShortcut(.saved(sea.id))
            default:
                night.model.levels[.ocean] = 0.5
                night.model.playFromShortcut()
            }
            XCTAssertFalse(night.purchases.hasFullAccess, shortcut)
            XCTAssertEqual(night.purchases.trialState, .ended, shortcut)
            XCTAssertTrue(night.model.isPlaying, shortcut)
            XCTAssertEqual(night.engine.gains.ocean, 0, "\(shortcut): not one more Pro night")
            XCTAssertNil(night.model.visibleTrialNote, "\(shortcut): nothing is said at night")
            XCTAssertFalse(night.model.showPaywall, shortcut)
        }
    }

    // MARK: Set the timer

    func testTheTimerShortcutSetsTheModeLikeTheSheetAndStartsTheMix() throws {
        let night = try NightHarness(at: time(23))
        night.model.chooseTimer(.untilAsleep(30))
        night.model.chooseTimer(TimerChoice(mode: .off, minutes: 30, endHour: 6, endMinute: 30))

        // "Until I sleep": the length that mode already had.
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep), .started)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.timer.choice.mode, .untilAsleep)
        XCTAssertEqual(night.model.timer.selectedMinutes, 30)
        XCTAssertEqual(night.model.timer.endsAt, time(23, 30))
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.untilAsleepMinutes, 30, "stored, like the sheet")

        // "Blanket": the hour that mode already had. Nothing starts twice.
        night.engine.forgetCalls()
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .blanket), .started)
        XCTAssertEqual(night.engine.starts, [])
        XCTAssertEqual(night.model.timer.choice.mode, .blanket)
        XCTAssertEqual(night.model.timer.endsAt, time(day: 18, 6, 30))
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.mode, .blanket)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.minutes, 30, "the length is kept for later")

        // A length written into the Shortcut is the length of "Until I sleep".
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep, minutes: 90), .started)
        XCTAssertEqual(night.model.timer.selectedMinutes, 90)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults), TimerChoice(
            mode: .untilAsleep, minutes: 90, endHour: 6, endMinute: 30
        ))
        // It means nothing to the other modes.
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .blanket, minutes: 15), .started)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.minutes, 90)
    }

    func testTheWholeTimerIsFreeFromAShortcutAndALengthStaysInRange() throws {
        let night = try NightHarness(at: time(15), free: true)
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep, minutes: 240), .started)
        XCTAssertEqual(night.model.timer.selectedMinutes, 240)
        XCTAssertFalse(night.model.showPaywall)

        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep, minutes: 100_000), .started)
        XCTAssertEqual(night.model.timer.selectedMinutes, AccessPolicy.maxTimerMinutes)
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep, minutes: 0), .started)
        XCTAssertEqual(night.model.timer.selectedMinutes, 1)
        XCTAssertFalse(night.model.showPaywall)
    }

    func testOffOnlySetsTheTimer() throws {
        let rest = try NightHarness(at: time(23))
        XCTAssertEqual(rest.model.setTimerFromShortcut(mode: .off), .applied)
        XCTAssertFalse(rest.model.isPlaying, "\"Off\" does not start a night")
        XCTAssertEqual(rest.engine.starts, [])
        XCTAssertEqual(MixerModel.storedTimer(defaults: rest.defaults)?.mode, .off)

        // While it sounds, the count goes and the night goes on.
        let playing = try NightHarness(at: time(23))
        playing.model.play()
        XCTAssertTrue(playing.model.timer.hasCount)
        XCTAssertEqual(playing.model.setTimerFromShortcut(mode: .off), .applied)
        XCTAssertTrue(playing.model.isPlaying)
        XCTAssertFalse(playing.model.timer.hasCount)

        // Small Hours has its own clock: "Off" leaves it alone.
        let small = try NightHarness(at: time(4))
        small.model.startSmallHours()
        XCTAssertEqual(small.model.setTimerFromShortcut(mode: .off), .applied)
        XCTAssertTrue(small.model.isSmallHours)
        XCTAssertTrue(small.model.isPlaying)
    }

    func testATimerThatCountsTakesTheMixBackFromSmallHours() throws {
        let night = try NightHarness(at: time(4))
        night.model.startSmallHours()
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep), .started)
        XCTAssertFalse(night.model.isSmallHours)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertGreaterThan(night.engine.gains.pink, 0)
        XCTAssertTrue(night.model.timer.hasCount)
    }

    func testTheTimerShortcutStartsASilentMixLikeTheDisc() throws {
        let night = try NightHarness(at: time(23), free: true)
        silence(night.model)
        XCTAssertEqual(night.model.setTimerFromShortcut(mode: .untilAsleep, minutes: 30), .started)
        XCTAssertTrue(night.model.isPlayingFallback)
        XCTAssertEqual(night.model.timer.selectedMinutes, 30)
    }

    // MARK: Pause and Small Hours

    func testPauseSaysWhetherThereWasAnythingToPause() throws {
        let night = try NightHarness(at: time(23))
        XCTAssertEqual(night.model.pauseFromShortcut(), .nothingPlaying)
        night.model.play()
        XCTAssertEqual(night.model.pauseFromShortcut(), .stopped)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .person)
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: PlaybackFade.pause)], "never a cut")
        XCTAssertEqual(night.model.pauseFromShortcut(), .nothingPlaying)
    }

    func testSmallHoursIsForEveryoneAndSellsNothing() throws {
        for free in [true, false] {
            let night = try NightHarness(at: time(15), free: free)
            let levelsBefore = night.model.levels
            XCTAssertEqual(night.model.startSmallHours(), .started, "free: \(free)")
            XCTAssertTrue(night.model.isSmallHours)
            XCTAssertGreaterThan(night.engine.gains.ocean, 0, "the recipe plays for everyone (C05)")
            XCTAssertNotEqual(night.engine.breath, .off, "and so does its tide")
            XCTAssertFalse(night.model.showPaywall)
            XCTAssertFalse(night.model.canSell, "whatever the hour")
            XCTAssertEqual(night.model.levels, levelsBefore, "the person's mix is not touched")
        }
    }

    // MARK: The intents themselves

    func testThePlaybackIntentsBringTheAppForwardAndPauseDoesNot() {
        // Changing any of these has to be tried on a real iPhone first.
        XCTAssertTrue(PlayLastMixIntent.openAppWhenRun)
        XCTAssertTrue(PlayMixIntent.openAppWhenRun)
        XCTAssertTrue(SetTimerIntent.openAppWhenRun)
        XCTAssertTrue(SmallHoursIntent.openAppWhenRun)
        XCTAssertFalse(PauseIntent.openAppWhenRun, "pausing never lights a dark bedroom")
    }

    func testTheIntentsDriveTheMixerAndSayNothingWhenItWorks() async throws {
        let night = try NightHarness(at: time(23))
        IntentBridge.attach(night.model)

        _ = try await PlayLastMixIntent().perform()
        XCTAssertTrue(night.model.isPlaying)

        _ = try await PauseIntent().perform()
        XCTAssertFalse(night.model.isPlaying)
        // Nothing to pause: still no error and no word.
        _ = try await PauseIntent().perform()

        let mixIntent = PlayMixIntent()
        mixIntent.mix = MixEntity(.house(.wall), name: "Wall")
        _ = try await mixIntent.perform()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.loadedMix, .house(.wall))

        let timerIntent = SetTimerIntent()
        timerIntent.mode = .blanket
        timerIntent.minutes = nil
        _ = try await timerIntent.perform()
        XCTAssertEqual(night.model.timer.choice.mode, .blanket)
        timerIntent.mode = .off
        _ = try await timerIntent.perform()
        XCTAssertEqual(night.model.timer.choice.mode, .off)
        XCTAssertTrue(night.model.isPlaying)

        _ = try await SmallHoursIntent().perform()
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertFalse(night.model.showPaywall)
        XCTAssertEqual(night.purchases.trialState, .notStarted)
        XCTAssertNil(night.trialStorage.record)
    }

    func testAnIntentThatCannotStartTheSoundSaysOnlyThat() async throws {
        let night = try NightHarness(at: time(23))
        night.engine.failsToStart = true
        IntentBridge.attach(night.model)

        let mixIntent = PlayMixIntent()
        mixIntent.mix = MixEntity(.house(.wall), name: "Wall")
        let timerIntent = SetTimerIntent()
        timerIntent.mode = .untilAsleep
        timerIntent.minutes = nil
        let attempts: [(String, () async throws -> Void)] = [
            ("play", { _ = try await PlayLastMixIntent().perform() }),
            ("mix", { _ = try await mixIntent.perform() }),
            ("timer", { _ = try await timerIntent.perform() }),
            ("small hours", { _ = try await SmallHoursIntent().perform() }),
        ]
        for (name, attempt) in attempts {
            do {
                try await attempt()
                XCTFail("\(name) should have failed")
            } catch let failure as IntentFailure {
                XCTAssertEqual(failure, .soundDidNotStart, name)
            }
            XCTAssertFalse(night.model.isPlaying, name)
            XCTAssertFalse(night.model.showPaywall, name)
        }

        // Without the app's mixer there is nothing to drive.
        IntentBridge.mixer = nil
        do {
            _ = try await PlayLastMixIntent().perform()
            XCTFail("no mixer")
        } catch let failure as IntentFailure {
            XCTAssertEqual(failure, .soundDidNotStart)
        }
        _ = try await PauseIntent().perform()
    }

    func testAMixThatIsGoneAsksWhichOne() async throws {
        let night = try NightHarness(at: time(23))
        IntentBridge.attach(night.model)
        let intent = PlayMixIntent()
        for stale in [MixEntity(.saved(UUID()), name: "Gone"), MixEntity(.house(.wall), name: "Wall")] {
            intent.mix = stale
            do {
                _ = try await intent.perform()
                XCTAssertEqual(stale.reference, .house(.wall), "only the house mix is still there")
            } catch {
                XCTAssertFalse(error is IntentFailure, "not an audio failure: the system asks for the mix again")
                XCTAssertNotEqual(stale.reference, .house(.wall))
                XCTAssertFalse(night.model.isPlaying)
            }
        }
    }

    // MARK: The mixes a Shortcut can name

    func testEveryMixCanBeAskedForYoursFirst() async throws {
        let night = try NightHarness(at: time(12))
        for name in ["Hotel", "Árbol de casa"] {
            _ = night.model.mixStore.save(name: name, levels: [.pink: 0.3], hasFullAccess: true)
        }
        IntentBridge.attach(night.model)
        let query = MixEntityQuery()

        let all = try await query.suggestedEntities()
        XCTAssertEqual(all.map(\.name), ["Árbol de casa", "Hotel"] + HouseMix.allCases.map(\.localizedName))
        XCTAssertEqual(Set(all.map(\.id)).count, all.count)
        XCTAssertEqual(all.suffix(4).map(\.id), ["house:pinkAndRain", "house:seaAndWind", "house:brownAndFire", "house:wall"])
        for entity in all {
            XCTAssertNotNil(entity.reference, entity.id)
        }

        // By id, in the order asked, without the ones that are gone.
        let wanted = [all[5].id, "saved:\(UUID().uuidString)", all[0].id, "nonsense"]
        let found = try await query.entities(for: wanted)
        XCTAssertEqual(found.map(\.id), [all[5].id, all[0].id])

        // By name, whatever its capitals and accents.
        let byName = try await query.entities(matching: "arbol DE CASA")
        XCTAssertEqual(byName.map(\.name), ["Árbol de casa"])
        let none = try await query.entities(matching: "   ")
        XCTAssertEqual(none, [])
    }

    func testANameSaidInFullComesBeforeTheOnesThatContainIt() {
        let id = UUID()
        let mixes = [
            MixEntity(.saved(id), name: "Pared de hotel"),
            MixEntity(.house(.wall), name: "Pared"),
            MixEntity(.house(.pinkAndRain), name: "Rosa y lluvia"),
        ]
        XCTAssertEqual(MixEntity.matching("pared", in: mixes).map(\.name), ["Pared", "Pared de hotel"])
        XCTAssertEqual(MixEntity.matching("LLUVIA", in: mixes).map(\.name), ["Rosa y lluvia"])
        XCTAssertEqual(MixEntity.matching("mar", in: mixes), [])
        XCTAssertEqual(MixEntity.matching("", in: mixes), [])
    }

    func testEveryTimerModeCanBeSaid() {
        XCTAssertEqual(Set(ShortcutTimerMode.allCases.map(\.mode)), Set(TimerMode.allCases))
        XCTAssertEqual(ShortcutTimerMode.allCases.count, TimerMode.allCases.count)
        XCTAssertEqual(
            Set(ShortcutTimerMode.caseDisplayRepresentations.keys),
            Set(ShortcutTimerMode.allCases),
            "every mode has a name Siri can match"
        )
        // The raw values are what a stored Shortcut keeps.
        XCTAssertEqual(ShortcutTimerMode.allCases.map(\.rawValue), ["untilAsleep", "blanket", "off"])
    }
}

// MARK: - The phrases and what Siri says

final class ShortcutCatalogTests: XCTestCase {
    private func phrases() throws -> [String: [String: [String]]] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SleepNoise/Resources/AppShortcuts.xcstrings")
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let strings = try XCTUnwrap(root["strings"] as? [String: Any])
        var found: [String: [String: [String]]] = [:]
        for (key, entry) in strings {
            let localizations = try XCTUnwrap((entry as? [String: Any])?["localizations"] as? [String: Any])
            for (language, node) in localizations {
                let set = try XCTUnwrap((node as? [String: Any])?["stringSet"] as? [String: Any])
                found[key, default: [:]][language] = try XCTUnwrap(set["values"] as? [String])
            }
        }
        return found
    }

    func testFiveShortcutsWithTheirPhrasesInBothLanguages() throws {
        let phrases = try phrases()
        XCTAssertEqual(Set(phrases.keys), [
            "Play ${applicationName}",
            "Pause ${applicationName}",
            "Play ${mix} in ${applicationName}",
            "Set ${mode} in ${applicationName}",
            "Small hours in ${applicationName}",
        ])
        for (key, languages) in phrases {
            XCTAssertEqual(Set(languages.keys), ["en", "es"], key)
            XCTAssertEqual(languages["en"]?.first, key, "the key is the first English phrase")
            XCTAssertEqual(languages["en"]?.count, languages["es"]?.count, key)
            XCTAssertEqual(languages["en"]?.count, 2, key)
        }
    }

    /// The app is always named with the token (C10), a phrase carries at
    /// most one parameter and never a number, and nothing in it sells.
    func testEveryPhraseNamesTheAppWithItsTokenAndNothingElse() throws {
        let tokens = try NSRegularExpression(pattern: #"\$\{([A-Za-z]+)\}"#)
        for (key, languages) in try phrases() {
            for (language, values) in languages {
                XCTAssertEqual(Set(values).count, values.count, "\(key) [\(language)] repeats a phrase")
                for phrase in values {
                    let range = NSRange(phrase.startIndex..., in: phrase)
                    let names = tokens.matches(in: phrase, range: range).compactMap { match in
                        Range(match.range(at: 1), in: phrase).map { String(phrase[$0]) }
                    }
                    XCTAssertEqual(names.filter { $0 == "applicationName" }.count, 1, phrase)
                    let parameters = names.filter { $0 != "applicationName" }
                    XCTAssertLessThanOrEqual(parameters.count, 1, phrase)
                    XCTAssertTrue(parameters.allSatisfy { ["mix", "mode"].contains($0) }, phrase)

                    let plain = tokens.stringByReplacingMatches(in: phrase, range: range, withTemplate: "")
                    let lowered = plain.lowercased()
                    let words = lowered.split { !$0.isLetter }.map(String.init)
                    XCTAssertFalse(lowered.contains("sleepnoise"), phrase)
                    XCTAssertFalse(words.contains("pro"), phrase)
                    XCTAssertNil(plain.rangeOfCharacter(from: .decimalDigits), phrase)
                    XCTAssertFalse(plain.contains("!") || plain.contains("¡"), phrase)
                    if language == "es" {
                        for banned in ["mix", "timer", "preset"] {
                            XCTAssertFalse(words.contains(banned), phrase)
                        }
                    }
                }
            }
        }
    }

    /// What Siri may say: that the sound did not start, and which mix. No
    /// exclamation, no "Done", no price and no Pro.
    func testWhatSiriSaysFollowsTheGuide() throws {
        let strings = try TimerCatalogTests.catalog()
        let spoken = strings.keys.filter { $0.hasPrefix("siri.") }.sorted()
        XCTAssertEqual(spoken, ["siri.error", "siri.mezcla.cual"])
        let expected = [
            "siri.error": ["en": "Couldn't start the sound.", "es": "No se ha podido iniciar el sonido."],
            "siri.mezcla.cual": ["en": "Which of your mixes?", "es": "¿Cuál de tus mezclas?"],
        ]
        for (key, values) in expected {
            for (language, value) in values {
                XCTAssertEqual(TimerCatalogTests.values(key, language, in: strings), [value], key)
            }
        }
        // Everything Shortcuts shows: titles, parameters, summaries.
        let shown = strings.keys.filter { $0.hasPrefix("atajo.") || $0.hasPrefix("siri.") || $0.contains("${") }
        XCTAssertGreaterThan(shown.count, 8)
        for key in shown {
            for language in ["en", "es"] {
                let values = TimerCatalogTests.values(key, language, in: strings)
                XCTAssertFalse(values.isEmpty, "\(key) [\(language)] is missing")
                for value in values {
                    XCTAssertFalse(value.contains("!") || value.contains("¡"), "\(key): \(value)")
                    XCTAssertFalse(value.contains("€"), "\(key): \(value)")
                    let words = value.lowercased().split { !$0.isLetter }.map(String.init)
                    for banned in ["pro", "done", "listo", "hecho", "sleepnoise"] {
                        XCTAssertFalse(words.contains(banned), "\(key): \(value)")
                    }
                }
            }
        }
    }

    /// The range of the length in the Shortcuts editor is written as a
    /// literal next to the intent: it must be the range of the timer.
    func testTheLengthAShortcutCarriesIsTheRangeOfTheTimer() {
        XCTAssertEqual(AccessPolicy.maxTimerMinutes, 360)
        XCTAssertEqual(TimerChoice.untilAsleep(360).minutes, 360)
        XCTAssertEqual(TimerChoice.untilAsleep(1).minutes, 1)
    }
}
