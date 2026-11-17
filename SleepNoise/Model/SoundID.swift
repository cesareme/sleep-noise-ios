import Foundation

/// The raw values are stored: saved mixes, the last levels and Shortcuts all
/// keep them. Renaming a case loses that data, so they are frozen by a test.
enum SoundID: String, Codable, CaseIterable, Identifiable {
    case white
    case pink
    case brown
    case rain
    case fan
    case ocean
    case thunder
    case campfire
    case brook
    case wind
    case cabin

    var id: String { rawValue }

    var nameKey: String {
        switch self {
        case .white: return "sound.white"
        case .pink: return "sound.pink"
        case .brown: return "sound.brown"
        case .rain: return "sound.rain"
        case .fan: return "sound.fan"
        case .ocean: return "sound.ocean"
        case .thunder: return "sound.thunder"
        case .campfire: return "sound.campfire"
        case .brook: return "sound.brook"
        case .wind: return "sound.wind"
        case .cabin: return "sound.cabin"
        }
    }

    /// The line of use under the name, in lower case ("on the roof").
    var detailKey: String { "capas.\(rawValue).detalle" }

    var localizedName: String {
        String(localized: String.LocalizationValue(stringLiteral: nameKey))
    }
}
