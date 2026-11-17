import SwiftUI

/// Grafito grid (03 §3.5): a 4 pt unit, a 20 pt side margin, hairlines of one
/// device pixel and no corner radius on anything the app draws itself.
enum Grid {
    static let unit: CGFloat = 4
    /// Spacing steps of the grid. Nothing else is a valid distance.
    static let steps: [CGFloat] = [4, 8, 12, 16, 20, 24, 32, 56, 64, 80]

    /// Side margin: the column is 353 pt on a 393 pt screen.
    static let margin: CGFloat = 20
    /// Air inside a group.
    static let inner: CGFloat = 16
    /// Air between groups, twice the inner air.
    static let group: CGFloat = 32

    /// Plain list row.
    static let row: CGFloat = 56
    /// Row with a subtitle.
    static let rowSubtitle: CGFloat = 72
    /// Layer row: the touch area of the control.
    static let layerTouch: CGFloat = 56
    /// Layer row: dead channel under the touch area, where no gesture starts.
    static let layerChannel: CGFloat = 24
    /// Pitch of a layer row, touch area plus channel.
    static let layerRow: CGFloat = 80

    /// Band the Horizon lives in.
    static let horizonBand: CGFloat = 24
    /// The Horizon sits at a third of the full screen height.
    static let horizonFraction: CGFloat = 0.333

    /// Smallest touch target.
    static let target: CGFloat = 44
    /// Touch target of the Disc, of the primary action and of night actions.
    static let largeTarget: CGFloat = 64

    /// The accent only ever draws lines of 1.5 pt or more.
    static let accentLine: CGFloat = 1.5

    /// Own shapes have square corners. The only round thing is the Disc.
    static let radius: CGFloat = 0
    /// The Disc: a 44 pt circle inside a 64 pt target.
    static let disc: CGFloat = 44
    /// Glyph of the Disc.
    static let discGlyph: CGFloat = 22

    /// The one long-press duration of the app.
    static let longPress: TimeInterval = 0.6
    /// A thumb that settles does not "move": slop of the long press.
    static let longPressSlop: CGFloat = 10

    /// Least height of an editorial row by text size (04 §5d): 56, or 72
    /// with a subtitle; 64 and 80 from xL to xxxL; 88 and 104 at the
    /// accessibility sizes. Taller text pushes the row further.
    static func row(subtitle: Bool, dynamicType: DynamicTypeSize) -> CGFloat {
        let base = subtitle ? rowSubtitle : row
        if dynamicType.isAccessibilitySize { return base + 32 }
        return dynamicType > .large ? base + 8 : base
    }

    /// Least height of the primary action (04 §5d): 64, and 80 from AX1.
    static func primaryAction(dynamicType: DynamicTypeSize) -> CGFloat {
        dynamicType.isAccessibilitySize ? 80 : largeTarget
    }

    /// Least height of a text action (04 §5d): 44, 56 from xL to AX2 and 64
    /// from AX3. On the night page it is never under 64.
    static func textAction(dynamicType: DynamicTypeSize, night: Bool) -> CGFloat {
        let height: CGFloat
        if dynamicType >= .accessibility3 {
            height = 64
        } else {
            height = dynamicType > .large ? 56 : target
        }
        return night ? max(height, largeTarget) : height
    }

    /// How far the system toggle draws past its own frame on the trailing
    /// side: 2 pt on iOS 26 (measured: 63 pt drawn, ending 2 pt beyond the
    /// frame), nothing before. Taken back so its edge is the column's.
    static var toggleOverhang: CGFloat {
        if #available(iOS 26, *) { return 2 }
        return 0
    }

    /// Hairline thickness: one device pixel, 0.5 pt at 2x.
    static func hairline(displayScale: CGFloat) -> CGFloat {
        1 / max(1, displayScale)
    }

    /// A thickness rounded up to whole device pixels. A line of the accent
    /// may never be thinner than 1.5 pt, and 1.5 pt is four and a half
    /// pixels at 3x: left alone it is drawn as four or five depending on
    /// where it falls. Rounded up it is always five (three at 2x).
    static func pixelCeil(_ thickness: CGFloat, displayScale: CGFloat) -> CGFloat {
        let scale = max(1, displayScale)
        return (thickness * scale - 0.001).rounded(.up) / scale
    }

    /// Vertical position of the Horizon on a screen of `fullHeight` points,
    /// measured over the whole screen and snapped to the grid: 284 on 852.
    static func horizonY(fullHeight: CGFloat) -> CGFloat {
        (fullHeight * horizonFraction / unit).rounded() * unit
    }
}

/// The only separator: one device pixel high, from margin to margin.
/// `trazo` on black, `trazo-hoja` on a sheet. There is no vertical variant.
struct Hairline: View {
    /// Overrides the surface colour (the accent rules of the purchase action).
    var color: Color?
    /// Overrides the one-pixel thickness.
    var thickness: CGFloat?

    @Environment(\.displayScale) private var displayScale
    @Environment(\.inkSurface) private var surface

    var body: some View {
        Rectangle()
            .fill(color ?? Ink.rule(on: surface))
            .frame(height: thickness.map { Grid.pixelCeil($0, displayScale: displayScale) }
                ?? Grid.hairline(displayScale: displayScale))
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

#Preview("Hairline") {
    VStack(spacing: Grid.group) {
        Hairline()
        Hairline()
            .padding(.vertical, Grid.inner)
            .background(Ink.sheet)
            .environment(\.inkSurface, .sheet)
    }
    .padding(.horizontal, Grid.margin)
    .frame(maxHeight: .infinity)
    .grafitoRoot()
}
