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
    /// High and low water are marked. Small Hours draws no marks: the
    /// travel of the line already shows the band.
    var showsMarks = true
    /// 2 pt in the tide sheet; 1.5 pt in Small Hours.
    var lineThickness = TideLine.thickness
    /// Height of the band: 120 pt, or 96 on the page of a short screen.
    var band = TideLine.band
    /// How far inside the band the line turns: 0 in the sheet, where it
    /// travels from edge to edge. On the page low water is the Horizon,
    /// which sits inside the band, and the marks stay on its edges.
    var highWaterInset: CGFloat = 0
    var lowWaterInset: CGFloat = 0
    /// The ink of the line when it is not the sheet's: on the page the
    /// water line is the Horizon, and carries the accent while it sounds.
    var ink: Color?
    /// What the line of water carries behind it while the page is painted
    /// (lenguaje §5: "the reserve goes with it"): nil over black.
    var halo: Halo?

    /// The dry backing of the line of water over the paint: a strip of
    /// black at `reserveOpacity`, `reserve` points tall and centred on the
    /// line, and a halo of pure black `thickness` points each side of it.
    /// Drawn with the line, so it moves with the line, pixel for pixel.
    /// The strip runs `bleed` points past each end of the line: the paint
    /// is full bleed, so the strip is too, and does not read as a bar.
    struct Halo: Equatable {
        var thickness: CGFloat
        var reserve: CGFloat
        var reserveOpacity: Double
        var bleed: CGFloat = 0
    }

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

    private var lineInk: Color {
        if let ink { return ink }
        return isUnderFinger ? Ink.accent(phase) : Ink.primary(phase)
    }

    /// Where the top of the line sits for a level, with this line's band
    /// and insets.
    /// On a whole device pixel: the breath is continuous, and a line of
    /// 2 pt set between two rows of pixels is drawn with a ragged edge. At
    /// 30 frames a second it travels a few pixels a frame, so the snap is
    /// not seen as steps.
    private func top(_ level: Float) -> CGFloat {
        Grid.pixelRound(
            highWaterInset + Self.offset(
                level: level,
                band: band - highWaterInset - lowWaterInset,
                thickness: lineThickness
            ),
            displayScale: displayScale
        )
    }

    private var isPaused: Bool { mode != .moving || scenePhase != .active }

    var body: some View {
        ZStack(alignment: .top) {
            if showsMarks {
                marks
                    .opacity(mode == .off ? 0 : 1)
            }
            switch mode {
            case .off:
                Hairline()
                    .padding(.bottom, lowWaterInset)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            case .paused:
                water
                    .opacity(Self.pausedOpacity)
                    .padding(.bottom, lowWaterInset)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            case .moving:
                TimelineView(.animation(minimumInterval: reduceMotion ? 0.25 : 1.0 / 30, paused: isPaused)) { context in
                    let level = level(context.date)
                    if reduceMotion {
                        water
                            .opacity(Self.reducedOpacity(level: level))
                            .offset(y: top(0.5))
                    } else {
                        water.offset(y: top(level))
                    }
                }
            }
        }
        .frame(height: band, alignment: .top)
        .animation(Motion.controlCurve, value: isUnderFinger)
        .animation(Motion.startCurve, value: mode)
    }

    private var water: some View {
        let thickness = Grid.pixelCeil(lineThickness, displayScale: displayScale)
        return Rectangle()
            .fill(lineInk)
            .frame(height: thickness)
            .frame(maxWidth: .infinity)
            .background {
                if let halo {
                    // Centred on the line and taller than it: the strip
                    // first, the halo over it, both under the water.
                    Rectangle()
                        .fill(.black.opacity(halo.reserveOpacity))
                        .frame(height: halo.reserve)
                        .padding(.horizontal, -halo.bleed)
                    Rectangle()
                        .fill(.black)
                        .frame(height: thickness + halo.thickness * 2)
                }
            }
    }

    /// High and low water: two short hairlines at the trailing edge. They
    /// are there only while the line has a course.
    private var marks: some View {
        VStack(spacing: 0) {
            mark
            Spacer(minLength: 0)
            mark
        }
        .frame(height: band)
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
