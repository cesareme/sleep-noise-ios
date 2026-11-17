import Foundation

/// Snapshot published from the main thread and consumed by the render callback.
///
/// The mailbox only ever holds the latest command, so a gain or breathing
/// update published right after `start` would overwrite the fade-in before the
/// render thread read it. Envelope changes therefore carry their own
/// `envelopeGeneration`: the render state begins a fade only when that number
/// moves, and every other publish carries the last envelope request unchanged.
/// `rampSamples < 0` means "leave the envelope alone". `envelopeShape` is the
/// curve of that fade (`FadeShape`) and travels with the request.
struct EngineCommand: Equatable {
    var gains: SoundGains = .zero
    var envelopeTarget: Float = 0
    var rampSamples: Int32 = -1
    var envelopeShape: Int32 = FadeShape.smooth
    /// Mailbox publish counter. Not used by the render state.
    var generation: UInt32 = 0
    var envelopeGeneration: UInt32 = 0
    var breath = BreathParameters.off

    static let silence = EngineCommand()
}
