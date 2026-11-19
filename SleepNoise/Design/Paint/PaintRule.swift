import CoreGraphics
import Foundation
import SwiftUI

/// The painted rule of a layer row in Layers (camino-contenido.md, frame
/// 2): 4 pt wide in the left margin, the height of the row's touch area,
/// the darkest tint of the texture as its ground and nine dabs of the next
/// tint at 90 %, placed by the seed of the texture and never moving. Live
/// at 100 % when the layer sounds, dry at 42 % at zero, by level in
/// between. The name does not move: the rule lives in the margin.
///
/// Decorative: VoiceOver never hears it, no gesture starts on it, and it
/// is absent in the same conditions as the painted window.
enum PaintRule {
    static let width: CGFloat = 4
    /// From the edge of the screen: the mock-up draws it 12 pt left of the
    /// text, inside the 20 pt margin.
    static let leading: CGFloat = 8
    /// The rule of a layer at zero.
    static let dryOpacity: Double = 0.42
    /// Dabs on a row of 56 pt; taller rows get more, so the grain is the same.
    static let dabsPerRow: Double = 9
    static let rowReference: CGFloat = 56

    struct Dab: Equatable {
        /// From the top of the rule, as a share of its height.
        var y: Double
        /// In points, 2 to 7.
        var height: Double
    }

    /// 0.42 at zero, 1 at full level.
    static func opacity(level: Float) -> Double {
        let clamped = Double(min(1, max(0, level)))
        return dryOpacity + (1 - dryOpacity) * clamped
    }

    /// The seed of a texture's rule: its own, apart from the window's.
    static func seed(_ sound: SoundID) -> UInt32 {
        Pigment.fnv1a("rule." + sound.rawValue)
    }

    /// The dabs of a rule of `height` points, in the order of the mock-up's
    /// draws: nine per 56 pt, each at a random height with a random size.
    static func dabs(seed: UInt32, height: CGFloat) -> [Dab] {
        var R = Pigment.LCG(seed: seed)
        let count = max(1, Int((dabsPerRow * Double(height) / Double(rowReference)).rounded()))
        return (0..<count).map { _ in
            let y = R.next()
            let h = 2 + R.next() * 5
            return Dab(y: y, height: h)
        }
    }
}

extension Pigment.Tint {
    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: 1) }
}

/// The drawing of a rule: shapes in the two dark tints, no raster.
struct PaintRuleMark: View {
    var motif: Pigment.Motif
    var seed: UInt32
    var level: Float

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        let palette = motif.palette
        let ground = palette[palette.count - 1]
        let dab = palette[palette.count - 2]
        GeometryReader { geometry in
            let height = geometry.size.height
            ZStack(alignment: .topLeading) {
                Rectangle().fill(ground.color)
                ForEach(Array(PaintRule.dabs(seed: seed, height: height).enumerated()), id: \.offset) { _, d in
                    Rectangle()
                        .fill(dab.color.opacity(0.9))
                        .frame(height: Grid.pixelCeil(CGFloat(d.height), displayScale: displayScale))
                        .offset(y: Grid.pixelRound(CGFloat(d.y) * height, displayScale: displayScale))
                }
            }
            .clipped()
        }
        .frame(width: PaintRule.width)
        .opacity(PaintRule.opacity(level: level))
        .animation(Motion.contentCurve, value: level)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
