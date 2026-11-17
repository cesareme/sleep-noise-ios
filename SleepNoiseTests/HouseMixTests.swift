import XCTest
@testable import SleepNoise

/// The four house mixes and the trimmed load of a mix with Pro layers.
final class HouseMixTests: XCTestCase {
    private typealias AccessRule = (SoundID, Bool) -> Bool

    /// The free list the product settled on. Only used as one of the access
    /// rules these tests pass in: the code under test never lists textures.
    private static let settledFree: Set<SoundID> = [.white, .pink, .brown, .rain, .wind]

    private func rule(free: Set<SoundID>) -> AccessRule {
        { sound, hasFullAccess in hasFullAccess || free.contains(sound) }
    }

    /// The compiled string catalog in one language, whatever the simulator speaks.
    private func catalog(_ language: String) throws -> (String) -> String {
        let url = try XCTUnwrap(Bundle(for: MixStore.self).url(forResource: language, withExtension: "lproj"))
        let bundle = try XCTUnwrap(Bundle(url: url))
        return { bundle.localizedString(forKey: $0, value: "<missing \($0)>", table: nil) }
    }

    private func title(_ load: MixLoad, _ mix: HouseMix, in language: String) throws -> String {
        let strings = try catalog(language)
        return load.title(name: strings(mix.nameKey), soundName: { strings($0.nameKey) }, localized: strings)
    }

    private func audible(_ levels: [SoundID: Float]) -> [SoundID: Float] {
        levels.filter { $0.value > MixLoad.audibleThreshold }
    }

    // MARK: Recipes

    func testTheFourHouseMixesAndTheirLevels() throws {
        let expected: [(HouseMix, String, String, String, [SoundID: Float])] = [
            (.pinkAndRain, "pinkAndRain", "Pink and rain", "Rosa y lluvia", [.rain: 0.55, .pink: 0.20]),
            (.seaAndWind, "seaAndWind", "Sea and wind", "Mar y viento", [.ocean: 0.50, .wind: 0.20]),
            (.brownAndFire, "brownAndFire", "Brown and fire", "Marrón y hoguera", [.brown: 0.40, .campfire: 0.30]),
            (.wall, "wall", "Wall", "Pared", [.brown: 0.40, .rain: 0.30, .wind: 0.30]),
        ]
        XCTAssertEqual(HouseMix.allCases, expected.map(\.0))
        let (english, spanish) = (try catalog("en"), try catalog("es"))
        for (mix, id, en, es, levels) in expected {
            // Shortcuts keep the id: it is frozen like the sound ids.
            XCTAssertEqual(mix.rawValue, id)
            XCTAssertEqual(mix.id, id)
            XCTAssertEqual(english(mix.nameKey), en)
            XCTAssertEqual(spanish(mix.nameKey), es)
            XCTAssertEqual(audible(mix.levelsBySound()), levels, id)
        }
    }

    func testRecipesAreWellFormed() {
        for mix in HouseMix.allCases {
            let recipe = mix.recipe
            XCTAssertFalse(recipe.isEmpty, mix.rawValue)
            XCTAssertLessThanOrEqual(recipe.count, 6, "\(mix.rawValue): six layers at once is the cap")
            XCTAssertEqual(Set(recipe.map(\.sound)).count, recipe.count, "\(mix.rawValue): a sound appears once")
            XCTAssertEqual(recipe.map(\.value), recipe.map(\.value).sorted(by: >), "\(mix.rawValue): loudest first")
            for layer in recipe {
                XCTAssertGreaterThan(layer.value, MixLoad.audibleThreshold, mix.rawValue)
                XCTAssertLessThanOrEqual(layer.value, 1, mix.rawValue)
            }
            let levels = mix.levelsBySound()
            XCTAssertEqual(Set(levels.keys), Set(SoundID.allCases), "\(mix.rawValue): one level per sound")
            XCTAssertEqual(audible(levels).count, recipe.count, mix.rawValue)
        }
    }

    // MARK: Trimmed load

    /// Against whatever `AccessPolicy` says today: what is left out is exactly
    /// what the policy does not include, and nothing else changes.
    func testLoadFollowsAccessPolicyAsItIs() {
        for mix in HouseMix.allCases {
            for hasFullAccess in [false, true] {
                let label = "\(mix.rawValue), full access \(hasFullAccess)"
                let load = mix.load(hasFullAccess: hasFullAccess)
                let recipe = mix.recipe.map(\.sound)
                let notIncluded = recipe.filter { !AccessPolicy.soundIsIncluded($0, hasFullAccess: hasFullAccess) }

                XCTAssertEqual(load.levels, mix.levelsBySound(), "\(label): the mixer keeps every level")
                XCTAssertEqual(Set(load.omitted), Set(notIncluded), label)
                XCTAssertEqual(load.isTrimmed, !notIncluded.isEmpty, label)
                XCTAssertEqual(
                    Set(audible(load.audibleLevels).keys), Set(recipe).subtracting(notIncluded), label
                )
                for (sound, level) in audible(load.audibleLevels) {
                    XCTAssertEqual(level, load.levels[sound], "\(label): what plays keeps its level")
                }
                XCTAssertEqual(load.isSilent, notIncluded.count == recipe.count, label)
                if hasFullAccess {
                    XCTAssertFalse(load.isTrimmed, "\(label): full access plays every house mix whole")
                }
            }
        }
    }

    /// The same four mixes over three access rules, with what each must give.
    func testLoadOverAccessRules() throws {
        struct Row {
            let rule: String
            let free: Set<SoundID>
            let mix: HouseMix
            let omitted: [SoundID]
            let plays: Set<SoundID>
            let english: String
            let spanish: String
        }
        // The rule main ships today still keeps wind for Pro.
        let withoutWind = Self.settledFree.subtracting([.wind])
        let rows = [
            Row(rule: "settled", free: Self.settledFree, mix: .pinkAndRain, omitted: [],
                plays: [.rain, .pink], english: "Pink and rain", spanish: "Rosa y lluvia"),
            Row(rule: "settled", free: Self.settledFree, mix: .seaAndWind, omitted: [.ocean],
                plays: [.wind], english: "Sea and wind · without Ocean", spanish: "Mar y viento · sin Océano"),
            Row(rule: "settled", free: Self.settledFree, mix: .brownAndFire, omitted: [.campfire],
                plays: [.brown], english: "Brown and fire · without Campfire", spanish: "Marrón y hoguera · sin Hoguera"),
            Row(rule: "settled", free: Self.settledFree, mix: .wall, omitted: [],
                plays: [.brown, .rain, .wind], english: "Wall", spanish: "Pared"),

            Row(rule: "wind is Pro", free: withoutWind, mix: .pinkAndRain, omitted: [],
                plays: [.rain, .pink], english: "Pink and rain", spanish: "Rosa y lluvia"),
            Row(rule: "wind is Pro", free: withoutWind, mix: .seaAndWind, omitted: [.ocean, .wind],
                plays: [], english: "Sea and wind · without Ocean or Wind", spanish: "Mar y viento · sin Océano ni Viento"),
            Row(rule: "wind is Pro", free: withoutWind, mix: .brownAndFire, omitted: [.campfire],
                plays: [.brown], english: "Brown and fire · without Campfire", spanish: "Marrón y hoguera · sin Hoguera"),
            Row(rule: "wind is Pro", free: withoutWind, mix: .wall, omitted: [.wind],
                plays: [.brown, .rain], english: "Wall · without Wind", spanish: "Pared · sin Viento"),

            Row(rule: "nothing free", free: [], mix: .wall, omitted: [.brown, .rain, .wind],
                plays: [], english: "Wall · without Brown, Rain or Wind", spanish: "Pared · sin Marrón, Lluvia ni Viento"),
            Row(rule: "everything free", free: Set(SoundID.allCases), mix: .seaAndWind, omitted: [],
                plays: [.ocean, .wind], english: "Sea and wind", spanish: "Mar y viento"),
        ]
        for row in rows {
            let label = "\(row.rule): \(row.mix.rawValue)"
            let load = MixLoad(levels: row.mix.levelsBySound(), hasFullAccess: false, isIncluded: rule(free: row.free))
            XCTAssertEqual(load.omitted, row.omitted, label)
            XCTAssertEqual(Set(audible(load.audibleLevels).keys), row.plays, label)
            XCTAssertEqual(load.isSilent, row.plays.isEmpty, label)
            XCTAssertEqual(load.levels, row.mix.levelsBySound(), "\(label): Pro layers keep their levels")
            XCTAssertEqual(try title(load, row.mix, in: "en"), row.english, label)
            XCTAssertEqual(try title(load, row.mix, in: "es"), row.spanish, label)

            // With full access the same mix is whole under every rule.
            let whole = MixLoad(levels: row.mix.levelsBySound(), hasFullAccess: true, isIncluded: rule(free: row.free))
            XCTAssertFalse(whole.isTrimmed, label)
            XCTAssertEqual(whole.audibleLevels, whole.levels, label)
            XCTAssertEqual(try title(whole, row.mix, in: "es"), try catalog("es")(row.mix.nameKey), label)
        }
    }

    /// Under the settled rule every house mix still has something to play.
    func testEveryHouseMixPlaysSomethingForFreeUnderTheSettledRule() {
        for mix in HouseMix.allCases {
            let load = MixLoad(levels: mix.levelsBySound(), hasFullAccess: false, isIncluded: rule(free: Self.settledFree))
            XCTAssertFalse(load.isSilent, mix.rawValue)
        }
    }

    /// The same rule serves a saved mix: any levels, not only the four recipes.
    func testLoadOfAnyLevels() {
        let free = rule(free: Self.settledFree)
        let levels: [SoundID: Float] = [.rain: 0.5, .thunder: 0.3, .fan: 0.7, .cabin: 0.3, .ocean: 0, .brook: 0.000_5]
        let load = MixLoad(levels: levels, hasFullAccess: false, isIncluded: free)
        // Loudest first; `SoundID.allCases` order between equal levels. A Pro
        // layer at zero, or below the threshold, was never part of the mix.
        XCTAssertEqual(load.omitted, [.fan, .thunder, .cabin])
        XCTAssertEqual(audible(load.audibleLevels), [.rain: 0.5])
        XCTAssertEqual(load.levels, levels)

        let empty = MixLoad(levels: [:], hasFullAccess: false, isIncluded: free)
        XCTAssertFalse(empty.isTrimmed)
        XCTAssertTrue(empty.isSilent)

        let names = ["Fan", "Thunder", "Cabin"]
        XCTAssertEqual(MixLoad.list([], lastPair: "%@ or %@"), "")
        XCTAssertEqual(MixLoad.list(Array(names.prefix(1)), lastPair: "%@ or %@"), "Fan")
        XCTAssertEqual(MixLoad.list(Array(names.prefix(2)), lastPair: "%@ or %@"), "Fan or Thunder")
        XCTAssertEqual(MixLoad.list(names, lastPair: "%@ ni %@"), "Fan, Thunder ni Cabin")
        XCTAssertEqual(
            load.title(name: "100% mine", soundName: { $0.rawValue }, localized: { key in
                key == MixLoad.titleKey ? "%@ · without %@" : "%@ or %@"
            }),
            "100% mine · without fan, thunder or cabin"
        )
    }
}

/// House mixes through the mixer. Nothing here starts the audio engine.
@MainActor
final class HouseMixModelTests: XCTestCase {
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

    func testLoadingAHouseMixNeverRaisesThePaywall() throws {
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        expire(purchases)
        XCTAssertFalse(purchases.hasFullAccess)
        let model = MixerModel(purchases: purchases, defaults: defaults)

        for mix in HouseMix.allCases {
            let load = model.loadHouseMix(mix)
            XCTAssertEqual(load, mix.load(hasFullAccess: false), mix.rawValue)
            XCTAssertFalse(model.showPaywall, "\(mix.rawValue): a house mix never opens the Pro sheet")
            XCTAssertEqual(model.levels, mix.levelsBySound(), "\(mix.rawValue): Pro layers keep their levels")
            XCTAssertEqual(model.activeHouseMix, mix)
            XCTAssertEqual(model.loadedMixWasStripped, load.isTrimmed, mix.rawValue)
            XCTAssertEqual(model.loadedMixName, load.title(name: mix.localizedName), mix.rawValue)
            XCTAssertEqual(model.loadedMixBaseName, mix.localizedName, mix.rawValue)
            XCTAssertEqual(
                model.nowPlayingTitle, load.title(name: mix.localizedName),
                "\(mix.rawValue): outside the app it says what is not playing too"
            )
            XCTAssertFalse(model.isPlaying, "loading does not start playback")
            XCTAssertFalse(load.isSilent, "\(mix.rawValue): every house mix has a free layer")
        }

        // The levels survive a relaunch, Pro layers included.
        let last = try XCTUnwrap(HouseMix.allCases.last)
        XCTAssertEqual(MixerModel(purchases: purchases, defaults: defaults).levels, last.levelsBySound())

        // Editing a level makes it the person's own mix again.
        let free = try XCTUnwrap(SoundID.allCases.first { AccessPolicy.soundIsIncluded($0, hasFullAccess: false) })
        model.setLevel(free, 0.33)
        XCTAssertNil(model.activeHouseMix)
        XCTAssertNil(model.loadedMixName)
        XCTAssertNil(model.loadedMixBaseName)
    }

    func testAHouseMixIsWholeWithAccessAndSaysWhatItLosesWithout() throws {
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        XCTAssertTrue(purchases.hasFullAccess)
        let model = MixerModel(purchases: purchases, defaults: defaults)
        let mix = try XCTUnwrap(HouseMix.allCases.first { $0.load(hasFullAccess: false).isTrimmed })

        XCTAssertFalse(model.loadHouseMix(mix).isTrimmed)
        XCTAssertEqual(model.loadedMixName, mix.localizedName)
        XCTAssertFalse(model.loadedMixWasStripped)

        expire(purchases)
        model.refreshEntitledAudio()
        let trimmed = mix.load(hasFullAccess: false)
        XCTAssertEqual(model.loadedMixName, trimmed.title(name: mix.localizedName))
        XCTAssertNotEqual(model.loadedMixName, mix.localizedName)
        XCTAssertTrue(model.loadedMixWasStripped)
        XCTAssertEqual(model.activeHouseMix, mix, "still the same house mix, trimmed")
        XCTAssertEqual(model.levels, mix.levelsBySound(), "nothing is written when access goes")
        XCTAssertFalse(model.showPaywall)
    }

    /// The tide raises a silent ocean so it can be heard, and that keeps the
    /// mix's identity. The title still follows the recipe: a layer the recipe
    /// never had is not named as missing when access goes.
    func testTheTitleFollowsTheRecipeNotALayerTheTideRaised() throws {
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        let model = MixerModel(purchases: purchases, defaults: defaults)
        let mix = HouseMix.pinkAndRain
        XCTAssertFalse(mix.load(hasFullAccess: false).isTrimmed, "the recipe has no Pro layer")

        model.loadHouseMix(mix)
        model.setBreathingEnabled(true)
        XCTAssertEqual(model.levels[.ocean], MixerModel.tideOceanLevel, "raised by the tide")
        XCTAssertEqual(model.activeHouseMix, mix)

        expire(purchases)
        model.refreshEntitledAudio()
        XCTAssertEqual(model.loadedMixName, mix.localizedName)
        XCTAssertEqual(model.nowPlayingTitle, mix.localizedName)
    }

    /// Loading a mix replaces every level, the ocean the tide raised too,
    /// and switching the tide off afterwards changes nothing in the new mix.
    func testLoadingAMixForgetsTheOceanTheTideRaised() throws {
        let seaAndWind = HouseMix.seaAndWind
        XCTAssertEqual(seaAndWind.levelsBySound()[.ocean], 0.5)
        var savedLevels = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        savedLevels[.ocean] = 0.5
        savedLevels[.rain] = 0.2
        let saved = SavedMix(
            id: UUID(),
            name: "Shore",
            levels: SoundID.allCases.map { MixLevel(sound: $0, value: savedLevels[$0] ?? 0) },
            createdAt: day0
        )

        for house in [true, false] {
            let name = house ? "house mix" : "saved mix"
            let expected = house ? seaAndWind.levelsBySound() : savedLevels
            let defaults = try makeDefaults()
            let purchases = PurchaseManager(defaults: defaults, now: day0)
            XCTAssertTrue(purchases.hasFullAccess)
            let model = MixerModel(purchases: purchases, defaults: defaults)
            XCTAssertEqual(model.levels[.ocean], 0, name)

            model.setBreathingEnabled(true)
            XCTAssertEqual(model.levels[.ocean], MixerModel.tideOceanLevel, "\(name): raised by the tide")
            if house {
                model.loadHouseMix(seaAndWind)
            } else {
                model.apply(saved)
            }
            model.setBreathingEnabled(false)
            XCTAssertEqual(model.levels, expected, "\(name): the mix keeps its ocean")
            XCTAssertEqual(MixerModel(purchases: purchases, defaults: defaults).levels, expected, "\(name): stored whole")
        }

        // Without a load in between the ocean the tide raised stays up: the
        // tide never switches off a layer it turned on.
        let defaults = try makeDefaults()
        let model = MixerModel(purchases: PurchaseManager(defaults: defaults, now: day0), defaults: defaults)
        model.setBreathingEnabled(true)
        model.setBreathingEnabled(false)
        XCTAssertEqual(model.levels[.ocean], MixerModel.tideOceanLevel)
    }

    /// A saved mix with Pro layers loads trimmed like a house mix: the title
    /// says what it plays without, and the name itself is kept apart.
    func testASavedMixWithProLayersLoadsTrimmed() throws {
        let defaults = try makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        expire(purchases)
        let model = MixerModel(purchases: purchases, defaults: defaults)
        let pro = try XCTUnwrap(SoundID.allCases.first { !AccessPolicy.soundIsIncluded($0, hasFullAccess: false) })
        let free = try XCTUnwrap(SoundID.allCases.first { AccessPolicy.soundIsIncluded($0, hasFullAccess: false) })
        let mix = SavedMix(
            id: UUID(),
            name: "Hotel",
            levels: [MixLevel(sound: free, value: 0.4), MixLevel(sound: pro, value: 0.7)],
            createdAt: day0
        )

        XCTAssertTrue(model.apply(mix))
        let trimmed = MixLoad(levels: model.levels, hasFullAccess: false)
        XCTAssertEqual(trimmed.omitted, [pro])
        XCTAssertEqual(model.loadedMixName, trimmed.title(name: "Hotel"))
        XCTAssertNotEqual(model.loadedMixName, "Hotel")
        XCTAssertEqual(model.loadedMixBaseName, "Hotel", "a save or a rename starts from the name alone")
        XCTAssertEqual(model.nowPlayingTitle, model.loadedMixName)
        XCTAssertTrue(model.loadedMixWasStripped)
        XCTAssertEqual(model.levels[pro], 0.7, "the Pro layer keeps its level")
        XCTAssertFalse(model.showPaywall)

        // Whole with access, and trimmed again when the title is worked out
        // after access changes.
        let fresh = try makeDefaults()
        let trial = PurchaseManager(defaults: fresh, now: day0)
        let whole = MixerModel(purchases: trial, defaults: fresh)
        XCTAssertFalse(whole.apply(mix))
        XCTAssertEqual(whole.loadedMixName, "Hotel")
        expire(trial)
        whole.refreshEntitledAudio()
        XCTAssertEqual(whole.loadedMixName, trimmed.title(name: "Hotel"))
        XCTAssertEqual(whole.loadedMixBaseName, "Hotel")
    }
}
