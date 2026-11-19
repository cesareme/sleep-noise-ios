import CoreGraphics
import Foundation

/// What of the page's text enters the painted window, from the top of the
/// window in points. Under text the veil is 90 %: the paint never carries a
/// glyph (lenguaje §5). Nil means that text stays outside.
struct PaintReserves: Equatable {
    /// The top of the layer rows under the Horizon.
    var rowsTop: CGFloat?
    /// The bottom of the state line above the Horizon.
    var textBottom: CGFloat?

    static let none = PaintReserves()
}

/// The black veil over the painted window (exploration 12 §7 fase 2,
/// camino-lienzo.md): 35 % at the Horizon and 75 % at the edges of the
/// window, straight in between, so the paint goes out towards the text
/// without a line of cut and no pixel of it passes Y 0.28 (lenguaje §5;
/// `PaintEngineTests` measures the four house windows with this very
/// function); 80 % over the reserve strip of 24 pt around the Horizon,
/// where no light tint is painted either; 96 % under any text that enters
/// the window: the design said 90, and 90 left `texto2` at 3.6:1 over the
/// light tints of the band's feather, under AA (measured in the captures);
/// 96 keeps it at 4.8:1 over the lightest tint of the house palettes.
/// Pure, so the page draws exactly what the tests measure.
enum PaintVeil {
    static let centre: Double = 0.35
    static let edge: Double = 0.75
    static let reserve: Double = 0.80
    static let text: Double = 0.96

    /// The veil at a height of the window.
    static func opacity(atY y: CGFloat, geometry: PaintWindowGeometry, reserves: PaintReserves = .none) -> Double {
        if let top = reserves.rowsTop, y >= top { return text }
        if let bottom = reserves.textBottom, y < bottom { return text }
        let fromHorizon = abs(y - geometry.horizonY)
        if fromHorizon <= PaintWindowGeometry.reserve / 2 { return reserve }
        let distance = Double(min(1, fromHorizon / (geometry.height / 2)))
        return centre + (edge - centre) * distance
    }

    /// Where the veil jumps: the edges of the reserve strip and of the text.
    static func breaks(geometry: PaintWindowGeometry, reserves: PaintReserves) -> [CGFloat] {
        var breaks = [
            geometry.horizonY - PaintWindowGeometry.reserve / 2,
            geometry.horizonY + PaintWindowGeometry.reserve / 2,
        ]
        if let top = reserves.rowsTop { breaks.append(top) }
        if let bottom = reserves.textBottom { breaks.append(bottom) }
        return breaks.filter { $0 > 0 && $0 < geometry.height }.sorted()
    }

    /// The veil as the stops of one vertical gradient over the window:
    /// sampled every `step` points, with a double stop at every break so
    /// the strip and the text keep their hard edge. Locations 0 to 1.
    static func stops(
        geometry: PaintWindowGeometry, reserves: PaintReserves = .none, step: CGFloat = 4
    ) -> [(location: CGFloat, opacity: Double)] {
        let height = geometry.height
        guard height > 0 else { return [] }
        var ys: [CGFloat] = Array(stride(from: 0, through: height, by: step))
        if ys.last != height { ys.append(height) }
        let breaks = breaks(geometry: geometry, reserves: reserves)
        var stops: [(location: CGFloat, opacity: Double)] = []
        for y in ys {
            // Breaks between the previous sample and this one, both sides.
            for b in breaks where b > (stops.last.map { $0.location * height } ?? -1) && b <= y {
                stops.append((b / height, opacity(atY: b - 0.001, geometry: geometry, reserves: reserves)))
                stops.append((b / height, opacity(atY: b + 0.001, geometry: geometry, reserves: reserves)))
            }
            if let last = stops.last, last.location * height == y { continue }
            stops.append((y / height, opacity(atY: y, geometry: geometry, reserves: reserves)))
        }
        return stops
    }
}
