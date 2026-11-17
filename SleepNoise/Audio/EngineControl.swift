import Foundation

/// The decisions the engine takes on the main thread, with no audio in them.
///
/// `SleepAudioEngine` owns the `AVAudioEngine`; this owns what it is supposed
/// to be doing: whether it is wanted running, which stop is still waiting for
/// its fade, how long a master ramp may be and whether a start begins from
/// silence. The offline engine of the tests runs on the same value, so the
/// rules are tested where they live and never on a copy.
struct EngineControl: Equatable {
    /// What a start that failed has to undo.
    enum FailedStart: Equatable {
        /// Something was sounding when the start was asked for: it must
        /// leave, because whoever asked now believes nothing plays.
        case stopWhatSounds
        /// Nothing renders and no stop is waiting: give the session back.
        case releaseSession
        /// A stop asked for earlier is still fading: it finishes by itself.
        case waitForStop
    }

    /// A start went through and no stop was asked for since. Only then may a
    /// configuration change start the engine again by itself.
    private(set) var wantsRunning = false
    /// Moves with every start and stop: a stop that waits for its fade only
    /// pauses the engine if nothing else happened meanwhile.
    private(set) var stopToken = 0

    /// The session is active and the graph is built: the engine is wanted
    /// from here on, and whatever stop was waiting is called off. Never
    /// before: a start that fails must not leave a restart pending.
    mutating func started() {
        stopToken += 1
        wantsRunning = true
    }

    /// The session, the graph or the engine did not start.
    mutating func startFailed(isRendering: Bool) -> FailedStart {
        let wasWanted = wantsRunning
        wantsRunning = false
        if wasWanted { return .stopWhatSounds }
        return isRendering ? .waitForStop : .releaseSession
    }

    /// A stop was asked for. The token it returns is due once its fade has
    /// been rendered, unless something moved it first.
    mutating func stopRequested() -> Int {
        wantsRunning = false
        stopToken += 1
        return stopToken
    }

    func stopIsDue(_ token: Int) -> Bool {
        token == stopToken
    }

    /// The graph is gone (media services reset): nothing is wanted and no
    /// stop is waiting.
    mutating func invalidated() {
        stopToken += 1
        wantsRunning = false
    }

    /// The system stopped the engine under a night that plays (a route or
    /// configuration change): it starts again. Never after a start that
    /// failed, and never after a stop.
    func shouldRestart(isRendering: Bool) -> Bool {
        wantsRunning && !isRendering
    }

    /// A stop was asked for and its fade is still being rendered.
    func isStopping(isRendering: Bool) -> Bool {
        !wantsRunning && isRendering
    }

    /// A start that finds the engine stopped begins from silence: the render
    /// state is reset first. With the engine rendering the envelope rises
    /// from where it is.
    func startsFromSilence(isRendering: Bool) -> Bool {
        !isRendering
    }

    /// Samples of the envelope ramp a start asks for: never under 30 ms.
    static func startRamp(fadeIn seconds: TimeInterval, sampleRate: Double) -> Int32 {
        PlaybackFade.samples(max(shortestStart, seconds), sampleRate: sampleRate)
    }

    /// Samples of a master ramp. The level is simply there (one sample) only
    /// when nothing can be heard and nothing is about to be: the engine is
    /// neither rendering nor wanted. A night that plays while the system has
    /// the engine stopped for a moment still gets a ramp, so the level never
    /// arrives as a step when it restarts (rule 5).
    func masterRamp(over seconds: TimeInterval, sampleRate: Double, isRendering: Bool) -> Int32 {
        guard wantsRunning || isRendering else { return 1 }
        return PlaybackFade.samples(max(Self.shortestMasterRamp, seconds), sampleRate: sampleRate)
    }

    /// The shortest rise of a start.
    static let shortestStart: TimeInterval = 0.03
    /// The shortest ramp of the master level while the engine renders: a
    /// finger dragging the level in Night publishes many small moves, and
    /// each one is smoothed over this long. Never a step (rule 5).
    static let shortestMasterRamp: TimeInterval = 0.05
}
