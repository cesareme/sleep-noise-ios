import SwiftUI

/// The bottom bar (03 §4.11): "Mixes", the Disc and "Night".
///
/// Always there, on the page and in the Layers and Mixes sheets: nothing
/// blocks the sound. Words in plain ink and the Disc in the middle; no tint,
/// no icon outside the Disc. "Night" always works: with the mix at rest it
/// starts the sound and covers the page in the same gesture.
struct PageBar: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var timer: SleepTimerController
    /// Nil on the Mixes sheet itself: its place stays empty there, because
    /// the word would do nothing and the title already says it.
    var onMixes: (() -> Void)?
    var onNight: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.inkSurface) private var surface
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes

    /// Height of the system's own bottom bar, which this one stands in for.
    static let height: CGFloat = 49

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                if let onMixes {
                    mixes(onMixes)
                }
                Spacer(minLength: Grid.largeTarget + Grid.inner * 2)
                night
            }
            .padding(.horizontal, Grid.margin)
            // The final fade pulses the glyph by day; at night nothing moves
            // but the sound.
            PlayDisc(isPlaying: model.isPlaying, isFading: timer.isFading && !phase.isNight) {
                model.togglePlayback()
            }
        }
        // The Disc's 64 pt target is taller than the bar and reaches past
        // it on both sides; the bar itself keeps the system's height.
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .background((surface == .sheet ? Ink.sheet : Ink.background).ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Hairline() }
    }

    private func mixes(_ action: @escaping () -> Void) -> some View {
        word("barra.mezclas", glyph: "square.stack", alignment: .leading, action: action)
            .accessibilityLabel(Text("barra.mezclas"))
            .accessibilityIdentifier("openMixes")
    }

    private var night: some View {
        word("barra.noche", glyph: "circle.lefthalf.filled", alignment: .trailing, action: onNight)
            .accessibilityLabel(Text("barra.noche.ax"))
            .accessibilityIdentifier("openNight")
    }

    private func word(
        _ key: LocalizedStringKey,
        glyph: String,
        alignment: Alignment,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if dynamicType >= .accessibility4 {
                    // The word no longer fits beside the Disc.
                    Image(systemName: glyph)
                        .font(.system(size: 28, weight: .medium))
                } else {
                    Text(key)
                        .step(.bar)
                        .underline(buttonShapes, color: Ink.primary(phase))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
            }
            .foregroundStyle(Ink.primary(phase))
            .frame(minWidth: Grid.target, minHeight: Grid.target, alignment: alignment)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressedFadeStyle())
    }
}
