import Foundation

enum SoundID: String, Codable, CaseIterable, Identifiable {
    case white
    case pink
    case brown
    case rain
    case fan
    case ocean

    var id: String { rawValue }

    var nameKey: String {
        switch self {
        case .white: return "sound.white"
        case .pink: return "sound.pink"
        case .brown: return "sound.brown"
        case .rain: return "sound.rain"
        case .fan: return "sound.fan"
        case .ocean: return "sound.ocean"
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
        }
    }

    var localizedName: String {
        String(localized: String.LocalizationValue(stringLiteral: nameKey))
    }
}
