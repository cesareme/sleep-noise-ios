import XCTest
@testable import SleepNoise

/// Six at once, by one rule (C19, `LayerCap`): whatever road leads to more
/// than six layers above zero, the six highest that are included sound and
/// the others keep their level without sounding. Nothing stored changes.
@MainActor
final class LayerCapTests: XCTestCase {
    private let levelsKey = "sleepnoise.levels.v1"

    /// Eight layers, no two at the same level. The six highest are ocean,
    /// rain, campfire, pink, wind and thunder; white and brown wait.
    private let eight: [SoundID: Float] = [
        .white: 0.15, .pink: 0.3, .brown: 0.1, .rain: 0.45, .wind: 0.25,
        .ocean: 0.5, .thunder: 0.2, .campfire: 0.35,
    ]
    private let sixOfEight: Set<SoundID> = [.ocean, .rain, .campfire, .pink, .wind, .thunder]

    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    /// The levels as a launch finds them on disk.
    private func store(_ levels: [SoundID: Float], in defaults: UserDefaults) throws {
        let payload = SoundID.allCases.map { MixLevel(sound: $0, value: levels[$0] ?? 0) }
        defaults.set(try JSONEncoder().encode(payload), forKey: levelsKey)
    }

    private func full(_ levels: [SoundID: Float]) -> [SoundID: Float] {
        Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, levels[$0] ?? 0) })
    }

    /// What the engine was last told: the layers with a gain above zero.
    private func heard(_ night: NightHarness) -> [SoundID: Float] {
        var heard: [SoundID: Float] = [:]
        for sound in SoundID.allCases where night.engine.gains.value(for: sound) > 0 {
            heard[sound] = night.engine.gains.value(for: sound)
        }
        return heard
    }

    private func assertHeard(
        _ night: NightHarness,
        _ expected: Set<SoundID>,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let heard = self.heard(night)
        XCTAssertEqual(Set(heard.keys), expected, message, file: file, line: line)
        for (sound, gain) in heard {
            XCTAssertEqual(gain, night.model.levels[sound], "\(sound.rawValue) at its own level", file: file, line: line)
        }
        XCTAssertEqual(Set(night.model.soundingLayers), expected, message, file: file, line: line)
    }

    // MARK: The rule

    func testTheSixHighestIncludedLayersSound() {
        XCTAssertEqual(LayerCap.limit, 6)
        XCTAssertEqual(MixerModel.maxSimultaneousLayers, LayerCap.limit)
        let everything: (SoundID) -> Bool = { _ in true }
        XCTAssertEqual(
            LayerCap.ranked(eight, isIncluded: everything),
            [.ocean, .rain, .campfire, .pink, .wind, .thunder, .white, .brown]
        )
        XCTAssertEqual(LayerCap.sounding(eight, isIncluded: everything), sixOfEight)
        XCTAssertEqual(LayerCap.waiting(eight, isIncluded: everything), [.white, .brown], "the next one in first")

        // A layer that is not included is not counted and takes no place.
        let free: (SoundID) -> Bool = { AccessPolicy.soundIsIncluded($0, hasFullAccess: false) }
        XCTAssertEqual(LayerCap.sounding(eight, isIncluded: free), [.white, .pink, .brown, .rain, .wind])
        XCTAssertEqual(LayerCap.waiting(eight, isIncluded: free), [])

        // Six or fewer: all of them, and nobody waits.
        let six = eight.filter { sixOfEight.contains($0.key) }
        XCTAssertEqual(LayerCap.sounding(six, isIncluded: everything), sixOfEight)
        XCTAssertEqual(LayerCap.waiting(six, isIncluded: everything), [])
        XCTAssertEqual(LayerCap.sounding([:], isIncluded: everything), [])
        // A layer at zero is not in the mix.
        XCTAssertEqual(LayerCap.sounding([.rain: 0, .pink: 0.2], isIncluded: everything), [.pink])
    }

    /// Red if two layers at the same level could trade places from one
    /// launch to the next: the first in the order of the stored ids sounds.
    func testEqualLevelsAreSettledByTheOrderOfTheStoredIds() {
        let everything: (SoundID) -> Bool = { _ in true }
        let flat = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0.3)) })
        let order = SoundID.allCases
        XCTAssertEqual(order.count, 11)
        for _ in 0..<20 {
            XCTAssertEqual(LayerCap.ranked(flat, isIncluded: everything), order)
            XCTAssertEqual(LayerCap.sounding(flat, isIncluded: everything), Set(order.prefix(6)))
            XCTAssertEqual(LayerCap.waiting(flat, isIncluded: everything), Array(order.dropFirst(6)))
        }
        XCTAssertEqual(Array(order.prefix(6)), [.white, .pink, .brown, .rain, .fan, .ocean])

        // The tie is only between equals: a higher level always goes first.
        var mixed = flat
        mixed[.cabin] = 0.31
        XCTAssertEqual(LayerCap.ranked(mixed, isIncluded: everything).first, .cabin)
        XCTAssertEqual(
            LayerCap.sounding(mixed, isIncluded: everything), [.cabin, .white, .pink, .brown, .rain, .fan]
        )
    }

    // MARK: Every road to more than six

    /// Red if a saved mix of eight plays eight, loses a level on the way
    /// in, or is written back with fewer layers.
    func testASavedMixWithMoreThanSixPlaysItsSixHighestAndKeepsEveryLevel() throws {
        let night = try NightHarness(at: time(12))
        guard case .saved(let saved) = night.model.mixStore.save(
            name: "Eight", levels: eight, hasFullAccess: true
        ) else { return XCTFail("saved") }
        XCTAssertEqual(saved.levelsBySound, full(eight), "saved whole")

        XCTAssertEqual(night.model.playMix(.saved(saved.id)), .started)
        XCTAssertEqual(night.model.levels, full(eight), "every level as it was saved")
        assertHeard(night, sixOfEight)
        XCTAssertEqual(night.model.waitingLayers, [.white, .brown])
        XCTAssertEqual(night.model.loadedMixName, "Eight", "the mix keeps its own name")
        XCTAssertFalse(night.model.showPaywall)

        // Nothing stored was rewritten: the mix in the list, and the live
        // levels a new launch reads.
        XCTAssertEqual(night.model.mixStore.mix(saved.id), saved)
        let next = try NightHarness(at: time(13), defaults: night.defaults)
        XCTAssertEqual(next.model.levels, full(eight))
        XCTAssertEqual(next.model.loadedMixName, "Eight")
        XCTAssertEqual(Set(next.model.soundingLayers), sixOfEight)
        next.model.play()
        assertHeard(next, sixOfEight, "the same six after a restart")

        // Loaded without playing, then Play: the same six.
        let quiet = try NightHarness(at: time(12))
        guard case .saved(let again) = quiet.model.mixStore.save(
            name: "Eight", levels: eight, hasFullAccess: true
        ) else { return XCTFail("saved") }
        quiet.model.apply(again)
        XCTAssertEqual(Set(quiet.model.soundingLayers), sixOfEight)
        quiet.model.play()
        assertHeard(quiet, sixOfEight)
    }

    func testAShortcutThatPlaysSuchAMixFollowsTheSameRule() throws {
        let night = try NightHarness(at: time(23))
        guard case .saved(let saved) = night.model.mixStore.save(
            name: "Eight", levels: eight, hasFullAccess: true
        ) else { return XCTFail("saved") }
        XCTAssertEqual(night.model.playMixFromShortcut(.saved(saved.id)), .started)
        assertHeard(night, sixOfEight)
        XCTAssertEqual(night.model.levels, full(eight))

        // "Play my last mix" on the levels a launch finds: the same.
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let last = try NightHarness(at: time(23), defaults: defaults)
        XCTAssertEqual(last.model.playFromShortcut(), .started)
        assertHeard(last, sixOfEight)
    }

    /// Red if levels stored before the cap existed are trimmed on disk, or
    /// all sound.
    func testLevelsStoredByAnEarlierVersionAreKeptAndCapped() throws {
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let before = try XCTUnwrap(defaults.data(forKey: levelsKey))

        let night = try NightHarness(at: time(12), defaults: defaults)
        XCTAssertEqual(night.model.levels, full(eight))
        XCTAssertEqual(night.model.waitingLayers, [.white, .brown])
        night.model.play()
        assertHeard(night, sixOfEight)
        night.model.pause()
        XCTAssertEqual(defaults.data(forKey: levelsKey), before, "nothing on disk was rewritten")
    }

    /// Red if getting access back with Pro layers kept at a level makes a
    /// seventh layer sound, or moves a level.
    func testAccessThatComesBackDoesNotPassSix() async throws {
        // Five free layers sounding, and two Pro layers kept from before.
        let kept: [SoundID: Float] = [
            .white: 0.15, .pink: 0.3, .brown: 0.2, .rain: 0.45, .wind: 0.25, .ocean: 0.5, .thunder: 0.6,
        ]
        let defaults = try makeDefaults()
        try store(kept, in: defaults)
        let before = try XCTUnwrap(defaults.data(forKey: levelsKey))
        let night = try NightHarness(at: time(23), access: .free, defaults: defaults)
        night.model.play()
        assertHeard(night, [.white, .pink, .brown, .rain, .wind], "without access the Pro layers are silent")
        XCTAssertEqual(night.model.waitingLayers, [])

        // Restored in the middle of the night: heard at once, six at most.
        night.store.entitlementAfterSync = .entitled(
            ProReceipt(purchaseDate: time(day: 10, 12), isFamilyShared: false)
        )
        await night.purchases.restore()
        XCTAssertTrue(night.purchases.hasFullAccess)
        assertHeard(night, [.thunder, .ocean, .rain, .pink, .wind, .brown])
        XCTAssertEqual(night.model.waitingLayers, [.white], "the lowest one waits")
        XCTAssertEqual(night.model.levels, full(kept), "no level moved")
        XCTAssertEqual(defaults.data(forKey: levelsKey), before, "nothing on disk was rewritten")
        XCTAssertFalse(night.model.showPaywall)
    }

    /// The other way round: when the trial ends, the Pro layers go and the
    /// free ones that waited behind them sound.
    func testWhenTheTrialEndsTheLayersThatWaitedComeIn() throws {
        let start = time(12)
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let night = try NightHarness(at: start, access: .trial, defaults: defaults)
        XCTAssertTrue(night.purchases.hasFullAccess)
        night.model.play()
        assertHeard(night, sixOfEight)
        XCTAssertEqual(night.model.waitingLayers, [.white, .brown])
        night.model.pause()

        // Eight days on, a new night: the trial is found over before
        // anything sounds.
        night.jump(to: start.addingTimeInterval(8 * 86_400))
        night.model.play()
        XCTAssertFalse(night.purchases.hasFullAccess)
        assertHeard(night, [.white, .pink, .brown, .rain, .wind], "white and brown no longer wait")
        XCTAssertEqual(night.model.waitingLayers, [])
        XCTAssertEqual(night.model.levels, full(eight), "the Pro layers keep their level")
    }

    // MARK: While the mix is edited

    /// Red if a layer that waits never gets its turn.
    func testTakingOneOfTheSixToZeroLetsTheNextOneIn() throws {
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let night = try NightHarness(at: time(12), defaults: defaults)
        night.model.play()
        assertHeard(night, sixOfEight)

        XCTAssertEqual(night.model.setLevel(.thunder, 0), .applied)
        assertHeard(night, [.ocean, .rain, .campfire, .pink, .wind, .white], "white was the next by level")
        XCTAssertEqual(night.model.waitingLayers, [.brown])
        XCTAssertEqual(night.model.levels[.white], 0.15, "at the level it kept")

        XCTAssertEqual(night.model.setLevel(.ocean, 0), .applied)
        assertHeard(night, [.rain, .campfire, .pink, .wind, .white, .brown])
        XCTAssertEqual(night.model.waitingLayers, [])

        // Six sound again: a seventh from zero is still refused.
        XCTAssertEqual(night.model.setLevel(.thunder, 0.9), .capReached)
        XCTAssertEqual(night.model.levels[.thunder], 0)
    }

    /// The rule has no memory: the six that sound are the six highest at
    /// every moment, also while a level moves.
    func testTheSixAreAlwaysTheHighestWhileALevelMoves() throws {
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let night = try NightHarness(at: time(12), defaults: defaults)
        night.model.play()

        // A layer that waits is raised over the lowest of the six.
        XCTAssertEqual(night.model.setLevel(.white, 0.22), .applied)
        assertHeard(night, [.ocean, .rain, .campfire, .pink, .wind, .white])
        XCTAssertEqual(night.model.waitingLayers, [.thunder, .brown])
        // One of the six is lowered under a layer that waits.
        XCTAssertEqual(night.model.setLevel(.ocean, 0.04), .applied)
        assertHeard(night, [.rain, .campfire, .pink, .wind, .white, .thunder])
        XCTAssertEqual(night.model.waitingLayers, [.brown, .ocean])
        // And a layer that waits may be taken out of the mix.
        XCTAssertEqual(night.model.setLevel(.brown, 0), .applied)
        XCTAssertEqual(night.model.waitingLayers, [.ocean])

        // With more than six in the mix, one more from zero is refused.
        XCTAssertEqual(night.model.setLevel(.cabin, 0.8), .capReached)
        XCTAssertEqual(night.model.levels[.cabin], 0)
        // The tide does not raise an ocean that waits.
        night.model.setBreathingEnabled(true)
        XCTAssertEqual(night.model.levels[.ocean], 0.04)
        XCTAssertEqual(night.model.breathingNote, Localized.string("capas.tope"))
    }

    /// A tie in a real mix is settled the same way at every launch.
    func testATieInTheMixIsSettledTheSameWayEveryTime() throws {
        var tied = eight
        // Thunder, white and brown at one level, for one place.
        tied[.thunder] = 0.2
        tied[.white] = 0.2
        tied[.brown] = 0.2
        for _ in 0..<3 {
            let defaults = try makeDefaults()
            try store(tied, in: defaults)
            let night = try NightHarness(at: time(12), defaults: defaults)
            night.model.play()
            assertHeard(night, [.ocean, .rain, .campfire, .pink, .wind, .white], "white is first in the stored order")
            XCTAssertEqual(night.model.waitingLayers, [.brown, .thunder])
        }
    }

    // MARK: What the row says

    /// Red if a row that waits reads like one that sounds, or if the words
    /// of the cap change.
    func testALayerThatWaitsSaysSoInTheWordsOfTheCap() throws {
        let app = Bundle(for: MixStore.self)
        let spanish = try XCTUnwrap(app.url(forResource: "es", withExtension: "lproj").flatMap(Bundle.init(url:)))
        let english = try XCTUnwrap(app.url(forResource: "en", withExtension: "lproj").flatMap(Bundle.init(url:)))
        func speech(_ level: Float, waiting: Bool, bundle: Bundle) -> LevelRuleSpeech {
            LevelRuleSpeech(
                name: "Name", subtitle: "detail", level: level, isWaiting: waiting, bundle: bundle
            )
        }
        XCTAssertEqual(
            speech(0.15, waiting: true, bundle: spanish).value, "en silencio, nivel guardado 15, Seis a la vez"
        )
        XCTAssertEqual(
            speech(0.15, waiting: true, bundle: english).value, "silent, saved level 15, Six at once"
        )
        // Sounding, or at zero: the level and nothing else.
        XCTAssertEqual(
            speech(0.15, waiting: false, bundle: english).value,
            Localized.format("a11y.percentFormat", bundle: english, Int64(15))
        )
        XCTAssertFalse(speech(0, waiting: true, bundle: english).value.contains("Six"))
        // The label never says Pro for it: the layer is the person's.
        XCTAssertEqual(
            speech(0.15, waiting: true, bundle: english).label,
            speech(0.15, waiting: false, bundle: english).label
        )
    }
}
