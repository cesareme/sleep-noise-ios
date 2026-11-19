import CoreGraphics
import Foundation

/// The two layers of a painted window, at the scale of the screen: the dry
/// layer (ground, grain and the ribbons that stay still) and the live layer
/// (the ribbons that breathe with the sound, drawn by the page in opacity
/// only). Both carry alpha and are composed over black by the page.
struct PaintRaster {
    let scene: PaintScene
    let scale: CGFloat
    let dry: CGImage
    let live: CGImage
    let strokeCount: Int
    /// Wall time of the raster, in seconds.
    let renderTime: TimeInterval
    /// Where it was drawn. Always false: the page never rasterizes.
    let renderedOnMainThread: Bool

    /// The bytes the two bitmaps hold.
    var bytes: Int { dry.bytesPerRow * dry.height + live.bytesPerRow * live.height }
}

enum PaintRasterError: Error, Equatable {
    /// A bitmap of the window could not be made.
    case bitmap
}

/// One raster asked for. It is cancelled when the scene changes before it
/// is done, or when the paint is no longer wanted; a cancelled request
/// throws `CancellationError` to whoever awaits it and stops drawing at the
/// next stroke.
final class PaintRenderRequest: @unchecked Sendable {
    let scene: PaintScene
    let scale: CGFloat

    private let lock = NSLock()
    private var cancelled = false
    private var result: Result<PaintRaster, Error>?
    private var waiting: [CheckedContinuation<PaintRaster, Error>] = []

    init(scene: PaintScene, scale: CGFloat) {
        self.scene = scene
        self.scale = scale
    }

    var isCancelled: Bool {
        lock.lock(); defer { lock.unlock() }
        return cancelled
    }

    var isFinished: Bool {
        lock.lock(); defer { lock.unlock() }
        return result != nil
    }

    func cancel() {
        lock.lock()
        cancelled = true
        lock.unlock()
    }

    /// The raster, once it is drawn.
    var value: PaintRaster {
        get async throws {
            try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    lock.lock()
                    if let result {
                        lock.unlock()
                        continuation.resume(with: result)
                    } else {
                        waiting.append(continuation)
                        lock.unlock()
                    }
                }
            } onCancel: {
                cancel()
            }
        }
    }

    fileprivate func finish(_ outcome: Result<PaintRaster, Error>) {
        lock.lock()
        guard result == nil else { lock.unlock(); return }
        result = outcome
        let continuations = waiting
        waiting = []
        lock.unlock()
        for continuation in continuations { continuation.resume(with: outcome) }
    }
}

/// Turns a scene into its two bitmaps on a serial queue of utility
/// priority, never on the main thread and never on the audio thread (it
/// has no way to it: the engine is not imported here). Asking for a new
/// scene cancels the one in flight; the drawing checks every few strokes
/// and stops.
final class PaintRasterizer: @unchecked Sendable {
    /// Strokes between two checks of the cancellation.
    static let checkEvery = 32

    private let queue: DispatchQueue
    private let lock = NSLock()
    private var current: PaintRenderRequest?

    init(queue: DispatchQueue = DispatchQueue(label: "sleepnoise.paint.raster", qos: .utility)) {
        self.queue = queue
    }

    /// Asks for `scene` at `scale`; whatever was in flight is cancelled.
    @discardableResult
    func request(_ scene: PaintScene, scale: CGFloat) -> PaintRenderRequest {
        let request = PaintRenderRequest(scene: scene, scale: scale)
        lock.lock()
        current?.cancel()
        current = request
        lock.unlock()
        queue.async { [request] in
            do {
                let raster = try Self.draw(scene, scale: scale) { !request.isCancelled }
                request.finish(.success(raster))
            } catch {
                request.finish(.failure(error))
            }
            // Done: the rasterizer lets go of the request, so the raster
            // lives only where it was asked for (the store), and goes when
            // the store drops it.
            self.forget(request)
        }
        return request
    }

    private func forget(_ request: PaintRenderRequest) {
        lock.lock()
        if current === request { current = nil }
        lock.unlock()
    }

    /// Cancels whatever is in flight. Nothing is drawn after this until the
    /// next request.
    func cancelAll() {
        lock.lock()
        current?.cancel()
        current = nil
        lock.unlock()
    }

    /// The drawing itself, on the calling thread, which is never the main
    /// one. `shouldContinue` is asked between strokes; a false answer
    /// throws `CancellationError`.
    static func draw(
        _ scene: PaintScene, scale: CGFloat, shouldContinue: @escaping () -> Bool = { true }
    ) throws -> PaintRaster {
        #if DEBUG
        // A rule of performance, not of safety: it is checked where it is
        // developed and never kills the published app.
        dispatchPrecondition(condition: .notOnQueue(.main))
        #endif
        let started = DispatchTime.now()
        guard shouldContinue() else { throw CancellationError() }

        let g = scene.geometry
        let W = Double(g.width), H = Double(g.height)
        let composition = PaintComposition(scene)
        guard let dry = Pigment.Canvas(width: W, height: H, scale: scale, opaque: false),
              let live = Pigment.Canvas(width: W, height: H, scale: scale, opaque: false)
        else { throw PaintRasterError.bitmap }

        // The ground: the darkest tint of the dominant layer at 55 % in the
        // middle of the window, fading to nothing at its edges, only here;
        // outside the window the page is black. Then the grain.
        let palette = scene.dominant.motif.palette
        let darkest = palette[palette.count - 1]
        let ground = [CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0), darkest.cgColor(alpha: 0.55),
                      CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0)] as CFArray
        if let gradient = CGGradient(colorsSpace: Pigment.sRGB, colors: ground, locations: [0, 0.5, 1]) {
            dry.context.saveGState()
            dry.context.clip(to: CGRect(x: 0, y: 0, width: W, height: H))
            dry.context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: H), options: [])
            dry.context.restoreGState()
        }
        var R = composition.grainGenerator
        Pigment.grain(dry.context, width: W, height: H, &R, 0.06)

        // Pass 1: the whole window, the two dark tints of each palette.
        var since = 0
        func check() throws {
            since += 1
            if since % checkEvery == 0, !shouldContinue() { throw CancellationError() }
        }
        for stroke in composition.strokes where !stroke.isCrack {
            try check()
            let target = stroke.isLive ? live : dry
            Pigment.paint(stroke.ribbon, palette: stroke.motif.palette, minimumTint: max(2, stroke.minimumTint), into: target.context)
        }

        // Pass 2: the band, all four tints, feathered 26 pt over its edges.
        let bandRect = CGRect(
            x: 0, y: g.bandTop - 14, width: g.width, height: g.bandBottom - g.bandTop + 28
        )
        let banded = composition.strokes.filter { g.touchesBand($0.ribbon.points) }
        if !banded.isEmpty {
            guard let dryBand = Pigment.Canvas(width: W, height: H, scale: scale, opaque: false),
                  let liveBand = Pigment.Canvas(width: W, height: H, scale: scale, opaque: false)
            else { throw PaintRasterError.bitmap }
            for canvas in [dryBand, liveBand] { canvas.context.clip(to: bandRect) }
            for stroke in banded {
                try check()
                let target = stroke.isLive ? liveBand : dryBand
                // A muted motif (lenguaje §7: no warm pigment over the blue
                // of sea and rain, no blue in the campfire) keeps its two
                // dark tints inside the band as well.
                Pigment.paint(stroke.ribbon, palette: stroke.motif.palette, minimumTint: stroke.minimumTint, into: target.context)
            }
            let clear = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0), solid = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            let ramp = Double(PaintWindowGeometry.feather) / Double(bandRect.height)
            if let mask = CGGradient(
                colorsSpace: Pigment.sRGB, colors: [clear, solid, solid, clear] as CFArray,
                locations: [0, CGFloat(ramp), CGFloat(1 - ramp), 1]
            ) {
                for (canvas, target) in [(dryBand, dry), (liveBand, live)] {
                    canvas.context.setBlendMode(.destinationIn)
                    canvas.context.drawLinearGradient(
                        mask, start: CGPoint(x: 0, y: bandRect.minY), end: CGPoint(x: 0, y: bandRect.maxY), options: []
                    )
                    canvas.context.setBlendMode(.normal)
                    guard let image = canvas.image() else { throw PaintRasterError.bitmap }
                    // The canvas is flipped to draw with the origin at the top;
                    // an image drawn into it must be flipped back.
                    target.context.saveGState()
                    target.context.translateBy(x: 0, y: H)
                    target.context.scaleBy(x: 1, y: -1)
                    target.context.draw(image, in: CGRect(x: 0, y: 0, width: W, height: H))
                    target.context.restoreGState()
                }
            }
        }

        // The reserve strip under the Horizon: 24 pt without light tints,
        // painted over with the darkest tint of the dominant layer at 40 %.
        dry.fill(darkest, alpha: 0.4, rect: CGRect(
            x: 0, y: g.horizonY - PaintWindowGeometry.reserve / 2, width: g.width, height: PaintWindowGeometry.reserve
        ))

        guard shouldContinue() else { throw CancellationError() }
        guard let dryImage = dry.image(), let liveImage = live.image() else { throw PaintRasterError.bitmap }
        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds) / 1_000_000_000
        return PaintRaster(
            scene: scene,
            scale: scale,
            dry: dryImage,
            live: liveImage,
            strokeCount: composition.strokes.count,
            renderTime: elapsed,
            renderedOnMainThread: Thread.isMainThread
        )
    }
}
