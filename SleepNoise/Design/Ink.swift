import SwiftUI
import UIKit

/// Grafito colour tokens (design direction 03 §3.1).
///
/// The app is dark only in 1.0, so a token has two values: the regular one and
/// the one used when the system setting "Increase Contrast" is on. Black,
/// three greys and one accent per screen; nothing else, ever.
struct InkToken: Equatable {
    let hex: UInt32
    let highContrastHex: UInt32

    init(_ hex: UInt32, highContrast: UInt32? = nil) {
        self.hex = hex
        self.highContrastHex = highContrast ?? hex
    }

    func hex(highContrast: Bool) -> UInt32 {
        highContrast ? highContrastHex : hex
    }

    /// Resolves against the trait collection, so "Increase Contrast" switches
    /// the value without any view knowing about it.
    var uiColor: UIColor {
        let regular = hex
        let contrast = highContrastHex
        return UIColor { traits in
            UIColor(grafitoHex: traits.accessibilityContrast == .high ? contrast : regular)
        }
    }

    var color: Color {
        Color(uiColor: uiColor)
    }
}

/// The accent, "índice". One declaration for the whole app: if the owner
/// picks the alternative hue, these three values change and nothing else.
///
/// Law "colour = sound": the accent exists only while the engine is producing
/// audio or under a finger, one element per screen, never as a fill and never
/// as body text. Lines of 1.5 pt or more only.
enum AccentToken {
    /// `índice`.
    static let hex: UInt32 = 0xF0C020
    /// `índice-noche`: the accent on the night page, shapes of 2 pt or more.
    static let nightHex: UInt32 = 0xBA941C
    /// `índice-ac`: both of the above under "Increase Contrast".
    static let highContrastHex: UInt32 = 0xFFD23C
}

enum InkTokens {
    /// `negro`: page background. A pixel that is off.
    static let background = InkToken(0x000000)
    /// `hoja`: background of modal sheets, "another room". Never black on black.
    static let sheet = InkToken(0x1C1C1E)
    /// `grafito`: the only relief, the Disc and the track under a finger.
    static let relief = InkToken(0x1E1D1B)
    /// `trazo`: hairline on black.
    static let rule = InkToken(0x2A2A2E, highContrast: 0x3A3836)
    /// `trazo-hoja`: hairline on a sheet.
    static let ruleSheet = InkToken(0x38383B, highContrast: 0x3A3836)
    /// `texto`: main ink.
    static let text = InkToken(0xE8E4DC)
    /// `texto2`: secondary ink, state words, notes.
    static let text2 = InkToken(0x9C9A96, highContrast: 0xB4B2AE)
    /// `texto3`: non-text only (empty tracks), or text of 18 pt and more.
    static let text3 = InkToken(0x6E6C68, highContrast: 0x7A7672)
    /// `texto-noche`: the single text ink at night.
    static let textNight = InkToken(0xA2A09A, highContrast: 0xB4B2AE)
    /// `índice`.
    static let index = InkToken(AccentToken.hex, highContrast: AccentToken.highContrastHex)
    /// `índice-noche`.
    static let indexNight = InkToken(AccentToken.nightHex, highContrast: AccentToken.highContrastHex)

    static let all: [(name: String, token: InkToken)] = [
        ("negro", background), ("hoja", sheet), ("grafito", relief),
        ("trazo", rule), ("trazo-hoja", ruleSheet),
        ("texto", text), ("texto2", text2), ("texto3", text3), ("texto-noche", textNight),
        ("índice", index), ("índice-noche", indexNight),
    ]
}

/// The colours views use. Every one is a token above; no view writes a hex.
enum Ink {
    static let background = InkTokens.background.color
    static let sheet = InkTokens.sheet.color
    static let relief = InkTokens.relief.color
    static let rule = InkTokens.rule.color
    static let ruleSheet = InkTokens.ruleSheet.color
    static let text = InkTokens.text.color
    static let text2 = InkTokens.text2.color
    static let text3 = InkTokens.text3.color
    static let textNight = InkTokens.textNight.color
    static let index = InkTokens.index.color
    static let indexNight = InkTokens.indexNight.color

    /// At night, one ink (03 §3.1 rule 3).
    static func primary(_ phase: NightPhase) -> Color {
        phase.isNight ? textNight : text
    }

    static func secondary(_ phase: NightPhase) -> Color {
        phase.isNight ? textNight : text2
    }

    static func accent(_ phase: NightPhase) -> Color {
        phase.isNight ? indexNight : index
    }

    /// Hairline colour for the surface a view sits on.
    static func rule(on surface: InkSurface) -> Color {
        surface == .sheet ? ruleSheet : rule
    }
}

/// Phase of the night (03 §3.2). It changes luminance, never hue.
enum NightPhase: Equatable {
    /// The page before bed and by day.
    case day
    /// The page after coming back from Night: same page, one ink.
    case nightPage
    /// The Night screen.
    case night
    /// Small hours.
    case smallHours

    var isNight: Bool { self != .day }

    /// Night and small hours: the whole screen is the button.
    var isNightScreen: Bool { self == .night || self == .smallHours }
}

/// What a view is drawn on. Sheets are `hoja` with `trazo-hoja` hairlines;
/// the page is black with `trazo`.
enum InkSurface: Equatable {
    case black
    case sheet
}

private struct NightPhaseKey: EnvironmentKey {
    static let defaultValue = NightPhase.day
}

private struct InkSurfaceKey: EnvironmentKey {
    static let defaultValue = InkSurface.black
}

extension EnvironmentValues {
    var nightPhase: NightPhase {
        get { self[NightPhaseKey.self] }
        set { self[NightPhaseKey.self] = newValue }
    }

    var inkSurface: InkSurface {
        get { self[InkSurfaceKey.self] }
        set { self[InkSurfaceKey.self] = newValue }
    }
}

extension UIColor {
    /// Opaque sRGB colour from 0xRRGGBB.
    convenience init(grafitoHex hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension View {
    /// Root of every Grafito screen: black, dark only, and no inherited tint,
    /// so no control picks up an accent on its own.
    func grafitoRoot() -> some View {
        self
            .background(Ink.background.ignoresSafeArea())
            .tint(Ink.text)
            .preferredColorScheme(.dark)
    }
}
