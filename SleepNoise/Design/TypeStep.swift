import SwiftUI
import UIKit

/// The nine steps of the Grafito type scale (03 §3.4). One family, SF Pro;
/// the system picks Text or Display. No rounded, serif or mono face, and no
/// Light, Thin or Bold weight exists here.
///
/// A step is a size at Large plus the text style it scales with, so every
/// step follows Dynamic Type. Views never call `.font(.system(size:))`: they
/// call `.step(_:)`.
enum TypeStep: CaseIterable {
    /// 1 · Figure: the Night clock.
    case figure
    /// 1 · Figure, small: price, countdown.
    case figureSmall
    /// 2 · Name of the mix on the page.
    case name
    /// 3 · Header of a sheet or a pushed screen.
    case header
    /// 3 · State on the Night screen (Medium).
    case nightState
    /// 4 · Night action.
    case nightAction
    /// 5 · Row: layer name, setting name, primary action.
    case row
    /// 5 · The level value under the finger (Medium, tabular).
    case value
    /// 6 · Body, secondary action.
    case body
    /// 6 · Long reading, with more leading.
    case reading
    /// 6 · Words of the bottom bar (Medium).
    case bar
    /// 7 · Subtitle, state line.
    case secondary
    /// 8 · Footnote.
    case note
    /// 9 · Datum: level value, minutes (Medium, tabular).
    case data
    /// 9 · State word in small caps.
    case stateWord

    /// Position in the nine-step scale.
    var scaleStep: Int {
        switch self {
        case .figure, .figureSmall: return 1
        case .name: return 2
        case .header, .nightState: return 3
        case .nightAction: return 4
        case .row, .value: return 5
        case .body, .reading, .bar: return 6
        case .secondary: return 7
        case .note: return 8
        case .data, .stateWord: return 9
        }
    }

    /// Point size at Large.
    var size: CGFloat {
        switch self {
        case .figure: return 72
        case .figureSmall: return 56
        case .name: return 28
        case .header, .nightState: return 22
        case .nightAction: return 20
        case .row, .value, .body, .reading, .bar: return 17
        case .secondary: return 15
        case .note, .data, .stateWord: return 13
        }
    }

    /// Line height at Large (the real line height, not extra leading).
    var lineHeight: CGFloat {
        switch self {
        case .figure: return 80
        case .figureSmall: return 64
        case .name: return 34
        case .header, .nightState: return 28
        case .nightAction: return 25
        case .row, .value, .body, .bar: return 22
        case .reading: return 26
        case .secondary: return 20
        case .note, .data, .stateWord: return 18
        }
    }

    /// The system text style the step scales with.
    var textStyle: UIFont.TextStyle {
        switch self {
        case .figure, .figureSmall: return .largeTitle
        case .name: return .title1
        case .header, .nightState: return .title2
        case .nightAction: return .title3
        case .row, .value: return .headline
        case .body, .reading, .bar: return .body
        case .secondary: return .subheadline
        case .note, .data, .stateWord: return .footnote
        }
    }

    /// Daytime weight. At night nothing goes under Medium except the figure,
    /// which is 20 pt or more.
    func weight(_ phase: NightPhase) -> Font.Weight {
        switch self {
        case .figure, .figureSmall:
            return .regular
        case .name, .nightState, .nightAction, .value, .bar, .data, .stateWord:
            return .medium
        case .header, .row:
            return .semibold
        case .body, .reading, .secondary, .note:
            return phase.isNight ? .medium : .regular
        }
    }

    /// Tracking as a fraction of the size: −1 % on the figure, +2 % on small caps.
    var trackingFraction: CGFloat {
        switch self {
        case .figure, .figureSmall: return -0.01
        case .stateWord: return 0.02
        default: return 0
        }
    }

    /// The figure stops growing at Accessibility 2; the rest go all the way.
    var largestDynamicType: DynamicTypeSize {
        switch self {
        case .figure, .figureSmall: return .accessibility2
        default: return .accessibility5
        }
    }

    /// Numbers never change width.
    var isTabular: Bool {
        switch self {
        case .figure, .figureSmall, .value, .data: return true
        default: return false
        }
    }

    var isSmallCaps: Bool { self == .stateWord }

    /// Point size at a Dynamic Type size, scaled with the step's text style
    /// and capped at `largestDynamicType`.
    func scaledSize(for dynamicType: DynamicTypeSize) -> CGFloat {
        let capped = min(dynamicType, largestDynamicType)
        let traits = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(capped))
        return UIFontMetrics(forTextStyle: textStyle).scaledValue(for: size, compatibleWith: traits)
    }

    /// Line height at a Dynamic Type size: the same proportion as at Large.
    func scaledLineHeight(for dynamicType: DynamicTypeSize) -> CGFloat {
        lineHeight * scaledSize(for: dynamicType) / size
    }

    /// The font of the step, for the rare text that mixes two steps in one
    /// paragraph. Everything else calls `.step(_:)`.
    func font(_ phase: NightPhase, dynamicType: DynamicTypeSize) -> Font {
        var font = Font.system(size: scaledSize(for: dynamicType), weight: weight(phase))
        if isSmallCaps { font = font.lowercaseSmallCaps() }
        if isTabular { font = font.monospacedDigit() }
        return font
    }
}

/// Applies a step: size scaled with its text style, weight by phase, small
/// caps, tabular digits, tracking, and the line height of the scale.
private struct Stepped: ViewModifier {
    let step: TypeStep

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType

    func body(content: Content) -> some View {
        let size = step.scaledSize(for: dynamicType)
        let weight = step.weight(phase)
        // SwiftUI's line spacing is extra air between lines, so it is worked
        // out against the natural line height of the system font.
        let natural = UIFont.systemFont(ofSize: size, weight: weight.uiWeight).lineHeight
        let extra = max(0, step.scaledLineHeight(for: dynamicType) - natural)

        return content
            .font(step.font(phase, dynamicType: dynamicType))
            .tracking(size * step.trackingFraction)
            .lineSpacing(extra)
    }
}

extension View {
    /// The only way a text gets its font.
    func step(_ step: TypeStep) -> some View {
        modifier(Stepped(step: step))
    }
}

private extension Font.Weight {
    var uiWeight: UIFont.Weight {
        switch self {
        case .semibold: return .semibold
        case .medium: return .medium
        default: return .regular
        }
    }
}

#Preview("Type scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: Grid.inner) {
            Text(verbatim: "23:41").step(.figure)
            Text(verbatim: "29,99").step(.figureSmall)
            Text(verbatim: "Name").step(.name)
            Text(verbatim: "Header").step(.header)
            Text(verbatim: "Night action").step(.nightAction)
            Text(verbatim: "Row").step(.row)
            Text(verbatim: "Body").step(.body)
            Text(verbatim: "Secondary").step(.secondary).foregroundStyle(Ink.text2)
            Text(verbatim: "Note").step(.note).foregroundStyle(Ink.text2)
            Text(verbatim: "Datum 65").step(.data).foregroundStyle(Ink.text2)
            Text(verbatim: "State word").step(.stateWord).foregroundStyle(Ink.text2)
        }
        .foregroundStyle(Ink.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Grid.margin)
    }
    .grafitoRoot()
}
