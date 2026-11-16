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

    var detailKey: String {
        switch self {
        case .white: return "sound.white.detail"
        case .pink: return "sound.pink.detail"
        case .brown: return "sound.brown.detail"
        case .rain: return "sound.rain.detail"
        case .fan: return "sound.fan.detail"
        case .ocean: return "sound.ocean.detail"
        case .thunder: return "sound.thunder.detail"
        case .campfire: return "sound.campfire.detail"
        case .brook: return "sound.brook.detail"
        case .wind: return "sound.wind.detail"
        case .cabin: return "sound.cabin.detail"
        }
    }

    var symbolName: String {
        switch self {
        case .white: return "waveform"
        case .pink: return "waveform.path"
        case .brown: return "speaker.wave.1.fill"
        case .rain: return "cloud.rain.fill"
        case .fan: return "fan.fill"
        case .ocean: return "water.waves"
        case .thunder: return "cloud.bolt.fill"
        case .campfire: return "flame.fill"
        case .brook: return "drop.fill"
        case .wind: return "wind"
        case .cabin: return "airplane"
        }
    }

    var localizedName: String {
        String(localized: String.LocalizationValue(stringLiteral: nameKey))
    }
}
