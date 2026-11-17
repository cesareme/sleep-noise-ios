import XCTest
@testable import SleepNoise

/// Mix format v2 and the move from what v1 stored.
final class MixCodecTests: XCTestCase {
    /// Two mixes exactly as a v1 build wrote them (`JSONEncoder` on the old
    /// `Codable` `SavedMix`): every sound listed, zeros included, the date in
    /// seconds since the reference date. The third spells a `Float` the long
    /// way, as older encoders did.
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
            // On the way out, whatever the mix in memory holds.
            let saved = try mix("5B1F0C52-6E0B-4B44-9D0C-0D6C0E3A7A11", "Edge", [.pink: raw], at: 1)
            let written = try XCTUnwrap(try MixCodec.decode(try MixCodec.encode([saved])).first)
            XCTAssertEqual(written.value(for: .pink), expected, "\(raw)")
            XCTAssertEqual(MixCodec.normalized(saved), written, "\(raw)")
        }

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
        }
        let defaults = try makeDefaults()
        defaults.set(Data("not json".utf8), forKey: MixStore.legacyStorageKey)
        XCTAssertTrue(MixStore(defaults: defaults).mixes.isEmpty)
        XCTAssertNil(defaults.data(forKey: MixStore.storageKey), "nothing is written for a list that did not load")
    }
}
