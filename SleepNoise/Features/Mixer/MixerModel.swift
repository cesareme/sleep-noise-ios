import Combine
import Foundation

/// Why the bed is paused. The page says it in words.
enum PauseCause: Equatable {
    /// The person paused.
    case person
    /// The person paused from the headphones or the lock screen while the
    /// night was playing on headphones (C49).
    case headphones
    /// The system took the output: an alarm, Siri, another app. It does not
    /// say which.
    case system
    /// A call took the output (`CXCallObserver`, C48).
    case call
    /// The output went away: earbuds out.
    case lostOutput

    /// How long the bed takes to leave.
    var fade: TimeInterval {
        switch self {
        case .person: return PlaybackFade.pause
        case .headphones: return RoutePolicy.headphonesPauseFadeOut
        case .system, .call: return PlaybackFade.interruption
        case .lostOutput: return PlaybackFade.lostOutput
        }
    }
}

/// The three things the mixer drives that reach outside the process: the
/// engine, the audio session and the lock screen. The app passes the real
/// ones; the tests of the model pass doubles and never open a session.
struct MixerAudio {
    var engine: AudioEngineControlling
    var session: AudioSessionObserving
    var nowPlaying: NowPlayingControlling
    /// False for doubles: the model then leaves the store and the Shortcuts
    /// bridge alone, and starts no timer of its own on the run loop.
    var isLive: Bool

    static func live() -> MixerAudio {
        MixerAudio(
            engine: SleepAudioEngine(),
            session: AudioSessionObserver(),
            nowPlaying: NowPlayingController(),
            isLive: true
        )
    }
}

/// What became of a request to change a level.
enum LevelChange: Equatable {
    case applied
    /// A Pro layer without access: nothing changed.
    case needsPro
    /// Six layers already sound: the seventh is not added.
    case capReached
}

@MainActor
final class MixerModel: ObservableObject {
    /// The most layers that may sound at once (C19). A rule of the model:
    /// the interface never draws slots for it.
    nonisolated static let maxSimultaneousLayers = 6
    /// What Play raises when nothing would sound: the instrument always
    /// sounds.
    nonisolated static let fallbackSound = SoundID.pink
    nonisolated static let fallbackLevel: Float = 0.4
    /// Where the tide puts a silent ocean so that it can be heard. It never
    /// lowers it again: the tide does not switch off a layer it raised.
    nonisolated static let tideOceanLevel: Float = 0.4
    /// The lowest the session level goes: the vertical axis of Night turns
    /// the night down, it does not switch it off in the dark by accident.
    nonisolated static let minimumSessionLevel: Float = 0.05
    /// Seconds the level takes to come back when "+15 min" calls the final
    /// fade off.
    nonisolated static let fadeReturn: TimeInterval = 3

    @Published var levels: [SoundID: Float]
    @Published private(set) var isPlaying = false
    @Published var audioError: String?
    /// The Pro sheet is asked for. Only `offerPro()` raises it, and never at
    /// night.
    @Published private(set) var showPaywall = false
    /// Paused, and why. Nil at rest and once a night has ended.
    @Published private(set) var pauseCause: PauseCause?
    /// Starts that failed in a row, for the ladder of the error line.
    @Published private(set) var startFailures = 0
    /// Play found nothing to sound and raised the fallback layer. Cleared by
    /// the next change of the mix.
    @Published private(set) var isPlayingFallback = false
    /// The page shows one ink: it came back from the Night screen. It lasts
    /// until the person leaves it; no clock ends it (C40).
    @Published private(set) var isNightSession = false
    /// Moves whenever the whole mix is replaced, so the page knows when to
    /// choose its rows again.
    @Published private(set) var mixRevision = 0
    /// What the page and Now Playing call the loaded mix: its name, or
    /// "<name> · without <layers>" when it plays trimmed.
    @Published private(set) var loadedMixName: String?
    /// The loaded mix's own name, without the trimmed part: what a save or a
    /// rename starts from.
    private(set) var loadedMixBaseName: String?
    /// House mix last loaded, until the person edits a level.
    @Published private(set) var activeHouseMix: HouseMix?
    /// The saved mix that is loaded as it was saved, until the person edits
    /// a level or deletes it.
    @Published private(set) var loadedSavedMixID: UUID?
    /// Night screen is covering the interface. Audio keeps running when this
    /// turns off.
    @Published private(set) var isBedtime = false
    /// The loaded mix has layers that are muted because they need Pro.
    @Published private(set) var loadedMixWasStripped = false
    /// Short note under the breathing card ("Ocean raised so you can hear it").
    @Published private(set) var breathingNote: String?
    /// The Night screen has gone 60 s without a touch and is drawn dimmed
    /// (C46). Not a state of the night: only how bright it is drawn.
    @Published private(set) var isBedtimeDimmed = false
    /// "Keep screen on" (C46). Stored.
    @Published private(set) var keepScreenOn: KeepScreenOn
    /// Small Hours is what plays, or is paused: the fixed recipe, not the
    /// mix (C05). Nothing is sold while it lasts, at any hour.
    @Published private(set) var isSmallHours = false
    /// The session level, `minimumSessionLevel` to 1 (C51): the vertical
    /// axis of Night and Small Hours, and the speaker cap. It belongs to the
    /// night: a new night starts at 1 and it is never stored. Never the
    /// system volume.
    @Published private(set) var sessionLevel: Float = 1
    /// "Keep playing on speaker" is offered until then (C49). Nil when it
    /// is not on offer.
    @Published private(set) var speakerOfferUntil: Date?
    /// When the last night ended by itself (its timer, a long pause, the
    /// morning): "Ended at 03:42" on the Night screen. Nil while a night is
    /// open and after Small Hours, which ends without a word.
    @Published private(set) var sessionEndedAt: Date?
    /// The Night screen shows its two first-time sentences: nobody has
    /// seen them on this install yet. They are fixed text, not a tip (C65).
    @Published private(set) var showsNightIntro = false
    /// The night came back on the iPhone's speaker turned down to the cap
    /// (C49): the page says "Playing · at 40" until the next touch. Nil
    /// otherwise. A note, not a state: the level itself is `sessionLevel`.
    @Published private(set) var cappedLevelNote: Int?
    /// The output that went away was a pair of headphones, as far as the
    /// system tells: only then does the pause say "headphones".
    @Published private(set) var lostOutputWasHeadphones = true

    let purchases: PurchaseManager
    let mixStore: MixStore
    let timer: SleepTimerController
    let breathing: BreathingGuideController
    let smallHours: SmallHoursController

    private let audio: MixerAudio
    private var engine: AudioEngineControlling { audio.engine }
    private var nowPlaying: NowPlayingControlling { audio.nowPlaying }
    private var sessionObserver: AudioSessionObserving { audio.session }
    private let defaults: UserDefaults
    private let now: () -> Date
    private let calendar: Calendar
    private let levelsKey = "sleepnoise.levels.v1"
    /// Which mix the stored levels are, while they are still that mix: its
    /// name, the recipe it came with and where it came from.
    nonisolated static let loadedMixKey = "sleepnoise.loadedMix.v1"
    /// Where the timer lived when it was only a length in minutes.
    nonisolated static let legacyTimerKey = "sleepnoise.timerMinutes.v1"
    nonisolated static let timerKey = "sleepnoise.timer.v2"
    /// Set on the first launch of an install that never had another
    /// timer: with it, "nothing stored" is the first-use timer. Without it
    /// and with levels already stored, the install comes from a version
    /// where no timer meant "Off".
    nonisolated static let timerFirstUseKey = "sleepnoise.timer.firstUse.v1"
    nonisolated static let keepScreenOnKey = "sleepnoise.night.keepScreenOn.v1"
    nonisolated static let nightIntroKey = "sleepnoise.night.introShown.v1"
    private var didStart = false
    /// The timer the person chose, as it is stored.
    private var storedTimer: TimerChoice
    /// The interruption that is open, if any (`InterruptionPolicy`).
    private var interruptions: InterruptionTracker
    /// The night was playing when the open interruption began: silent now,
    /// but not paused by the person.
    private var heldByInterruption = false
    private var callInProgress = false
    /// When the night went silent. Nil while it plays and once it is over.
    private var pausedAt: Date?
    /// When the night was paused because its output went away.
    private var lostOutputAt: Date?
    /// The output the night plays on, or played on when it paused.
    private var sessionRoute: OutputRoute?
    /// The output that went away, until something plays again: a night
    /// that ended paused by a lost output still caps the next Play when
    /// what is left is the iPhone's speaker (C49). It is forgotten with
    /// that night's evening: `lostRouteMemory` after the loss, or when the
    /// app is opened by day with the night over.
    private var lostRoute: OutputRoute?
    private var lostRouteAt: Date?
    /// How long a lost output still caps a Play on the speaker.
    nonisolated static let lostRouteMemory: TimeInterval = 6 * 60 * 60
    private var appIsActive = true
    private var bedtimeTouchedAt: Date?
    private var expiryTimer: Timer?
    private var offerTimer: Timer?
    private var dimTimer: Timer?
    private var noteTask: Task<Void, Never>?
    /// The levels the loaded mix came with. Its title is worked out from
    /// these, not from the live levels, which the tide may have raised.
    private var loadedMixRecipe: [SoundID: Float]?
    /// Level rows with a finger on them right now.
    private var liveLevelGestures = 0

    init(
        purchases: PurchaseManager,
        mixStore: MixStore? = nil,
        timer: SleepTimerController? = nil,
        breathing: BreathingGuideController? = nil,
        smallHours: SmallHoursController? = nil,
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { Date() },
        calendar: Calendar = .autoupdatingCurrent,
        audio: MixerAudio? = nil
    ) {
        let audio = audio ?? .live()
        self.audio = audio
        self.purchases = purchases
        self.defaults = defaults
        self.now = now
        self.calendar = calendar
        self.mixStore = mixStore ?? MixStore(defaults: defaults)
        // The timer and Small Hours read the same clock as the model, so a
        // test (or a staged launch for the captures) moves all three at once.
        self.timer = timer ?? SleepTimerController(now: now, calendar: calendar, ticks: audio.isLive)
        self.breathing = breathing ?? BreathingGuideController(defaults: defaults, now: now, ticks: audio.isLive)
        self.smallHours = smallHours ?? SmallHoursController(now: now, ticks: audio.isLive)
        interruptions = InterruptionTracker(calendar: calendar, now: now)
        let storedLevels = Self.loadLevels(defaults: defaults, key: levelsKey)
        storedTimer = Self.timerAtLaunch(defaults: defaults, hasStoredLevels: storedLevels != nil)
        keepScreenOn = defaults.string(forKey: Self.keepScreenOnKey).flatMap(KeepScreenOn.init) ?? .whileCharging
        let isFirstUse = storedLevels == nil
        if let stored = storedLevels {
            levels = stored
            // The levels may still be a mix that was loaded: it keeps its
            // name, and what it plays without, across a restart.
            restoreLoadedMix()
        } else {
            // First use, no onboarding: the house mix "Pink and rain" loaded
            // as it is. Both its layers are free, so it is never trimmed.
            let mix = HouseMix.pinkAndRain
            let load = mix.load(hasFullAccess: purchases.hasFullAccess)
            levels = load.levels
            activeHouseMix = mix
            loadedMixBaseName = mix.localizedName
            loadedMixRecipe = load.levels
            loadedMixName = load.title(name: mix.localizedName)
            loadedMixWasStripped = load.isTrimmed
        }
        // The first night has a timer (03 §5 #8): "Until I sleep", 45
        // minutes. It is not stored, so it is never taken for a choice.
        self.timer.choose(storedTimer)
        if isFirstUse {
            // Stored like any mix that is loaded: the first edit that only
            // writes the levels (a row touched, the ocean the tide raised)
            // must not leave them without the name they came with.
            persistLevels()
            persistLoadedMix()
        }
        bindTimer()
        bindBreathing()
        bindSmallHours()
        bindAccess()
    }

    func startIfNeeded() {
        guard !didStart else { return }
        didStart = true
        if audio.isLive {
            IntentBridge.attach(self)
            purchases.start()
            // Once per launch: the phrases that carry a mix by name only
            // work for the names the app has registered, and someone who
            // never edits their list would never register any.
            SleepNoiseShortcuts.updateAppShortcutParameters()
        }
        installSessionHandlers()
        nowPlaying.install(
            onPlay: { [weak self] in self?.play() },
            onPause: { [weak self] in self?.remotePause() },
            onToggle: { [weak self] in
                guard let self else { return }
                if self.isPlaying { self.remotePause() } else { self.play() }
            }
        )
        nowPlaying.update(isPlaying: false, title: nowPlayingTitle)
    }

    /// Sets the level of a layer. A Pro layer without access does not move
    /// (and asks for the Pro sheet, which the night refuses). A layer raised
    /// from zero while six already sound is not added.
    @discardableResult
    func setLevel(_ sound: SoundID, _ value: Float) -> LevelChange {
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else {
            offerPro()
            return .needsPro
        }
        let next = min(1, max(0, value))
        let current = levels[sound] ?? 0
        if current <= MixLoad.audibleThreshold, next > MixLoad.audibleThreshold,
           soundingLayers.count >= Self.maxSimultaneousLayers {
            return .capReached
        }
        // Nothing changed (a drag that came back, a refused seventh layer
        // let go at zero): the mix keeps its name.
        guard next != current else { return .applied }
        levels[sound] = next
        // A drag writes here on every sample: only what really changes is
        // published.
        let hadName = loadedMixName != nil
        if isPlayingFallback { isPlayingFallback = false }
        if hadName { forgetLoadedMix() }
        if liveLevelGestures == 0 {
            persistLevels()
        }
        if isPlaying {
            engine.updateGains(currentGains())
            // The lock screen follows the page: once, not on every sample.
            if hadName {
                nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
            }
        }
        return .applied
    }

    /// A finger went down on a level row. While it is there the levels are
    /// not written to disk; they are when it leaves.
    func beginLevelGesture() {
        liveLevelGestures += 1
        dismissCappedLevelNote()
    }

    func endLevelGesture() {
        liveLevelGestures = max(0, liveLevelGestures - 1)
        if liveLevelGestures == 0 {
            persistLevels()
        }
    }

    /// The layers that sound: above zero and included at this access level.
    /// A Pro layer that keeps a level without access is not one of them.
    var soundingLayers: [SoundID] {
        SoundID.allCases.filter { sound in
            (levels[sound] ?? 0) > MixLoad.audibleThreshold
                && AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess)
        }
    }

    // MARK: Pro sheet and night

    /// Whether anything may be sold right now: not inside `NightWindow` and
    /// not on the night page.
    var canSell: Bool {
        // Small Hours never sells, whatever the hour (C05).
        !isSmallHours && SaleGate.isOpen(at: now(), calendar: calendar, nightSession: isNightSession)
    }

    /// Asks for the Pro sheet. At night the request is dropped: nothing
    /// opens and nothing is queued for the morning (C08).
    func offerPro() {
        guard canSell else { return }
        showPaywall = true
    }

    func dismissPro() {
        showPaywall = false
    }

    /// A Pro sheet that was already up when the night began comes down: the
    /// gate is not only for new requests. Called when the app comes forward
    /// and when the night page begins.
    func closeSaleIfNight() {
        if showPaywall, !canSell {
            showPaywall = false
        }
    }

    /// The page keeps one ink from now on (C40). Called when the person
    /// comes back from the Night screen.
    func beginNightSession() {
        isNightSession = true
        closeSaleIfNight()
    }

    /// The deliberate way out of the night page: a tap on the name.
    func endNightSession() {
        isNightSession = false
    }

    /// Level of what the engine is producing right now, for the Horizon: the
    /// RMS measured on the render thread, smoothed with `tau` seconds. 0 when
    /// nothing sounds.
    func outputLevel(tau: TimeInterval) -> Float {
        engine.smoothedOutputRMS(tau: tau)
    }

    /// The model's clock, for the views that show an hour (the Night
    /// screen): a staged launch runs on a pinned one.
    var clockNow: Date { now() }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    // MARK: Play and pause

    /// Play, asked for by the person: the Disc, the lock screen, the
    /// headphones, a Shortcut, the Night screen. It resumes the night that
    /// is paused, or begins a new one when none is open or the pause lasted
    /// too long (`SessionPause`). Whatever interruption was open is
    /// forgotten: what the person chose meanwhile wins.
    ///
    /// Play never starts the trial, from the Disc or from a Shortcut: only
    /// "Start the trial" in the Pro sheet does (`startTrial()`, C07).
    func play() {
        startIfNeeded()
        // Kept until the start is known to work: a Play that fails during a
        // call must not cost the night the resume that call owes it (C48).
        let open = interruptions
        let wasHeld = heldByInterruption
        interruptions.cancel()
        heldByInterruption = false
        guard !isPlaying else { return }
        audioError = nil
        if isSmallHours, !nightIsOpen(at: now()) {
            // Small Hours left paused past its twenty minutes, and nothing
            // ran to end it (the app was suspended): it is over. Play is
            // the mix, in a new night.
            closeNight(endedAt: nil)
        }
        guard startSound(asked: true) else {
            // Whatever night was open stays as it was, its timer and its
            // interruption included: the page says the sound did not start,
            // and the line retries.
            interruptions = open
            heldByInterruption = wasHeld
            purchases.applyAccess(canDowngrade: true)
            noteStartFailure()
            return
        }
    }

    /// Every start goes through here: the person's Play (`asked`) and the
    /// resumes nobody asked for (the end of an interruption, the output
    /// coming back, a media-services reset). An unasked resume continues the
    /// tide's window instead of guiding a sleeper again, never raises the
    /// fallback layer and never changes the session level.
    @discardableResult
    private func startSound(
        asked: Bool,
        fadeIn requested: TimeInterval? = nil
    ) -> Bool {
        let now = now()
        let current = sessionObserver.currentRoute
        // Whoever resumes unasked has already decided it is the same night:
        // a call never ends it, however long it was (C48).
        if asked, !nightIsOpen(at: now) {
            beginNewNight()
            // The one moment the trial is evaluated: a new night starts
            // (C07). Not a resume inside the same night, which keeps what
            // it had, and not Small Hours, which plays for everyone. A
            // trial that ran out ends here, before anything sounds: the mix
            // plays trimmed from its first sample and nothing is said.
            if !isSmallHours {
                purchases.evaluateTrialAtSessionStart(now: now)
            }
        }
        var capped = false
        if asked {
            forgetLostRouteIfStale(at: now)
            // Capped only when the output changed to the iPhone's speaker
            // since the night paused (C49).
            let before = sessionLevel
            sessionLevel = RoutePolicy.resumeMaster(
                pausedOn: sessionRoute ?? lostRoute ?? current,
                current: current,
                master: sessionLevel
            )
            capped = sessionLevel < before
        }
        let fadeIn: TimeInterval
        let level: Float
        if isSmallHours {
            fadeIn = requested ?? smallHours.recipe.fadeIn
            if smallHours.isPaused {
                smallHours.resume(risingOver: fadeIn)
            } else if !smallHours.isActive {
                smallHours.begin()
            }
            level = smallHours.fadeLevel
        } else {
            fadeIn = requested ?? PlaybackFade.start
            if asked, isSilent {
                // Nothing would sound: an empty mix, or one whose every
                // layer needs Pro. The instrument always sounds: the
                // fallback layer comes up as a real level and the mix keeps
                // its name.
                writeLevel(Self.fallbackSound, Self.fallbackLevel)
                isPlayingFallback = true
            }
            // The guide publishes before the engine starts, so the first
            // command the render thread reads already carries the breath
            // (and its epoch).
            if asked {
                startBreathingIfEnabled()
            } else {
                resumeBreathingIfEnabled()
            }
            // The timer anchors its dates here and calls nothing back: a
            // night that resumes inside its final fade rises to where that
            // fade stands, and the timer asks for the rest of it afterwards.
            timer.start(risingOver: fadeIn)
            level = timer.fadeLevel
        }
        // With the engine stopped this is not a ramp: the level is there
        // when the bed rises. When something is still sounding (Small
        // Hours taking over from the mix, a Play inside the tail of a
        // pause) the level moves with the rise, never in 50 ms: a new
        // night starts at 1, and that must not arrive as a jump.
        engine.setMaster(effectiveMaster, over: fadeIn)
        do {
            try engine.start(gains: currentGains(), fadeIn: fadeIn, level: level)
        } catch {
            if isSmallHours {
                smallHours.pause()
            } else {
                timer.pause()
                breathing.end()
            }
            return false
        }
        isPlaying = true
        pauseCause = nil
        pausedAt = nil
        lostOutputAt = nil
        lostRoute = nil
        lostRouteAt = nil
        heldByInterruption = false
        sessionRoute = current
        startFailures = 0
        cancelExpiry()
        clearSpeakerOffer()
        let note = capped ? NightAxis.percent(sessionLevel) : nil
        if cappedLevelNote != note { cappedLevelNote = note }
        nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        return true
    }

    /// One more start that did not sound. The page reads the count and says
    /// more with each one.
    private func noteStartFailure() {
        startFailures += 1
        audioError = String(localized: "pagina.error.inicio")
    }

    /// Pause, asked for by the person. The bed leaves over the fade of its
    /// cause: never a cut (`PlaybackFade.pause`), and three seconds when it
    /// comes from the headphones. It also closes an interruption that was
    /// holding the night: a stop during a call is not undone when the call
    /// ends.
    func pause(cause: PauseCause = .person) {
        interruptions.cancel()
        let wasHeld = heldByInterruption
        heldByInterruption = false
        if isPlaying {
            stopSound(cause: cause, fade: cause.fade, held: false)
        } else if wasHeld {
            // Silent already, under the interruption: now it is the
            // person's pause, and access lost meanwhile applies.
            pauseCause = cause
            purchases.applyAccess(canDowngrade: true)
        }
    }

    /// Pause from the lock screen or the headphones (C49): on headphones the
    /// bed takes three seconds to leave, because earbuds send this command
    /// by themselves when someone falls asleep.
    func remotePause() {
        // Only what the system says is a pair of headphones: a speaker in
        // the room or AirPlay is not "headphones" on the page.
        pause(cause: sessionObserver.currentRoute.isHeadphones ? .headphones : .person)
    }

    /// The note of the capped level has been read: any touch takes it away.
    func dismissCappedLevelNote() {
        if cappedLevelNote != nil { cappedLevelNote = nil }
    }

    /// A lost output caps the next Play on the speaker for the rest of that
    /// night, not for ever (C49 is about resuming that night).
    private func forgetLostRouteIfStale(at now: Date) {
        guard let lostRouteAt else { return }
        if now.timeIntervalSince(lostRouteAt) >= Self.lostRouteMemory {
            lostRoute = nil
            self.lostRouteAt = nil
        }
    }

    /// The sound stops and the night stays open. `held`: an interruption
    /// took it, so it is not the end of the night: access lost meanwhile
    /// waits until the session really ends.
    private func stopSound(cause: PauseCause, fade: TimeInterval, held: Bool) {
        guard isPlaying else { return }
        dismissCappedLevelNote()
        heldByInterruption = held
        endPlayback(engineAction: .stop(fadeOut: fade), canDowngrade: !held)
        pauseCause = cause
        pausedAt = now()
        scheduleExpiry()
    }

    // MARK: The night as a session

    /// A night is open while it plays and, once paused, for as long as
    /// `SessionPause` allows. One rule for every pause.
    private func nightIsOpen(at now: Date) -> Bool {
        if isPlaying { return true }
        guard pauseCause != nil, let pausedAt else { return false }
        return !SessionPause.isOver(pausedAt: pausedAt, now: now)
    }

    /// A night that is neither playing nor paused within its twenty
    /// minutes is over, whether or not anything noticed yet.
    private func beginNewNight() {
        cancelExpiry()
        pauseCause = nil
        pausedAt = nil
        heldByInterruption = false
        sessionRoute = nil
        lostOutputAt = nil
        sessionLevel = 1
        sessionEndedAt = nil
        dismissCappedLevelNote()
        timer.reset()
        nowPlaying.resetElapsed()
    }

    /// The night is over: its timer ran out, it stayed paused too long, the
    /// morning ended it, or Small Hours finished. Nothing resumes it. The
    /// page goes back to silence, not to "Paused".
    private func closeNight(endedAt: Date?) {
        cancelExpiry()
        clearSpeakerOffer()
        interruptions.cancel()
        heldByInterruption = false
        pauseCause = nil
        pausedAt = nil
        sessionRoute = nil
        lostOutputAt = nil
        dismissCappedLevelNote()
        timer.reset()
        let wasSmallHours = isSmallHours
        if wasSmallHours {
            smallHours.end()
            engine.setBreathing(.off)
            isSmallHours = false
            // Small Hours is a night surface: what is behind it is the
            // night page, not the Night screen it may have come from.
            isBedtime = false
            cancelDimming()
            beginNightSession()
        }
        // When Small Hours ends, nothing is said about it (C60).
        sessionEndedAt = wasSmallHours ? nil : endedAt
        nowPlaying.update(isPlaying: false, title: nowPlayingTitle)
        purchases.applyAccess(canDowngrade: !isPlaying)
    }

    /// The session level times what the blanket leaves of it.
    private var effectiveMaster: Float {
        sessionLevel * (isSmallHours ? 1 : timer.blanketGain)
    }

    /// The vertical axis of Night and Small Hours (C51). Smoothed by the
    /// engine; never the system volume, never stored.
    func setSessionLevel(_ level: Float) {
        let next = min(1, max(Self.minimumSessionLevel, level))
        guard next != sessionLevel else { return }
        sessionLevel = next
        dismissCappedLevelNote()
        engine.setMaster(effectiveMaster, over: 0)
    }

    // MARK: Timer

    /// The person's choice in the timer sheet: stored, and counting at once
    /// when the night is playing. The whole timer is free (C03): nothing
    /// here can ask for Pro.
    func chooseTimer(_ choice: TimerChoice) {
        storedTimer = choice
        if let data = try? JSONEncoder().encode(choice) {
            defaults.set(data, forKey: Self.timerKey)
        }
        defaults.removeObject(forKey: Self.legacyTimerKey)
        applyTimer(choice)
    }

    private func applyTimer(_ choice: TimerChoice) {
        let wasDipped = timer.blanketGain < 1
        let wasFading = timer.isFading
        timer.choose(choice)
        guard isPlaying, !isSmallHours else { return }
        timer.start(risingOver: Self.fadeReturn)
        if wasDipped {
            // The blanket that had eased the level down is gone.
            engine.setMaster(effectiveMaster, over: TimerMath.blanketDipRamp)
        }
        if wasFading || timer.isFading {
            // A final fade that was under way belonged to the timer that is
            // gone: the level goes to where the new one stands.
            engine.fade(to: timer.fadeLevel, over: Self.fadeReturn)
            if wasFading, !timer.isFading { resumeBreathingIfEnabled() }
        }
    }

    /// "Until I sleep" with this length, or no timer. A length outside the
    /// range is not a sale (C03): it is ignored.
    func selectTimer(minutes: Int?) {
        guard let minutes else {
            chooseTimer(storedTimer.with(mode: .off))
            return
        }
        guard AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) else { return }
        var choice = storedTimer.with(mode: .untilAsleep)
        choice.minutes = minutes
        chooseTimer(choice)
    }

    /// "+15 min" is there to be pressed: a timer is chosen and its count
    /// exists (running or paused). It never creates one (C47).
    var canExtendTimer: Bool {
        !isSmallHours && timer.hasCount
    }

    /// "+15 min". Free at any hour and without a ceiling. Inside the final
    /// fade it calls the fade off and the level comes back.
    @discardableResult
    func extendTimer() -> Bool {
        guard canExtendTimer else { return false }
        return timer.extend()
    }

    /// The timer has no Pro length any more (C03), so there is nothing to
    /// take away when access changes. Kept for the page, which still calls
    /// it; a stored length outside the range is the only thing it drops.
    func clampTimerToEntitlement() {
        guard let minutes = timer.selectedMinutes else { return }
        guard !AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) else { return }
        let wasCounting = timer.remaining != nil
        selectTimer(minutes: nil)
        if wasCounting {
            pause()
        }
    }

    /// The timer a launch starts with. A stored choice rules. With nothing
    /// stored, an install that already has levels and never saw this
    /// version comes from one where no timer meant "Off": it stays off, and
    /// that is stored as the choice it was. Only an install with nothing at
    /// all gets the first-use timer (03 §5 #8), which is marked, not stored,
    /// so it is never taken for a choice.
    nonisolated static func timerAtLaunch(defaults: UserDefaults, hasStoredLevels: Bool) -> TimerChoice {
        if let stored = storedTimer(defaults: defaults) { return stored }
        if hasStoredLevels, !defaults.bool(forKey: timerFirstUseKey) {
            if let data = try? JSONEncoder().encode(TimerChoice.off) {
                defaults.set(data, forKey: timerKey)
            }
            return .off
        }
        defaults.set(true, forKey: timerFirstUseKey)
        return .firstUse
    }

    /// The stored choice, from either format. Nil when the person never
    /// chose: the first-use timer then stands in.
    nonisolated static func storedTimer(defaults: UserDefaults) -> TimerChoice? {
        if let data = defaults.data(forKey: timerKey),
           let choice = try? JSONDecoder().decode(TimerChoice.self, from: data) {
            // Through the initialiser, which keeps every field in range.
            return TimerChoice(
                mode: choice.mode,
                minutes: choice.minutes,
                endHour: choice.endHour,
                endMinute: choice.endMinute
            )
        }
        if let minutes = defaults.object(forKey: legacyTimerKey) as? Int,
           (1...AccessPolicy.maxTimerMinutes).contains(minutes) {
            return .untilAsleep(minutes)
        }
        return nil
    }

    // MARK: Mixes

    /// What the save field starts with: the name the mix already has, or
    /// the one its layers give it (copy guide §4.2).
    var suggestedMixName: String {
        loadedMixBaseName ?? MixAutoName.name(levels: levels)
    }

    /// Three saved mixes are free; a fourth needs full access.
    var canSaveMix: Bool {
        AccessPolicy.canSave(existingCount: mixStore.mixes.count, hasFullAccess: purchases.hasFullAccess)
    }

    /// The mix that is loaded as it was loaded: a house mix or a saved one.
    /// Nil once a level is edited: the mix is "Tonight" then.
    var loadedMix: MixReference? {
        if let activeHouseMix { return .house(activeHouseMix) }
        if let loadedSavedMixID { return .saved(loadedSavedMixID) }
        return nil
    }

    /// Saves the live mix under a name, whole: a Pro layer that is muted
    /// keeps its level in the recipe (C23). A name left empty is the one
    /// the field started with. A fourth mix without access is a request for
    /// the Pro sheet, which the night refuses; nothing is lost either way.
    func saveCurrent(name: String) -> SaveMixResult {
        let asked = MixCodec.cleanName(name)
        let result = mixStore.save(
            name: asked.isEmpty ? suggestedMixName : asked,
            levels: levels,
            hasFullAccess: purchases.hasFullAccess
        )
        switch result {
        case .saved(let mix):
            // The live mix is that saved mix from now on. Nothing about the
            // sound or the rows of the page changes.
            setIdentity(
                .saved(mix.id),
                name: mix.name,
                load: MixLoad(levels: levels, hasFullAccess: purchases.hasFullAccess)
            )
            refreshNowPlayingTitle()
            shortcutMixesDidChange()
        case .needsPro:
            offerPro()
        case .emptyName:
            break
        }
        return result
    }

    /// Loads a saved mix. Pro layers are muted (their levels are kept) when
    /// they are not included: the mix loads trimmed, like a house mix, and
    /// its title says what it plays without. Never a sheet.
    @discardableResult
    func apply(_ mix: SavedMix) -> Bool {
        let next = mix.levelsBySound
        let load = MixLoad(levels: next, hasFullAccess: purchases.hasFullAccess)
        levels = next
        setLoadedMix(.saved(mix.id), name: mix.name, load: load)
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        }
        return load.isTrimmed
    }

    /// Gives a saved mix another name. If it is the loaded one, the page
    /// and the lock screen follow. A name left empty changes nothing.
    @discardableResult
    func renameMix(_ id: UUID, to name: String) -> Bool {
        guard let stored = mixStore.rename(id, to: name) else { return false }
        if loadedSavedMixID == id, let recipe = loadedMixRecipe {
            setIdentity(
                .saved(id),
                name: stored,
                load: MixLoad(levels: recipe, hasFullAccess: purchases.hasFullAccess)
            )
            refreshNowPlayingTitle()
        }
        shortcutMixesDidChange()
        return true
    }

    /// Deletes a saved mix. If it is the loaded one, what sounds is not
    /// touched: the live mix is "Tonight" again.
    func deleteMix(_ id: UUID) {
        mixStore.delete(id)
        if loadedSavedMixID == id {
            forgetLoadedMix()
            refreshNowPlayingTitle()
        }
        shortcutMixesDidChange()
    }

    /// Moves a saved mix one place up or down its list.
    func moveMix(_ id: UUID, by offset: Int) {
        if mixStore.move(id, by: offset) {
            shortcutMixesDidChange()
        }
    }

    /// "Clear" (08 §2.2): every layer at zero and the mix is "Tonight".
    /// What was sounding leaves like a pause and the night is over, so the
    /// page says "Silent", not "Paused". The saved mix it came from is not
    /// touched; loading a mix undoes it.
    func clearMix() {
        guard !isSmallHours else { return }
        interruptions.cancel()
        heldByInterruption = false
        forgetLoadedMix()
        if isPlaying {
            // The engine fades with the gains it has: the levels below are
            // not sent to it.
            endPlayback(engineAction: .stop(fadeOut: PlaybackFade.pause), canDowngrade: true)
        }
        closeNight(endedAt: nil)
        levels = Self.defaultLevels()
        isPlayingFallback = false
        mixRevision += 1
        persistLevels()
    }

    /// Every whole replacement of `levels` by a mix ends here: the title
    /// follows the mix as it was loaded, and the page chooses its rows
    /// again.
    private func setLoadedMix(_ reference: MixReference, name: String, load: MixLoad) {
        setIdentity(reference, name: name, load: load)
        isPlayingFallback = false
        mixRevision += 1
    }

    /// Which mix the live levels are, and under what name. Stored, so the
    /// mix keeps its name and its trimmed title across a restart.
    private func setIdentity(_ reference: MixReference, name: String, load: MixLoad) {
        switch reference {
        case .house(let mix):
            if activeHouseMix != mix { activeHouseMix = mix }
            if loadedSavedMixID != nil { loadedSavedMixID = nil }
        case .saved(let id):
            if activeHouseMix != nil { activeHouseMix = nil }
            if loadedSavedMixID != id { loadedSavedMixID = id }
        }
        loadedMixBaseName = name
        loadedMixRecipe = load.levels
        let title = load.title(name: name)
        if loadedMixName != title { loadedMixName = title }
        if loadedMixWasStripped != load.isTrimmed { loadedMixWasStripped = load.isTrimmed }
        persistLoadedMix()
    }

    /// The live mix is no longer the one that was loaded: it is "Tonight".
    private func forgetLoadedMix() {
        if loadedMixName != nil { loadedMixName = nil }
        loadedMixBaseName = nil
        loadedMixRecipe = nil
        if loadedMixWasStripped { loadedMixWasStripped = false }
        if activeHouseMix != nil { activeHouseMix = nil }
        if loadedSavedMixID != nil { loadedSavedMixID = nil }
        defaults.removeObject(forKey: Self.loadedMixKey)
    }

    /// The identity as it is stored. The name of a house mix is not kept:
    /// it is read from the catalog again, in whatever language the app
    /// speaks then.
    private struct StoredMixIdentity: Codable {
        var house: String?
        var saved: UUID?
        var name: String
        var recipe: [MixLevel]
    }

    private func persistLoadedMix() {
        guard let name = loadedMixBaseName, let recipe = loadedMixRecipe, loadedMix != nil else {
            defaults.removeObject(forKey: Self.loadedMixKey)
            return
        }
        let stored = StoredMixIdentity(
            house: activeHouseMix?.rawValue,
            saved: loadedSavedMixID,
            name: name,
            recipe: SoundID.allCases.compactMap { sound in
                let level = recipe[sound] ?? 0
                return level > 0 ? MixLevel(sound: sound, value: level) : nil
            }
        )
        guard let data = try? JSONEncoder().encode(stored) else { return }
        defaults.set(data, forKey: Self.loadedMixKey)
    }

    /// Reads the identity back at launch. A house mix this version does not
    /// know, or a saved mix that is no longer in the list, is forgotten:
    /// the levels stay and the mix is "Tonight".
    private func restoreLoadedMix() {
        guard let data = defaults.data(forKey: Self.loadedMixKey) else { return }
        guard let stored = try? JSONDecoder().decode(StoredMixIdentity.self, from: data) else {
            defaults.removeObject(forKey: Self.loadedMixKey)
            return
        }
        var recipe = Self.defaultLevels()
        for level in stored.recipe {
            recipe[level.sound] = MixCodec.bounded(level.value)
        }
        let name: String
        if let mix = stored.house.flatMap(HouseMix.init(rawValue:)) {
            activeHouseMix = mix
            name = mix.localizedName
        } else if let mix = stored.saved.flatMap({ mixStore.mix($0) }) {
            loadedSavedMixID = mix.id
            name = mix.name
        } else {
            defaults.removeObject(forKey: Self.loadedMixKey)
            return
        }
        let load = MixLoad(levels: recipe, hasFullAccess: purchases.hasFullAccess)
        loadedMixBaseName = name
        loadedMixRecipe = recipe
        loadedMixName = load.title(name: name)
        loadedMixWasStripped = load.isTrimmed
    }

    /// The lock screen follows the name of the mix, playing or paused. Not
    /// before the first Play: until then the app is not what is playing.
    private func refreshNowPlayingTitle() {
        guard didStart else { return }
        nowPlaying.update(isPlaying: isPlaying, title: nowPlayingTitle)
    }

    /// The mixes a Shortcut can name changed: Siri learns them again.
    private func shortcutMixesDidChange() {
        guard audio.isLive else { return }
        SleepNoiseShortcuts.updateAppShortcutParameters()
    }

    // MARK: House mixes

    /// Replaces the mix with a house mix, without starting playback. A house
    /// mix is never refused and never raises the paywall: without full access
    /// its Pro layers keep their levels, stay muted, and the name says what
    /// it plays without.
    ///
    /// A trial that ran out and has not been evaluated yet still loads the
    /// mix whole here. The Play that follows starts a new night, evaluates
    /// the trial and trims the mix before anything sounds
    /// (`accessDidChange()`).
    @discardableResult
    func loadHouseMix(_ mix: HouseMix) -> MixLoad {
        let load = mix.load(hasFullAccess: purchases.hasFullAccess)
        levels = load.levels
        setLoadedMix(.house(mix), name: mix.localizedName, load: load)
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        }
        return load
    }

    /// Loads a mix and plays it: a row of the Mixes sheet, or a Shortcut.
    /// What was sounding gives way to it under the same envelope; with
    /// nothing playing it starts like a Play, so a mix whose every layer
    /// needs Pro comes up with the fallback layer (the instrument always
    /// sounds). It never raises the Pro sheet and never touches the timer
    /// (C18).
    @discardableResult
    func playMix(_ reference: MixReference) -> IntentOutcome {
        switch reference {
        case .house(let mix):
            leaveSmallHoursForTheMix()
            loadHouseMix(mix)
        case .saved(let id):
            guard let mix = mixStore.mix(id) else { return .notFound }
            leaveSmallHoursForTheMix()
            apply(mix)
        }
        if isPlaying { return .started }
        play()
        return isPlaying ? .started : .failed
    }

    // MARK: Shortcuts

    /// Shortcuts: play the last mix, with the timer the person chose. If
    /// something is already sounding, nothing changes. Like every Shortcut,
    /// it never raises the Pro sheet and never starts a trial: what needs
    /// Pro without access does not sound, and nothing is said about it.
    @discardableResult
    func playFromShortcut() -> IntentOutcome {
        // "Play my last mix" is the mix: Small Hours gives way to it,
        // playing or paused, like every other request for the mix.
        leaveSmallHoursForTheMix()
        if isPlaying { return .started }
        play()
        return isPlaying ? .started : .failed
    }

    /// Shortcuts: load a mix by name and play it.
    @discardableResult
    func playMixFromShortcut(_ reference: MixReference) -> IntentOutcome {
        playMix(reference)
    }

    /// Shortcuts: set the timer the way its sheet does. The mode is stored,
    /// with the length or the hour that mode already had; `minutes`, when
    /// the Shortcut carries one, is the length of "Until I sleep". The whole
    /// timer is free (C03). A mode that counts starts the mix if it was at
    /// rest; "Off" only sets it.
    @discardableResult
    func setTimerFromShortcut(mode: TimerMode, minutes: Int? = nil) -> IntentOutcome {
        var choice = storedTimer.with(mode: mode)
        if mode == .untilAsleep, let minutes {
            // Through the initialiser, which keeps the length in range.
            choice = TimerChoice(
                mode: mode,
                minutes: minutes,
                endHour: choice.endHour,
                endMinute: choice.endMinute
            )
        }
        guard mode != .off else {
            chooseTimer(choice)
            return .applied
        }
        leaveSmallHoursForTheMix()
        chooseTimer(choice)
        if isPlaying { return .started }
        play()
        return isPlaying ? .started : .failed
    }

    /// Shortcuts: pause. Also cancels a resume that was waiting for the end
    /// of an interruption. Reports when there was nothing to pause.
    func pauseFromShortcut() -> IntentOutcome {
        let wasActive = isPlaying || heldByInterruption
        pause()
        return wasActive ? .stopped : .nothingPlaying
    }

    // MARK: Night

    /// Covers the interface with the Night screen, starting the current mix
    /// if it was at rest, the way Play does: a mix where nothing would sound
    /// comes up with the fallback layer, so "Night" on the bar always works.
    /// Night never chooses, changes or stores a sleep timer (C47): the one
    /// the person chose starts with playback as usual, and "+15 min" only
    /// adds to a count that exists. The screen is dimmed after 60 s without
    /// a touch; whether the iPhone stays awake is `bedtimeKeepsScreenAwake`,
    /// for the view to apply.
    @discardableResult
    func enterBedtime() -> BedtimeEntryOutcome {
        guard !isSmallHours else { return .entered }
        if BedtimeScreenPolicy.startsPlayback(isPlaying: isPlaying) {
            play()
        }
        guard isPlaying else { return .audioFailed }
        isBedtime = true
        // Nothing is sold on the Night screen, at any hour.
        if showPaywall { showPaywall = false }
        showsNightIntro = !defaults.bool(forKey: Self.nightIntroKey)
        noteBedtimeTouch()
        return .entered
    }

    /// The iPhone was locked (C47): with the night playing and nothing in
    /// front of the page, what is there at the next unlock is Night. Only
    /// inside `NightWindow`: by day a lock is not "in bed".
    @discardableResult
    func enterBedtimeOnLock(sheetIsOpen: Bool) -> Bool {
        guard BedtimeScreenPolicy.entersOnLock(
            isPlaying: isPlaying,
            isCovered: isBedtime || isSmallHours,
            sheetIsOpen: sheetIsOpen,
            isNight: NightWindow.contains(now(), calendar: calendar)
        ) else { return false }
        return enterBedtime() == .entered
    }

    /// The two first-time sentences have been on screen for their time.
    /// They are not shown again on this install.
    func nightIntroDidShow() {
        guard showsNightIntro else { return }
        showsNightIntro = false
        defaults.set(true, forKey: Self.nightIntroKey)
    }

    /// Back to the page, which is the night page from now on (C40).
    func leaveBedtime() {
        guard isBedtime else { return }
        isBedtime = false
        if showsNightIntro { showsNightIntro = false }
        cancelDimming()
        beginNightSession()
    }

    /// A touch on the Night screen (or on Small Hours): it is drawn at full
    /// ink again and the 60 s start over.
    func noteBedtimeTouch() {
        bedtimeTouchedAt = now()
        if isBedtimeDimmed { isBedtimeDimmed = false }
        dimTimer?.invalidate()
        dimTimer = schedule(after: BedtimeScreenPolicy.dimDelay) { [weak self] in
            self?.refreshBedtimeDimming()
        }
    }

    /// Dims the Night screen once its 60 s are up. Called by its own timer;
    /// a test moves the clock and calls it.
    func refreshBedtimeDimming() {
        guard isBedtime || isSmallHours, let bedtimeTouchedAt else { return }
        let dimmed = BedtimeScreenPolicy.isDimmed(lastTouch: bedtimeTouchedAt, now: now())
        if isBedtimeDimmed != dimmed { isBedtimeDimmed = dimmed }
    }

    private func cancelDimming() {
        dimTimer?.invalidate()
        dimTimer = nil
        bedtimeTouchedAt = nil
        if isBedtimeDimmed { isBedtimeDimmed = false }
    }

    /// "Keep screen on" (C46). Stored.
    func setKeepScreenOn(_ value: KeepScreenOn) {
        guard keepScreenOn != value else { return }
        keepScreenOn = value
        defaults.set(value.rawValue, forKey: Self.keepScreenOnKey)
    }

    /// Whether the Night screen should hold the iPhone awake right now
    /// (`isIdleTimerDisabled`). The view asks with the battery state it
    /// reads; the model never touches the idle timer itself.
    ///
    /// Only while a night is open: once it has ended by itself the screen
    /// goes back to the system's own setting, so an iPhone on its charger
    /// does not stay lit all morning showing "Ended at".
    func bedtimeKeepsScreenAwake(isCharging: Bool) -> Bool {
        (isBedtime || isSmallHours)
            && nightHoldsTheScreen
            && BedtimeScreenPolicy.keepsScreenAwake(keepScreenOn, isCharging: isCharging)
    }

    /// A night is playing, or paused and not yet over: what the idle timer
    /// follows. It changes with `isPlaying`, `pauseCause` and
    /// `sessionEndedAt`, which the view watches.
    var nightHoldsTheScreen: Bool {
        isPlaying || heldByInterruption || nightIsOpen(at: now())
    }

    // MARK: Small Hours

    /// Starts Small Hours (C05, C27, C60): the fixed recipe, for everyone.
    /// Whatever night was open is over; the person's mix, its levels and the
    /// timer they chose are not touched, no trial starts and nothing is
    /// sold. It never refuses for want of Pro, so the answer is `.started`
    /// or `.failed`.
    @discardableResult
    func startSmallHours() -> IntentOutcome {
        startIfNeeded()
        interruptions.cancel()
        heldByInterruption = false
        audioError = nil
        if isSmallHours {
            // Asked for again: the twenty minutes start over.
            smallHours.end()
        } else if isPlaying {
            // The mix gives way without stopping the engine: the gains
            // cross over under the same envelope.
            endPlayback(engineAction: .none, canDowngrade: true)
        }
        if !isSmallHours { closeNight(endedAt: nil) }
        isPlaying = false
        pauseCause = nil
        pausedAt = nil
        isSmallHours = true
        if showPaywall { showPaywall = false }
        noteBedtimeTouch()
        guard startSound(asked: true) else {
            closeNight(endedAt: nil)
            noteStartFailure()
            return .failed
        }
        return .started
    }

    /// The person leaves Small Hours before its end. The sea leaves like
    /// any pause and the page is the night page.
    func endSmallHours() {
        guard isSmallHours else { return }
        interruptions.cancel()
        heldByInterruption = false
        if isPlaying {
            endPlayback(engineAction: .stop(fadeOut: PlaybackFade.pause), canDowngrade: true)
        }
        closeNight(endedAt: nil)
    }

    /// A request to play the mix (a row of Mixes, a Shortcut) while Small
    /// Hours has the engine: the recipe gives way.
    private func leaveSmallHoursForTheMix() {
        guard isSmallHours else { return }
        if isPlaying {
            endPlayback(engineAction: .none, canDowngrade: true)
        }
        closeNight(endedAt: nil)
    }

    private func bindSmallHours() {
        smallHours.onTide = { [weak self] parameters in
            guard let self else { return }
            // The tide of Small Hours plays for everyone (C05).
            guard AccessPolicy.breathingIsIncluded(
                hasFullAccess: self.purchases.hasFullAccess,
                inSmallHours: true
            ) else { return }
            self.engine.setBreathing(parameters)
        }
        smallHours.onFade = { [weak self] seconds in
            self?.engine.fadeOut(over: seconds)
        }
        smallHours.onComplete = { [weak self] in
            guard let self else { return }
            // When it ends, nothing happens (C60): no sound, no notice.
            self.engine.stop(fadeOut: 0.05)
            self.isPlaying = false
            self.closeNight(endedAt: nil)
        }
    }

    /// Outside the app the mix goes by the title the page shows, so a
    /// trimmed mix says what is not playing there too.
    var nowPlayingTitle: String {
        // Small Hours is not the mix: it goes by its own name.
        if isSmallHours { return Localized.string("madrugada.titulo") }
        // "Tonight" while the live mix has no name of its own.
        return PageTitle.text(loadedMixName: loadedMixName)
    }

    var isSilent: Bool {
        currentGainsTotal() <= 0.001
    }

    /// The mixer tells the store when the bed is sounding, and hears from it
    /// when access changes: no view has to pass that on.
    private func bindAccess() {
        purchases.isSoundPlaying = { [weak self] in self?.isPlaying ?? false }
        purchases.onAccessChange = { [weak self] in self?.accessDidChange() }
    }

    /// Access changed: bought, restored, the trial started, or lost once
    /// nothing was sounding. Nothing stored is written: the levels, the
    /// saved mixes and the tide's switch stay as they were (C23). What
    /// changes is what may sound and what the page says about it.
    private func accessDidChange() {
        clampTimerToEntitlement()
        refreshEntitledAudio()
    }

    // MARK: The trial

    /// "Start the trial · 7 nights": the only way the trial begins (C07).
    /// It goes through the same gate as the Pro sheet, so nothing happens
    /// at night, on the night page or in Small Hours. When it starts, the
    /// sheet comes down and what was waiting for Pro is heard at once.
    @discardableResult
    func startTrial() -> TrialStartResult {
        guard canSell else { return .closedAtNight }
        let result = purchases.startTrial(now: now(), calendar: calendar)
        if result == .started, showPaywall {
            showPaywall = false
        }
        return result
    }

    /// The paragraph about the trial the page may show right now: by day,
    /// on the day page and in silence. At night it waits (08 §2.4).
    var visibleTrialNote: TrialNote? {
        guard canSell, !isPlaying, !isBedtime else { return nil }
        return purchases.trialNote
    }

    /// Access changed (purchase, restore, revocation, trial start or end).
    /// Gains and the breathing guide follow it while playing.
    func refreshEntitledAudio() {
        // A mix that was whole during the trial is a stripped one once the
        // trial ends: say so instead of keeping its name as if nothing had
        // changed. Its title names what it plays without, and it gets its
        // own name back when access returns. The title follows the mix as it
        // was loaded: a layer the tide raised later is not part of its name.
        if let name = loadedMixBaseName, let recipe = loadedMixRecipe {
            loadedMixName = MixLoad(levels: recipe, hasFullAccess: purchases.hasFullAccess).title(name: name)
        }
        loadedMixWasStripped = loadedMixName != nil
            && Self.hasMutedLayers(levels, hasFullAccess: purchases.hasFullAccess)
        guard isPlaying else { return }
        engine.updateGains(currentGains())
        nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        // The tide of Small Hours does not depend on access (C05).
        guard !isSmallHours else { return }
        if !breathingIsIncluded {
            breathing.end()
        } else if breathing.settings.isEnabled, !breathing.isActive {
            breathing.begin()
        }
    }

    // MARK: Breathing tide

    var breathingIsIncluded: Bool {
        AccessPolicy.breathingIsIncluded(hasFullAccess: purchases.hasFullAccess)
    }

    /// Switches the tide on or off. Takes effect at once when playing.
    /// Turning it on with the ocean silent raises the ocean so the tide can
    /// be heard, unless six layers already sound: the cap is a rule of the
    /// model, so the tide is armed and the ocean stays where it was. The
    /// ocean it raised stays up when the tide goes.
    ///
    /// `startsSound` is the switch on the page and in the tide sheet: with
    /// nothing playing, turning the tide on starts the night, so the switch
    /// never says "on" over silence (05 §2.1; the instrument always sounds).
    /// Without access the request is for the Pro sheet, which only goes up
    /// while something may be sold; nothing else happens.
    func setBreathingEnabled(_ enabled: Bool, startsSound: Bool = false) {
        if enabled, !breathingIsIncluded {
            offerPro()
            return
        }
        guard breathing.settings.isEnabled != enabled else { return }
        breathing.settings.isEnabled = enabled
        if enabled, (levels[.ocean] ?? 0) < 0.05 {
            if !soundingLayers.contains(.ocean), soundingLayers.count >= Self.maxSimultaneousLayers {
                showBreathingNote(String(localized: "capas.tope"))
            } else {
                writeLevel(.ocean, Self.tideOceanLevel)
                showBreathingNote(String(
                    format: String(localized: "marea.oceano.subido"),
                    Int64((Self.tideOceanLevel * 100).rounded())
                ))
            }
        }
        // Small Hours has its own tide: the switch is armed for the mix.
        guard !isSmallHours else { return }
        guard isPlaying else {
            // Play begins the guide with the bed.
            if enabled, startsSound { play() }
            return
        }
        if enabled {
            breathing.begin()
        } else {
            breathing.end()
        }
    }

    func updateBreathing(_ settings: BreathingSettings) {
        var next = settings
        next.isEnabled = breathing.settings.isEnabled
        guard breathing.settings != next else { return }
        breathing.settings = next
        breathing.settingsDidChange()
    }

    private func startBreathingIfEnabled() {
        guard breathing.settings.isEnabled, breathingIsIncluded else {
            breathing.end()
            return
        }
        breathing.begin()
    }

    private func resumeBreathingIfEnabled() {
        guard breathing.settings.isEnabled, breathingIsIncluded else {
            breathing.end()
            return
        }
        breathing.resume()
    }

    /// Level change that keeps the loaded mix's identity (used by the tide's
    /// ocean raise).
    private func writeLevel(_ sound: SoundID, _ value: Float) {
        levels[sound] = min(1, max(0, value))
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
        }
    }

    private func showBreathingNote(_ text: String) {
        noteTask?.cancel()
        breathingNote = text
        noteTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            self?.breathingNote = nil
        }
    }

    private func bindBreathing() {
        breathing.onChange = { [weak self] parameters in
            self?.engine.setBreathing(parameters)
        }
    }

    // MARK: Playback end

    private enum EngineAction {
        case stop(fadeOut: TimeInterval)
        case none
    }

    /// Every way the sound stops goes through here: a pause, an
    /// interruption, the end of the timer, a media-services reset. It stops
    /// the guide, pauses the timer (or the clock of Small Hours), updates
    /// Now Playing and, when the session is really over (`canDowngrade`),
    /// lets access that was lost while the bed was playing finally apply.
    private func endPlayback(engineAction: EngineAction, canDowngrade: Bool) {
        if case .stop(let seconds) = engineAction {
            engine.stop(fadeOut: seconds)
        }
        isPlaying = false
        if isSmallHours {
            smallHours.pause()
        } else {
            timer.pause()
            breathing.end()
        }
        nowPlaying.update(isPlaying: false, title: nowPlayingTitle)
        purchases.applyAccess(canDowngrade: canDowngrade)
    }

    private func bindTimer() {
        timer.onFade = { [weak self] seconds in
            self?.engine.fadeOut(over: seconds)
            self?.breathing.release(over: seconds)
        }
        timer.onFadeCancelled = { [weak self] in
            guard let self else { return }
            // "+15 min" inside the final fade: the level comes back, and the
            // tide with it if its window is still open.
            self.engine.fade(to: 1, over: Self.fadeReturn)
            self.resumeBreathingIfEnabled()
        }
        timer.onBlanketDip = { [weak self] _, ramp in
            guard let self else { return }
            // The timer has already taken the dip into `blanketGain`.
            self.engine.setMaster(self.effectiveMaster, over: ramp)
        }
        timer.onComplete = { [weak self] in
            guard let self else { return }
            self.endPlayback(engineAction: .stop(fadeOut: 0.01), canDowngrade: true)
            // The night is over: the page is silent again, not paused.
            self.closeNight(endedAt: self.now())
        }
    }

    // MARK: Interruptions (C48)

    /// The system took the output. While playing it is a pause with a short
    /// fade and the night is held: `InterruptionPolicy` says what happens
    /// when it ends. During the tail of a pause already under way (the
    /// person's own lasts 1.5 s) the tail is cut to that same short fade.
    private func interruptionBegan(_ kind: InterruptionKind) {
        if kind == .routeDisconnected {
            // The system says the output went away. That is `RoutePolicy`'s
            // to answer: it pauses and makes its offer, and what
            // `InterruptionPolicy` would say of it (stay paused, over after
            // twenty minutes) is what a lost output gets anyway. Under an
            // interruption already open, `outputLost` adds it to the tracker.
            outputLost()
            return
        }
        let wasPlaying = isPlaying
        let known: InterruptionKind = callInProgress ? .call : kind
        interruptions.began(known, wasPlaying: wasPlaying)
        if wasPlaying {
            stopSound(cause: known == .call ? .call : .system, fade: PlaybackFade.interruption, held: true)
        } else if engine.isStopping {
            engine.stop(fadeOut: PlaybackFade.interruption)
        }
    }

    /// The interruption is over, or the app is in front again with one that
    /// never closed. One table decides (`InterruptionPolicy`): outside the
    /// morning window the night resumes with a three second fade; inside it
    /// the night is over; a lost output stays paused. A resume still has to
    /// pass the route gate: never by itself on another output.
    private func interruptionEnded() {
        guard interruptions.isOpen else { return }
        let wasHeld = heldByInterruption
        let outcome = interruptions.ended(fixedEnd: isSmallHours ? nil : timer.fixedEnd)
        heldByInterruption = false
        switch outcome {
        case .resume(let fadeIn):
            let current = sessionObserver.currentRoute
            if wasHeld, !isPlaying,
               RoutePolicy.mayResumeUnasked(pausedOn: sessionRoute ?? current, current: current) {
                // If it does not start (something else still holds the
                // output), the night stays paused and says nothing.
                startSound(asked: false, fadeIn: fadeIn)
            }
        case .endSession:
            if !isPlaying { closeNight(endedAt: pausedAt) }
        case .stayPaused:
            break
        }
        if !isPlaying {
            // Paused after all: access lost meanwhile applies, and the
            // twenty minutes of `SessionPause` count from the pause.
            purchases.applyAccess(canDowngrade: true)
            if pausedAt != nil { scheduleExpiry() }
        }
    }

    private func callChanged(_ inCall: Bool) {
        callInProgress = inCall
        guard inCall, interruptions.isOpen else { return }
        // The call observer may speak after the interruption began.
        interruptions.note(.call)
        if pauseCause == .system { pauseCause = .call }
    }

    // MARK: Route (C49)

    private func routeState(at now: Date) -> RouteState {
        let current = sessionObserver.currentRoute
        return RouteState(
            isPlaying: isPlaying,
            sessionRoute: sessionRoute ?? current,
            currentRoute: current,
            lostOutputAt: lostOutputAt,
            appIsActive: appIsActive,
            master: sessionLevel,
            heldByInterruption: heldByInterruption
        )
    }

    /// The output in use went away. The night pauses with a fade short
    /// enough not to be heard on the speaker the system falls back to, and
    /// it never plays again by itself there: "Keep playing on speaker" is
    /// offered for a minute.
    private func outputLost() {
        let now = now()
        // The system may say it twice (an interruption and a route change).
        guard isPlaying || lostOutputAt == nil else { return }
        guard case .pause(let fadeOut, let offerUntil) = RoutePolicy.action(
            for: .outputLost,
            state: routeState(at: now),
            now: now
        ) else {
            // Nothing was playing: only the tail of a pause, cut short.
            if engine.isStopping { engine.stop(fadeOut: PlaybackFade.lostOutput) }
            return
        }
        if interruptions.isOpen { interruptions.note(.routeDisconnected) }
        lostRoute = sessionRoute
        lostRouteAt = now
        let wasHeadphones = sessionRoute?.isHeadphones ?? true
        if lostOutputWasHeadphones != wasHeadphones { lostOutputWasHeadphones = wasHeadphones }
        if isPlaying {
            stopSound(cause: .lostOutput, fade: fadeOut, held: false)
        } else {
            // Under an open interruption: silent already, and the loss is
            // remembered. Nothing plays by itself while it is open.
            pauseCause = .lostOutput
        }
        lostOutputAt = now
        offerSpeaker(until: offerUntil)
    }

    /// An output appeared. The night resumes unasked only when it is the
    /// output it was playing on and the app is in front; twenty minutes
    /// after the loss it is over instead.
    private func outputAvailable() {
        let now = now()
        switch RoutePolicy.action(for: .outputAvailable, state: routeState(at: now), now: now) {
        case .resume(let fadeIn, _):
            startSound(asked: false, fadeIn: fadeIn)
        case .endSession:
            closeNight(endedAt: pausedAt)
        case .none, .pause, .startNewSession:
            routeChanged()
        }
    }

    /// The route changed under a night that plays: the engine follows the
    /// hardware rate and the night is on that output from now on.
    private func routeChanged() {
        guard isPlaying else { return }
        try? engine.retargetSampleRateIfNeeded(gains: currentGains())
        sessionRoute = sessionObserver.currentRoute
    }

    /// "Keep playing on speaker": the explicit way on after the output went
    /// away (C49). It is a Play the person asked for, so the level is capped
    /// at `RoutePolicy.speakerMasterCap` when the speaker is what is left.
    func continueOnSpeaker() {
        play()
    }

    private func offerSpeaker(until: Date?) {
        offerTimer?.invalidate()
        offerTimer = nil
        if speakerOfferUntil != until { speakerOfferUntil = until }
        guard let until else { return }
        offerTimer = schedule(after: until.timeIntervalSince(now())) { [weak self] in
            self?.refreshSpeakerOffer()
        }
    }

    private func clearSpeakerOffer() {
        offerSpeaker(until: nil)
    }

    /// Withdraws the offer once its minute is up, or when the speaker is no
    /// longer what is left. Called by its own timer and when the app comes
    /// forward; a test moves the clock and calls it.
    func refreshSpeakerOffer() {
        guard speakerOfferUntil != nil else { return }
        let now = now()
        if !RoutePolicy.speakerOfferIsVisible(state: routeState(at: now), now: now) {
            clearSpeakerOffer()
        }
    }

    // MARK: A pause that lasts (SessionPause)

    private func scheduleExpiry() {
        cancelExpiry()
        guard let pausedAt else { return }
        let wait = SessionPause.longest - now().timeIntervalSince(pausedAt)
        expiryTimer = schedule(after: max(0, wait)) { [weak self] in
            self?.expireNightIfOver()
        }
    }

    private func cancelExpiry() {
        expiryTimer?.invalidate()
        expiryTimer = nil
    }

    /// A night paused for twenty minutes is over, whatever paused it. An
    /// interruption that is still open is not judged here: a call never
    /// ends the night, however long, and `InterruptionPolicy` decides when
    /// it closes. Called by its own timer and when the app comes forward;
    /// a test moves the clock and calls it.
    func expireNightIfOver() {
        guard !isPlaying, pauseCause != nil, let pausedAt, !interruptions.isOpen else { return }
        guard SessionPause.isOver(pausedAt: pausedAt, now: now()) else { return }
        closeNight(endedAt: pausedAt)
    }

    // MARK: The app comes and goes

    /// The scene became active. An interruption that never got its end is
    /// closed here, unless something still holds the output; a night that
    /// stayed paused too long is over; and the night page, which no clock
    /// ends while it is looked at (C40), gives way once its night is over
    /// and the app is opened by day.
    func appDidBecomeActive() {
        appIsActive = true
        // The clock is sampled between sessions; the trial's answer still
        // changes only at the next session start.
        purchases.observeClock(now: now())
        purchases.applyAccess(canDowngrade: !isPlaying)
        if audio.isLive {
            // The price is asked for again, so the Pro sheet opens with it.
            Task { [purchases] in await purchases.refresh() }
        }
        if interruptions.isOpen, !callInProgress, !sessionObserver.isOtherAudioPlaying {
            interruptionEnded()
        }
        expireNightIfOver()
        refreshSpeakerOffer()
        refreshBedtimeDimming()
        let now = now()
        let nightIsOver = !nightIsOpen(at: now) && !heldByInterruption
        let isDay = !NightWindow.contains(now, calendar: calendar)
        if isNightSession, !isBedtime, !isSmallHours, nightIsOver, isDay {
            isNightSession = false
        }
        if nightIsOver, isDay {
            // The output lost last night says nothing about today's.
            lostRoute = nil
            lostRouteAt = nil
        } else {
            forgetLostRouteIfStale(at: now)
        }
        closeSaleIfNight()
    }

    /// The scene is no longer active: nothing resumes unasked from here.
    func appDidResignActive() {
        appIsActive = false
    }

    /// One-shot on the main run loop. With doubles for audio nothing is
    /// scheduled: a test moves the clock and calls the refresh itself.
    private func schedule(after seconds: TimeInterval, _ action: @escaping @MainActor () -> Void) -> Timer? {
        guard audio.isLive else { return nil }
        let timer = Timer(timeInterval: max(0, seconds), repeats: false) { _ in
            MainActor.assumeIsolated {
                action()
            }
        }
        timer.tolerance = 1
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }

    private func installSessionHandlers() {
        sessionObserver.onInterruptionBegan = { [weak self] kind in
            self?.interruptionBegan(kind)
        }
        sessionObserver.onInterruptionEnded = { [weak self] in
            self?.interruptionEnded()
        }
        sessionObserver.onCallChanged = { [weak self] inCall in
            self?.callChanged(inCall)
        }
        sessionObserver.onOutputLost = { [weak self] in
            self?.outputLost()
        }
        sessionObserver.onOutputAvailable = { [weak self] in
            self?.outputAvailable()
        }
        sessionObserver.onRouteChange = { [weak self] in
            self?.routeChanged()
        }
        sessionObserver.onMediaServicesReset = { [weak self] in
            guard let self else { return }
            let wasPlaying = self.isPlaying
            self.engine.invalidateGraph()
            guard wasPlaying else { return }
            // The same night, on a new graph. If it does not come back it
            // stays paused, and the page says so.
            self.endPlayback(engineAction: .none, canDowngrade: false)
            self.pauseCause = .system
            self.pausedAt = self.now()
            if !self.startSound(asked: false) {
                self.purchases.applyAccess(canDowngrade: true)
                self.scheduleExpiry()
            }
        }
        sessionObserver.start()
    }

    private func currentGains() -> SoundGains {
        // Small Hours plays its recipe, for everyone: never the mix.
        if isSmallHours {
            return smallHours.gains(hasFullAccess: purchases.hasFullAccess)
        }
        var gains = SoundGains.zero
        for sound in SoundID.allCases {
            let level = levels[sound] ?? 0
            if AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) {
                gains.set(sound, level)
            }
        }
        return gains
    }

    /// True when a layer above zero is not included at this access level.
    static func hasMutedLayers(_ levels: [SoundID: Float], hasFullAccess: Bool) -> Bool {
        SoundID.allCases.contains { sound in
            (levels[sound] ?? 0) > 0.001 && !AccessPolicy.soundIsIncluded(sound, hasFullAccess: hasFullAccess)
        }
    }

    private func currentGainsTotal() -> Float {
        let gains = currentGains()
        return SoundID.allCases.reduce(0) { $0 + gains.value(for: $1) }
    }

    private func persistLevels() {
        let payload = SoundID.allCases.map { MixLevel(sound: $0, value: levels[$0] ?? 0) }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: levelsKey)
    }

    private static func loadLevels(defaults: UserDefaults, key: String) -> [SoundID: Float]? {
        // Read by id, so a sound stored by a later version is left out and
        // does not send the rest back to the factory levels.
        guard let data = defaults.data(forKey: key), let stored = MixCodec.decodeLevels(data) else { return nil }
        return defaultLevels().merging(stored) { _, stored in stored }
    }

    /// Every layer at zero: the base a mix or the stored levels are laid on.
    private static func defaultLevels() -> [SoundID: Float] {
        Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
    }
}

#if DEBUG
extension MixerModel {
    /// Debug builds only: the page as it is after a start that failed,
    /// without touching the audio session. For the reference captures.
    func debugFailStart() {
        startIfNeeded()
        noteStartFailure()
    }

    /// Debug builds only: the output in use goes away, as when earbuds are
    /// taken out. For the reference captures.
    func debugLoseOutput() {
        // The night was on earbuds: what is left is the iPhone's speaker.
        sessionRoute = .external(id: "debug.earbuds")
        outputLost()
    }
}
#endif
