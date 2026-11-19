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
    /// A raster is being drawn.
    private(set) var isRendering = false
    /// Wall time of the last raster, for the diagnostics.
    private(set) var lastRenderTime: TimeInterval?

    @ObservationIgnored private let rasterizer: PaintRasterizer
    @ObservationIgnored private var pending: PaintRenderRequest?
    @ObservationIgnored private var pendingTask: Task<Void, Never>?

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
        if let pending, pending.scene == scene, pending.scale == scale, !pending.isCancelled {
            return
        }
        cancelPending()
        let request = rasterizer.request(scene, scale: scale)
        pending = request
        isRendering = true
        pendingTask = Task { [weak self] in
            let outcome: PaintRaster?
            do {
                outcome = try await request.value
            } catch {
                outcome = nil
            }
            guard let self, self.pending === request else { return }
            self.pending = nil
            self.pendingTask = nil
            self.isRendering = false
            if let outcome, self.phase.exists {
                self.raster = outcome
                self.lastRenderTime = outcome.renderTime
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
        pendingTask = nil
        isRendering = false
    }
}
