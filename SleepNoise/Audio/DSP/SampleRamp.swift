import Foundation

/// A gain that moves from where it is to a target over a whole number of
/// samples.
///
/// The progress is a count of samples, not a sum of float steps: a fifteen
/// minute fade is 43 million samples, and a step of 2e-8 added to a `Float`
/// near 1 is lost to rounding (C31). The count is exact, so the ramp ends on
/// its last sample at any length. Plain values only: it lives inside
/// `RenderState`.
struct SampleRamp: Equatable {
    /// The gain right now.
    private(set) var value: Float
    private(set) var from: Float
    private(set) var to: Float
    /// Samples of the current ramp already rendered, and its length. Both
    /// are zero when nothing is moving.
    private(set) var done: UInt32 = 0
    private(set) var total: UInt32 = 0
    /// Curve of the ramp in progress: a `FadeShape`.
    private(set) var shape: Int32 = FadeShape.smooth

    init(_ value: Float) {
        self.value = value
        from = value
        to = value
    }

    var isRunning: Bool { done < total }

    /// Starts a ramp from the current value. One sample or less is not a
    /// ramp: the value is simply set, which is only ever asked for while
    /// nothing is audible.
    mutating func begin(to target: Float, samples: Int32, shape: Int32 = FadeShape.smooth) {
        guard samples > 1 else {
            set(target)
            self.shape = shape
            return
        }
        self.shape = shape
        from = value
        to = target
        done = 0
        total = UInt32(samples)
    }

    /// Puts the gain at `target` with nothing left to render.
    mutating func set(_ target: Float) {
        value = target
        from = target
        to = target
        done = 0
        total = 0
    }

    /// Forgets the curve of the last ramp. Only with the engine stopped.
    mutating func reset(to target: Float) {
        set(target)
        shape = FadeShape.smooth
    }

    /// The sample rate changed by `ratio` (new over old) with the engine
    /// stopped: a ramp in course keeps its value, its target and the share
    /// of it already done, and what is left lasts the same seconds as
    /// before (rule 8).
    mutating func rescale(by ratio: Double) {
        guard done < total, ratio > 0, ratio.isFinite else { return }
        let fraction = Double(done) / Double(total)
        let length = min(max(2, (Double(total) * ratio).rounded()), Double(UInt32.max))
        total = UInt32(length)
        done = min(total - 1, UInt32((fraction * length).rounded()))
    }

    /// One sample.
    @inline(__always)
    mutating func advance() {
        guard done < total else { return }
        done += 1
        if done >= total {
            value = to
            done = 0
            total = 0
            return
        }
        // In Double: past 2^24 a Float cannot hold the count, and near its
        // flat ends the curve in Float wobbles by a bit from one sample to
        // the next. In Double the ramp only ever moves towards its target.
        let t = Double(done) / Double(total)
        let shaped: Double
        if shape == FadeShape.easeOut {
            let rest = 1 - t
            shaped = 1 - rest * rest
        } else if shape == FadeShape.linear {
            shaped = t
        } else {
            shaped = t * t * (3 - 2 * t)
        }
        value = Float(Double(from) + (Double(to) - Double(from)) * shaped)
    }
}
