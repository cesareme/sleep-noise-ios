import Foundation

/// One-tap mixes. A preset is Pro when any of its layers is a Pro sound, the
/// same rule as the mixer: during the local trial `hasFullAccess` is true, so
/// every preset plays; afterwards a locked preset does not change the sliders.
///
/// Model only: no view and no Shortcut offers these yet. The house mixes that
/// replace them bring their own names and their own intent.
enum SoundPreset: String, CaseIterable, Identifiable {
    case steadyRain
    case storm
    case cabin
    case campfire
    case brook
    case nightWind
    case shore

    var id: String { rawValue }

    var nameKey: String { "preset.\(rawValue)" }

    /// Layers above zero. Missing sounds are silent when the preset is applied.
    var layers: [SoundID: Float] {
        switch self {
        case .steadyRain:
            return [.rain: 0.78, .pink: 0.24]
        case .storm:
            return [.rain: 0.55, .thunder: 0.62]
        case .cabin:
            return [.cabin: 0.78, .brown: 0.20]
        case .campfire:
            return [.campfire: 0.72, .wind: 0.16]
        case .brook:
            return [.brook: 0.80]
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
    /// Stop was asked for while nothing was playing.
    case nothingPlaying
    case needsPro
    /// The timer was asked to start a night with every audible layer at zero.
    case nothingToPlay
    /// A timer length outside 1...`AccessPolicy.maxTimerMinutes`.
    case outOfRange
    case failed
}

enum PresetApplyResult: Equatable {
    case levels([SoundID: Float])
    case needsPro
}

enum PresetLibrary {
    /// Level of a sound that a Shortcut plays on its own.
    static let engagedLevel: Float = 0.65

    static func apply(_ preset: SoundPreset, hasFullAccess: Bool) -> PresetApplyResult {
        if preset.requiresFullAccess && !hasFullAccess {
            return .needsPro
        }
        return .levels(preset.levelsBySound())
    }
}
