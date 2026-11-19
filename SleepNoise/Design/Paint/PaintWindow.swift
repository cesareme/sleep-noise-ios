import SwiftUI

/// What of the page the paint needs to know where it is: the Horizon, the
/// rows under it and the text above it, as anchors the page's background
/// resolves (`PaintAnchorKey`). Several texts may be marked: the lowest
/// one sets the reserve.
struct PaintAnchors: Equatable {
    var horizon: Anchor<CGRect>?
    var rows: Anchor<CGRect>?
    var texts: [Anchor<CGRect>] = []

    enum Part {
        case horizon, rows, text
    }

    init(_ part: Part? = nil, _ anchor: Anchor<CGRect>? = nil) {
        switch part {
        case .horizon: horizon = anchor
        case .rows: rows = anchor
        case .text: texts = anchor.map { [$0] } ?? []
        case nil: break
        }
    }

    mutating func merge(_ other: PaintAnchors) {
        if let anchor = other.horizon { horizon = anchor }
        if let anchor = other.rows { rows = anchor }
        texts += other.texts
    }
}

struct PaintAnchorKey: PreferenceKey {
    static var defaultValue = PaintAnchors()

    static func reduce(value: inout PaintAnchors, nextValue: () -> PaintAnchors) {
        value.merge(nextValue())
    }
}

extension View {
    /// Marks this view as one part of what the painted window sits around.
    func paintAnchor(_ part: PaintAnchors.Part) -> some View {
        anchorPreference(key: PaintAnchorKey.self, value: .bounds) { PaintAnchors(part, $0) }
    }
}

/// The painted window of the day page (exploration 12 §4.2 and §7 fase 2;
/// camino-lienzo.md): 240 pt around the Horizon, behind everything the
/// page draws, where the mix that sounds is painted and breathes.
///
/// Two layers composed over black: the dry one, still, and the live one,
/// which changes in opacity alone with the sound the Horizon reads
/// (`PaintPulse`), never in hue, position or scale. The tide slides both
/// by whole pixels. Over them the veil (`PaintVeil`). The opacity of the
/// phase (born, dried, dimmed, fading) moves the two layers only: the
/// veil stays whole, as in the mock-up, so a dried paint is darker, never
/// lighter, under the rows. The dry halo of the Horizon, 3 pt of black
/// each side of the line, is drawn by the line itself (`SoundLine`,
/// `TideLine`), so it follows the line of water when the tide guides.
/// Outside the window the page is the black of Grafito.
///
/// The window does not decide when it exists: the page does
/// (`PaintPolicy.phase`), and when the paint is absent there is no window
/// and no raster, not a window at opacity 0. Decorative: no touch, no
/// VoiceOver.
struct PaintWindow: View {
    let store: PaintStore
    let pulse: PaintPulse
    var geometry: PaintWindowGeometry
    var reserves: PaintReserves
    /// The opacity of the paint in its phase, 0 to 1. The veil ignores it.
    var opacity: Double = 1

    /// Black each side of the Horizon, dry: no blur.
    static let halo: CGFloat = 3

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        // Read here, not in the layers: it changes with the tide's course,
        // not with its breath.
        let tideGuides = pulse.tideGuides
        ZStack(alignment: .top) {
            PaintTideSlide(pulse: pulse) {
                ZStack(alignment: .top) {
                    if let dry = store.dry {
                        Image(decorative: dry, scale: displayScale)
                            .opacity(opacity)
                    }
                    if let live = store.live {
                        PaintLiveLayer(pulse: pulse, image: live, scale: displayScale, opacity: opacity)
                    }
                }
            }
            .frame(width: geometry.width, height: geometry.height, alignment: .top)
            .clipped()
            LinearGradient(
                stops: PaintVeil.stops(geometry: geometry, reserves: reserves, horizonReserve: !tideGuides).map {
                    Gradient.Stop(color: .black.opacity($0.opacity), location: $0.location)
                },
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(width: geometry.width, height: geometry.height, alignment: .top)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// The live layer alone reads the pulse: a tick redraws this image and
/// nothing else of the page.
private struct PaintLiveLayer: View {
    let pulse: PaintPulse
    let image: CGImage
    let scale: CGFloat
    let opacity: Double

    var body: some View {
        Image(decorative: image, scale: scale)
            .opacity(pulse.liveOpacity * opacity)
    }
}

/// The slide of the tide, already rounded to the pixel by the pulse
/// (`Grid.pixelRound`): the paint moves by whole pixels or not at all, so
/// no edge goes soft, and this view is drawn again only when it moves.
private struct PaintTideSlide<Content: View>: View {
    let pulse: PaintPulse
    @ViewBuilder var content: Content

    var body: some View {
        let offset = pulse.tideOffset
        content.offset(x: offset.width, y: offset.height)
    }
}
