import SwiftUI

/// The Disc (03 §4.4): Play. The only element of the app with volume.
///
/// A 44 pt `grafito` circle with a 1 pt inner shadow, like a key, inside a
/// 64 pt touch target; `play.fill` or `pause.fill` in plain ink. It never
/// carries colour and it is never disabled: nothing blocks the sound.
///
/// Magic Tap is not declared here: the root of the page declares it so it
/// works from any focus.
struct PlayDisc: View {
    var isPlaying: Bool
    /// The final fade is running: the glyph pulses (not with Reduce Motion).
    var isFading = false
    var action: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var playCount = 0
    @State private var pauseCount = 0

    var body: some View {
        Button {
            if isPlaying {
                pauseCount += 1
            } else {
                playCount += 1
            }
            action()
        } label: {
            // The glyph has the fixed size of the key it is printed on.
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: Grid.discGlyph, weight: .medium))
                .foregroundStyle(Ink.primary(phase))
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.pulse, isActive: isFading && !reduceMotion)
                .frame(width: Grid.disc, height: Grid.disc)
        }
        .buttonStyle(DiscStyle())
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: playCount) { _, _ in
            MotionGate.allows(phase)
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.5), trigger: pauseCount) { _, _ in
            MotionGate.allows(phase)
        }
        .accessibilityLabel(Text(isPlaying ? "ax.accion.pausar" : "control.play"))
        .accessibilityAddTraits(.startsMediaSession)
        .accessibilityIdentifier("playButton")
    }
}

/// Relief of the Disc: `grafito` with an inner shadow of 1 pt, 2 pt while
/// pressed. No outer shadow, no gradient, no colour.
///
/// On a sheet the body is `negro` (`Ink.relief(on:)`), where a black inner
/// shadow would not show: the edge is a `trazo-hoja` line along the bottom
/// instead. With "Increase Contrast" the Disc also carries a 1 pt ring in
/// the hairline of its surface.
///
/// The 64 pt target is part of the label, so it is what the button answers
/// to: a frame put around the button from outside would only move it.
private struct DiscStyle: ButtonStyle {
    @Environment(\.inkSurface) private var surface
    @Environment(\.colorSchemeContrast) private var contrast

    func makeBody(configuration: Configuration) -> some View {
        let depth: CGFloat = configuration.isPressed ? 2 : 1
        let onSheet = surface == .sheet
        configuration.label
            .background(
                Circle().fill(
                    Ink.relief(on: surface).shadow(
                        onSheet
                            ? .inner(color: Ink.ruleSheet, radius: 0, x: 0, y: -depth)
                            : .inner(color: Ink.background.opacity(0.6), radius: depth / 2, x: 0, y: depth)
                    )
                )
            )
            .overlay {
                if contrast == .increased {
                    Circle().strokeBorder(Ink.rule(on: surface), lineWidth: 1)
                }
            }
            .frame(width: Grid.largeTarget, height: Grid.largeTarget)
            .contentShape(Circle())
            .animation(Motion.controlCurve, value: configuration.isPressed)
    }
}

#Preview("Disc") {
    HStack(spacing: Grid.group) {
        PlayDisc(isPlaying: false) {}
        PlayDisc(isPlaying: true) {}
        PlayDisc(isPlaying: true, isFading: true) {}
        PlayDisc(isPlaying: false) {}
            .environment(\.nightPhase, .nightPage)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .grafitoRoot()
}
