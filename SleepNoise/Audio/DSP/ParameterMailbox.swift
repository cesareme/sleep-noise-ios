import Foundation

/// Single-producer seqlock.
///
/// The main thread is the only writer. It marks the sequence odd, copies one
/// command, then marks the sequence even with a release store. The render
/// thread copies the command and retries by falling back to the previous
/// command if the sequence moved. It never spins and never takes a lock.
final class ParameterMailbox: @unchecked Sendable {
    let storage: UnsafeMutablePointer<EngineCommand>
    let sequence: UnsafeMutablePointer<UInt32>
    private var sequenceValue: UInt32 = 0
    private var generation: UInt32 = 0

    init(initial: EngineCommand = .silence) {
        storage = .allocate(capacity: 1)
        storage.initialize(to: initial)
        sequence = .allocate(capacity: 1)
        sequence.initialize(to: 0)
    }

    deinit {
        storage.deinitialize(count: 1)
        storage.deallocate()
        sequence.deinitialize(count: 1)
        sequence.deallocate()
    }

    /// Main thread only.
    func publish(_ command: EngineCommand) {
        generation &+= 1
        var copy = command
        copy.generation = generation
        sequenceValue &+= 1
        sn_store_u32_release(sequence, sequenceValue)
        storage.pointee = copy
        sequenceValue &+= 1
        sn_store_u32_release(sequence, sequenceValue)
    }

    func load(fallback: EngineCommand) -> EngineCommand {
        readEngineCommand(
            command: UnsafePointer(storage),
            sequence: sequence,
            fallback: fallback
        )
    }
}

/// Render-thread entry point. Free function so the callback does not retain a class.
func readEngineCommand(
    command: UnsafePointer<EngineCommand>,
    sequence: UnsafeMutablePointer<UInt32>,
    fallback: EngineCommand
) -> EngineCommand {
    let start = sn_load_u32_acquire(sequence)
    if (start & 1) == 1 {
        return fallback
    }
    let candidate = command.pointee
    let end = sn_load_u32_acquire(sequence)
    if start != end {
        return fallback
    }
    return candidate
}
