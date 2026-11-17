import SwiftUI

/// A row whose value opens the system's menu: a setting with a few options
/// ("Pace", "Keep screen on"). The whole row is the target; the value and
/// its mark are secondary ink, never a tint.
struct MenuRow<Options: View>: View {
    var title: String
    var value: String
    /// What VoiceOver reads as the value, when it is not the visible one.
    var spokenValue: String?
    @ViewBuilder var options: Options

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType

    var body: some View {
        Menu {
            options
                .pickerStyle(.inline)
                .labelsHidden()
        } label: {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Grid.inner) {
                    name
                    Spacer(minLength: 0)
                    mark
                }
                // Larger text: the value drops under the name.
                VStack(alignment: .leading, spacing: Grid.unit) {
                    name
                    mark
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Grid.unit * 3)
            .padding(.horizontal, Grid.margin)
            .frame(minHeight: Grid.row(subtitle: false, dynamicType: dynamicType))
            .contentShape(Rectangle())
        }
        .overlay(alignment: .bottom) {
            Hairline().padding(.horizontal, Grid.margin)
        }
        .accessibilityLabel(Text(verbatim: title))
        .accessibilityValue(Text(verbatim: spokenValue ?? value))
    }

    private var name: some View {
        Text(verbatim: title)
            .step(.row)
            .foregroundStyle(Ink.primary(phase))
            .multilineTextAlignment(.leading)
    }

    private var mark: some View {
        HStack(spacing: Grid.unit) {
            Text(verbatim: value)
                .step(.body)
                .monospacedDigit()
            Image(systemName: "chevron.up.chevron.down")
                .font(.footnote.weight(.medium))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .accessibilityHidden(true)
        }
        .foregroundStyle(Ink.secondary(phase))
    }
}
