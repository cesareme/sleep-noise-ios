import Foundation

/// One-tap mixes. A preset is Pro when any of its layers is a Pro sound, the
/// same rule as the mixer: during the local trial `hasFullAccess` is true, so
/// every preset plays; afterwards a locked preset opens the paywall and does
/// not change the sliders.
enum SoundPreset: String, CaseIterable, Identifiable {
    case deepSleep
    case focus
    case steadyRain
    case baby
    case storm
    case cabin
    case campfire
    case brook
    case nightWind
    case shore

    var id: String { rawValue }

    var nameKey: String { "preset.\(rawValue)" }

    var symbolName: String {
        switch self {
        case .deepSleep: return "moon.zzz.fill"
        case .focus: return "scope"
        case .steadyRain: return "cloud.rain.fill"
        case .baby: return "moon.haze.fill"
        case .storm: return "cloud.bolt.rain.fill"
        case .cabin: return "airplane"
        case .campfire: return "flame.fill"
        case .brook: return "drop.fill"
        case .nightWind: return "wind"
        case .shore: return "water.waves"
        }
    }

    /// Layers above zero. Missing sounds are silent when the preset is applied.
    var layers: [SoundID: Float] {
        switch self {
        case .deepSleep:
            return [.brown: 0.74, .rain: 0.32, .pink: 0.16]
        case .focus:
            return [.pink: 0.80, .brown: 0.20]
        case .steadyRain:
            return [.rain: 0.78, .pink: 0.24]
        case .baby:
            return [.brown: 0.48, .fan: 0.40, .pink: 0.12]
        case .storm:
            return [.rain: 0.55, .thunder: 0.62]
        case .cabin:
            return [.cabin: 0.78, .brown: 0.20]
        case .campfire:
            return [.campfire: 0.72, .wind: 0.16]
        case .brook:
            return [.stream: 0.80]
        case .nightWind:
            return [.wind: 0.70, .rain: 0.15]
        case .shore:
            return [.ocean: 0.70, .rain: 0.18]
        }
    }

    var requiresFullAccess: Bool {
        layers.contains { sound, level in
            level > 0.001 && !AccessPolicy.soundIsIncluded(sound, hasFullAccess: false)
        }
    }

    func levelsBySound() -> [SoundID: Float] {
        var levels = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        for (sound, level) in layers {
            levels[sound] = min(1, max(0, level))
        }
        return levels
    }

    var localizedName: String {
        String(localized: String.LocalizationValue(stringLiteral: nameKey))
    }
}

enum IntentOutcome: Equatable {
    case started
    case stopped
    case needsPro
    case failed
}

enum PresetApplyResult: Equatable {
    case levels([SoundID: Float])
    case needsPro
}

enum PresetLibrary {
    /// Level a tile uses when it is switched on from the grid.
    static let engagedLevel: Float = 0.65

    static func apply(_ preset: SoundPreset, hasFullAccess: Bool) -> PresetApplyResult {
        if preset.requiresFullAccess && !hasFullAccess {
            return .needsPro
        }
        return .levels(preset.levelsBySound())
    }
}
