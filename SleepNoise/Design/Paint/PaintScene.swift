import CoreGraphics
import Foundation

/// Where the paint sits on the day page (exploration 12 §4.2 and §7 fase 2,
/// docs/design/color/camino-lienzo.md): a window of 240 pt centred on the
/// Horizon, the band of the tide inside it where the paint is dense and
/// carries its light tints, and a reserve strip of 24 pt under the accent.
/// All in points of the window, origin top left.
struct PaintWindowGeometry: Hashable {
    /// The height of the window: 240 pt (120 at the accessibility sizes,
    /// set by the page).
    static let height: CGFloat = 240
    /// From the first accessibility size: 120 pt, so the rows under the
    /// Horizon keep their place on the screen (camino-lienzo.md).
    static let accessibilityHeight: CGFloat = 120
    /// The band of the tide (`TideLine.band`): full density and all four
    /// tints inside, the two dark ones outside.
    static let bandHeight: CGFloat = 120
    /// Over this distance from the band the density falls to a quarter.
    static let falloff: CGFloat = 120
    /// The least density, at the edges of the window.
    static let edgeDensity: Double = 0.25
    /// The reserve strip under the Horizon: 24 pt, no light tints.
    static let reserve: CGFloat = 24
    /// Ribbons that touch the band, within this margin, are painted again
    /// in all four tints, feathered over `feather` points.
    static let bandMargin: CGFloat = 8
    static let feather: CGFloat = 26

    var width: CGFloat
    var height: CGFloat
    /// The Horizon, from the top of the window.
    var horizonY: CGFloat
    /// The band of the tide, from the top of the window. On the page its
    /// bottom edge sits at the bottom of the Horizon band.
    var bandTop: CGFloat
    var bandBottom: CGFloat

    /// The window of the page for a screen `width` points wide: the
    /// Horizon at the middle, the band ending 12 pt under it.
    init(width: CGFloat, height: CGFloat = PaintWindowGeometry.height) {
        self.width = width
        self.height = height
        horizonY = height / 2
        bandBottom = horizonY + Grid.horizonBand / 2
        bandTop = bandBottom - Self.bandHeight
    }

    var size: CGSize { CGSize(width: width, height: height) }

    /// How much of the paint is kept at a height: all of it in the band,
    /// a quarter 120 pt away from it.
    func density(atY y: CGFloat) -> Double {
        let d: CGFloat = y < bandTop ? bandTop - y : (y > bandBottom ? y - bandBottom : 0)
        return max(Self.edgeDensity, 1 - 0.75 * Double(d / Self.falloff))
    }

    /// Whether a stroke touches the band, with its margin.
    func touchesBand(_ points: [Pigment.P]) -> Bool {
        let top = Double(bandTop - Self.bandMargin), bottom = Double(bandBottom + Self.bandMargin)
        return points.contains { $0.y >= top && $0.y <= bottom }
    }
}

/// One layer of a scene: a texture with its level, as the mix has it.
struct PaintLayer: Hashable {
    var sound: SoundID
    var level: Float

    var motif: Pigment.Motif { sound.motif }
}

extension SoundID {
    /// The motif of a texture (lenguaje §2, one per texture).
    var motif: Pigment.Motif {
        switch self {
        case .white: return .white
        case .pink: return .pink
        case .brown: return .brown
        case .rain: return .rain
        case .fan: return .fan
        case .ocean: return .ocean
        case .thunder: return .thunder
        case .campfire: return .campfire
        case .brook: return .brook
        case .wind: return .wind
        case .cabin: return .cabin
        }
    }
}

/// What the window paints for a mix: the active layers with their levels,
/// the seed of the day and the geometry. Pure data; two equal scenes paint
/// the same pixels, so the store knows when nothing has to be drawn again.
///
/// The seed is per (mix, day): today's paint is not yesterday's, and
/// tonight's does not change however often the page is drawn. It is never
/// reseeded in a session (lenguaje §2).
struct PaintScene: Hashable {
    var layers: [PaintLayer]
    var seed: UInt32
    var geometry: PaintWindowGeometry

    /// The layers that sound, loudest first. Nil when nothing sounds: there
    /// is nothing to paint.
    init?(levels: [SoundID: Float], seed: UInt32, geometry: PaintWindowGeometry) {
        let active = SoundID.allCases.compactMap { sound -> PaintLayer? in
            guard let level = levels[sound], level > 0 else { return nil }
            return PaintLayer(sound: sound, level: level)
        }
        guard !active.isEmpty else { return nil }
        layers = active.sorted { $0.level > $1.level || ($0.level == $1.level && $0.sound.rawValue < $1.sound.rawValue) }
        self.seed = seed
        self.geometry = geometry
    }

    /// A house mix, as it is loaded: what sounds (trimmed without full access).
    init?(mix: HouseMix, hasFullAccess: Bool = true, on day: Date, calendar: Calendar = .current, geometry: PaintWindowGeometry) {
        self.init(
            levels: mix.load(hasFullAccess: hasFullAccess).audibleLevels,
            seed: PaintScene.seed(identity: mix.rawValue, day: day, calendar: calendar),
            geometry: geometry
        )
    }

    /// A saved mix, as it is loaded.
    init?(mix: SavedMix, hasFullAccess: Bool = true, on day: Date, calendar: Calendar = .current, geometry: PaintWindowGeometry) {
        self.init(
            levels: MixLoad(levels: mix.levelsBySound, hasFullAccess: hasFullAccess).audibleLevels,
            seed: PaintScene.seed(identity: mix.id.uuidString, day: day, calendar: calendar),
            geometry: geometry
        )
    }

    /// The loudest layer: its palette grounds the band.
    var dominant: PaintLayer { layers[0] }

    /// The direction the window slides with the tide: the dominant motif's.
    var direction: Double { dominant.motif.direction }

    /// The seed of a mix for a day, as the mock-up makes it: the hash of
    /// what identifies the mix, folded with the year and the day of the
    /// year. The identity of a house mix is its id (not its name, which has
    /// two languages), of a saved mix its UUID, of an unnamed mix the list
    /// of its sounds (`identity(ofSounds:)`).
    static func seed(identity: String, day: Date, calendar: Calendar = .current) -> UInt32 {
        let year = calendar.component(.year, from: day)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: day) ?? 1
        return Pigment.fnv1a(identity) ^ UInt32(truncatingIfNeeded: year * 1000 + dayOfYear)
    }

    /// The identity of a mix nobody named: the sounds above zero, in the
    /// order of `SoundID`. Changing a level keeps the paint; adding or
    /// taking a layer changes it.
    static func identity(ofSounds levels: [SoundID: Float]) -> String {
        SoundID.allCases.filter { (levels[$0] ?? 0) > 0 }.map(\.rawValue).joined(separator: "+")
    }
}

/// A scene worked out into strokes: the ground, the dry ribbons and the
/// live ones (the 18 % that breathe with the sound, chosen by the seed, the
/// same for the whole session). Deterministic: one scene, one composition.
/// This is the port of `paintMix` in camino-lienzo.html, with the strokes
/// born inside the window instead of over the whole page.
struct PaintComposition {
    struct Stroke: Equatable {
        var motif: Pigment.Motif
        var ribbon: Pigment.Ribbon
        var isLive: Bool
        /// The one crack of the thunder: band only, never breathes.
        var isCrack: Bool
    }

    /// The share of ribbons that breathe (lenguaje §3).
    static let liveShare = 0.18
    /// Strokes are born this far outside the window too, so the edge is
    /// not a line of stroke heads.
    static let margin: Double = 20

    let scene: PaintScene
    var strokes: [Stroke] = []
    /// The LCG as the composition leaves it: the grain of the ground is
    /// drawn by the rasterizer from the same sequence, before the strokes,
    /// so the rasterizer gets the generator at the point the grain needs.
    private(set) var grainGenerator: Pigment.LCG

    var dryStrokes: [Stroke] { strokes.filter { !$0.isLive } }
    var liveStrokes: [Stroke] { strokes.filter(\.isLive) }

    init(_ scene: PaintScene) {
        self.scene = scene
        var R = Pigment.LCG(seed: scene.seed)
        grainGenerator = R
        // The grain of the ground is drawn first in the mock-up; its draws
        // come before the strokes'. The rasterizer replays them from
        // `grainGenerator`; here they are skipped at the same count.
        let g = scene.geometry
        let W = Double(g.width), H = Double(g.height)
        Pigment.times(W * H / 40) { for _ in 0..<5 { _ = R.next() } }

        let total = Double(scene.layers.reduce(0) { $0 + $1.level })
        guard total > 0 else { return }
        // Fields first (the ground), then beds (the figure); within, by
        // ascending level, so the loudest is painted last and on top.
        let order = scene.layers.sorted { a, b in
            if a.motif.isField != b.motif.isField { return a.motif.isField }
            return a.level < b.level
        }
        for layer in order {
            let motif = layer.motif
            let share = Double(layer.level) / total
            let n = ((W * H / motif.density) * share * 1.15).rounded()
            let maker = PaintStrokeMaker(motif: motif, geometry: g, R: &R)
            var i = 0.0
            while i < n {
                i += 1
                let made = maker.make(&R)
                let k = made.tintIndex ?? Pigment.pick(&R, motif.weights)
                let y = made.points[0].y
                if y < -Self.margin || y > H + Self.margin { continue }
                if R.next() > g.density(atY: CGFloat(y)) { continue }
                let live = !made.isBlack && R.next() < Self.liveShare
                strokes.append(Stroke(
                    motif: motif,
                    ribbon: Pigment.Ribbon(
                        points: made.points, width: made.width, alpha: made.alpha,
                        tintIndex: k, taper: made.taper, isBlack: made.isBlack
                    ),
                    isLive: live,
                    isCrack: false
                ))
            }
            if motif == .thunder {
                // One crack, fixed by the seed, five bends, in the band.
                var x = W * 0.35 + R.next() * W * 0.3
                var y = Double(g.bandTop) - 6
                var pts = [Pigment.P(x: x, y: y)]
                for _ in 0..<5 {
                    x += (R.next() - 0.5) * 34
                    y += Double(g.bandBottom - g.bandTop) * 0.22 + R.next() * 8
                    pts.append(Pigment.P(x: x, y: y))
                }
                strokes.append(Stroke(
                    motif: .thunder,
                    ribbon: Pigment.Ribbon(points: pts, width: 3.5, alpha: 0.95, tintIndex: 1, taper: false, isBlack: false),
                    isLive: false,
                    isCrack: true
                ))
            }
        }
    }
}

/// One ribbon at a time for a motif, with the random draws in the order of
/// the mock-up's `makeGen`. Strokes are born over the window plus its
/// margin; the campfire's tongues under the band, rising towards it.
struct PaintStrokeMaker {
    struct Made {
        var points: [Pigment.P]
        var width: Double
        var alpha: Double
        var tintIndex: Int?
        var taper: Bool
        var isBlack: Bool
    }

    let motif: Pigment.Motif
    let W: Double
    let H: Double
    let bandTop: Double
    let bandBottom: Double
    private let field: (Double, Double) -> Double
    private let fanCentre: Pigment.P

    init(motif: Pigment.Motif, geometry: PaintWindowGeometry, R: inout Pigment.LCG) {
        self.motif = motif
        W = Double(geometry.width)
        H = Double(geometry.height)
        bandTop = Double(geometry.bandTop)
        bandBottom = Double(geometry.bandBottom)
        // The mock-up makes two noise lattices per layer, whatever the
        // motif, so the draws stay in step.
        let f = Pigment.ValueNoise(&R), g = Pigment.ValueNoise(&R)
        field = { x, y in f(x, y) + 0.5 * g(x * 2, y * 2) }
        fanCentre = Pigment.P(x: W * 1.25, y: H * 0.95)
    }

    /// A y over the window and its margins.
    private func spanY(_ R: inout Pigment.LCG) -> Double {
        -PaintComposition.margin + R.next() * (H + 2 * PaintComposition.margin)
    }

    func make(_ R: inout Pigment.LCG) -> Made {
        switch motif {
        case .white:
            let x = R.next() * W, y = spanY(&R), ang = R.next() * 6.28, len = 6 + R.next() * 4
            let pts = Pigment.strokeNoise(x, y, ang, len, 3, &R, 0.4)
            return Made(points: pts, width: 3 + R.next(), alpha: 0.85, tintIndex: nil, taper: false, isBlack: false)
        case .pink:
            let x = R.next() * W, y = spanY(&R), ang = (R.next() - 0.5) * 0.7, len = 10 + R.next() * 8
            let pts = Pigment.strokeNoise(x, y, ang, len, 4, &R, 0.5)
            return Made(points: pts, width: 4 + R.next() * 2, alpha: 0.9, tintIndex: nil, taper: false, isBlack: false)
        case .brown:
            let x = R.next() * W - 10, y = spanY(&R), ang = (R.next() - 0.5) * 0.5, len = 22 + R.next() * 18
            let pts = Pigment.strokeNoise(x, y, ang, len, 6, &R, 0.3)
            return Made(points: pts, width: 7 + R.next() * 3, alpha: 0.9, tintIndex: nil, taper: false, isBlack: false)
        case .rain:
            let x = R.next() * (W + 40) - 20, y = spanY(&R)
            let a = 72 * Double.pi / 180 + (R.next() - 0.5) * 0.2, len = 18 + R.next() * 16
            let pts = Pigment.strokeNoise(x, y, a, len, 6, &R, 0.25)
            return Made(points: pts, width: 2 + R.next(), alpha: 0.85, tintIndex: nil, taper: false, isBlack: false)
        case .fan:
            let r = 60 + R.next() * (W * 1.4), a0 = Double.pi * 0.95 + R.next() * Double.pi * 0.55, da = (24 + R.next() * 24) / r
            var pts: [Pigment.P] = []
            for s in 0...8 {
                let a = a0 + da * Double(s) / 8 + (R.next() - 0.5) * 0.015
                pts.append(Pigment.P(x: fanCentre.x + cos(a) * r, y: fanCentre.y + sin(a) * r))
            }
            return Made(points: pts, width: 3 + R.next() * 2, alpha: 0.85, tintIndex: nil, taper: false, isBlack: false)
        case .ocean:
            let x = R.next() * W, y = spanY(&R), len = 18 + R.next() * 18
            let pts = Pigment.strokeFlow(x, y, len, 8, field, 70, 0.12)
            return Made(points: pts, width: 5 + R.next() * 3, alpha: 0.9, tintIndex: nil, taper: false, isBlack: false)
        case .thunder:
            let x = R.next() * W - 10, y = spanY(&R), ang = (R.next() - 0.5) * 0.3, len = 16 + R.next() * 14
            let pts = Pigment.strokeNoise(x, y, ang, len, 5, &R, 0.3)
            return Made(points: pts, width: 5 + R.next() * 2, alpha: 0.9, tintIndex: nil, taper: false, isBlack: false)
        case .campfire:
            // Tongues wide at the base that narrow as they rise, born under
            // the band and rising towards it; light flame only in a central
            // core of 40 % of the width, ember red at the edges, burnt wood
            // outside; 30 % of them black.
            let x0 = R.next() * W, y0 = bandTop + 40 + R.next() * (bandBottom - bandTop + 120)
            let d = abs(x0 - W / 2) / (W * 0.5)
            let len = (30 + R.next() * 60) * (d < 0.4 ? 1 : 0.7)
            let isBlack = R.next() < 0.30
            let k: Int
            if d < 0.4 { k = R.next() < 0.55 ? 1 : 0 } else if d < 0.7 { k = R.next() < 0.6 ? 2 : 1 } else { k = R.next() < 0.7 ? 3 : 2 }
            let pts = Pigment.strokeNoise(x0, y0, -Double.pi / 2 + (R.next() - 0.5) * 0.5, len, 8, &R, 0.45)
            let width = isBlack ? 6 + R.next() * 6 : 8 + R.next() * 6
            return Made(points: pts, width: width, alpha: 0.92, tintIndex: k, taper: true, isBlack: isBlack)
        case .brook:
            let y0 = spanY(&R), x0 = R.next() * W - 40, len = 40 + R.next() * 50, ph = R.next() * 6.28, amp = 3 + R.next() * 5
            var pts: [Pigment.P] = []
            for s in 0...10 {
                pts.append(Pigment.P(x: x0 + len * Double(s) / 10, y: y0 + sin(ph + Double(s) * 1.9) * amp))
            }
            return Made(points: pts, width: 3 + R.next() * 2, alpha: 0.9, tintIndex: nil, taper: false, isBlack: false)
        case .wind:
            let x = R.next() * W - 60, y = spanY(&R), ang = (R.next() - 0.5) * 0.35, len = 60 + R.next() * 80
            let pts = Pigment.strokeNoise(x, y, ang, len, 10, &R, 0.12)
            return Made(points: pts, width: 1.5 + R.next(), alpha: 0.8, tintIndex: nil, taper: false, isBlack: false)
        case .cabin:
            let x = R.next() * W - 80, y = spanY(&R), len = 80 + R.next() * 120
            let pts = Pigment.strokeNoise(x, y, 0, len, 8, &R, 0.05)
            return Made(points: pts, width: 6 + R.next() * 6, alpha: 0.85, tintIndex: nil, taper: false, isBlack: false)
        }
    }
}
