import SwiftUI

/// The primary action (03 §4.6): a word between two hairlines.
///
/// A 64 pt row across the column with the word centred in it. No fill, no
/// radius, no icon: the two hairlines are the button. One per screen.
///
/// The hairlines are plain unless the caller asks for the accent, which the
/// design allows in exactly one place: the purchase action once the price is
/// known, the only border of colour in the app, on the only button that
/// costs money. Any number in the title comes from code (`displayPrice`),
/// never from a string.
struct HairlineAction: View {
    enum Rules: Equatable {
        /// `trazo` on black, `trazo-hoja` on a sheet.
        case plain
        /// 1.5 pt in the accent: the least the accent is allowed to be.
        case accent
    }

    var title: String
    var rules = Rules.plain
    /// Disabled or busy: the word steps back to secondary ink and the row
    /// does not answer. The hairlines are never the accent then.
    var isEnabled = true
    /// A line under the row: why it is disabled, or what happened.
    var note: String?
    /// The row above another primary row gives up its lower hairline: the
    /// one between them belongs to the row below (the trial over the
    /// purchase, whose rules are the accent).
    var showsBottomRule = true
    /// What VoiceOver reads instead of the title, its value and its hint.
    /// Without a hint it reads the note.
    var spokenTitle: String?
    var spokenValue: String?
    var hint: String?
    var action: () -> Void

    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.nightPhase) private var phase

    private var showsAccent: Bool { rules == .accent && isEnabled }
    /// On the night page the word takes its one ink, like everything else.
    private var wordColor: Color { isEnabled ? Ink.primary(phase) : Ink.secondary(phase) }

    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit * 2) {
            Button(action: action) {
                Text(verbatim: title)
                    .step(.row)
                    .foregroundStyle(wordColor)
                    .underline(buttonShapes, color: wordColor)
                    .multilineTextAlignment(.center)
                    // Air for a title that wraps at large text sizes; at
                    // Large the row is exactly 64 pt, and 80 from AX1.
                    .padding(.vertical, Grid.unit * 3)
                    .frame(maxWidth: .infinity, minHeight: Grid.primaryAction(dynamicType: dynamicType))
                    .contentTransition(.opacity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressedFadeStyle())
            .disabled(!isEnabled)
            .accessibilityLabel(Text(verbatim: spokenTitle ?? title))
            .accessibilityValue(Text(verbatim: spokenValue ?? ""))
            .accessibilityHint(Text(verbatim: hint ?? note ?? ""))
            .overlay(alignment: .top) { rule }
            .overlay(alignment: .bottom) {
                if showsBottomRule { rule }
            }
            .animation(Motion.contentCurve, value: showsAccent)
            .animation(Motion.contentCurve, value: title)

            if let note {
                Text(verbatim: note)
                    .step(.note)
                    .foregroundStyle(Ink.text2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, Grid.margin)
    }

    private var rule: some View {
        Hairline(
            color: showsAccent ? Ink.index : nil,
            thickness: showsAccent ? Grid.accentLine : nil
        )
    }
}

/// Pressed: opacity 0.6 for 200 ms. Nothing moves.
struct PressedFadeStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(Motion.controlCurve, value: configuration.isPressed)
    }
}

#Preview("Primary action") {
    VStack(spacing: Grid.group) {
        HairlineAction(title: "Save") {}
        HairlineAction(title: "Buy · {displayPrice}", rules: .accent) {}
        HairlineAction(title: "Buy", isEnabled: false, note: "The store is not answering. Nothing changes.") {}
    }
    .frame(maxHeight: .infinity)
    .background(Ink.sheet)
    .environment(\.inkSurface, .sheet)
    .preferredColorScheme(.dark)
}
