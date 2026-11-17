import SwiftUI

/// The water line (03 §4.3): the shape of the tide. Never a circle.
///
/// One straight horizontal line that rises and falls inside a 120 pt band,
/// between two short hairline marks for high and low water. Its height is
/// the breath the engine is rendering, read from the same anchor as the
/// audio, never a curve of its own. In a sheet it is plain ink; the accent
/// is only for the line under a finger.
///
/// Off, it is not water: a still hairline at low tide, without marks.
/// Paused, it waits at low tide at lower opacity. With Reduce Motion the
/// line stays at mid band and the breath is its opacity.
struct TideLine: View {
    enum Mode: Equatable {
        /// A still hairline at low tide.
        case off
        /// Moving with the breath.
        case moving
        /// Waiting at low tide.
        case paused
    }

    var mode: Mode
    /// Height of the water at an instant, 0 (low tide) to 1 (high tide),
    /// amplitude included.
    var level: (Date) -> Float
    /// A finger is dragging the line.
    var isUnderFinger = false

    @Environment(\.nightPhase) private var phase
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.displayScale) private var displayScale
    @Environment(\.inkSurface) private var surface
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static let band: CGFloat = 120
    static let thickness: CGFloat = 2
    static let markLength: CGFloat = 24
    static let pausedOpacity = 0.6

    /// Where the top of the line sits for a level, inside the band.
    static func offset(level: Float, band: CGFloat = TideLine.band, thickness: CGFloat = TideLine.thickness) -> CGFloat {
        let clamped = CGFloat(min(1, max(0, level)))
        return (band - thickness) * (1 - clamped)
    }

    /// Opacity of the line with Reduce Motion: the breath without travel.
    static func reducedOpacity(level: Float) -> Double {
        0.6 + 0.4 * Double(min(1, max(0, level)))
    }

    private var ink: Color {
        isUnderFinger ? Ink.accent(phase) : Ink.primary(phase)
    }

    private var isPaused: Bool { mode != .moving || scenePhase != .active }

    var body: some View {
        ZStack(alignment: .top) {
            marks
                .opacity(mode == .off ? 0 : 1)
            switch mode {
            case .off:
                Hairline()
                    .frame(maxHeight: .infinity, alignment: .bottom)
            case .paused:
                water
                    .opacity(Self.pausedOpacity)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            case .moving:
                TimelineView(.animation(minimumInterval: reduceMotion ? 0.25 : 1.0 / 30, paused: isPaused)) { context in
                    let level = level(context.date)
                    if reduceMotion {
                        water
                            .opacity(Self.reducedOpacity(level: level))
                            .offset(y: Self.offset(level: 0.5))
                    } else {
                        water.offset(y: Self.offset(level: level))
                    }
                }
            }
        }
        .frame(height: Self.band, alignment: .top)
        .animation(Motion.controlCurve, value: isUnderFinger)
        .animation(Motion.startCurve, value: mode)
    }

    private var water: some View {
        Rectangle()
            .fill(ink)
            .frame(height: Self.thickness)
            .frame(maxWidth: .infinity)
    }

    /// High and low water: two short hairlines at the trailing edge. They
    /// are there only while the line has a course.
    private var marks: some View {
        VStack(spacing: 0) {
            mark
            Spacer(minLength: 0)
            mark
        }
        .frame(height: Self.band)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var mark: some View {
        Rectangle()
            .fill(Ink.text3)
            .frame(width: Self.markLength, height: Grid.hairline(displayScale: displayScale))
    }
}

#Preview("Tide line") {
    VStack(spacing: Grid.group) {
        TideLine(mode: .off, level: { _ in 0 })
        TideLine(mode: .moving, level: { date in
            BreathCurve.value(
                secondsSinceStart: date.timeIntervalSinceReferenceDate,
                parameters: .guided(breathsPerMinute: 6)
            )
        })
        TideLine(mode: .paused, level: { _ in 0 })
    }
    .padding(.horizontal, Grid.margin)
    .frame(maxHeight: .infinity)
    .background(Ink.sheet)
    .environment(\.inkSurface, .sheet)
    .preferredColorScheme(.dark)
}
