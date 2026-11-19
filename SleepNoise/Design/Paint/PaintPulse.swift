import CoreGraphics
import Foundation
import Observation

/// What the live layer of the painted window draws at right now, fed by
/// the Horizon's own timeline (`SoundLine.tick`): the paint has no clock of
/// its own and shares the Horizon's `isFrozen` (camino-lienzo.md). Only the
/// window reads it, so a tick invalidates the live layer and nothing else
/// of the page.
@MainActor
@Observable
final class PaintPulse {
    /// Opacity of the live layer, 0 to `PaintBreath.liveMax`.
    private(set) var liveOpacity: Double = 0
    /// Where the window sits for the tide, in points, not yet rounded.
    private(set) var tideOffset: CGSize = .zero

    /// False in the frozen phase (Reduce Motion): the ticks still come but
    /// the layer stays where it was, or, if the sound never lit it, at
    /// `PaintBreath.stillOpacity`, so the picture is whole and still.
    @ObservationIgnored var isLive = true
    /// The direction of the dominant motif, for the slide of the tide.
    @ObservationIgnored var direction: Double = 0
    /// The height of the water at an instant, 0 to 1, while the tide
    /// guides; nil when it does not.
    @ObservationIgnored var tide: ((Date) -> Float)?

    @ObservationIgnored private var follower = PaintBreathFollower()
    @ObservationIgnored private var lastTick: TimeInterval?

    /// The longest step the follower takes: a timeline that was paused for
    /// a while does not jump the paint on its first tick.
    static let longestStep: TimeInterval = 0.5

    /// One tick of the Horizon with its smoothed reading.
    func tick(rms: Float, at time: TimeInterval) {
        let dt = lastTick.map { max(0, min(Self.longestStep, time - $0)) } ?? 0
        lastTick = time
        guard isLive else {
            if liveOpacity == 0 { liveOpacity = PaintBreath.stillOpacity }
            return
        }
        follower.advance(rms: rms, dt: dt)
        let next = follower.liveOpacity
        if next != liveOpacity { liveOpacity = next }
        let date = Date(timeIntervalSinceReferenceDate: time)
        let offset = PaintBreath.offset(tide: tide?(date), direction: direction)
        if offset != tideOffset { tideOffset = offset }
    }

    /// Back to silence: the window was dropped, or is born again.
    func reset() {
        follower.reset()
        lastTick = nil
        liveOpacity = 0
        tideOffset = .zero
    }
}
