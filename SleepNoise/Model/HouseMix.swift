import Foundation

/// The four house mixes: recipes of levels whose names say what is in them
/// and promise nothing. They only set levels: never the timer, never the tide.
/// They are not renamed, deleted or reordered.
///
/// A house mix with Pro layers is never refused. Without full access it loads
/// trimmed, like a saved mix would: see `MixLoad`.
///
/// The raw values are ids that Shortcuts keep. Renaming a case breaks a
/// stored shortcut, so they are frozen by a test.
enum HouseMix: String, CaseIterable, Identifiable {
    case pinkAndRain
    case seaAndWind
    case brownAndFire
    case wall

    var id: String { rawValue }

    var nameKey: String {
        switch self {
        case .pinkAndRain: return "mezcla.casa.rosa_lluvia"
        case .seaAndWind: return "mezcla.casa.mar_viento"
        case .brownAndFire: return "mezcla.casa.marron_hoguera"
        case .wall: return "mezcla.casa.pared"
        }
    }

    /// The layers above zero, loudest first: the order the recipe is read in.
    var recipe: [MixLevel] {
        switch self {
        case .pinkAndRain:
            return [MixLevel(sound: .rain, value: 0.55), MixLevel(sound: .pink, value: 0.20)]
        case .seaAndWind:
            return [MixLevel(sound: .ocean, value: 0.50), MixLevel(sound: .wind, value: 0.20)]
        case .brownAndFire:
            return [MixLevel(sound: .brown, value: 0.40), MixLevel(sound: .campfire, value: 0.30)]
        case .wall:
            return [
                MixLevel(sound: .brown, value: 0.40),
                MixLevel(sound: .rain, value: 0.30),
                MixLevel(sound: .wind, value: 0.30),
            ]
        }
    }

    /// One level per sound. Sounds outside the recipe are silent.
    func levelsBySound() -> [SoundID: Float] {
        var levels = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        for layer in recipe {
            levels[layer.sound] = MixCodec.bounded(layer.value)
        }
        return levels
    }

    func load(hasFullAccess: Bool) -> MixLoad {
        MixLoad(levels: levelsBySound(), hasFullAccess: hasFullAccess)
    }

    var localizedName: String {
        String(localized: String.LocalizationValue(stringLiteral: nameKey))
    }
}
