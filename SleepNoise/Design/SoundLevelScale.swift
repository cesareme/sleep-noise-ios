import Darwin
import Foundation
import CoreGraphics

/// From the RMS the engine publishes to what the Horizon draws and says.
///
/// The engine reports a linear amplitude (0 silence, about 0.7 for a
/// full-scale sine). Loudness is closer to decibels, so the scale is a
/// straight line in dB between two anchors measured on the generators: one
/// quiet layer sits near −40 dBFS, the default mix near −18, six layers
/// stacked near −12 and everything at full near −6.
enum SoundLevelScale {
    /// RMS, in dBFS, drawn as the thinnest line.
    static let floorDecibels: Float = -48
    /// RMS, in dBFS, drawn as the thickest line.
    static let ceilingDecibels: Float = -9
    /// Under this the engine is silent as far as the eye is concerned.
    static let silenceDecibels: Float = -57
    /// From here up the line is fully there. Between the two it is born
    /// from, or returns to, the hairline.
    static let presentDecibels: Float = -51

    /// Thinnest and thickest sounding line: the accent never goes under 1.5 pt.
    static let minThickness: CGFloat = Grid.accentLine
    static let maxThickness: CGFloat = 3
    /// Opacity range of the sounding line.
    static let minOpacity: Double = 0.6
    static let maxOpacity: Double = 1

    static func decibels(rms: Float) -> Float {
        guard rms == rms, rms > 0 else { return -.infinity }
        return 20 * log10f(rms)
    }

    /// 0 at the floor and below, 1 at the ceiling and above.
    static func level(rms: Float) -> Float {
        let value = (decibels(rms: rms) - floorDecibels) / (ceilingDecibels - floorDecibels)
        guard value == value else { return 0 }
        return min(1, max(0, value))
    }

    /// 0 while silent, 1 once something is clearly sounding. It only shapes
    /// the birth and the death of the line; the level does the rest.
    static func presence(rms: Float) -> Float {
        let value = (decibels(rms: rms) - silenceDecibels) / (presentDecibels - silenceDecibels)
        guard value == value else { return 0 }
        return min(1, max(0, value))
    }

    /// Thickness of the sounding line, 1.5 pt to 3 pt.
    static func thickness(level: Float) -> CGFloat {
        let clamped = CGFloat(min(1, max(0, level)))
        return minThickness + (maxThickness - minThickness) * clamped
    }

    /// Opacity of the sounding line, 0.6 to 1.
    static func opacity(level: Float) -> Double {
        let clamped = Double(min(1, max(0, level)))
        return minOpacity + (maxOpacity - minOpacity) * clamped
    }

    /// What VoiceOver says about the level, in words.
    enum Spoken: Equatable {
        case silent
        case low
        case medium
        case high

        /// Catalog key of the spoken value.
        var key: String {
            switch self {
            case .silent: return "pagina.estado.silencio"
            case .low: return "ax.horizonte.valor.bajo"
            case .medium: return "ax.horizonte.valor.medio"
            case .high: return "ax.horizonte.valor.alto"
            }
        }
    }

    static func spoken(rms: Float) -> Spoken {
        guard presence(rms: rms) > 0 else { return .silent }
        let value = level(rms: rms)
        if value < 0.33 { return .low }
        if value < 0.66 { return .medium }
        return .high
    }
}

/// Keeps VoiceOver from chattering: the spoken level changes at most once
/// every few seconds, however fast the sound moves.
struct SpokenLevelGate {
    private(set) var spoken = SoundLevelScale.Spoken.silent
    private var changedAt: TimeInterval?

    /// Feeds the current reading and returns what should be on show.
    mutating func update(
        _ next: SoundLevelScale.Spoken,
        at time: TimeInterval,
        hold: TimeInterval = Motion.spokenLevelHold
    ) -> SoundLevelScale.Spoken {
        guard next != spoken else { return spoken }
        if let changedAt, time - changedAt < hold {
            return spoken
        }
        spoken = next
        changedAt = time
        return spoken
    }
}
