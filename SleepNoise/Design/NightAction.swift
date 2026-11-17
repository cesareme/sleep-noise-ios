import SwiftUI

/// The night action (03 §3.4 step 4, §4.5): "+15 min", "Stop", "Keep
/// playing on speaker", "Small hours · 20 min".
///
/// A word in step 4 and the one ink of the night, across the whole width in
/// a 64 pt row: the size a thumb finds in the dark without looking. No
/// fill, no border, no icon. It never moves and it never carries colour.
struct NightAction: View {
    var title: String
    var action: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes
    @Environment(\.dynamicTypeSize) private var dynamicType

    /// 64 pt, and 96 from the third accessibility size (spec 07 §5d).
    static func height(dynamicType: DynamicTypeSize) -> CGFloat {
        dynamicType >= .accessibility3 ? 96 : Grid.largeTarget
    }

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .step(.nightAction)
                .monospacedDigit()
                .foregroundStyle(Ink.primary(phase))
                .underline(buttonShapes, color: Ink.primary(phase))
                .lineLimit(dynamicType.isAccessibilitySize ? 2 : 1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Grid.margin)
                .frame(maxWidth: .infinity, minHeight: Self.height(dynamicType: dynamicType))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressedFadeStyle())
    }
}

#Preview("Night action") {
    VStack(spacing: Grid.layerChannel) {
        NightAction(title: "Keep playing on speaker") {}
        NightAction(title: "+15 min") {}
    }
    .frame(maxHeight: .infinity, alignment: .bottom)
    .environment(\.nightPhase, .night)
    .grafitoRoot()
}
