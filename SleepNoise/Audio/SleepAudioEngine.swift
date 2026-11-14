import AVFoundation
import Foundation

/// Owns the `AVAudioEngine` graph. Control methods are called from the main thread.
/// The source-node callback only reads the seqlock and runs `RenderState.process`.
final class SleepAudioEngine {
    private var engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let mailbox = ParameterMailbox()
    private let state: UnsafeMutablePointer<RenderState>
    private var sampleRate: Double = 48_000
    private var lastGains = SoundGains.zero
    private var stopToken = 0

    init() {
        state = .allocate(capacity: 1)
        state.initialize(to: RenderState())
    }

    deinit {
        engine.stop()
        if let sourceNode {
            engine.detach(sourceNode)
        }
        // Release the render callback before freeing the state it points at.
        self.sourceNode = nil
        state.deinitialize(count: 1)
        state.deallocate()
    }

    func start(gains: SoundGains) throws {
        stopToken += 1
        do {
            try AudioSessionConfigurator.activate()
        } catch {
            throw EngineError.session(error)
        }

        let sessionRate = AVAudioSession.sharedInstance().sampleRate
        let rate = sessionRate > 1 ? sessionRate : 44_100
        if sourceNode == nil || abs(rate - sampleRate) > 0.5 {
            try buildGraph(sampleRate: rate)
        }

        lastGains = gains
        let ramp = Int32(max(1, sampleRate * 0.03))
        mailbox.publish(EngineCommand(
            gains: gains,
            envelopeTarget: 1,
            rampSamples: ramp,
            generation: 0
        ))
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                throw EngineError.engine(error)
            }
        }
    }

    func updateGains(_ gains: SoundGains) {
        lastGains = gains
        mailbox.publish(EngineCommand(
            gains: gains,
            envelopeTarget: 0,
            rampSamples: -1,
            generation: 0
        ))
    }

    func fadeOut(over seconds: TimeInterval) {
        let samples = Int32(max(1, seconds * sampleRate))
        mailbox.publish(EngineCommand(
            gains: lastGains,
            envelopeTarget: 0,
            rampSamples: samples,
            generation: 0
        ))
    }

    /// Ramps to silence, then pauses the engine unless `start` ran again.
    func stop(fadeOut seconds: TimeInterval) {
        fadeOut(over: seconds)
        stopToken += 1
        let token = stopToken
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 0.02) { [weak self] in
            guard let self, self.stopToken == token else { return }
            self.engine.pause()
        }
    }

    /// Rebuild only when the hardware rate actually changed, so a route notification
    /// during a sleep fade does not snap the envelope back to full volume.
    func retargetSampleRateIfNeeded(gains: SoundGains) throws {
        let sessionRate = AVAudioSession.sharedInstance().sampleRate
        let rate = sessionRate > 1 ? sessionRate : sampleRate
        guard abs(rate - sampleRate) > 0.5 else { return }
        lastGains = gains
        try buildGraph(sampleRate: rate)
        let ramp = Int32(max(1, sampleRate * 0.03))
        mailbox.publish(EngineCommand(
            gains: gains,
            envelopeTarget: 1,
            rampSamples: ramp,
            generation: 0
        ))
        if !engine.isRunning {
            try engine.start()
        }
    }

    /// Media services reset invalidates the running engine. Drop the graph so the next
    /// `start` builds a new one.
    func invalidateGraph() {
        stopToken += 1
        engine.stop()
        if let sourceNode {
            engine.detach(sourceNode)
        }
        self.sourceNode = nil
        engine = AVAudioEngine()
    }

    private func buildGraph(sampleRate: Double) throws {
        self.sampleRate = sampleRate
        engine.stop()
        if let sourceNode {
            engine.disconnectNodeOutput(sourceNode)
            engine.detach(sourceNode)
        }
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else {
            throw EngineError.formatUnavailable
        }
        state.pointee.prepare(sampleRate: Float(sampleRate))
        let node = makeSourceNode(format: format)
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1
        sourceNode = node
    }

    private func makeSourceNode(format: AVAudioFormat) -> AVAudioSourceNode {
        let state = self.state
        let commandPtr = mailbox.storage
        let sequencePtr = mailbox.sequence

        return AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList in
            let frames = Int(frameCount)
            if frames == 0 { return noErr }

            var render = state.pointee
            let command = readEngineCommand(
                command: UnsafePointer(commandPtr),
                sequence: sequencePtr,
                fallback: render.lastCommand
            )
            render.lastCommand = command

            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            if buffers.isEmpty {
                state.pointee = render
                return noErr
            }

            if buffers.count == 1, let data = buffers[0].mData?.assumingMemoryBound(to: Float.self) {
                let channels = max(1, Int(buffers[0].mNumberChannels))
                if channels == 1 {
                    for index in 0..<frames {
                        data[index] = render.process(command)
                    }
                } else {
                    var offset = 0
                    for _ in 0..<frames {
                        let sample = render.process(command)
                        for channel in 0..<channels {
                            data[offset + channel] = sample
                        }
                        offset += channels
                    }
                }
            } else {
                for index in 0..<frames {
                    let sample = render.process(command)
                    for buffer in buffers {
                        guard let data = buffer.mData?.assumingMemoryBound(to: Float.self) else { continue }
                        data[index] = sample
                    }
                }
            }

            state.pointee = render
            return noErr
        }
    }
}
