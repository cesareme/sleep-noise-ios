import SwiftUI

/// The text action (03 §4.9): the secondary action of a screen.
///
/// A borderless word in step 6 and secondary ink ("Restore purchase", "Not
/// now"). 44 pt tall; 64 pt on the night page, where it is also Medium.
struct TextAction: View {
    var title: String
    var alignment = Alignment.center
    var action: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .step(.body)
                .foregroundStyle(Ink.secondary(phase))
                .underline(buttonShapes, color: Ink.secondary(phase))
                .frame(
                    maxWidth: .infinity,
                    minHeight: phase.isNight ? Grid.largeTarget : Grid.target,
                    alignment: alignment
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PressedFadeStyle())
        .padding(.horizontal, Grid.margin)
    }
}

#Preview("Text action") {
    VStack(spacing: Grid.inner) {
        TextAction(title: "Restore purchase") {}
        TextAction(title: "Not now", alignment: .leading) {}
        TextAction(title: "Not now") {}
            .environment(\.nightPhase, .nightPage)
    }
    .frame(maxHeight: .infinity)
    .grafitoRoot()
}
