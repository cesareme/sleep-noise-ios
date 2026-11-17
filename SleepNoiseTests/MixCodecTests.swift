import XCTest
@testable import SleepNoise

/// Mix format v2 and the move from what v1 stored.
final class MixCodecTests: XCTestCase {
    /// Two mixes shaped as a v1 build wrote them (`JSONEncoder` on the old
    /// `Codable` `SavedMix`): every sound listed, zeros included, the date in
    /// seconds since the reference date. The third spells a `Float` the long
    /// way, as older encoders did. Written by hand; `V1Mix` below ties the
    /// format to the real encoder.
    private let v1Blob = """
    [{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"Hotel","createdAt":785000123.456789,\
    "levels":[{"value":0,"sound":"white"},{"value":0,"sound":"pink"},{"value":0.3,"sound":"brown"},\
    {"value":0.45,"sound":"rain"},{"value":0,"sound":"fan"},{"value":0,"sound":"ocean"},\
    {"value":0,"sound":"thunder"},{"value":0,"sound":"campfire"},{"value":0,"sound":"brook"},\
    {"value":0,"sound":"wind"},{"value":0,"sound":"cabin"}]},\
    {"id":"9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22","name":"Tormenta de domingo","createdAt":784900000.25,\
    "levels":[{"value":0,"sound":"white"},{"value":0,"sound":"pink"},{"value":0,"sound":"brown"},\
    {"value":0.5,"sound":"rain"},{"value":1,"sound":"fan"},{"value":0,"sound":"ocean"},\
    {"value":0.62,"sound":"thunder"},{"value":0,"sound":"campfire"},{"value":0,"sound":"brook"},\
    {"value":0,"sound":"wind"},{"value":0,"sound":"cabin"}]},\
    {"id":"0A1B2C3D-4E5F-4A6B-8C7D-9E0F1A2B3C4D","name":"Fan","createdAt":700000000,\
    "levels":[{"sound":"fan","value":0.699999988079071},{"sound":"pink","value":0.20000000298023224}]}]
    """

    /// The `SavedMix` of v1 builds, as it was declared, so the tests can
    /// store what `JSONEncoder` really wrote for it.
    private struct V1Mix: Codable {
        var id: UUID
        var name: String
        var levels: [MixLevel]
        var createdAt: Date
    }

    private func mix(
        _ uuid: String,
        _ name: String,
        _ levels: [SoundID: Float],
        at seconds: TimeInterval,
        unknown: [UnknownMixLayer] = []
    ) throws -> SavedMix {
        SavedMix(
            id: try XCTUnwrap(UUID(uuidString: uuid)),
            name: name,
            levels: SoundID.allCases.map { MixLevel(sound: $0, value: levels[$0] ?? 0) },
            createdAt: Date(timeIntervalSinceReferenceDate: seconds),
            unknownLayers: unknown
        )
    }

    private func audible(_ mix: SavedMix) -> [SoundID: Float] {
        var levels: [SoundID: Float] = [:]
        for level in mix.levels where level.value > 0 {
            levels[level.sound] = level.value
        }
        return levels
    }

    private func json(_ data: Data) throws -> [String: Any] {
        try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func testRoundTripKeepsEveryMix() throws {
        let mixes = [
            try mix("5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "Hotel", [.rain: 0.45, .brown: 0.3], at: 785_000_123.456789),
            try mix("9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22", "Mañana · «niebla»", [.cabin: 1, .white: 0.01], at: 0.125),
            try mix(
                "0A1B2C3D-4E5F-4A6B-8C7D-9E0F1A2B3C4D", "Every sound",
                Dictionary(uniqueKeysWithValues: SoundID.allCases.enumerated().map { ($1, Float($0 + 1) / 16) }),
                at: -31_536_000,
                unknown: [UnknownMixLayer(id: "glacier", level: 0.35)]
            ),
            try mix("11111111-2222-4333-8444-555555555555", "Silent", [:], at: 800_000_000),
        ]
        let data = try MixCodec.encode(mixes)
        XCTAssertEqual(try MixCodec.decode(data), mixes)
        // Encoding what was read gives the same bytes: nothing drifts.
        XCTAssertEqual(try MixCodec.encode(try MixCodec.decode(data)), data)
        XCTAssertEqual(try MixCodec.decode(try MixCodec.encode([])), [])
    }

    func testDocumentIsVersionTwoWithIdAndLevelPairsOnly() throws {
        let saved = try mix("5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "Hotel", [.rain: 0.45, .brown: 0.3], at: 785_000_123.25)
        let document = try json(try MixCodec.encode([saved]))

        XCTAssertEqual(Set(document.keys), ["version", "mixes"])
        XCTAssertEqual(document["version"] as? Int, 2)
        XCTAssertEqual(MixCodec.currentVersion, 2)

        let stored = try XCTUnwrap((document["mixes"] as? [[String: Any]])?.first)
        // A mix is a name and its layers: no timer, no tide, nothing synced.
        XCTAssertEqual(Set(stored.keys), ["id", "name", "createdAt", "layers"])
        XCTAssertEqual(stored["id"] as? String, "5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11")
        XCTAssertEqual(stored["name"] as? String, "Hotel")
        XCTAssertEqual(stored["createdAt"] as? Double, 785_000_123.25)

        let layers = try XCTUnwrap(stored["layers"] as? [[String: Any]])
        // Silent layers are not written; the rest follow `SoundID.allCases`.
        XCTAssertEqual(layers.map { $0["id"] as? String }, ["brown", "rain"])
        for layer in layers {
            XCTAssertEqual(Set(layer.keys), ["id", "level"])
        }
        XCTAssertEqual(try XCTUnwrap(layers[0]["level"] as? Double), 0.3, accuracy: 0.000_001)
        XCTAssertEqual(try XCTUnwrap(layers[1]["level"] as? Double), 0.45, accuracy: 0.000_001)
    }

    func testReadsWhatV1Stored() throws {
        let mixes = try MixCodec.decode(Data(v1Blob.utf8))
        XCTAssertEqual(mixes.map(\.name), ["Hotel", "Tormenta de domingo", "Fan"])
        XCTAssertEqual(mixes.map(\.id.uuidString), [
            "5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11",
            "9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22",
            "0A1B2C3D-4E5F-4A6B-8C7D-9E0F1A2B3C4D",
        ])
        XCTAssertEqual(mixes.map(\.createdAt.timeIntervalSinceReferenceDate), [785_000_123.456789, 784_900_000.25, 700_000_000])
        XCTAssertEqual(audible(mixes[0]), [.brown: 0.3, .rain: 0.45])
        XCTAssertEqual(audible(mixes[1]), [.rain: 0.5, .fan: 1, .thunder: 0.62])
        XCTAssertEqual(audible(mixes[2]), [.fan: 0.7, .pink: 0.2])
        for mix in mixes {
            XCTAssertEqual(mix.levels.map(\.sound), SoundID.allCases, "one level per sound, in order")
            XCTAssertTrue(mix.unknownLayers.isEmpty)
        }
        // From here on it is a v2 document like any other.
        XCTAssertEqual(try MixCodec.decode(try MixCodec.encode(mixes)), mixes)
    }

    func testUnknownIdsAreKeptAndWrittenBack() throws {
        let newer = """
        {"version":2,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"North","createdAt":1,\
        "layers":[{"id":"glacier","level":0.4},{"id":"rain","level":0.5},{"id":"sleet","level":3},\
        {"id":"hush","level":0}]}]}
        """
        let mixes = try MixCodec.decode(Data(newer.utf8))
        let north = try XCTUnwrap(mixes.first)
        XCTAssertEqual(audible(north), [.rain: 0.5], "the mix plays without the layers it does not know")
        XCTAssertEqual(
            north.unknownLayers,
            [UnknownMixLayer(id: "glacier", level: 0.4), UnknownMixLayer(id: "sleet", level: 1)],
            "kept in order, bounded, and without the silent one"
        )

        let document = try json(try MixCodec.encode(mixes))
        let layers = try XCTUnwrap((document["mixes"] as? [[String: Any]])?.first?["layers"] as? [[String: Any]])
        XCTAssertEqual(layers.map { $0["id"] as? String }, ["rain", "glacier", "sleet"])

        // The same holds for a v1 list that names a sound this build lacks.
        let oldList = """
        [{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"North","createdAt":1,\
        "levels":[{"sound":"glacier","value":0.4},{"sound":"rain","value":0.5}]}]
        """
        let fromV1 = try XCTUnwrap(try MixCodec.decode(Data(oldList.utf8)).first)
        XCTAssertEqual(audible(fromV1), [.rain: 0.5])
        XCTAssertEqual(fromV1.unknownLayers, [UnknownMixLayer(id: "glacier", level: 0.4)])
    }

    func testLevelsAreBounded() throws {
        let cases: [(Float, Float)] = [
            (-3, 0), (-0.000_1, 0), (0, 0), (0.25, 0.25), (1, 1), (1.000_1, 1), (40, 1),
            (.infinity, 0), (-.infinity, 0), (.nan, 0),
        ]
        for (raw, expected) in cases {
            XCTAssertEqual(MixCodec.bounded(raw), expected, "\(raw)")
            // On the way out, whatever the mix in memory holds: a layer this
            // version knows and one it does not. Encoding never fails on a
            // level that is not a number.
            let saved = try mix(
                "5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "Edge", [.pink: raw], at: 1,
                unknown: [UnknownMixLayer(id: "glacier", level: raw)]
            )
            let written = try XCTUnwrap(try MixCodec.decode(try MixCodec.encode([saved])).first)
            XCTAssertEqual(written.value(for: .pink), expected, "\(raw)")
            XCTAssertEqual(
                written.unknownLayers, expected > 0 ? [UnknownMixLayer(id: "glacier", level: expected)] : [],
                "\(raw): bounded, and not written when silent"
            )
            XCTAssertEqual(MixCodec.normalized(saved), written, "\(raw)")
        }

        // An unknown layer is written once, and never under a known id.
        let crowded = try mix(
            "5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "Crowded", [.rain: 0.5], at: 1,
            unknown: [
                UnknownMixLayer(id: "glacier", level: 0.2),
                UnknownMixLayer(id: "glacier", level: 0.9),
                UnknownMixLayer(id: "rain", level: 0.9),
                UnknownMixLayer(id: "pink", level: 0.9),
            ]
        )
        let once = try XCTUnwrap(try MixCodec.decode(try MixCodec.encode([crowded])).first)
        XCTAssertEqual(once.unknownLayers, [UnknownMixLayer(id: "glacier", level: 0.2)])
        XCTAssertEqual(audible(once), [.rain: 0.5])
        XCTAssertEqual(MixCodec.normalized(crowded), once)

        // On the way in, whatever the document holds.
        let wild = """
        {"version":2,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"Wild","createdAt":1,\
        "layers":[{"id":"rain","level":7},{"id":"brown","level":-2},{"id":"pink","level":0.5}]}]}
        """
        let read = try XCTUnwrap(try MixCodec.decode(Data(wild.utf8)).first)
        XCTAssertEqual(audible(read), [.rain: 1, .pink: 0.5])
        for level in read.levels {
            XCTAssertTrue((0...1).contains(level.value), level.sound.rawValue)
        }
    }

    func testARepeatedIdCountsOnce() throws {
        let twice = """
        {"version":2,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"Twice","createdAt":1,\
        "layers":[{"id":"rain","level":0.2},{"id":"rain","level":0.9},{"id":"glacier","level":0.1},\
        {"id":"glacier","level":0.8}]}]}
        """
        let read = try XCTUnwrap(try MixCodec.decode(Data(twice.utf8)).first)
        XCTAssertEqual(audible(read), [.rain: 0.2])
        XCTAssertEqual(read.unknownLayers, [UnknownMixLayer(id: "glacier", level: 0.1)])
    }

    func testARepeatedMixIdCountsOnce() throws {
        let twice = """
        {"version":2,"mixes":[\
        {"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"First","createdAt":1,"layers":[{"id":"rain","level":0.2}]},\
        {"id":"9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22","name":"Other","createdAt":2,"layers":[]},\
        {"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"Second","createdAt":3,"layers":[{"id":"pink","level":0.9}]}]}
        """
        let read = try MixCodec.read(Data(twice.utf8))
        XCTAssertEqual(read.mixes.map(\.name), ["First", "Other"])
        XCTAssertEqual(audible(read.mixes[0]), [.rain: 0.2])
        XCTAssertEqual(Set(read.mixes.map(\.id)).count, read.mixes.count, "one row per id in the list")
        XCTAssertFalse(read.isComplete, "something was left out")
        XCTAssertEqual(try MixCodec.decode(Data(twice.utf8)), read.mixes)
    }

    func testNamesAreStoredTrimmedAndCut() throws {
        let long = String(repeating: "abcde", count: 12)
        let cases: [(String, String)] = [
            ("Hotel", "Hotel"),
            ("  Hotel \n", "Hotel"),
            ("Tormenta de domingo", "Tormenta de domingo"),
            (long, String(long.prefix(40))),
            ("", ""),
            (" \t\n ", ""),
        ]
        XCTAssertEqual(MixCodec.maxNameLength, 40)
        for (raw, expected) in cases {
            XCTAssertEqual(MixCodec.cleanName(raw), expected, "\"\(raw)\"")
            // On the way out and on the way in.
            let saved = try mix("5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", raw, [.pink: 0.5], at: 1)
            XCTAssertEqual(try MixCodec.decode(try MixCodec.encode([saved])).first?.name, expected, "\"\(raw)\"")
            let stored: [String: Any] = ["id": "5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "name": raw, "createdAt": 1]
            let document: [String: Any] = ["version": 2, "mixes": [stored.merging(["layers": [Any]()]) { $1 }]]
            let read = try MixCodec.read(try JSONSerialization.data(withJSONObject: document))
            XCTAssertEqual(read.mixes.map(\.name), [expected], "\"\(raw)\": the mix is kept, whatever its name")
            XCTAssertTrue(read.isComplete)
        }
    }

    func testReadSaysWhenSomethingWasLeftOut() throws {
        let whole = #"{"version":2,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"A","createdAt":1,"#
            + #""layers":[{"id":"glacier","level":0.4},{"id":"rain","level":0.5}]}]}"#
        XCTAssertTrue(try MixCodec.read(Data(whole.utf8)).isComplete, "an unknown id is kept, so nothing is missing")
        XCTAssertTrue(try MixCodec.read(Data(v1Blob.utf8)).isComplete)
        XCTAssertTrue(try MixCodec.read(try MixCodec.encode([])).isComplete)

        let incomplete = [
            // A mix that cannot be read.
            #"{"version":2,"mixes":[{"id":"not-a-uuid","name":"A","createdAt":1,"layers":[]}]}"#,
            // A layer that cannot be read.
            #"{"version":2,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"A","createdAt":1,"#
                + #""layers":[{"id":"rain","level":"loud"}]}]}"#,
            // The same in a v1 list.
            #"[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"A","createdAt":1,"levels":[{"sound":"rain"}]}]"#,
            #"[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"A","createdAt":1,"levels":[]},{"name":"B"}]"#,
        ]
        for text in incomplete {
            XCTAssertFalse(try MixCodec.read(Data(text.utf8)).isComplete, text)
        }
    }

    func testLiveLevelsAreReadByIdAndUnknownSoundsLeftOut() throws {
        let stored = #"[{"sound":"pink","value":0.3},{"sound":"glacier","value":0.8},{"sound":"rain","value":7},"#
            + #"{"sound":"rain","value":0.1},{"value":0.5},{"sound":"brown","value":"loud"},{"sound":"wind","value":0}]"#
        XCTAssertEqual(MixCodec.decodeLevels(Data(stored.utf8)), [.pink: 0.3, .rain: 1, .wind: 0])
        XCTAssertEqual(MixCodec.decodeLevels(Data("[]".utf8)), [:])
        for text in ["", "not json", #"{"version":2,"mixes":[]}"#, #""pink""#] {
            XCTAssertNil(MixCodec.decodeLevels(Data(text.utf8)), text)
        }
        // What the mixer wrote with `JSONEncoder` reads back whole.
        let written = SoundID.allCases.enumerated().map { MixLevel(sound: $1, value: Float($0) / 16) }
        let read = try XCTUnwrap(MixCodec.decodeLevels(try JSONEncoder().encode(written)))
        XCTAssertEqual(read, Dictionary(uniqueKeysWithValues: written.map { ($0.sound, $0.value) }))
    }

    func testWhatCannotBeReadIsSkippedAndTheRestLoads() throws {
        let damaged = """
        {"version":2,"mixes":[\
        {"id":"not-a-uuid","name":"Broken id","createdAt":1,"layers":[]},\
        {"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","createdAt":1,"layers":[]},\
        {"id":"9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22","name":"Whole","createdAt":2,\
        "layers":[{"id":"rain","level":"loud"},{"level":0.4},{"id":"pink","level":0.6}]}]}
        """
        let mixes = try MixCodec.decode(Data(damaged.utf8))
        XCTAssertEqual(mixes.map(\.name), ["Whole"])
        XCTAssertEqual(audible(try XCTUnwrap(mixes.first)), [.pink: 0.6])
    }

    func testOtherDocumentsAreRefused() {
        let refused: [(String, MixCodec.Failure)] = [
            (#"{"version":3,"mixes":[]}"#, .newerVersion(3)),
            (#"{"version":99,"mixes":"later"}"#, .newerVersion(99)),
            (#"{"version":1,"mixes":[]}"#, .unreadable),
            (#"{"version":2}"#, .unreadable),
            (#"{"version":"2","mixes":[]}"#, .unreadable),
            (#"{"mixes":[]}"#, .unreadable),
            (#""Hotel""#, .unreadable),
            ("", .unreadable),
            ("not json", .unreadable),
        ]
        for (text, expected) in refused {
            XCTAssertThrowsError(try MixCodec.decode(Data(text.utf8)), text) { error in
                XCTAssertEqual(error as? MixCodec.Failure, expected, text)
            }
        }
    }

    // MARK: MixStore

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    func testStoreMovesV1MixesToV2AndLeavesTheOldDataAlone() throws {
        let defaults = try makeDefaults()
        let old = Data(v1Blob.utf8)
        defaults.set(old, forKey: MixStore.legacyStorageKey)
        XCTAssertEqual(MixStore.legacyStorageKey, "sleepnoise.mixes.v1", "the key v1 builds wrote")

        let store = MixStore(defaults: defaults)
        XCTAssertEqual(store.mixes.map(\.name), ["Hotel", "Tormenta de domingo", "Fan"])
        XCTAssertEqual(audible(store.mixes[1]), [.rain: 0.5, .fan: 1, .thunder: 0.62])

        // Written as v2 at once, without waiting for the next save.
        let moved = try XCTUnwrap(defaults.data(forKey: MixStore.storageKey))
        XCTAssertEqual(try json(moved)["version"] as? Int, 2)
        XCTAssertEqual(try MixCodec.decode(moved), store.mixes)
        XCTAssertEqual(defaults.data(forKey: MixStore.legacyStorageKey), old)

        guard case .saved(let added) = store.save(name: "New", levels: [.wind: 0.3], hasFullAccess: true) else {
            return XCTFail("Full access saves another mix")
        }
        let reloaded = MixStore(defaults: defaults)
        XCTAssertEqual(reloaded.mixes.map(\.name), ["New", "Hotel", "Tormenta de domingo", "Fan"])
        XCTAssertEqual(reloaded.mixes.first, added, "what was saved is what loads")
        XCTAssertEqual(defaults.data(forKey: MixStore.legacyStorageKey), old)
    }

    /// The same move, from data the real v1 encoder wrote: `JSONEncoder()`
    /// with its defaults over the old `Codable` type, as `MixStore.persist`
    /// did in v1 builds.
    func testStoreReadsWhatTheV1EncoderWrote() throws {
        let old = [
            V1Mix(
                id: UUID(), name: "Lluvia/café · «niebla» \"2\"",
                levels: SoundID.allCases.enumerated().map { MixLevel(sound: $1, value: Float($0) / 10) },
                createdAt: Date(timeIntervalSinceReferenceDate: 785_000_123.456789)
            ),
            V1Mix(
                id: UUID(), name: "Fan",
                levels: SoundID.allCases.map { MixLevel(sound: $0, value: $0 == .fan ? 0.7 : 0) },
                createdAt: Date(timeIntervalSinceReferenceDate: 700_000_000)
            ),
            V1Mix(
                id: UUID(), name: "One third",
                levels: SoundID.allCases.map { MixLevel(sound: $0, value: $0 == .rain ? 1 / 3 : 0) },
                createdAt: Date(timeIntervalSinceReferenceDate: 0.1)
            ),
        ]
        let defaults = try makeDefaults()
        defaults.set(try JSONEncoder().encode(old), forKey: MixStore.legacyStorageKey)

        for store in [MixStore(defaults: defaults), MixStore(defaults: defaults)] {
            XCTAssertEqual(store.mixes.count, old.count)
            for (read, written) in zip(store.mixes, old) {
                XCTAssertEqual(read.id, written.id)
                XCTAssertEqual(read.name, written.name)
                XCTAssertEqual(read.createdAt, written.createdAt, written.name)
                XCTAssertEqual(read.levels, written.levels.map { MixLevel(sound: $0.sound, value: min(1, $0.value)) })
                XCTAssertTrue(read.unknownLayers.isEmpty)
            }
        }
        XCTAssertNil(defaults.data(forKey: MixStore.unreadStorageKey), "everything was read")
    }

    func testOnceV2ExistsTheOldListDoesNotComeBack() throws {
        let defaults = try makeDefaults()
        defaults.set(Data(v1Blob.utf8), forKey: MixStore.legacyStorageKey)

        let store = MixStore(defaults: defaults)
        for id in store.mixes.map(\.id) {
            store.delete(id)
        }
        XCTAssertTrue(store.mixes.isEmpty)
        XCTAssertTrue(MixStore(defaults: defaults).mixes.isEmpty, "deleted mixes stay deleted")
    }

    func testStoreKeepsUnknownLayersThroughASave() throws {
        let defaults = try makeDefaults()
        let newer = """
        {"version":2,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"North","createdAt":1,\
        "layers":[{"id":"glacier","level":0.4},{"id":"rain","level":0.5}]}]}
        """
        defaults.set(Data(newer.utf8), forKey: MixStore.storageKey)

        let store = MixStore(defaults: defaults)
        guard case .saved = store.save(name: "Other", levels: [.pink: 0.4], hasFullAccess: true) else {
            return XCTFail("Full access saves another mix")
        }
        let north = try XCTUnwrap(MixStore(defaults: defaults).mixes.first { $0.name == "North" })
        XCTAssertEqual(north.unknownLayers, [UnknownMixLayer(id: "glacier", level: 0.4)])
        XCTAssertEqual(audible(north), [.rain: 0.5])
    }

    func testStoreStartsEmptyOnDataItCannotRead() throws {
        for text in ["not json", #"{"version":3,"mixes":[]}"#] {
            let defaults = try makeDefaults()
            defaults.set(Data(text.utf8), forKey: MixStore.storageKey)
            XCTAssertTrue(MixStore(defaults: defaults).mixes.isEmpty, text)
            XCTAssertEqual(defaults.data(forKey: MixStore.storageKey), Data(text.utf8), "\(text): loading writes nothing")
        }
        let defaults = try makeDefaults()
        defaults.set(Data("not json".utf8), forKey: MixStore.legacyStorageKey)
        XCTAssertTrue(MixStore(defaults: defaults).mixes.isEmpty)
        XCTAssertNil(defaults.data(forKey: MixStore.storageKey), "nothing is written for a list that did not load")
    }

    /// A save must not be the end of what this version could not read: a
    /// document from a later format, a damaged one, one with skipped entries.
    func testWhatTheStoreCouldNotReadSurvivesASave() throws {
        let later = #"{"version":3,"mixes":[{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","title":"North","tide":true}]}"#
        let partial = #"{"version":2,"mixes":[{"id":"not-a-uuid","name":"Lost","createdAt":1,"layers":[]},"#
            + #"{"id":"9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22","name":"Kept","createdAt":2,"layers":[]}]}"#
        XCTAssertEqual(MixStore.unreadStorageKey, "sleepnoise.mixes.v2.unread")
        for (text, names) in [(later, []), ("not json", []), (partial, ["Kept"])] as [(String, [String])] {
            let defaults = try makeDefaults()
            let original = Data(text.utf8)
            defaults.set(original, forKey: MixStore.storageKey)

            let store = MixStore(defaults: defaults)
            XCTAssertEqual(store.mixes.map(\.name), names, text)
            guard case .saved = store.save(name: "Tonight", levels: [.pink: 0.4], hasFullAccess: true) else {
                return XCTFail("Full access saves another mix")
            }
            store.delete(try XCTUnwrap(store.mixes.last).id)

            XCTAssertNotEqual(defaults.data(forKey: MixStore.storageKey), original, "the list was written again")
            XCTAssertEqual(defaults.data(forKey: MixStore.unreadStorageKey), original, "\(text): still there, as it was")
            // And it stays there on the next launches, when the list reads whole.
            XCTAssertEqual(MixStore(defaults: defaults).mixes, store.mixes)
            XCTAssertEqual(defaults.data(forKey: MixStore.unreadStorageKey), original, text)
        }

        // A list that reads whole sets nothing aside.
        let defaults = try makeDefaults()
        defaults.set(try MixCodec.encode([try mix("5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "A", [.pink: 0.5], at: 1)]),
                     forKey: MixStore.storageKey)
        XCTAssertEqual(MixStore(defaults: defaults).mixes.map(\.name), ["A"])
        XCTAssertNil(defaults.data(forKey: MixStore.unreadStorageKey))
    }

    func testAStoredMixWithoutANameIsNamedAfterItsLayers() throws {
        let unnamed = #"{"version":2,"mixes":["#
            + #"{"id":"5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11","name":"  ","createdAt":3,"layers":[{"id":"rain","level":0.5}]},"#
            + #"{"id":"9C2E7A10-1F4D-4E0A-8B7C-3A5D2E9F4B22","name":"Hotel","createdAt":2,"layers":[]},"#
            + #"{"id":"0A1B2C3D-4E5F-4A6B-8C7D-9E0F1A2B3C4D","name":"","createdAt":1,"layers":[]}]}"#
        let defaults = try makeDefaults()
        defaults.set(Data(unnamed.utf8), forKey: MixStore.storageKey)

        let store = MixStore(defaults: defaults)
        // One layer is its name; a mix with nothing in it is "Tonight".
        let empty = MixAutoName.name(levels: [:])
        XCTAssertEqual(store.mixes.map(\.name), [SoundID.rain.localizedName, "Hotel", empty])
        XCTAssertEqual(audible(store.mixes[0]), [.rain: 0.5], "the mix itself is kept")
        XCTAssertFalse(empty.isEmpty)
        XCTAssertNil(defaults.data(forKey: MixStore.unreadStorageKey), "nothing was left out")
    }
}
