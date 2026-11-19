import CoreGraphics
import Foundation

/// The painted pieces of the house (exploration 12 §6.1, the minimal
/// variant): short ribbon strokes of high pigment, generated as PNG at build
/// time by `scripts/paint/generate.sh` and never drawn at runtime. Own work
/// made by code, from a palette per texture and a fixed seed per mix.
///
/// One piece per house mix, in the asset catalog under `Paint/`. Saved
/// mixes and Settings carry none: the house paints, what is yours is yours.
/// Whether a band shows at all is `PaintPolicy`.
enum HousePaint {
    /// The band of a house row in Mixes: 64 pt wide, bled off the left
    /// edge, as tall as a row whose recipe takes two lines at the Large
    /// text size. A shorter row clips it; larger text scales it.
    static let bandSize = CGSize(width: 64, height: 92)

    /// The black veil over the band, so the paint stays paper under the
    /// text beside it.
    static let veil: Double = 0.12

    /// The text of a painted row starts this far from the band (mock-up,
    /// frame 2 of the content path): 84 pt from the edge, not 20.
    static let textGap: CGFloat = 20

    /// Where the text of a painted row starts.
    static var textLeading: CGFloat { bandSize.width + textGap }

    /// The name of the band of a mix in the asset catalog.
    static func bandName(_ mix: HouseMix) -> String {
        "Paint/HouseMix-\(mix.rawValue)"
    }
}
