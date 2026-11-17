import XCTest
@testable import SleepNoise

/// An engine without audio hardware. It keeps its commands with the same
/// `CommandDesk` the real engine uses, takes its decisions with the same
/// `EngineControl` and renders offline through a real `RenderState`, so a
/// test of the model can ask what the envelope and the master level actually
/// did, sample by sample. What it stands in for is only the hardware: the
/// session that may refuse, the engine the system stops, the rate of the
/// route.
final class OfflineEngine: AudioEngineControlling {
    enum Call: Equatable {
        case start(fadeIn: TimeInterval, level: Float)
        case gains
        case breathing(BreathParameters)
        case master(level: Float, seconds: TimeInterval)
        case fade(level: Float, seconds: TimeInterval)
        case stop(fadeOut: TimeInterval)
        case retarget
        case invalidate
    }

    private(set) var sampleRate: Double
    private(set) var desk = CommandDesk()
    private(set) var control = EngineControl()
    private(set) var state: RenderState
    private(set) var calls: [Call] = []
    /// The hardware renders. False after a stop, and while the system has
    /// the engine stopped (`systemStops()`).
    private(set) var isRunning = false
    /// The session is held: activated by a start, given back by a stop.
    private(set) var sessionIsActive = false
    /// The next start throws, as when the session cannot be activated.
    var failsToStart = false
    /// The rate the route reports. `retargetSampleRateIfNeeded` follows it.
    var hardwareRate: Double
    /// Samples left before a stop that was asked for pauses the engine, and
    /// the token that says whether it is still due.
    private var stopCountdown: (samples: Int, token: Int)?

    init(sampleRate: Double = 48_000) {
        self.sampleRate = sampleRate
        hardwareRate = sampleRate
        state = RenderState(sampleRate: Float(sampleRate))
    }

    var envelope: Float { state.envelope }
    var master: Float { state.master }
    var gains: SoundGains { desk.gains }
    var breath: BreathParameters { desk.breath }

    /// The calls of one kind, in order.
    var starts: [Call] { calls.filter { if case .start = $0 { return true } else { return false } } }
    var stops: [Call] { calls.filter { if case .stop = $0 { return true } else { return false } } }
    var fades: [Call] { calls.filter { if case .fade = $0 { return true } else { return false } } }
    var masters: [Call] { calls.filter { if case .master = $0 { return true } else { return false } } }

    func forgetCalls() {
        calls.removeAll()
    }

    func start(gains: SoundGains, fadeIn seconds: TimeInterval, level: Float) throws {
        calls.append(.start(fadeIn: seconds, level: level))
        if failsToStart {
            switch control.startFailed(isRendering: isRunning) {
            case .stopWhatSounds:
                beginStop(fadeOut: PlaybackFade.interruption)
            case .releaseSession:
                sessionIsActive = false
            case .waitForStop:
                break
            }
            throw EngineError.formatUnavailable
        }
        sessionIsActive = true
        control.started()
        stopCountdown = nil
        if control.startsFromSilence(isRendering: isRunning) {
            state.resetForFreshStart()
        }
        desk.gains = gains
        desk.fadeEnvelope(
            to: level,
            samples: EngineControl.startRamp(fadeIn: seconds, sampleRate: sampleRate),
            shape: FadeShape.easeOut
        )
        isRunning = true
    }

    func updateGains(_ gains: SoundGains) {
        calls.append(.gains)
        desk.gains = gains
    }

    func setBreathing(_ parameters: BreathParameters) {
        calls.append(.breathing(parameters))
        desk.breath = parameters
    }

    func setMaster(_ level: Float, over seconds: TimeInterval) {
        calls.append(.master(level: level, seconds: seconds))
        desk.rampMaster(
            to: level,
            samples: control.masterRamp(over: seconds, sampleRate: sampleRate, isRendering: isRunning)
        )
    }

    func fade(to level: Float, over seconds: TimeInterval) {
        calls.append(.fade(level: level, seconds: seconds))
        desk.fadeEnvelope(to: level, samples: PlaybackFade.samples(seconds, sampleRate: sampleRate))
    }

    func stop(fadeOut seconds: TimeInterval) {
        calls.append(.stop(fadeOut: seconds))
        beginStop(fadeOut: seconds)
    }

    private func beginStop(fadeOut seconds: TimeInterval) {
        desk.fadeEnvelope(to: 0, samples: PlaybackFade.samples(seconds, sampleRate: sampleRate))
        let token = control.stopRequested()
        stopCountdown = (Int(((seconds + 0.02) * sampleRate).rounded()), token)
        if !isRunning {
            // Nothing renders, so nothing counts the fade down: it is due.
            finishStop()
        }
    }

    private func finishStop() {
        guard let pending = stopCountdown else { return }
        stopCountdown = nil
        guard control.stopIsDue(pending.token) else { return }
        isRunning = false
        sessionIsActive = false
        desk.breath = .off
    }

    var isStopping: Bool { control.isStopping(isRendering: isRunning) }

    /// The route reports another rate: the render state is prepared for it
    /// with the engine stopped, as `buildGraph` does, and the engine starts
    /// again if the night still plays. Nothing is asked of the fades.
    func retargetSampleRateIfNeeded(gains: SoundGains) throws {
        calls.append(.retarget)
        if abs(hardwareRate - sampleRate) > 0.5 {
            desk.gains = gains
            sampleRate = hardwareRate
            isRunning = false
            state.prepare(sampleRate: Float(sampleRate))
        }
        configurationChanged()
    }

    func invalidateGraph() {
        calls.append(.invalidate)
        control.invalidated()
        isRunning = false
        stopCountdown = nil
        desk.breath = .off
    }

    func smoothedOutputRMS(tau: TimeInterval) -> Float {
        isRunning ? state.outputMeter.rms : 0
    }

    /// `AVAudioEngine` stops itself when the configuration changes.
    func systemStops() {
        isRunning = false
    }

    /// What the engine does on `AVAudioEngineConfigurationChange`: it
    /// starts again only if it is still wanted.
    func configurationChanged() {
        if control.shouldRestart(isRendering: isRunning) {
            isRunning = true
        }
    }

    /// Renders `seconds` of sound as the callback would and returns its RMS.
    /// A stop that comes due pauses the engine, and nothing more is rendered.
    @discardableResult
    func render(seconds: TimeInterval) -> Float {
        let frames = Int((seconds * sampleRate).rounded())
        let command = desk.command
        var sum = 0.0
        var rendered = 0
        for _ in 0..<frames {
            guard isRunning else { break }
            let frame = state.processStereo(command)
            sum += Double(frame.left * frame.left + frame.right * frame.right) * 0.5
            rendered += 1
            if let pending = stopCountdown {
                if pending.samples <= 1 {
                    finishStop()
                } else {
                    stopCountdown = (pending.samples - 1, pending.token)
                }
            }
        }
        return rendered > 0 ? Float((sum / Double(rendered)).squareRoot()) : 0
    }
}

/// The audio session as a test sees it: the route is whatever the test says,
/// and the events are raised by hand.
final class ScriptedSession: AudioSessionObserving {
    var onInterruptionBegan: (@MainActor (InterruptionKind) -> Void)?
    var onInterruptionEnded: (@MainActor () -> Void)?
    var onOutputLost: (@MainActor () -> Void)?
    var onOutputAvailable: (@MainActor () -> Void)?
    var onRouteChange: (@MainActor () -> Void)?
    var onMediaServicesReset: (@MainActor () -> Void)?
    var onCallChanged: (@MainActor (Bool) -> Void)?

    var currentRoute = OutputRoute.builtInSpeaker
    var isOtherAudioPlaying = false
    private(set) var started = false

    static let airPods = OutputRoute.external(id: "airpods")
    static let speakerInTheRoom = OutputRoute.external(id: "bedroom")

    func start() {
        started = true
    }

    @MainActor
    func interrupt(_ kind: InterruptionKind = .system) {
        onInterruptionBegan?(kind)
    }

    @MainActor
    func endInterruption() {
        onInterruptionEnded?()
    }

    @MainActor
    func call(_ inCall: Bool) {
        onCallChanged?(inCall)
    }

    /// The output in use goes away and the system falls back to `route`.
    @MainActor
    func loseOutput(fallingBackTo route: OutputRoute = .builtInSpeaker) {
        currentRoute = route
        onOutputLost?()
    }

    @MainActor
    func connect(_ route: OutputRoute) {
        currentRoute = route
        onOutputAvailable?()
    }

    @MainActor
    func resetMediaServices() {
        onMediaServicesReset?()
    }
}

/// The lock screen: what it was told, and its three commands.
final class ScriptedNowPlaying: NowPlayingControlling {
    private(set) var titles: [String] = []
    private(set) var isPlaying = false
    private(set) var elapsedResets = 0
    private var onPlay: (@MainActor () -> Void)?
    private var onPause: (@MainActor () -> Void)?
    private var onToggle: (@MainActor () -> Void)?

    var title: String? { titles.last }

    func install(
        onPlay: @escaping @MainActor () -> Void,
        onPause: @escaping @MainActor () -> Void,
        onToggle: @escaping @MainActor () -> Void
    ) {
        self.onPlay = onPlay
        self.onPause = onPause
        self.onToggle = onToggle
    }

    func update(isPlaying: Bool, title: String) {
        self.isPlaying = isPlaying
        titles.append(title)
    }

    func resetElapsed() {
        elapsedResets += 1
    }

    @MainActor func pressPlay() { onPlay?() }
    @MainActor func pressPause() { onPause?() }
    @MainActor func pressToggle() { onToggle?() }
}

/// A clock a test moves.
final class TestClock {
    var now: Date
    init(_ now: Date) { self.now = now }
}

/// A mixer on doubles: no audio session, no store, no timers on the run
/// loop. The test moves the clock and the harness ticks what would tick.
@MainActor
struct NightHarness {
    let model: MixerModel
    let engine: OfflineEngine
    let session: ScriptedSession
    let nowPlaying: ScriptedNowPlaying
    let clock: TestClock
    let defaults: UserDefaults
    let purchases: PurchaseManager

    static let trialStart = Date(timeIntervalSinceReferenceDate: 700_000_000)

    static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    /// `hour`:`minute` UTC on a fixed day; `day` 18 is the morning after.
    static func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = day
        components.hour = hour
        components.minute = minute
        return utc.date(from: components) ?? trialStart
    }

    /// `free`: the trial ran out and nothing was bought.
    init(at start: Date, free: Bool = false, defaults suite: UserDefaults? = nil) throws {
        let defaults: UserDefaults
        if let suite {
            defaults = suite
        } else {
            let name = "sleepnoise.tests.\(UUID().uuidString)"
            defaults = try XCTUnwrap(UserDefaults(suiteName: name))
            defaults.removePersistentDomain(forName: name)
        }
        let purchases = PurchaseManager(defaults: defaults, now: Self.trialStart)
        if free {
            purchases.startTrialIfNeeded(now: Self.trialStart)
            purchases.refreshAccess(now: Self.trialStart.addingTimeInterval(8 * 86_400), canDowngrade: true)
        }
        let clock = TestClock(start)
        let engine = OfflineEngine()
        let session = ScriptedSession()
        let nowPlaying = ScriptedNowPlaying()
        self.defaults = defaults
        self.purchases = purchases
        self.clock = clock
        self.engine = engine
        self.session = session
        self.nowPlaying = nowPlaying
        model = MixerModel(
            purchases: purchases,
            defaults: defaults,
            now: { clock.now },
            calendar: Self.utc,
            audio: MixerAudio(engine: engine, session: session, nowPlaying: nowPlaying, isLive: false)
        )
    }

    /// Moves the clock second by second and ticks what the run loop would:
    /// the timer, Small Hours, the guide of the tide and the model's own
    /// one-shots.
    func advance(seconds: Int) {
        for _ in 0..<seconds {
            clock.now += 1
            model.timer.tick()
            model.smallHours.tick()
            model.breathing.advance()
        }
        settle()
    }

    /// Jumps the clock without a tick in between: the app was not running.
    func jump(to date: Date) {
        clock.now = date
    }

    /// What the model's own timers would do once their time has come.
    func settle() {
        model.expireNightIfOver()
        model.refreshSpeakerOffer()
        model.refreshBedtimeDimming()
    }
}
