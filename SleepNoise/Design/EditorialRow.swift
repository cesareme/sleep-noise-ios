import SwiftUI

/// The editorial row (03 §4.7): words on the left, a value or a state on the
/// right, a hairline from margin to margin. 56 pt, or 72 pt with a subtitle;
/// taller with larger text (`Grid.row(subtitle:dynamicType:)`).
///
/// No icon, no chevron, no card: the words are the icons. Pressed, the row
/// shows `grafito` for 200 ms. In a list of options the chosen one carries
/// the system checkmark in plain ink.
struct EditorialRow: View {
    enum Rule: Equatable {
        case none
        /// The page draws the hairline above its rows.
        case top
        /// Lists draw it below.
        case bottom
    }

    var title: String
    var subtitle: String?
    /// Value or state on the right, in secondary ink.
    var value: String?
    /// The value is a datum ("and 2 more"), not a setting: step 9, tabular
    /// figures, like the level of a row (05 §2.1).
    var valueIsDatum = false
    /// A state word in small caps on the right ("pro").
    var stateWord: String?
    /// The chosen option of a list.
    var isSelected = false
    var rule = Rule.bottom
    var action: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType

    var body: some View {
        Button(action: action) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: Grid.inner) {
                    labels
                    Spacer(minLength: 0)
                    trailing
                }
                // Larger text: the value drops under the words.
                VStack(alignment: .leading, spacing: Grid.unit) {
                    labels
                    trailing
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Grid.unit * 3)
            .padding(.horizontal, Grid.margin)
            .frame(minHeight: Grid.row(subtitle: subtitle != nil, dynamicType: dynamicType))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressedReliefStyle())
        .overlay(alignment: rule == .top ? .top : .bottom) {
            if rule != .none {
                Hairline().padding(.horizontal, Grid.margin)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: Grid.unit / 2) {
            Text(verbatim: title)
                .step(.row)
                .foregroundStyle(stateWord == nil ? Ink.primary(phase) : Ink.secondary(phase))
            if let subtitle {
                Text(verbatim: subtitle)
                    .step(.secondary)
                    .foregroundStyle(Ink.secondary(phase))
            }
        }
        .multilineTextAlignment(.leading)
    }

    @ViewBuilder private var trailing: some View {
        if let stateWord {
            StateWord(text: stateWord)
        } else if isSelected {
            Image(systemName: "checkmark")
                .step(.bar)
                .foregroundStyle(Ink.primary(phase))
                .accessibilityHidden(true)
        } else if let value {
            Text(verbatim: value)
                .step(valueIsDatum ? .data : .secondary)
                .foregroundStyle(Ink.secondary(phase))
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Pressed: `grafito` behind the whole row for 200 ms, square corners.
private struct PressedReliefStyle: ButtonStyle {
    @Environment(\.inkSurface) private var surface

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Ink.relief(on: surface).opacity(configuration.isPressed ? 1 : 0))
            .animation(Motion.controlCurve, value: configuration.isPressed)
    }
}

#Preview("Editorial row") {
    VStack(spacing: 0) {
        EditorialRow(title: "All layers", value: "and 2 more", rule: .top) {}
        EditorialRow(title: "Sleep timer", value: "Until I fall asleep · 45 min", rule: .top) {}
        EditorialRow(title: "Sea and wind", subtitle: "ocean 50 · wind 20") {}
        EditorialRow(title: "45 min", isSelected: true) {}
        EditorialRow(title: "Ocean", stateWord: "pro") {}
    }
    .frame(maxHeight: .infinity)
    .grafitoRoot()
}
