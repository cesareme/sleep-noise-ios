import AVFoundation
import Foundation

/// Owns the `AVAudioEngine` graph. Control methods are called from the main thread.
/// The source-node callback only reads the seqlock and runs `RenderState.processStereo`.
final class SleepAudioEngine {
    /// Seconds the bed takes to rise from silence when Play is pressed. A sleep
    /// app is used in the dark; a soft onset is kinder than a 30 ms step.
    static let defaultFadeIn: TimeInterval = 1.5

    private var engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let mailbox = ParameterMailbox()
    private let state: UnsafeMutablePointer<RenderState>
    private var sampleRate: Double = 48_000
    private var lastGains = SoundGains.zero
    private var stopToken = 0
    private var wantsRunning = false
    private var configurationObserver: NSObjectProtocol?

    init() {
        state = .allocate(capacity: 1)
        state.initialize(to: RenderState())
        observeConfigurationChanges()
    }

    deinit {
        if let configurationObserver {
            NotificationCenter.default.removeObserver(configurationObserver)
        }
        engine.stop()
        if let sourceNode {
            engine.detach(sourceNode)
        }
        // Release the render callback before freeing the state it points at.
        self.sourceNode = nil
        state.deinitialize(count: 1)
        state.deallocate()
    }

    func start(gains: SoundGains, fadeIn seconds: TimeInterval = SleepAudioEngine.defaultFadeIn) throws {
        stopToken += 1
        wantsRunning = true
        do {
            try AudioSessionConfigurator.activate()
        } catch {
            throw EngineError.session(error)
        }

        let sessionRate = AVAudioSession.sharedInstance().sampleRate
        let rate = sessionRate > 1 ? sessionRate : 48_000
        if sourceNode == nil || abs(rate - sampleRate) > 0.5 {
            try buildGraph(sampleRate: rate)
        }

        lastGains = gains
        let ramp = Int32(max(1, sampleRate * max(0.03, seconds)))
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
                wantsRunning = false
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

    /// Ramps to silence, then pauses the engine and releases the session unless
    /// `start` ran again in the meantime.
    func stop(fadeOut seconds: TimeInterval) {
        fadeOut(over: seconds)
        wantsRunning = false
        stopToken += 1
        let token = stopToken
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 0.02) { [weak self] in
            guard let self, self.stopToken == token else { return }
            self.engine.pause()
            AudioSessionConfigurator.deactivate()
        }
    }

    /// Rebuild only when the hardware rate actually changed, so a route notification
    /// during a sleep fade does not snap the envelope back to full volume.
    func retargetSampleRateIfNeeded(gains: SoundGains) throws {
        let sessionRate = AVAudioSession.sharedInstance().sampleRate
        let rate = sessionRate > 1 ? sessionRate : sampleRate
        guard abs(rate - sampleRate) > 0.5 else {
            try restartIfWanted()
            return
        }
        lastGains = gains
        try buildGraph(sampleRate: rate)
        let ramp = Int32(max(1, sampleRate * 0.03))
        mailbox.publish(EngineCommand(
            gains: gains,
            envelopeTarget: 1,
            rampSamples: ramp,
            generation: 0
        ))
        try restartIfWanted()
    }

    /// Media services reset invalidates the running engine. Drop the graph so the next
    /// `start` builds a new one.
    func invalidateGraph() {
        stopToken += 1
        wantsRunning = false
        engine.stop()
        if let sourceNode {
            engine.detach(sourceNode)
        }
        self.sourceNode = nil
        engine = AVAudioEngine()
        observeConfigurationChanges()
    }

    /// `AVAudioEngine` stops itself when the output route changes (AirPods connect,
    /// a HomePod is picked, a cable comes out). Without this, the bed goes silent
    /// the moment earbuds pair and never comes back.
    private func observeConfigurationChanges() {
        if let configurationObserver {
            NotificationCenter.default.removeObserver(configurationObserver)
        }
        configurationObserver = NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: engine,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            try? self.restartIfWanted()
        }
    }

    private func restartIfWanted() throws {
        guard wantsRunning, !engine.isRunning else { return }
        try engine.start()
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
                // Interleaved (or mono) buffer.
                let channels = max(1, Int(buffers[0].mNumberChannels))
                if channels == 1 {
                    for index in 0..<frames {
                        data[index] = render.process(command)
                    }
                } else {
                    var offset = 0
                    for _ in 0..<frames {
                        let frame = render.processStereo(command)
                        data[offset] = frame.left
                        data[offset + 1] = frame.right
                        if channels > 2 {
                            for channel in 2..<channels {
                                data[offset + channel] = frame.left
                            }
                        }
                        offset += channels
                    }
                }
            } else {
                // Deinterleaved: one buffer per channel. This is the standard format.
                let leftData = buffers[0].mData?.assumingMemoryBound(to: Float.self)
                let rightData = buffers.count > 1 ? buffers[1].mData?.assumingMemoryBound(to: Float.self) : nil
                for index in 0..<frames {
                    let frame = render.processStereo(command)
                    leftData?[index] = frame.left
                    rightData?[index] = frame.right
                    if buffers.count > 2 {
                        for extra in 2..<buffers.count {
                            buffers[extra].mData?.assumingMemoryBound(to: Float.self)[index] = frame.left
                        }
                    }
                }
            }

            state.pointee = render
            return noErr
        }
    }
}
