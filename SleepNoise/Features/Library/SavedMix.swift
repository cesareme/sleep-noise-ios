import Foundation

struct MixLevel: Codable, Equatable, Identifiable {
    var sound: SoundID
    var value: Float

    var id: SoundID { sound }
}

struct SavedMix: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var levels: [MixLevel]
    var createdAt: Date

    func value(for sound: SoundID) -> Float {
        levels.first { $0.sound == sound }?.value ?? 0
    }
}

enum SaveMixResult: Equatable {
    case saved(SavedMix)
    case needsPro
    case emptyName
}
