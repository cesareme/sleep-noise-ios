import CoreGraphics
import Foundation
import Observation

/// Owns the two layers of the painted window on the main thread and
/// publishes them to the page. It never draws: it asks the rasterizer, on
/// its utility queue, and keeps the answer only while the scene it was drawn
/// for is still the one wanted.
///
/// When `PaintPolicy` says absent, or there is no scene to paint, both
/// layers are nil and nothing is in flight: no raster lives in memory
/// behind Night, the night page, the night window or a dark screen, and no
/// work ticks.
@MainActor
@Observable
final class PaintStore {
    /// The layers on show, drawn for `raster.scene` at `raster.scale`.
    private(set) var raster: PaintRaster?
    private(set) var phase: PaintPhase = .absent
    /// A raster is being drawn, or waits its turn to be.
    private(set) var isRendering = false
    /// Wall time of the last raster, for the diagnostics.
    private(set) var lastRenderTime: TimeInterval?

    /// Seconds a change of scene waits, while a raster is on show, before
    /// it is drawn: a finger dragging a level changes the scene many times
    /// a second, and only where it settles is painted. The first raster
    /// never waits.
    static let settle: TimeInterval = 0.35

    @ObservationIgnored private let rasterizer: PaintRasterizer
    @ObservationIgnored private var pending: PaintRenderRequest?
    @ObservationIgnored private var pendingTask: Task<Void, Never>?
    @ObservationIgnored private var wanted: (scene: PaintScene, scale: CGFloat)?

    init(rasterizer: PaintRasterizer = PaintRasterizer()) {
        self.rasterizer = rasterizer
    }

    var dry: CGImage? { raster?.dry }
    var live: CGImage? { raster?.live }

    /// Tells the store what the page wants now. Same scene and scale as
    /// the raster on show (or in flight): nothing happens. Absent, or no
    /// scene: the layers go to nil and whatever is in flight is cancelled.
    func apply(scene: PaintScene?, phase: PaintPhase, scale: CGFloat) {
        self.phase = phase
        guard phase.exists, let scene else {
            drop()
            return
        }
        if let raster, raster.scene == scene, raster.scale == scale {
            cancelPending()
            return
        }
        if let wanted, wanted.scene == scene, wanted.scale == scale, pendingTask != nil {
            return
        }
        cancelPending()
        wanted = (scene, scale)
        isRendering = true
        let delay = raster == nil ? 0 : Self.settle
        pendingTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(for: .seconds(delay))
            }
            guard let self, !Task.isCancelled, let wanted = self.wanted,
                  wanted.scene == scene, wanted.scale == scale else { return }
            let request = self.rasterizer.request(scene, scale: scale)
            self.pending = request
            let outcome: PaintRaster?
            do {
                outcome = try await request.value
            } catch {
                outcome = nil
            }
            guard self.pending === request else { return }
            self.pending = nil
            self.pendingTask = nil
            self.wanted = nil
            self.isRendering = false
            if let outcome, self.phase.exists {
                self.raster = outcome
                self.lastRenderTime = outcome.renderTime
                #if DEBUG
                print(String(
                    format: "paint: raster %@ · %.0f ms · %d strokes · %.2f MB · main thread %@",
                    outcome.scene.layers.map(\.sound.rawValue).joined(separator: "+"),
                    outcome.renderTime * 1000, outcome.strokeCount,
                    Double(outcome.bytes) / 1_048_576, outcome.renderedOnMainThread ? "yes" : "no"
                ))
                #endif
            }
        }
    }

    /// Both layers to nil, nothing in flight.
    func drop() {
        cancelPending()
        raster = nil
    }

    /// Waits for the raster in flight, if any. For tests and previews.
    func settle() async {
        await pendingTask?.value
    }

    private func cancelPending() {
        pending?.cancel()
        pending = nil
        // The rasterizer keeps no request of its own either: nothing holds
        // a raster but `raster`.
        rasterizer.cancelAll()
        pendingTask?.cancel()
        pendingTask = nil
        wanted = nil
        isRendering = false
    }
}
