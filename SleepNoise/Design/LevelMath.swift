import CoreGraphics
import Foundation

/// The arithmetic of a level row, kept apart from the view so it can be
/// tested: a level is 0…1, shown and stored as a whole percent.
enum LevelMath {
    /// VoiceOver and Switch Control move a level in steps of 5 %.
    static let accessibilityStep: Float = 0.05
    /// Part of the column the finger does not have to cover: a full sweep is
    /// the column minus this, so both ends are reachable without touching
    /// the screen edge.
    static let travelReserve: CGFloat = 20

    static func clamped(_ level: Float) -> Float {
        guard level == level else { return 0 }
        return min(1, max(0, level))
    }

    /// 0…100, the number the row shows.
    static func percent(_ level: Float) -> Int {
        Int((clamped(level) * 100).rounded())
    }

    /// The level snapped to a whole percent: what is kept when the finger lifts.
    static func quantized(_ level: Float) -> Float {
        Float(percent(level)) / 100
    }

    /// One accessibility step up or down, on whole percents.
    static func stepped(_ level: Float, up: Bool) -> Float {
        quantized(clamped(level) + (up ? accessibilityStep : -accessibilityStep))
    }

    /// Points of finger travel for the whole range: 333 on a 353 pt column.
    static func travel(columnWidth: CGFloat) -> CGFloat {
        max(1, columnWidth - travelReserve)
    }
}

/// One drag on a level row (spec 05 §2.6).
///
/// The axis is decided once, on the first movement: within 30° of the
/// horizontal (20° on the night page) the row owns the gesture, otherwise
/// the scroll does, and that does not change until the finger lifts. `LevelTouchSurface` asks `axis`
/// before its recognizer begins.
///
/// The drag itself is relative: the level moves by the distance travelled,
/// wherever the finger landed, so a row can be grabbed by its name in the
/// dark. Past either end no distance is banked: on the way back the level
/// moves from the first point.
struct LevelDrag: Equatable {
    enum Axis: Equatable {
        /// Horizontal: the row owns the gesture.
        case level
        /// Anything else: the scroll owns it and the row never changes.
        case scroll
    }

    /// tan 30°. At exactly 30° the scroll wins: it costs nothing to undo.
    static let coneTangent: CGFloat = 0.577_350_3
    /// tan 20°: the narrower cone of the night page (04 §2.2), where a hand
    /// half asleep must scroll rather than change a level.
    static let nightConeTangent: CGFloat = 0.363_970_2

    private var lastX: CGFloat = 0

    static func coneTangent(night: Bool) -> CGFloat {
        night ? nightConeTangent : coneTangent
    }

    static func axis(for movement: CGSize, coneTangent: CGFloat = LevelDrag.coneTangent) -> Axis {
        abs(movement.height) < abs(movement.width) * coneTangent ? .level : .scroll
    }

    /// Feeds the horizontal translation since the touch began and returns
    /// the new level.
    mutating func update(translationX: CGFloat, level: Float, travel: CGFloat) -> Float {
        let delta = translationX - lastX
        lastX = translationX
        return LevelMath.clamped(level + Float(delta / max(1, travel)))
    }
}

/// What VoiceOver says about a level row.
struct LevelRuleSpeech: Equatable {
    var name: String
    var subtitle: String
    var level: Float
    var isLocked = false
    /// Off on the night page, where nothing says "requires Pro".
    var namesPro = true
    var bundle: Bundle = .main

    /// "Rain, drops on a steady bed"; with ", requires Pro" when locked,
    /// except on the night page.
    var label: String {
        Localized.format(isLocked && namesPro ? "ax.capa.pro" : "ax.capa", bundle: bundle, name, subtitle)
    }

    /// "65 percent". A locked layer does not sound: "Silent", or
    /// "silent, saved level 30" when it keeps a level for later.
    var value: String {
        let percent = LevelMath.percent(level)
        guard isLocked else {
            return Localized.format("a11y.percentFormat", bundle: bundle, Int64(percent))
        }
        guard percent > 0 else {
            return Localized.string("pagina.estado.silencio", bundle: bundle)
        }
        return Localized.format("ax.capa.pro.valor", bundle: bundle, String(percent))
    }

    /// The word shown where the value would be on a locked row.
    var lockedWord: String {
        let percent = LevelMath.percent(level)
        guard percent > 0 else {
            return Localized.string("comun.pro", bundle: bundle)
        }
        return Localized.format("comun.pro.nivel", bundle: bundle, Int64(percent))
    }
}
