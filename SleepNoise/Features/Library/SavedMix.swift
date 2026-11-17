import Foundation

struct MixLevel: Codable, Equatable, Identifiable {
    var sound: SoundID
    var value: Float

    var id: SoundID { sound }
}

/// A layer whose id this version does not know: a texture added by a later
/// version. It is never played or shown; it is only carried, so saving the
/// list again does not take it out of the mix. See `MixCodec`.
struct UnknownMixLayer: Equatable {
    var id: String
    var level: Float
}

/// A mix the person saved. `MixCodec` owns how it is stored.
struct SavedMix: Equatable, Identifiable {
    var id: UUID
    var name: String
    var levels: [MixLevel]
    var createdAt: Date
    var unknownLayers: [UnknownMixLayer] = []

    func value(for sound: SoundID) -> Float {
        levels.first { $0.sound == sound }?.value ?? 0
    }

    /// One level per sound. Sounds the mix does not name are silent.
    var levelsBySound: [SoundID: Float] {
        var bySound = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        for level in levels {
            bySound[level.sound] = level.value
        }
        return bySound
    }
}

enum SaveMixResult: Equatable {
    case saved(SavedMix)
    case needsPro
    case emptyName
}
