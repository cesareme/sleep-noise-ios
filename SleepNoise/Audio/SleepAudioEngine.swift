import AVFoundation
import Foundation

/// What the mixer asks of the engine. The app has one, `SleepAudioEngine`;
/// the tests of the model put a double here and never open an audio session.
/// Every call is made on the main thread.
protocol AudioEngineControlling: AnyObject {
    /// Rises from where the envelope is to `level` (1, or where the final
    /// fade of the timer stands when a night resumes inside it).
    func start(gains: SoundGains, fadeIn seconds: TimeInterval, level: Float) throws
    func updateGains(_ gains: SoundGains)
    func setBreathing(_ parameters: BreathParameters)
    /// The session level, 0 to 1, reached over `seconds`.
    func setMaster(_ level: Float, over seconds: TimeInterval)
    /// Moves the envelope to `level` without stopping anything.
    func fade(to level: Float, over seconds: TimeInterval)
    func stop(fadeOut seconds: TimeInterval)
    var isStopping: Bool { get }
    func retargetSampleRateIfNeeded(gains: SoundGains) throws
    func invalidateGraph()
    func smoothedOutputRMS(tau: TimeInterval) -> Float
}

extension AudioEngineControlling {
    func fadeOut(over seconds: TimeInterval) {
        fade(to: 0, over: seconds)
    }
}

/// Owns the `AVAudioEngine` graph. Control methods are called from the main thread.
/// The source-node callback only reads the seqlock and runs `RenderState.processStereo`.
final class SleepAudioEngine: AudioEngineControlling {
    /// Seconds the bed takes to rise from silence when Play is pressed. A sleep
    /// app is used in the dark; a soft onset is kinder than a 30 ms step. It
    /// eases out (`FadeShape.easeOut`): most of the level is there in the
    /// first half, so one touch is heard at once, and it settles without a
    /// bump. The Horizon is born from the hairline over the same time.
    static let defaultFadeIn: TimeInterval = 0.8

    /// The shortest ramp of the master level while the engine renders: a
    /// finger dragging the level in Night publishes many small moves, and
    /// each one is smoothed over this long. Never a step (rule 5).
    static let shortestMasterRamp: TimeInterval = 0.05

    /// Volume of the graph's mixer: always 1 in a release build. A debug build
    /// launched with `-silentOutput` renders, meters and publishes as usual
    /// but sends nothing to the speaker, so the interface can be exercised on
    /// a simulator without making a sound.
    private static let mixerVolume: Float = {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-silentOutput") {
            return 0
        }
        #endif
        return 1
    }()

    private var engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let mailbox = ParameterMailbox()
    private let state: UnsafeMutablePointer<RenderState>
    /// Written by the render thread once per buffer, read here.
    private let outputLevel = OutputLevelCell()
    private var levelFollower = OutputLevelFollower()
    private var sampleRate: Double = 48_000
    /// What was last asked for: gains, tide, and the last envelope and
    /// master requests, which every publish carries unchanged so that a
    /// gain or breathing update never cancels or restarts a fade.
    private var desk = CommandDesk()
    private var stopToken = 0
    private var wantsRunning = false
    private var configurationObserver: NSObjectProtocol?

    init() {
        state = .allocate(capacity: 1)
        // Chosen here, on the main thread, once per launch: the thunder does
        // not rumble at the same seconds every night.
        state.initialize(to: RenderState(thunderSchedule: UInt32.random(in: 0...UInt32.max)))
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

    func start(
        gains: SoundGains,
        fadeIn seconds: TimeInterval = SleepAudioEngine.defaultFadeIn,
        level: Float = 1
    ) throws {
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
        if !engine.isRunning {
            // The render thread is idle, so this is safe. After an interruption
            // the system stopped the engine before our fade-out could render:
            // without this the envelope is still 1 and the fade-in is a no-op.
            state.pointee.resetForFreshStart()
            outputLevel.clear()
        }

        desk.gains = gains
        let ramp = PlaybackFade.samples(max(0.03, seconds), sampleRate: sampleRate)
        publishEnvelope(target: level, ramp: ramp, shape: FadeShape.easeOut)
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                wantsRunning = false
                throw EngineError.engine(error)
            }
        }
    }

    /// RMS of the stereo output after the soft clip, as the render thread last
    /// measured it: 0 for silence, about 0.7 for a full-scale sine. It is 0
    /// whenever the engine is not rendering, so a paused or interrupted engine
    /// never leaves a stale level on show. Main thread.
    var outputRMS: Float {
        guard engine.isRunning else { return 0 }
        return outputLevel.rms
    }

    /// `outputRMS` followed with a time constant of `tau` seconds. The
    /// smoothing advances with the clock between two calls, so the caller
    /// (the Horizon) decides how often it runs and nothing ticks when nobody
    /// draws. Once the engine stops rendering the fall has its own, shorter
    /// constant, whatever `tau` is: the level is gone well inside 1.5 s.
    /// Main thread.
    func smoothedOutputRMS(tau: TimeInterval) -> Float {
        smoothedOutputRMS(tau: tau, now: nil)
    }

    func smoothedOutputRMS(tau: TimeInterval, now: TimeInterval?) -> Float {
        levelFollower.follow(
            outputRMS,
            at: now ?? Self.monotonicSeconds(),
            tau: OutputLevelFollower.tau(requested: tau, isRendering: engine.isRunning)
        )
    }

    /// Monotonic seconds for the smoothing. `DispatchTime` on purpose: the
    /// system-uptime calls are "required reason" APIs for the privacy
    /// manifest, and a level meter is no reason to declare one.
    private static func monotonicSeconds() -> TimeInterval {
        TimeInterval(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
    }

    func updateGains(_ gains: SoundGains) {
        desk.gains = gains
        publishCurrent()
    }

    /// Breathing tide. Takes effect at once; the render state smooths the weight.
    func setBreathing(_ parameters: BreathParameters) {
        desk.breath = parameters
        publishCurrent()
    }

    /// Moves the envelope to `level` over `seconds`, from wherever it is:
    /// to silence for the final fade of the timer, back to 1 when "+15 min"
    /// calls that fade off. The render thread counts the samples, so the
    /// main thread only has to ask once.
    func fade(to level: Float, over seconds: TimeInterval) {
        publishEnvelope(target: level, ramp: PlaybackFade.samples(seconds, sampleRate: sampleRate))
    }

    /// The session level (C51). While the engine renders it is always a
    /// ramp, `shortestMasterRamp` at least; with the engine stopped nothing
    /// is audible and the level is simply there when the bed rises.
    func setMaster(_ level: Float, over seconds: TimeInterval) {
        let ramp = engine.isRunning
            ? PlaybackFade.samples(max(Self.shortestMasterRamp, seconds), sampleRate: sampleRate)
            : 1
        desk.rampMaster(to: level, samples: ramp)
        publishCurrent()
    }

    /// New envelope request: bumps the envelope generation so the render
    /// state starts the fade even if a later publish overwrites this command.
    private func publishEnvelope(target: Float, ramp: Int32, shape: Int32 = FadeShape.smooth) {
        desk.fadeEnvelope(to: target, samples: ramp, shape: shape)
        publishCurrent()
    }

    private func publishCurrent() {
        mailbox.publish(desk.command)
    }

    /// A stop was asked for and its fade is still being rendered. Main thread.
    var isStopping: Bool {
        !wantsRunning && engine.isRunning
    }

    /// Ramps to silence, then pauses the engine and releases the session unless
    /// `start` ran again in the meantime. Called again during the fade, the
    /// new one starts from where the envelope is and replaces the wait.
    func stop(fadeOut seconds: TimeInterval) {
        fadeOut(over: seconds)
        wantsRunning = false
        stopToken += 1
        let token = stopToken
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 0.02) { [weak self] in
            guard let self, self.stopToken == token else { return }
            self.engine.pause()
            self.desk.breath = .off
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
        desk.gains = gains
        try buildGraph(sampleRate: rate)
        if desk.envelopeTarget > 0 {
            // Back to where the envelope was going, which is below 1 when a
            // night resumed inside the final fade of its timer.
            publishEnvelope(target: desk.envelopeTarget, ramp: PlaybackFade.samples(0.03, sampleRate: sampleRate))
        } else {
            // A sleep-timer fade-out is in progress: keep it, just refresh the rest.
            publishCurrent()
        }
        try restartIfWanted()
    }

    /// Media services reset invalidates the running engine. Drop the graph so the next
    /// `start` builds a new one.
    func invalidateGraph() {
        stopToken += 1
        wantsRunning = false
        desk.breath = .off
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
        engine.mainMixerNode.outputVolume = Self.mixerVolume
        sourceNode = node
    }

    private func makeSourceNode(format: AVAudioFormat) -> AVAudioSourceNode {
        let state = self.state
        let commandPtr = mailbox.storage
        let sequencePtr = mailbox.sequence
        let levelPtr = outputLevel.storage

        return AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList in
            renderOutput(
                state: state,
                command: UnsafePointer(commandPtr),
                sequence: sequencePtr,
                level: levelPtr,
                frameCount: Int(frameCount),
                bufferList: audioBufferList
            )
            return noErr
        }
    }
}

/// The whole of the render callback: read the mailbox, fill the buffers,
/// publish the level. A free function over raw pointers so the callback
/// captures no object, and so a test can run it offline on a plain buffer.
/// Render thread: no allocation, no lock, no retry.
func renderOutput(
    state: UnsafeMutablePointer<RenderState>,
    command commandPtr: UnsafePointer<EngineCommand>,
    sequence sequencePtr: UnsafeMutablePointer<UInt32>,
    level levelPtr: UnsafeMutablePointer<UInt32>,
    frameCount frames: Int,
    bufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>
) {
    if frames <= 0 { return }

    var render = state.pointee
    let command = readEngineCommand(
        command: commandPtr,
        sequence: sequencePtr,
        fallback: render.lastCommand
    )
    render.lastCommand = command

    let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
    if buffers.isEmpty {
        state.pointee = render
        return
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
    publishOutputLevel(render.outputMeter.meanSquare, to: levelPtr)
}
