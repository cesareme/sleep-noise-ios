import Darwin
import Foundation

/// The output level on its way from the render thread to the main thread.
///
/// One 32-bit word holding the bits of a `Float` (the mean square of the
/// output). The render thread stores it once per buffer and the main thread
/// loads it whenever the interface wants to draw. No lock, no allocation, no
/// retry: the atomics live in `AtomicBridge.c`.
final class OutputLevelCell: @unchecked Sendable {
    let storage: UnsafeMutablePointer<UInt32>

    init() {
        storage = .allocate(capacity: 1)
        storage.initialize(to: Float(0).bitPattern)
    }

    deinit {
        storage.deinitialize(count: 1)
        storage.deallocate()
    }

    /// Last mean square the render thread published.
    var meanSquare: Float {
        Float(bitPattern: sn_cell_load(storage))
    }

    /// Last published level as an RMS amplitude, 0 for silence.
    var rms: Float {
        let value = meanSquare
        // A NaN can never be published (the meter only sees clipped samples),
        // but a reader must not trust that.
        guard value == value, value > 0 else { return 0 }
        return sqrtf(value)
    }

    /// Main thread, and only while the render thread is idle: a stopped engine
    /// would otherwise leave its last level on show.
    func clear() {
        sn_cell_store(storage, Float(0).bitPattern)
    }
}

/// Render-thread entry point. Free function so the callback captures the raw
/// pointer and never the class.
@inline(__always)
func publishOutputLevel(_ meanSquare: Float, to cell: UnsafeMutablePointer<UInt32>) {
    sn_cell_store(cell, meanSquare.bitPattern)
}
