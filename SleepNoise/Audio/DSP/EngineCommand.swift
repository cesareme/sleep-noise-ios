import Foundation

/// Snapshot published from the main thread and consumed by the render callback.
///
/// `rampSamples < 0` means "leave the envelope alone" so gain updates do not
/// restart a fade that is already in progress.
struct EngineCommand: Equatable {
    var gains: SoundGains = .zero
    var envelopeTarget: Float = 0
    var rampSamples: Int32 = -1
    var generation: UInt32 = 0

    static let silence = EngineCommand()
}
