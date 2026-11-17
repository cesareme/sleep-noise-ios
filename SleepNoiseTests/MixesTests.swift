import MediaPlayer
import XCTest
@testable import SleepNoise

/// The compiled string catalog in one language, whatever the simulator
/// speaks.
private func compiledCatalog(_ language: String) throws -> (String) -> String {
    let url = try XCTUnwrap(Bundle(for: MixStore.self).url(forResource: language, withExtension: "lproj"))
    let bundle = try XCTUnwrap(Bundle(url: url))
    return { bundle.localizedString(forKey: $0, value: "<missing \($0)>", table: nil) }
}

private func levels(_ some: [SoundID: Float]) -> [SoundID: Float] {
    Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, some[$0] ?? 0) })
}

// MARK: - The words of a mix

final class MixWordsTests: XCTestCase {
    private func name(_ mix: [SoundID: Float], _ language: String) throws -> String {
        let strings = try compiledCatalog(language)
        return MixAutoName.name(
            levels: levels(mix),
            soundName: { strings($0.nameKey) },
            localized: strings,
            locale: Locale(identifier: language)
        )
    }

    func testAMixIsNamedAfterItsLayers() throws {
        let cases: [([SoundID: Float], String, String)] = [
            ([:], "Tonight", "Esta noche"),
            ([.pink: 0.4], "Pink", "Rosa"),
            ([.rain: 0.55, .pink: 0.2], "Pink and rain", "Rosa y lluvia"),
            ([.brown: 0.4, .campfire: 0.3], "Brown and campfire", "Marrón y hoguera"),
            ([.rain: 0.3, .wind: 0.3, .brown: 0.4], "Brown, rain and wind", "Marrón, lluvia y viento"),
            ([.rain: 0.3, .wind: 0.3, .brown: 0.4, .white: 0.1], "White and 3 more", "Blanco y 3 más"),
            (
                [.rain: 0.3, .wind: 0.3, .brown: 0.4, .white: 0.1, .ocean: 0.2, .fan: 0.1],
                "White and 5 more", "Blanco y 5 más"
            ),
        ]
        for (mix, english, spanish) in cases {
            XCTAssertEqual(try name(mix, "en"), english)
            XCTAssertEqual(try name(mix, "es"), spanish)
        }
    }

    func testTheNameReadsColoursFirstAndCountsEveryLayerAboveZero() {
        XCTAssertEqual(MixAutoName.order.count, SoundID.allCases.count)
        XCTAssertEqual(Set(MixAutoName.order), Set(SoundID.allCases))
        XCTAssertEqual(
            MixAutoName.layers(levels([.ocean: 0.5, .wind: 0.2, .brown: 0.0005, .white: 0.1])),
            [.white, .wind, .ocean],
            "a layer at the threshold is not in the mix"
        )
    }

    func testARecipeIsItsLayersLoudestFirst() throws {
        let recipe = MixRecipe(levels: levels([.pink: 0.2, .rain: 0.55, .brown: 0.0005]), hasFullAccess: false)
        XCTAssertEqual(recipe.layers, [.init(sound: .rain, percent: 55), .init(sound: .pink, percent: 20)])
        XCTAssertEqual(recipe.needsPro, [])
        XCTAssertFalse(recipe.isEmpty)
        XCTAssertTrue(MixRecipe(levels: levels([:]), hasFullAccess: true).isEmpty)

        // Equal levels keep the order of `SoundID`.
        let wall = MixRecipe(levels: HouseMix.wall.levelsBySound(), hasFullAccess: false)
        XCTAssertEqual(wall.layers.map(\.sound), [.brown, .rain, .wind])
    }

    func testARecipeSaysWhatNeedsProInWordsAtTheEnd() throws {
        let sea = HouseMix.seaAndWind.levelsBySound()
        let (english, spanish) = (try compiledCatalog("en"), try compiledCatalog("es"))
        func text(_ recipe: MixRecipe, _ strings: @escaping (String) -> String, _ language: String) -> String {
            recipe.text(soundName: { strings($0.nameKey) }, localized: strings, locale: Locale(identifier: language))
        }
        let trimmed = MixRecipe(levels: sea, hasFullAccess: false)
        XCTAssertEqual(trimmed.needsPro, [.ocean])
        // As it is set: no segment breaks inside and each dot opens the
        // segment after it, so a second line is "· ocean is Pro", whole.
        XCTAssertEqual(
            text(trimmed, english, "en"),
            "ocean\u{00A0}50 ·\u{00A0}wind\u{00A0}20 ·\u{00A0}ocean\u{00A0}is\u{00A0}Pro"
        )
        XCTAssertEqual(
            text(trimmed, spanish, "es"),
            "océano\u{00A0}50 ·\u{00A0}viento\u{00A0}20 ·\u{00A0}océano\u{00A0}es\u{00A0}Pro"
        )
        XCTAssertEqual(
            trimmed.spoken(soundName: { spanish($0.nameKey) }, localized: spanish, locale: Locale(identifier: "es")),
            "océano 50, viento 20, océano requiere Pro"
        )

        // With access the recipe says nothing about Pro.
        let whole = MixRecipe(levels: sea, hasFullAccess: true)
        XCTAssertEqual(whole.needsPro, [])
        XCTAssertEqual(text(whole, english, "en"), "ocean\u{00A0}50 ·\u{00A0}wind\u{00A0}20")

        // Two Pro layers: one phrase each, loudest first. The layers keep
        // their levels in the recipe: nothing is dropped from it.
        let storm = MixRecipe(levels: levels([.rain: 0.5, .thunder: 0.3, .fan: 0.6]), hasFullAccess: false)
        XCTAssertEqual(storm.layers.map(\.sound), [.fan, .rain, .thunder])
        XCTAssertEqual(storm.needsPro, [.fan, .thunder])
        XCTAssertEqual(
            storm.segments(soundName: { english($0.nameKey) }, localized: english, locale: Locale(identifier: "en")),
            ["fan 60", "rain 50", "thunder 30", "fan is Pro", "thunder is Pro"]
        )
    }

    func testAReferenceKeepsTheIdAShortcutStores() throws {
        let id = try XCTUnwrap(UUID(uuidString: "5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11"))
        XCTAssertEqual(MixReference.house(.seaAndWind).stableID, "house:seaAndWind")
        XCTAssertEqual(MixReference.saved(id).stableID, "saved:5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11")
        for reference in HouseMix.allCases.map(MixReference.house) + [.saved(id)] {
            XCTAssertEqual(MixReference(stableID: reference.stableID), reference)
        }
        for broken in ["", "seaAndWind", "house:", "house:lagoon", "saved:", "saved:not-a-uuid", "other:wall"] {
            XCTAssertNil(MixReference(stableID: broken), broken)
        }
    }
}

// MARK: - What the sheet lists

final class MixesListTests: XCTestCase {
    private let day = Date(timeIntervalSinceReferenceDate: 700_000_000)

    private func saved(_ name: String, _ mix: [SoundID: Float]) -> SavedMix {
        SavedMix(
            id: UUID(),
            name: name,
            levels: SoundID.allCases.map { MixLevel(sound: $0, value: mix[$0] ?? 0) },
            createdAt: day
        )
    }

    private func list(_ input: MixesList.Input) -> MixesList {
        MixesList(input, houseName: { $0.rawValue })
    }

    func testTheHouseIsAlwaysItsFourMixes() {
        let empty = list(MixesList.Input())
        XCTAssertEqual(empty.house.map(\.reference), HouseMix.allCases.map(MixReference.house))
        XCTAssertEqual(empty.house.map(\.name), HouseMix.allCases.map(\.rawValue))
        XCTAssertTrue(empty.yours.isEmpty)
        XCTAssertNil(empty.live, "a mix with nothing in it is not offered to be saved")
        XCTAssertTrue(empty.showsEmptyNote)

        // Without access the recipe of a house mix says what needs Pro.
        let sea = empty.house[1]
        XCTAssertEqual(sea.recipe.needsPro, [.ocean])
        let open = list(MixesList.Input(hasFullAccess: true))
        XCTAssertTrue(open.house.allSatisfy { $0.recipe.needsPro.isEmpty })
    }

    func testTheLiveMixIsARowOnlyWhileItIsTonight() {
        let edited = levels([.rain: 0.45, .wind: 0.25])
        let tonight = list(MixesList.Input(levels: edited))
        XCTAssertEqual(tonight.live?.recipe.layers.map(\.sound), [.rain, .wind])
        XCTAssertEqual(tonight.live?.needsPro, false)
        XCTAssertFalse(tonight.showsEmptyNote, "the live row stands for the section")

        // Loaded as it was (a house mix or a saved one): it is its own row.
        let house = list(MixesList.Input(levels: edited, loaded: .house(.wall)))
        XCTAssertNil(house.live)
        XCTAssertTrue(house.showsEmptyNote)

        let hotel = saved("Hotel", [.rain: 0.45, .brown: 0.3])
        let loaded = list(MixesList.Input(saved: [hotel], levels: hotel.levelsBySound, loaded: .saved(hotel.id)))
        XCTAssertNil(loaded.live)
        XCTAssertFalse(loaded.showsEmptyNote)
        XCTAssertEqual(loaded.yours.map(\.name), ["Hotel"])
    }

    func testOnlyTheLoadedMixSaysItIsSoundingAndOnlyWhileItSounds() {
        let hotel = saved("Hotel", [.rain: 0.45, .brown: 0.3])
        let other = saved("Other", [.pink: 0.3])
        var input = MixesList.Input(
            saved: [hotel, other],
            levels: hotel.levelsBySound,
            loaded: .saved(hotel.id),
            isPlaying: true
        )
        XCTAssertEqual(list(input).yours.map(\.isSounding), [true, false])
        XCTAssertFalse(list(input).house.contains { $0.isSounding })

        // Paused: no row says anything. The name on the page says what is loaded.
        input.isPlaying = false
        XCTAssertFalse(list(input).yours.contains { $0.isSounding })

        input.isPlaying = true
        input.loaded = .house(.pinkAndRain)
        XCTAssertEqual(list(input).house.map(\.isSounding), [true, false, false, false])
        XCTAssertFalse(list(input).yours.contains { $0.isSounding })

        // Edited: it is "Tonight", and no saved row is what sounds.
        input.loaded = nil
        XCTAssertFalse((list(input).yours + list(input).house).contains { $0.isSounding })
    }

    func testTheFourthMixSaysProBeforeTheTouch() {
        let edited = levels([.rain: 0.45])
        let mixes = (1...AccessPolicy.freeSavedMixLimit).map { saved("Mix \($0)", [.pink: 0.3]) }
        for count in 0...AccessPolicy.freeSavedMixLimit {
            let free = list(MixesList.Input(saved: Array(mixes.prefix(count)), levels: edited))
            XCTAssertEqual(free.live?.needsPro, count >= AccessPolicy.freeSavedMixLimit, "\(count) saved")
            let open = list(MixesList.Input(saved: Array(mixes.prefix(count)), levels: edited, hasFullAccess: true))
            XCTAssertEqual(open.live?.needsPro, false, "\(count) saved, with access")
        }
    }

    func testVoiceOverReadsTheNameAndTheRecipe() {
        XCTAssertEqual(MixesList.spokenLabel(name: "Hotel", recipe: "rain 45, brown 30"), "Hotel, rain 45, brown 30")
        XCTAssertEqual(MixesList.spokenLabel(name: "Hotel", recipe: ""), "Hotel")
    }
}

// MARK: - The store

final class MixStoreEditingTests: XCTestCase {
    private func makeStore() throws -> (MixStore, UserDefaults) {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return (MixStore(defaults: defaults), defaults)
    }

    private func save(_ store: MixStore, _ names: [String]) -> [UUID] {
        // A save goes to the top: saved in reverse, the list reads as given.
        for name in names.reversed() {
            _ = store.save(name: name, levels: [.pink: 0.3], hasFullAccess: true)
        }
        return store.mixes.map(\.id)
    }

    func testRenamingIsStoredAndAnEmptyNameChangesNothing() throws {
        let (store, defaults) = try makeStore()
        let ids = save(store, ["Hotel", "Home"])
        XCTAssertEqual(store.rename(ids[0], to: "  Hotel in Lisbon  "), "Hotel in Lisbon")
        XCTAssertEqual(store.mixes.map(\.name), ["Hotel in Lisbon", "Home"])
        XCTAssertEqual(MixStore(defaults: defaults).mixes.map(\.name), ["Hotel in Lisbon", "Home"])

        XCTAssertNil(store.rename(ids[0], to: "   "))
        XCTAssertNil(store.rename(ids[0], to: "Hotel in Lisbon"), "the same name is not a change")
        XCTAssertNil(store.rename(UUID(), to: "Nobody"))
        XCTAssertEqual(store.mixes.map(\.name), ["Hotel in Lisbon", "Home"])
        XCTAssertEqual(store.mixes.map(\.id), ids, "a rename keeps the id a Shortcut stored")

        // A name is cut like a saved one.
        let long = String(repeating: "a", count: MixCodec.maxNameLength + 10)
        XCTAssertEqual(store.rename(ids[1], to: long)?.count, MixCodec.maxNameLength)
    }

    func testMovingAMixOnePlaceAndNotPastTheEnds() throws {
        let (store, defaults) = try makeStore()
        let ids = save(store, ["A", "B", "C"])
        XCTAssertFalse(store.move(ids[0], by: -1), "already first")
        XCTAssertFalse(store.move(ids[2], by: 1), "already last")
        XCTAssertFalse(store.move(ids[1], by: 0))
        XCTAssertFalse(store.move(UUID(), by: 1))
        XCTAssertEqual(store.mixes.map(\.name), ["A", "B", "C"])

        XCTAssertTrue(store.move(ids[2], by: -1))
        XCTAssertEqual(store.mixes.map(\.name), ["A", "C", "B"])
        XCTAssertTrue(store.move(ids[0], by: 1))
        XCTAssertEqual(store.mixes.map(\.name), ["C", "A", "B"])
        XCTAssertEqual(MixStore(defaults: defaults).mixes.map(\.name), ["C", "A", "B"])
        XCTAssertEqual(store.mix(ids[1])?.name, "B")
        XCTAssertNil(store.mix(UUID()))
    }
}

// MARK: - The model behind the sheet

@MainActor
final class MixesModelTests: XCTestCase {
    private func time(_ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(hour, minute)
    }

    /// A mix saved while everything was open: it keeps a Pro layer.
    @discardableResult
    private func saveStorm(_ night: NightHarness) throws -> SavedMix {
        let result = night.model.mixStore.save(
            name: "Storm",
            levels: levels([.rain: 0.5, .thunder: 0.6]),
            hasFullAccess: true
        )
        XCTAssertEqual(night.model.mixStore.mixes.first?.name, "Storm", "\(result)")
        return try XCTUnwrap(night.model.mixStore.mixes.first)
    }

    // MARK: Loading

    func testARowLoadsTheMixAndStartsItLikeAPlay() throws {
        let night = try NightHarness(at: time(12), free: true)
        let storm = try saveStorm(night)
        let timerBefore = night.model.timer.choice

        XCTAssertEqual(night.model.playMix(.saved(storm.id)), .started)
        XCTAssertTrue(night.model.isPlaying, "with nothing sounding a row starts the sound")
        XCTAssertEqual(night.engine.starts.count, 1)
        XCTAssertEqual(night.model.loadedMix, .saved(storm.id))
        XCTAssertEqual(night.model.loadedSavedMixID, storm.id)
        XCTAssertNil(night.model.activeHouseMix)

        // Trimmed: it plays without the thunder, keeps its level, and the
        // title says so, on the page and on the lock screen.
        let load = MixLoad(levels: storm.levelsBySound, hasFullAccess: false)
        XCTAssertEqual(night.model.loadedMixName, load.title(name: "Storm"))
        XCTAssertNotEqual(night.model.loadedMixName, "Storm")
        XCTAssertEqual(night.model.loadedMixBaseName, "Storm")
        XCTAssertTrue(night.model.loadedMixWasStripped)
        XCTAssertEqual(night.model.levels[.thunder], 0.6)
        XCTAssertEqual(night.engine.gains.thunder, 0)
        XCTAssertEqual(night.engine.gains.rain, 0.5)
        XCTAssertEqual(night.nowPlaying.title, load.title(name: "Storm"))

        XCTAssertFalse(night.model.showPaywall, "loading never raises the Pro sheet, by day either")
        XCTAssertEqual(night.model.timer.choice, timerBefore, "a mix never changes the timer (C18)")
    }

    func testARowGivesWayUnderTheSameNight() throws {
        let night = try NightHarness(at: time(23))
        night.model.play()
        night.engine.render(seconds: 2)
        let endsAt = night.model.timer.endsAt
        night.engine.forgetCalls()

        XCTAssertEqual(night.model.playMix(.house(.wall)), .started)
        XCTAssertEqual(night.engine.starts, [], "what sounds is not stopped and started again")
        XCTAssertEqual(night.engine.stops, [])
        XCTAssertEqual(night.engine.gains.brown, 0.4)
        XCTAssertEqual(night.engine.gains.pink, 0)
        XCTAssertEqual(night.model.loadedMix, .house(.wall))
        XCTAssertEqual(night.model.timer.endsAt, endsAt, "and the timer keeps counting")
        XCTAssertEqual(night.nowPlaying.title, HouseMix.wall.localizedName)
    }

    func testAMixWhoseEveryLayerNeedsProStillSounds() throws {
        let night = try NightHarness(at: time(12), free: true)
        let result = night.model.mixStore.save(
            name: "Sea",
            levels: levels([.ocean: 0.5, .fan: 0.2]),
            hasFullAccess: true
        )
        guard case .saved(let sea) = result else { return XCTFail("saved") }

        XCTAssertEqual(night.model.playMix(.saved(sea.id)), .started)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.isPlayingFallback, "the instrument always sounds")
        XCTAssertEqual(night.engine.gains.value(for: MixerModel.fallbackSound), MixerModel.fallbackLevel)
        XCTAssertEqual(night.engine.gains.ocean, 0)
        XCTAssertEqual(night.model.loadedMix, .saved(sea.id), "the mix keeps its name")
        XCTAssertFalse(night.model.showPaywall)
    }

    func testAMixThatIsGoneIsNotLoaded() throws {
        let night = try NightHarness(at: time(12))
        let before = night.model.levels
        XCTAssertEqual(night.model.playMix(.saved(UUID())), .notFound)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.levels, before)
        XCTAssertEqual(night.model.loadedMix, .house(.pinkAndRain))
    }

    // MARK: The identity of the mix across a restart

    func testALoadedMixKeepsItsNameAndWhatItPlaysWithoutAcrossARestart() throws {
        let first = try NightHarness(at: time(12), free: true)
        let storm = try saveStorm(first)
        first.model.apply(storm)
        let title = try XCTUnwrap(first.model.loadedMixName)
        XCTAssertNotEqual(title, "Storm", "trimmed: the title names the thunder")

        let again = try NightHarness(at: time(13), free: true, defaults: first.defaults)
        XCTAssertEqual(again.model.loadedMixName, title)
        XCTAssertEqual(again.model.loadedMixBaseName, "Storm")
        XCTAssertEqual(again.model.loadedMix, .saved(storm.id))
        XCTAssertTrue(again.model.loadedMixWasStripped)
        XCTAssertEqual(again.model.levels, first.model.levels)
        XCTAssertEqual(again.model.nowPlayingTitle, title)
        XCTAssertEqual(again.model.suggestedMixName, "Storm")
    }

    func testAHouseMixIsStillThatHouseMixAfterARestart() throws {
        let first = try NightHarness(at: time(12), free: true)
        let load = first.model.loadHouseMix(.seaAndWind)
        XCTAssertTrue(load.isTrimmed)

        let again = try NightHarness(at: time(13), free: true, defaults: first.defaults)
        XCTAssertEqual(again.model.activeHouseMix, .seaAndWind)
        XCTAssertEqual(again.model.loadedMix, .house(.seaAndWind))
        XCTAssertEqual(again.model.loadedMixName, load.title(name: HouseMix.seaAndWind.localizedName))
        XCTAssertEqual(again.model.loadedMixBaseName, HouseMix.seaAndWind.localizedName)
        XCTAssertTrue(again.model.loadedMixWasStripped)
    }

    func testAnEditedMixComesBackAsTonight() throws {
        let first = try NightHarness(at: time(12))
        first.model.loadHouseMix(.wall)
        XCTAssertNotNil(first.defaults.data(forKey: MixerModel.loadedMixKey))
        XCTAssertEqual(first.model.setLevel(.rain, 0.6), .applied)
        XCTAssertNil(first.model.loadedMix)
        XCTAssertNil(first.defaults.data(forKey: MixerModel.loadedMixKey), "the identity goes with the first edit")

        let again = try NightHarness(at: time(13), defaults: first.defaults)
        XCTAssertNil(again.model.loadedMixName)
        XCTAssertNil(again.model.loadedMix)
        XCTAssertEqual(again.model.levels[.rain], 0.6)
        XCTAssertEqual(again.model.nowPlayingTitle, PageTitle.text(loadedMixName: nil))
    }

    func testAnIdentityThatPointsNowhereIsForgottenAndTheLevelsStay() throws {
        let first = try NightHarness(at: time(12))
        let storm = try saveStorm(first)
        first.model.apply(storm)
        // The list lost the mix behind the model's back.
        first.model.mixStore.delete(storm.id)

        let again = try NightHarness(at: time(13), defaults: first.defaults)
        XCTAssertNil(again.model.loadedMix)
        XCTAssertNil(again.model.loadedMixName)
        XCTAssertEqual(again.model.levels[.thunder], 0.6, "what was loaded is still there")
        XCTAssertNil(again.defaults.data(forKey: MixerModel.loadedMixKey))

        // Damaged data is dropped the same way.
        again.defaults.set(Data("not json".utf8), forKey: MixerModel.loadedMixKey)
        let third = try NightHarness(at: time(14), defaults: first.defaults)
        XCTAssertNil(third.model.loadedMix)
        XCTAssertNil(third.defaults.data(forKey: MixerModel.loadedMixKey))
    }

    func testTheTideRaisingTheOceanDoesNotRenameTheMixAcrossARestart() throws {
        let first = try NightHarness(at: time(12))
        first.model.loadHouseMix(.wall)
        first.model.setBreathingEnabled(true)
        XCTAssertEqual(first.model.levels[.ocean], MixerModel.tideOceanLevel)
        XCTAssertEqual(first.model.loadedMix, .house(.wall), "the tide's ocean is not an edit")

        let again = try NightHarness(at: time(13), defaults: first.defaults)
        XCTAssertEqual(again.model.loadedMix, .house(.wall))
        XCTAssertEqual(again.model.loadedMixName, HouseMix.wall.localizedName)
        XCTAssertEqual(again.model.levels[.ocean], MixerModel.tideOceanLevel)
    }

    // MARK: Saving

    func testTheSaveFieldStartsFromTheNameOfTheMix() throws {
        let night = try NightHarness(at: time(12))
        XCTAssertEqual(night.model.suggestedMixName, HouseMix.pinkAndRain.localizedName, "the loaded mix's own name")

        XCTAssertEqual(night.model.setLevel(.wind, 0.3), .applied)
        XCTAssertNil(night.model.loadedMixName, "the page says Tonight")
        XCTAssertEqual(night.model.suggestedMixName, MixAutoName.name(levels: night.model.levels))
        XCTAssertNotEqual(night.model.suggestedMixName, PageTitle.text(loadedMixName: nil))

        night.model.clearMix()
        XCTAssertEqual(night.model.suggestedMixName, PageTitle.text(loadedMixName: nil), "nothing in it: Tonight")
    }

    func testSavingMakesTheLiveMixThatSavedMixAndTouchesNothingElse() throws {
        let night = try NightHarness(at: time(12))
        night.model.play()
        XCTAssertEqual(night.model.setLevel(.wind, 0.3), .applied)
        let revision = night.model.mixRevision
        let levelsBefore = night.model.levels
        night.engine.forgetCalls()

        guard case .saved(let mix) = night.model.saveCurrent(name: "  Hotel  ") else { return XCTFail("saved") }
        XCTAssertEqual(mix.name, "Hotel")
        XCTAssertEqual(night.model.loadedMixName, "Hotel")
        XCTAssertEqual(night.model.loadedMix, .saved(mix.id))
        XCTAssertEqual(night.model.mixRevision, revision, "the page does not choose its rows again")
        XCTAssertEqual(night.model.levels, levelsBefore)
        XCTAssertEqual(night.engine.calls, [], "a save does not touch the sound")
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.nowPlaying.title, "Hotel")
        XCTAssertTrue(night.nowPlaying.isPlaying)

        // And it survives a restart as that mix.
        let again = try NightHarness(at: time(13), defaults: night.defaults)
        XCTAssertEqual(again.model.loadedMix, .saved(mix.id))
        XCTAssertEqual(again.model.loadedMixName, "Hotel")
    }

    func testANameLeftEmptyIsTheOneTheFieldStartedWith() throws {
        let night = try NightHarness(at: time(12))
        XCTAssertEqual(night.model.setLevel(.wind, 0.3), .applied)
        let suggested = night.model.suggestedMixName
        guard case .saved(let mix) = night.model.saveCurrent(name: "   ") else { return XCTFail("saved") }
        XCTAssertEqual(mix.name, suggested)
        XCTAssertEqual(night.model.loadedMixName, suggested)
    }

    func testSavingKeepsAProLayerAtItsLevelAndTheTitleStaysHonest() throws {
        let night = try NightHarness(at: time(12), free: true)
        let storm = try saveStorm(night)
        night.model.mixStore.delete(storm.id)
        night.model.apply(storm)
        XCTAssertEqual(night.model.setLevel(.brown, 0.2), .applied)

        guard case .saved(let mix) = night.model.saveCurrent(name: "Storm two") else { return XCTFail("saved") }
        XCTAssertEqual(mix.value(for: .thunder), 0.6, "the recipe keeps the layer that does not sound (C23)")
        XCTAssertEqual(mix.value(for: .brown), 0.2)
        XCTAssertEqual(
            night.model.loadedMixName,
            MixLoad(levels: night.model.levels, hasFullAccess: false).title(name: "Storm two")
        )
        XCTAssertTrue(night.model.loadedMixWasStripped)
    }

    func testTheFourthMixAsksForProByDayAndForNothingAtNight() throws {
        let night = try NightHarness(at: time(12), free: true)
        for index in 1...AccessPolicy.freeSavedMixLimit {
            XCTAssertTrue(night.model.canSaveMix)
            guard case .saved = night.model.saveCurrent(name: "Mix \(index)") else {
                return XCTFail("the free tier keeps \(AccessPolicy.freeSavedMixLimit) mixes")
            }
        }
        XCTAssertFalse(night.model.canSaveMix)
        let loaded = night.model.loadedMix
        let levelsBefore = night.model.levels

        XCTAssertEqual(night.model.saveCurrent(name: "One more"), .needsPro)
        XCTAssertTrue(night.model.showPaywall, "by day the sheet goes up")
        night.model.dismissPro()

        for hour in [time(21), time(23, 30), time(3, 42), time(6, 59)] {
            night.clock.now = hour
            XCTAssertEqual(night.model.saveCurrent(name: "One more"), .needsPro)
            XCTAssertFalse(night.model.showPaywall, "inside the night window nothing is sold")
        }
        XCTAssertEqual(night.model.mixStore.mixes.count, AccessPolicy.freeSavedMixLimit)
        XCTAssertEqual(night.model.levels, levelsBefore, "the mix is intact")
        XCTAssertEqual(night.model.loadedMix, loaded)
    }

    // MARK: Renaming, deleting, clearing

    func testRenamingTheLoadedMixRenamesThePageAndTheLockScreen() throws {
        let night = try NightHarness(at: time(12), free: true)
        let storm = try saveStorm(night)
        night.model.playMix(.saved(storm.id))

        XCTAssertTrue(night.model.renameMix(storm.id, to: "Thunder at the window"))
        let load = MixLoad(levels: storm.levelsBySound, hasFullAccess: false)
        XCTAssertEqual(night.model.loadedMixName, load.title(name: "Thunder at the window"))
        XCTAssertEqual(night.model.loadedMixBaseName, "Thunder at the window")
        XCTAssertEqual(night.nowPlaying.title, load.title(name: "Thunder at the window"))
        XCTAssertEqual(night.model.loadedMix, .saved(storm.id))
        XCTAssertTrue(night.model.isPlaying)

        XCTAssertFalse(night.model.renameMix(storm.id, to: "  "), "an empty name changes nothing")
        XCTAssertEqual(night.model.loadedMixBaseName, "Thunder at the window")

        // Renaming another mix leaves the loaded one alone.
        guard case .saved(let other) = night.model.mixStore.save(
            name: "Other", levels: levels([.pink: 0.3]), hasFullAccess: true
        ) else { return XCTFail("saved") }
        XCTAssertTrue(night.model.renameMix(other.id, to: "Another"))
        XCTAssertEqual(night.model.loadedMixBaseName, "Thunder at the window")

        let again = try NightHarness(at: time(13), free: true, defaults: night.defaults)
        XCTAssertEqual(again.model.loadedMixBaseName, "Thunder at the window")
    }

    func testDeletingTheLoadedMixLeavesWhatSoundsAsTonight() throws {
        let night = try NightHarness(at: time(12))
        let storm = try saveStorm(night)
        night.model.playMix(.saved(storm.id))
        let levelsBefore = night.model.levels
        night.engine.forgetCalls()

        night.model.deleteMix(storm.id)
        XCTAssertTrue(night.model.mixStore.mixes.isEmpty)
        XCTAssertNil(night.model.loadedMix)
        XCTAssertNil(night.model.loadedMixName)
        XCTAssertTrue(night.model.isPlaying, "the sound is not touched")
        XCTAssertEqual(night.engine.calls, [])
        XCTAssertEqual(night.model.levels, levelsBefore)
        XCTAssertEqual(night.nowPlaying.title, PageTitle.text(loadedMixName: nil))

        // Deleting a mix that is not the loaded one changes nothing else.
        let other = try saveStorm(night)
        night.model.loadHouseMix(.wall)
        night.model.deleteMix(other.id)
        XCTAssertEqual(night.model.loadedMix, .house(.wall))
    }

    func testMovingAMixReordersTheList() throws {
        let night = try NightHarness(at: time(12))
        try saveStorm(night)
        guard case .saved(let hotel) = night.model.mixStore.save(
            name: "Hotel", levels: levels([.pink: 0.3]), hasFullAccess: true
        ) else { return XCTFail("saved") }
        XCTAssertEqual(night.model.mixStore.mixes.map(\.name), ["Hotel", "Storm"])
        night.model.moveMix(hotel.id, by: 1)
        XCTAssertEqual(night.model.mixStore.mixes.map(\.name), ["Storm", "Hotel"])
        night.model.moveMix(hotel.id, by: 1)
        XCTAssertEqual(night.model.mixStore.mixes.map(\.name), ["Storm", "Hotel"])
    }

    func testClearingLeavesSilenceAndTheSavedMixUntouched() throws {
        let night = try NightHarness(at: time(12))
        let storm = try saveStorm(night)
        night.model.playMix(.saved(storm.id))
        night.engine.render(seconds: 2)
        let revision = night.model.mixRevision
        night.engine.forgetCalls()

        night.model.clearMix()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause, "the night is over: the page says Silent, not Paused")
        XCTAssertEqual(night.engine.stops, [.stop(fadeOut: PlaybackFade.pause)], "it leaves like a pause, never a cut")
        XCTAssertFalse(night.engine.calls.contains(.gains), "the fade keeps the gains it had")
        XCTAssertTrue(night.model.levels.values.allSatisfy { $0 == 0 })
        XCTAssertTrue(night.model.isSilent)
        XCTAssertNil(night.model.loadedMix)
        XCTAssertNil(night.model.loadedMixName)
        XCTAssertGreaterThan(night.model.mixRevision, revision)
        XCTAssertFalse(night.model.timer.hasCount)
        XCTAssertEqual(night.model.mixStore.mix(storm.id), storm, "the mix it came from is not touched")
        XCTAssertFalse(night.nowPlaying.isPlaying)
        XCTAssertEqual(night.nowPlaying.title, PageTitle.text(loadedMixName: nil))

        // It is undone by loading a mix; the next Play is a new night.
        let again = try NightHarness(at: time(13), defaults: night.defaults)
        XCTAssertTrue(again.model.isSilent)
        XCTAssertNil(again.model.loadedMix)
        XCTAssertEqual(night.model.playMix(.saved(storm.id)), .started)
        XCTAssertEqual(night.model.levels[.rain], 0.5)

        // Small Hours is not the mix: Clear leaves it alone.
        night.model.startSmallHours()
        night.model.clearMix()
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.levels[.rain], 0.5)
    }
}

// MARK: - Now Playing (surface 34)

@MainActor
final class NowPlayingTests: XCTestCase {
    private func time(_ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(hour, minute)
    }

    func testTheLockScreenIsToldTheMixAndThatItIsLive() {
        let info = NowPlayingController.info(title: "Sea and wind", artist: "App", isPlaying: true, elapsed: 12)
        XCTAssertEqual(info[MPMediaItemPropertyTitle] as? String, "Sea and wind")
        XCTAssertEqual(info[MPMediaItemPropertyArtist] as? String, "App")
        XCTAssertEqual(info[MPNowPlayingInfoPropertyIsLiveStream] as? Bool, true, "no progress bar: it has no length")
        XCTAssertEqual(info[MPNowPlayingInfoPropertyPlaybackRate] as? Double, 1)
        XCTAssertNil(info[MPMediaItemPropertyPlaybackDuration])
        XCTAssertNil(info[MPMediaItemPropertyArtwork], "no artwork of its own")

        let paused = NowPlayingController.info(title: "Sea and wind", artist: "App", isPlaying: false, elapsed: 12)
        XCTAssertEqual(paused[MPNowPlayingInfoPropertyPlaybackRate] as? Double, 0)
        XCTAssertEqual(paused[MPNowPlayingInfoPropertyIsLiveStream] as? Bool, true)
    }

    func testTheTitleIsTheNameThePageShows() throws {
        let night = try NightHarness(at: time(23), free: true)
        XCTAssertEqual(night.model.nowPlayingTitle, HouseMix.pinkAndRain.localizedName)

        // Trimmed: the lock screen says what is not playing too.
        let load = night.model.loadHouseMix(.seaAndWind)
        XCTAssertEqual(night.model.nowPlayingTitle, load.title(name: HouseMix.seaAndWind.localizedName))
        XCTAssertNotEqual(night.model.nowPlayingTitle, HouseMix.seaAndWind.localizedName)

        // Edited: "Tonight", never the name of the app or an empty title.
        night.model.play()
        XCTAssertEqual(night.model.setLevel(.wind, 0.5), .applied)
        XCTAssertEqual(night.model.nowPlayingTitle, Localized.string("mezcla.nombre.vacio"))
        XCTAssertEqual(night.nowPlaying.title, Localized.string("mezcla.nombre.vacio"))
        XCTAssertFalse(night.model.nowPlayingTitle.isEmpty)

        // Small Hours goes by its own name, and the mix has its own back.
        night.model.startSmallHours()
        XCTAssertEqual(night.nowPlaying.title, Localized.string("madrugada.titulo"))
        night.model.endSmallHours()
        XCTAssertEqual(night.nowPlaying.title, Localized.string("mezcla.nombre.vacio"))
    }

    func testPlayAndPauseFromTheLockScreenFollowTheNightScreen() throws {
        let night = try NightHarness(at: time(23))
        night.model.enterBedtime()
        XCTAssertTrue(night.model.isBedtime)
        XCTAssertTrue(night.nowPlaying.isPlaying)

        night.nowPlaying.pressPause()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.pauseCause, .person, "on the speaker it is the person's pause")
        XCTAssertFalse(night.nowPlaying.isPlaying)
        XCTAssertTrue(night.model.isBedtime, "Night stays where it was")

        night.nowPlaying.pressPlay()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertNil(night.model.pauseCause)
        XCTAssertTrue(night.model.isBedtime)
        XCTAssertEqual(night.nowPlaying.elapsedResets, 1, "the same night: its time does not start again")

        night.nowPlaying.pressToggle()
        XCTAssertFalse(night.model.isPlaying)
        night.nowPlaying.pressToggle()
        XCTAssertTrue(night.model.isPlaying)
    }

    func testPlayAndPauseFromTheLockScreenDriveSmallHoursNotTheMix() throws {
        let night = try NightHarness(at: time(4), free: true)
        night.model.startSmallHours()
        night.advance(seconds: 120)

        night.nowPlaying.pressPause()
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertTrue(night.model.isSmallHours)
        XCTAssertTrue(night.model.smallHours.isPaused)
        XCTAssertEqual(night.nowPlaying.title, Localized.string("madrugada.titulo"))

        night.nowPlaying.pressPlay()
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertTrue(night.model.isSmallHours, "Play resumes the recipe, not the mix")
        XCTAssertFalse(night.model.smallHours.isPaused)
        XCTAssertEqual(night.model.smallHours.elapsed, 120, accuracy: 1, "where it was, not from the start")
        XCTAssertEqual(night.engine.gains.pink, 0)
        XCTAssertGreaterThan(night.engine.gains.ocean, 0)
        XCTAssertFalse(night.model.showPaywall)
    }
}

// MARK: - The catalog of the mixes

final class MixesCatalogTests: XCTestCase {
    static let keys = [
        "mezclas.titulo", "mezclas.seccion.tuyas", "mezclas.seccion.casa", "mezclas.esta_noche",
        "mezclas.receta.capa", "mezclas.receta.pro", "mezclas.receta.separador", "mezclas.sonando",
        "mezclas.vacio", "mezclas.guardada", "mezclas.eliminar.titulo", "mezclas.eliminar.nota",
        "mezcla.guardar.titulo", "mezcla.guardar.campo", "mezcla.menu.guardar",
        "mezcla.menu.vaciar", "mezcla.nombre.auto.3", "mezcla.nombre.auto.mas", "mezcla.nombre.sin",
        "mezcla.nombre.vacio", "pagina.capas.y", "comun.renombrar", "comun.eliminar",
        "ax.mezcla.pista", "ax.esta_noche", "ax.esta_noche.pista", "ax.receta.pro", "ax.vaciar.pista",
        "ax.guardar.pro", "ax.guardar.pro.pista", "ax.accion.guardar", "ax.accion.subir", "ax.accion.bajar"
    ]

    func testEveryMixStringExistsInBothLanguages() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in Self.keys {
            for language in ["en", "es"] {
                let found = TimerCatalogTests.values(key, language, in: strings)
                XCTAssertFalse(found.isEmpty, "\(key) [\(language)] is missing")
                XCTAssertFalse(found.contains { $0.isEmpty }, "\(key) [\(language)] is empty")
            }
        }
    }

    /// The old sheet, the old shortcuts and the old Now Playing title went
    /// with their strings; a key that comes back is copy nobody reads.
    func testTheStringsOfTheOldSheetAndShortcutsAreGone() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in strings.keys {
            for prefix in ["mixes.", "intent.", "shortcut."] {
                XCTAssertFalse(key.hasPrefix(prefix), "\(key) belongs to something that was removed")
            }
        }
        XCTAssertNil(strings["nowplaying.title"], "the title is the mix, not a fixed name")
        XCTAssertNotNil(strings["nowplaying.artist"])
    }

    /// A mix is never a "mix" in Spanish, and a row never says a layer is
    /// locked: it says it "is Pro".
    func testTheWordsOfTheSheetFollowTheGuide() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in Self.keys {
            for value in TimerCatalogTests.values(key, "es", in: strings) {
                let words = value.lowercased().split { !$0.isLetter }.map(String.init)
                XCTAssertFalse(words.contains("mix"), "\(key): \(value)")
                XCTAssertFalse(words.contains("preset"), "\(key): \(value)")
            }
            for language in ["en", "es"] {
                for value in TimerCatalogTests.values(key, language, in: strings) {
                    XCTAssertFalse(value.contains("!"), "\(key): \(value)")
                    XCTAssertFalse(value.contains("¡"), "\(key): \(value)")
                    for banned in ["unlock", "desbloque", "premium", "locked", "bloquead"] {
                        XCTAssertFalse(value.lowercased().contains(banned), "\(key): \(value)")
                    }
                }
            }
        }
    }
}
