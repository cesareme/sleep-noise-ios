import SwiftUI

/// Slow wash behind the mixer. While audio is running and the bedtime cover
/// is not up, the accent glow drifts on a ten-second cycle. Reduce Motion
/// holds a still frame. The timeline pauses when nothing is playing so an
/// overnight session does not redraw a hidden background.
struct NightBackground: View {
    var isPlaying: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0, paused: !isPlaying || reduceMotion)) { context in
            let breath = glow(at: context.date)
            ZStack {
                DesignTokens.Colors.background
                LinearGradient(
                    colors: [
                        DesignTokens.Colors.backgroundRaised,
                        DesignTokens.Colors.background,
                        DesignTokens.Colors.accent.opacity(0.05 + 0.12 * breath)
                    ],
                    startPoint: UnitPoint(x: 0.2 + 0.15 * breath, y: 0),
                    endPoint: UnitPoint(x: 0.8 - 0.1 * breath, y: 1)
                )
                RadialGradient(
                    colors: [
                        DesignTokens.Colors.accent.opacity(0.05 + 0.16 * breath),
                        .clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0.18 + 0.06 * breath),
                    startRadius: 8,
                    endRadius: 380 + 80 * breath
                )
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func glow(at date: Date) -> Double {
        guard isPlaying, !reduceMotion else { return 0.35 }
        let cycle = date.timeIntervalSinceReferenceDate / 10
        return 0.5 + 0.5 * sin(cycle * 2 * Double.pi)
    }
}
