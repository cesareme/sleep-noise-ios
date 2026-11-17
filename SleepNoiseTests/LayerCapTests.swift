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

    /// Red if the rule compares the fraction a finger passes through and
    /// not the whole percent the row shows and the mix keeps: two rows
    /// that both say "20" would sound in the wrong order, and a layer
    /// heard while it is dragged would go silent when the finger lifts.
    func testALevelIsComparedAsThePercentTheRowShows() {
        let everything: (SoundID) -> Bool = { _ in true }
        XCTAssertEqual(LayerCap.percent(0.2049), 20)
        XCTAssertEqual(LayerCap.percent(0.20), 20)
        XCTAssertEqual(LayerCap.percent(0.205), LevelMath.percent(0.205))
        for level: Float in [-1, 0, 0.004, 0.005, 0.1549, 0.155, 0.5, 0.995, 1, 2, .nan] {
            XCTAssertEqual(LayerCap.percent(level), LevelMath.percent(level), "\(level)")
        }

        // Six at 30 and two that both show 20: brown is before thunder in
        // the stored order, so brown sounds, however little thunder is
        // over it in the fraction nobody sees.
        var mix: [SoundID: Float] = [
            .white: 0.3, .pink: 0.3, .rain: 0.3, .wind: 0.3, .ocean: 0.3, .brown: 0.20, .thunder: 0.2049,
        ]
        XCTAssertEqual(
            LayerCap.sounding(mix, isIncluded: everything), [.white, .pink, .rain, .wind, .ocean, .brown]
        )
        XCTAssertEqual(LayerCap.waiting(mix, isIncluded: everything), [.thunder])
        // What is left when the finger lifts (20) is what sounded on the way.
        mix[.thunder] = LevelMath.quantized(0.2049)
        XCTAssertEqual(LayerCap.waiting(mix, isIncluded: everything), [.thunder])
        // A whole percent more is more.
        mix[.thunder] = 0.2051
        XCTAssertEqual(LayerCap.waiting(mix, isIncluded: everything), [.brown])
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

    /// Red if a drag that touches zero cannot come back: in a mix with
    /// layers waiting, the next one comes in the moment the row reaches
    /// zero, and the way back up would be refused as a seventh layer with
    /// the finger still down. The level would be lost at the lift.
    func testALayerTakenToZeroComesBackInTheSameDrag() throws {
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let night = try NightHarness(at: time(12), defaults: defaults)
        night.model.play()
        assertHeard(night, sixOfEight)

        night.model.beginLevelGesture()
        XCTAssertEqual(night.model.setLevel(.thunder, 0.1), .applied)
        XCTAssertEqual(night.model.setLevel(.thunder, 0), .applied)
        assertHeard(night, [.ocean, .rain, .campfire, .pink, .wind, .white], "white came in meanwhile")
        // Back up without lifting: it is still a layer of this mix.
        XCTAssertEqual(night.model.setLevel(.thunder, 0.05), .applied)
        XCTAssertEqual(night.model.levels[.thunder], 0.05)
        assertHeard(night, [.ocean, .rain, .campfire, .pink, .wind, .white], "under white it waits, by level")
        XCTAssertEqual(night.model.waitingLayers, [.brown, .thunder])
        XCTAssertEqual(night.model.setLevel(.thunder, 0.2), .applied)
        assertHeard(night, sixOfEight, "and over it, it sounds again")
        // Down and up again in the same drag.
        XCTAssertEqual(night.model.setLevel(.thunder, 0), .applied)
        XCTAssertEqual(night.model.setLevel(.thunder, 0.2), .applied)
        night.model.endLevelGesture()
        assertHeard(night, sixOfEight)
        XCTAssertEqual(night.model.levels, full(eight), "the mix is as it was")
        XCTAssertEqual(
            try JSONDecoder().decode([MixLevel].self, from: XCTUnwrap(defaults.data(forKey: levelsKey)))
                .first { $0.sound == .thunder }?.value,
            0.2
        )

        // Left at zero when the finger lifts, it is out of the mix: from
        // then on it is a seventh layer like any other.
        night.model.beginLevelGesture()
        XCTAssertEqual(night.model.setLevel(.thunder, 0), .applied)
        night.model.endLevelGesture()
        night.model.beginLevelGesture()
        XCTAssertEqual(night.model.setLevel(.thunder, 0.2), .capReached)
        XCTAssertEqual(night.model.levels[.thunder], 0)
        // And a layer that was never in the mix gets nothing from an open
        // drag on another row.
        XCTAssertEqual(night.model.setLevel(.pink, 0), .applied)
        XCTAssertEqual(night.model.setLevel(.cabin, 0.5), .capReached, "brown came in for pink")
        XCTAssertEqual(night.model.setLevel(.pink, 0.3), .applied)
        night.model.endLevelGesture()

        // Without a finger (a step of VoiceOver) there is no way back:
        // zero is zero at once.
        XCTAssertEqual(night.model.setLevel(.wind, 0), .applied)
        XCTAssertEqual(night.model.setLevel(.wind, 0.25), .capReached)
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

    /// Red if the tide can be switched on over an ocean that keeps a level
    /// and waits, and nothing says the ocean is not heard.
    func testTheTideOverAnOceanThatWaitsSaysSixAtOnce() throws {
        var mix = eight
        // The ocean at 10 is the lowest of the eight with brown: it waits.
        mix[.ocean] = 0.10
        mix[.brown] = 0.12
        let defaults = try makeDefaults()
        try store(mix, in: defaults)
        let night = try NightHarness(at: time(12), defaults: defaults)
        night.model.play()
        XCTAssertEqual(night.model.waitingLayers, [.brown, .ocean])
        let raises = night.model.tideOceanRaises

        night.model.setBreathingEnabled(true)
        XCTAssertTrue(night.model.breathing.settings.isEnabled, "the tide is armed")
        XCTAssertEqual(night.model.levels[.ocean], 0.10, "the level it keeps is not touched")
        XCTAssertEqual(night.model.tideOceanRaises, raises)
        XCTAssertEqual(night.model.breathingNote, Localized.string("capas.tope"))
        XCTAssertFalse(night.model.soundingLayers.contains(.ocean))

        // An ocean that sounds, however low, needs no note for the cap.
        let low = try makeDefaults()
        try store([.rain: 0.4, .ocean: 0.10], in: low)
        let quiet = try NightHarness(at: time(12), defaults: low)
        quiet.model.play()
        quiet.model.setBreathingEnabled(true)
        XCTAssertNil(quiet.model.breathingNote)
        XCTAssertEqual(quiet.model.levels[.ocean], 0.10)
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

    // MARK: What the page says

    /// Red if the page reads as if everything sounded. Its three rows are
    /// chosen in page order, beds first: in the mix of eight they are
    /// rain, wind and ocean, all sounding, and the two layers that wait
    /// have no row to say so.
    func testThePageSaysThatLayersWaitWhenNoneOfThemHasARow() throws {
        let app = Bundle(for: MixStore.self)
        let spanish = try XCTUnwrap(app.url(forResource: "es", withExtension: "lproj").flatMap(Bundle.init(url:)))
        let english = try XCTUnwrap(app.url(forResource: "en", withExtension: "lproj").flatMap(Bundle.init(url:)))
        func value(_ levels: [SoundID: Float], rows: [SoundID], waiting: [SoundID], _ bundle: Bundle) -> String? {
            PageLayers.moreValue(
                levels, rows: rows, waiting: waiting,
                more: { Localized.format("capas.mas", bundle: bundle, Int64($0)) },
                cap: Localized.string("capas.tope", bundle: bundle)
            )
        }
        let rows = PageLayers.rows(eight, capacity: 3)
        XCTAssertEqual(rows, [.rain, .wind, .ocean])
        let waiting = LayerCap.waiting(eight, isIncluded: { _ in true })
        XCTAssertEqual(waiting, [.white, .brown])
        XCTAssertEqual(value(eight, rows: rows, waiting: waiting, spanish), "y 5 más · Seis a la vez")
        XCTAssertEqual(value(eight, rows: rows, waiting: waiting, english), "and 5 more · Six at once")
        XCTAssertEqual(
            PageStatus.spoken(value(eight, rows: rows, waiting: waiting, english) ?? ""),
            "and 5 more, Six at once"
        )

        // Nothing waits: the value of always.
        let five: [SoundID: Float] = [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .pink: 0.3, .brown: 0.2]
        XCTAssertEqual(value(five, rows: [.rain, .wind, .ocean], waiting: [], spanish), "y 2 más")
        XCTAssertNil(value([.rain: 0.4], rows: [.rain], waiting: [], spanish))
        // Every layer that waits has its row, which says it itself.
        XCTAssertEqual(value(eight, rows: [.white, .brown], waiting: waiting, spanish), "y 6 más")
        // One of them has no row: the page still says it.
        XCTAssertEqual(value(eight, rows: [.rain, .white], waiting: waiting, spanish), "y 6 más · Seis a la vez")

        // The state line names them while it plays, in the words it
        // already has for a layer of the mix that does not sound.
        let defaults = try makeDefaults()
        try store(eight, in: defaults)
        let night = try NightHarness(at: time(12), defaults: defaults)
        night.model.play()
        XCTAssertEqual(night.model.unheardLayers, [.white, .brown])
        let status = PageStatus.resolve(PageStatus.Input(isPlaying: true, omitted: night.model.unheardLayers))
        XCTAssertEqual(status, .playingWithout([.white, .brown]))
        XCTAssertEqual(
            status.text(
                localized: { Localized.string($0, bundle: spanish) },
                soundName: { Localized.string($0.nameKey, bundle: spanish) },
                locale: Locale(identifier: "es")
            ),
            "Sonando · sin blanco ni marrón"
        )
        XCTAssertEqual(
            status.text(
                localized: { Localized.string($0, bundle: english) },
                soundName: { Localized.string($0.nameKey, bundle: english) },
                locale: Locale(identifier: "en")
            ),
            "Playing · without white or brown"
        )
        // One of the six goes: the next one sounds and leaves the line.
        night.model.setLevel(.thunder, 0)
        XCTAssertEqual(night.model.unheardLayers, [.brown])
        night.model.setLevel(.ocean, 0)
        XCTAssertEqual(night.model.unheardLayers, [])
        XCTAssertEqual(PageStatus.resolve(PageStatus.Input(isPlaying: true, omitted: [])), .playing)

        // Without access the Pro layers come first, then the ones that
        // wait: here five free layers sound and nothing waits.
        let free = try NightHarness(at: time(12), free: true, defaults: defaults)
        XCTAssertEqual(free.model.waitingLayers, [])
        XCTAssertTrue(free.model.unheardLayers.allSatisfy { !AccessPolicy.soundIsIncluded($0, hasFullAccess: false) })
    }
}
