import Foundation

/// Per-sound linear gains in 0...1. A value type so the audio thread can copy it.
struct SoundGains: Equatable {
    var white: Float = 0
    var pink: Float = 0
    var brown: Float = 0
    var rain: Float = 0
    var fan: Float = 0
    var ocean: Float = 0

    static let zero = SoundGains()

    func value(for sound: SoundID) -> Float {
        switch sound {
        case .white: return white
        case .pink: return pink
        case .brown: return brown
        case .rain: return rain
        case .fan: return fan
        case .ocean: return ocean
        }
    }

    mutating func set(_ sound: SoundID, _ value: Float) {
        let clamped = min(1, max(0, value))
        switch sound {
        case .white: white = clamped
        case .pink: pink = clamped
        case .brown: brown = clamped
        case .rain: rain = clamped
        case .fan: fan = clamped
        case .ocean: ocean = clamped
        }
    }

    mutating func approach(_ target: SoundGains, coefficient: Float) {
        white += (target.white - white) * coefficient
        pink += (target.pink - pink) * coefficient
        brown += (target.brown - brown) * coefficient
        rain += (target.rain - rain) * coefficient
        fan += (target.fan - fan) * coefficient
        ocean += (target.ocean - ocean) * coefficient
    }
}
