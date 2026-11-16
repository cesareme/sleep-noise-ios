import SwiftUI
import UIKit

/// Colors, spacing, radii and type for the night UI.
///
/// Dark is the primary palette. Light is a warm paper version of the same
/// accent so the system appearance stays readable. One accent is used for
/// selection, the play control and Pro; nothing else carries a second hue.
enum DesignTokens {
    enum Colors {
        static let background = dynamic(dark: RGBA(0.035, 0.040, 0.048), light: RGBA(0.965, 0.957, 0.945))
        static let backgroundRaised = dynamic(dark: RGBA(0.055, 0.062, 0.074), light: RGBA(0.945, 0.932, 0.910))
        static let surface = dynamic(dark: RGBA(0.10, 0.11, 0.125, 0.92), light: RGBA(1, 0.995, 0.985, 0.94))
        static let accent = dynamic(dark: RGBA(0.93, 0.74, 0.48), light: RGBA(0.55, 0.36, 0.14))
        static let onAccent = dynamic(dark: RGBA(0.09, 0.07, 0.05), light: RGBA(0.99, 0.97, 0.94))
        static let text = dynamic(dark: RGBA(0.95, 0.94, 0.91), light: RGBA(0.14, 0.12, 0.10))
        static let secondary = dynamic(dark: RGBA(0.62, 0.63, 0.66), light: RGBA(0.40, 0.37, 0.33))
        static let hairline = dynamic(dark: RGBA(1, 1, 1, 0.08), light: RGBA(0.12, 0.10, 0.08, 0.08))
        static let bedtime = Color.black
        static let bedtimeInk = Color(red: 0.93, green: 0.74, blue: 0.48)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let s: CGFloat = 12
        static let m: CGFloat = 18
        static let l: CGFloat = 28
        static let tile: CGFloat = 22
    }

    enum Typography {
        static func display(_ weight: Font.Weight = .medium) -> Font {
            .system(.largeTitle, design: .rounded).weight(weight)
        }

        static func title(_ weight: Font.Weight = .semibold) -> Font {
            .system(.title3, design: .rounded).weight(weight)
        }

        static func body(_ weight: Font.Weight = .regular) -> Font {
            .system(.body, design: .rounded).weight(weight)
        }

        static func callout(_ weight: Font.Weight = .medium) -> Font {
            .system(.callout, design: .rounded).weight(weight)
        }

        static func caption(_ weight: Font.Weight = .medium) -> Font {
            .system(.caption, design: .rounded).weight(weight)
        }

        static func clock() -> Font {
            .system(.largeTitle, design: .rounded).weight(.light)
        }
    }
}

extension View {
    func tokenFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> some View {
        font(.system(style, design: .rounded).weight(weight))
    }
}

private struct RGBA {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

private func dynamic(dark: RGBA, light: RGBA) -> Color {
    Color(uiColor: UIColor { traits in
        let tone = traits.userInterfaceStyle == .dark ? dark : light
        return UIColor(red: tone.red, green: tone.green, blue: tone.blue, alpha: tone.alpha)
    })
}

/// Names kept so existing screens pick up the new palette without a second accent.
enum Palette {
    static let background = DesignTokens.Colors.background
    static let ink = DesignTokens.Colors.backgroundRaised
    static let card = DesignTokens.Colors.surface
    static let amber = DesignTokens.Colors.accent
    static let mist = DesignTokens.Colors.secondary
    static let text = DesignTokens.Colors.text
    static let muted = DesignTokens.Colors.secondary
    static let onAccent = DesignTokens.Colors.onAccent
}
