import Foundation

/// How saved mixes are stored: mix format v2.
///
/// ```
/// { "version": 2,
///   "mixes": [ { "id": "<UUID>", "name": "Hotel", "createdAt": 785000123.25,
///                "layers": [ { "id": "rain", "level": 0.45 },
///                            { "id": "brown", "level": 0.3 } ] } ] }
/// ```
///
/// - A mix is its name and its `id` + `level` pairs, nothing else: no timer
///   and no tide. `id` is a `SoundID` raw value, `level` goes from 0 to 1.
/// - `createdAt` is seconds since the reference date (1 January 2001 UTC),
///   the number v1 already stored, so a date survives the round trip exactly.
/// - Only layers above zero are written. In memory a mix always has one
///   `MixLevel` per `SoundID`, in `SoundID.allCases` order, so a texture
///   added later reads as zero in every older mix.
/// - Levels are bounded on the way in and on the way out: below zero and
///   anything that is not a number become 0, above one becomes 1.
/// - An id this version does not know is kept, not dropped. It comes from a
///   later version with more textures; the mix plays without it here and
///   writes it back untouched, so nothing the person saved is lost by
///   opening the list with an older build. Its level is bounded like the rest.
/// - The same id twice in one mix: the first one counts. The same holds for
///   two mixes with one `id` in a document.
/// - A name is stored trimmed and cut to `maxNameLength`, the rule a save
///   applies. A name left empty by that is the store's to replace.
/// - A mix or a layer that cannot be read is skipped; the rest still load.
///   `read` says when that happened, so the store can keep the original.
/// - v1 is what earlier builds stored: a bare array of
///   `{ id, name, createdAt, levels: [ { sound, value } ] }`. It is read and
///   never written.
/// - A document from a later format version is refused, never guessed at.
///
/// The document lives in `UserDefaults` on the device. Nothing here syncs.
enum MixCodec {
    static let currentVersion = 2
    static let maxNameLength = 40

    enum Failure: Error, Equatable {
        /// Written by a later version of the format.
        case newerVersion(Int)
        /// Neither a v2 document nor a v1 list.
        case unreadable
    }

    static func encode(_ mixes: [SavedMix]) throws -> Data {
        let document = Document(version: currentVersion, mixes: mixes.map(wireMix))
        let encoder = JSONEncoder()
        // Stable output: the same mixes always give the same bytes.
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(document)
    }

    /// Reads a v2 document or a v1 list. The result is always normalized.
    static func decode(_ data: Data) throws -> [SavedMix] {
        try read(data).mixes
    }

    /// What `decode` gives, and whether that is everything the data held:
    /// `isComplete` is false when a mix or a layer could not be read, or a
    /// mix repeated an id, and was left out.
    static func read(_ data: Data) throws -> (mixes: [SavedMix], isComplete: Bool) {
        let decoder = JSONDecoder()
        let entries: [Lossy<LossyMix>]
        if let probe = try? decoder.decode(VersionProbe.self, from: data) {
            guard probe.version <= currentVersion else { throw Failure.newerVersion(probe.version) }
            guard probe.version == currentVersion,
                  let document = try? decoder.decode(LossyDocument.self, from: data)
            else { throw Failure.unreadable }
            entries = document.mixes
        } else if let legacy = try? decoder.decode([Lossy<LegacyMix>].self, from: data) {
            entries = legacy.map { entry in
                Lossy(entry.value.map { mix in
                    LossyMix(
                        id: mix.id,
                        name: mix.name,
                        createdAt: mix.createdAt,
                        layers: mix.levels.map { level in
                            Lossy(level.value.map { WireLayer(id: $0.sound, level: $0.value) })
                        }
                    )
                })
            }
        } else {
            throw Failure.unreadable
        }

        var mixes: [SavedMix] = []
        var seen = Set<UUID>()
        var isComplete = true
        for entry in entries {
            guard let mix = entry.value, seen.insert(mix.id).inserted else {
                isComplete = false
                continue
            }
            let layers = mix.layers.compactMap(\.value)
            if layers.count != mix.layers.count { isComplete = false }
            mixes.append(savedMix(WireMix(id: mix.id, name: mix.name, createdAt: mix.createdAt, layers: layers)))
        }
        return (mixes, isComplete)
    }

    /// Reads a bare list of `{ sound, value }` pairs, the shape the mixer
    /// stores its live levels in. A sound this version does not know is left
    /// out and the rest still load; nil when the data is not such a list.
    static func decodeLevels(_ data: Data) -> [SoundID: Float]? {
        guard let entries = try? JSONDecoder().decode([Lossy<LegacyMix.Level>].self, from: data) else { return nil }
        var levels: [SoundID: Float] = [:]
        for entry in entries.compactMap(\.value) {
            guard let sound = SoundID(rawValue: entry.sound), levels[sound] == nil else { continue }
            levels[sound] = bounded(entry.value)
        }
        return levels
    }

    /// The shape every stored mix has in memory: one bounded level per
    /// `SoundID` in `SoundID.allCases` order, and the unknown layers without
    /// repeats or zeros. `decode(encode(mixes))` equals `mixes.map(normalized)`.
    static func normalized(_ mix: SavedMix) -> SavedMix {
        savedMix(wireMix(mix))
    }

    static func bounded(_ level: Float) -> Float {
        guard level.isFinite else { return 0 }
        return min(1, max(0, level))
    }

    /// A name as it is stored: without the white space around it and no
    /// longer than `maxNameLength`.
    static func cleanName(_ name: String) -> String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxNameLength))
    }

    // MARK: Wire format

    private struct VersionProbe: Decodable {
        let version: Int
    }

    private struct Document: Encodable {
        let version: Int
        let mixes: [WireMix]
    }

    private struct LossyDocument: Decodable {
        let mixes: [Lossy<LossyMix>]
    }

    private struct WireLayer: Codable {
        let id: String
        let level: Float
    }

    private struct WireMix: Encodable {
        let id: UUID
        let name: String
        let createdAt: Double
        let layers: [WireLayer]
    }

    private struct LossyMix: Decodable {
        let id: UUID
        let name: String
        let createdAt: Double
        let layers: [Lossy<WireLayer>]
    }

    /// v1, as `JSONEncoder` wrote the old `Codable` `SavedMix`.
    private struct LegacyMix: Decodable {
        struct Level: Decodable {
            let sound: String
            let value: Float
        }

        let id: UUID
        let name: String
        let createdAt: Double
        let levels: [Lossy<Level>]
    }

    /// Decodes to nil instead of failing the whole list.
    private struct Lossy<Value: Decodable>: Decodable {
        let value: Value?

        init(_ value: Value?) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            value = try? Value(from: decoder)
        }
    }

    private static func savedMix(_ mix: WireMix) -> SavedMix {
        var known: [SoundID: Float] = [:]
        var unknown: [UnknownMixLayer] = []
        var seen = Set<String>()
        for layer in mix.layers where seen.insert(layer.id).inserted {
            let level = bounded(layer.level)
            if let sound = SoundID(rawValue: layer.id) {
                known[sound] = level
            } else if level > 0 {
                unknown.append(UnknownMixLayer(id: layer.id, level: level))
            }
        }
        return SavedMix(
            id: mix.id,
            name: cleanName(mix.name),
            levels: SoundID.allCases.map { MixLevel(sound: $0, value: known[$0] ?? 0) },
            createdAt: Date(timeIntervalSinceReferenceDate: mix.createdAt),
            unknownLayers: unknown
        )
    }

    private static func wireMix(_ mix: SavedMix) -> WireMix {
        var layers: [WireLayer] = []
        for sound in SoundID.allCases {
            let level = bounded(mix.value(for: sound))
            if level > 0 {
                layers.append(WireLayer(id: sound.rawValue, level: level))
            }
        }
        // Unknown layers leave as they came in: bounded, never silent, never
        // twice, and never under the id of a sound this version does know.
        var seen = Set(SoundID.allCases.map(\.rawValue))
        for layer in mix.unknownLayers where seen.insert(layer.id).inserted {
            let level = bounded(layer.level)
            if level > 0 {
                layers.append(WireLayer(id: layer.id, level: level))
            }
        }
        return WireMix(
            id: mix.id,
            name: cleanName(mix.name),
            createdAt: mix.createdAt.timeIntervalSinceReferenceDate,
            layers: layers
        )
    }
}
