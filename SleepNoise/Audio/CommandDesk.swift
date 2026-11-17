import Foundation

/// The main-thread side of the mailbox: what the engine last asked for, and
/// the one command that says all of it.
///
/// The mailbox keeps only the latest command, so every publish has to carry
/// everything: the gains, the tide, the last envelope request and the last
/// master request. A change of one must never restart another, which is why
/// the two fades are events with their own counters (rule 4): a publish that
/// only moves the gains carries the same counters and the render state
/// leaves both fades alone.
///
/// A plain value with no audio in it, so the tests that render offline build
/// their commands with the same code the engine does.
struct CommandDesk: Equatable {
    var gains = SoundGains.zero
    var breath = BreathParameters.off
    private(set) var envelopeTarget: Float = 0
    private(set) var envelopeRamp: Int32 = -1
    private(set) var envelopeShape: Int32 = FadeShape.smooth
    private(set) var envelopeGeneration: UInt32 = 0
    private(set) var masterTarget: Float = 1
    private(set) var masterRamp: Int32 = -1
    private(set) var masterGeneration: UInt32 = 0

    /// A new envelope request: the render state starts this fade from
    /// wherever the envelope is, even if a later publish overwrites the
    /// command first.
    mutating func fadeEnvelope(to target: Float, samples: Int32, shape: Int32 = FadeShape.smooth) {
        envelopeTarget = unitGain(target)
        envelopeRamp = max(1, samples)
        envelopeShape = shape
        envelopeGeneration &+= 1
    }

    /// A new master request, of the same kind.
    mutating func rampMaster(to target: Float, samples: Int32) {
        masterTarget = unitGain(target)
        masterRamp = max(1, samples)
        masterGeneration &+= 1
    }

    /// Everything, as the render thread reads it. `generation` is the
    /// mailbox's own counter and is written there.
    var command: EngineCommand {
        EngineCommand(
            gains: gains,
            envelopeTarget: envelopeTarget,
            rampSamples: envelopeRamp,
            envelopeShape: envelopeShape,
            generation: 0,
            envelopeGeneration: envelopeGeneration,
            breath: breath,
            masterTarget: masterTarget,
            masterRampSamples: masterRamp,
            masterGeneration: masterGeneration
        )
    }
}
