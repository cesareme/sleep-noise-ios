import Combine
import Foundation

/// Why the bed is paused. The page says it in words.
enum PauseCause: Equatable {
    /// The person paused.
    case person
    /// The system took the output: a call, an alarm, another app.
    case system
    /// The output went away: earbuds out.
    case lostOutput

    /// How long the bed takes to leave.
    var fade: TimeInterval {
        switch self {
        case .person: return PlaybackFade.pause
        case .system: return PlaybackFade.interruption
        case .lostOutput: return PlaybackFade.lostOutput
        }
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
    /// Night screen is covering the interface. Audio keeps running when this
    /// turns off.
    @Published private(set) var isBedtime = false
    /// The loaded mix has layers that are muted because they need Pro.
    @Published private(set) var loadedMixWasStripped = false
    /// Short note under the breathing card ("Ocean raised so you can hear it").
    @Published private(set) var breathingNote: String?

    let purchases: PurchaseManager
    let mixStore: MixStore
    let timer: SleepTimerController
    let breathing: BreathingGuideController

    private let engine = SleepAudioEngine()
    private let nowPlaying = NowPlayingController()
    private let sessionObserver = AudioSessionObserver()
    private let defaults: UserDefaults
    private let now: () -> Date
    private let calendar: Calendar
    private let levelsKey = "sleepnoise.levels.v1"
    private let timerKey = "sleepnoise.timerMinutes.v1"
    /// Length the timer Shortcut uses when none was asked for or chosen.
    static let fallbackTimerMinutes = 60
    /// Level of a sound that a Shortcut plays on its own.
    static let soloSoundLevel: Float = 0.65
    private var didStart = false
    private var resumeAfterInterruption = false
    private var noteTask: Task<Void, Never>?
    /// Ocean level before the tide raised it, restored if the tide is switched
    /// off again before the slider is touched.
    private var oceanBeforeTide: Float?
    /// The levels the loaded mix came with. Its title is worked out from
    /// these, not from the live levels, which the tide may have raised.
    private var loadedMixRecipe: [SoundID: Float]?

    init(
        purchases: PurchaseManager,
        mixStore: MixStore? = nil,
        timer: SleepTimerController? = nil,
        breathing: BreathingGuideController? = nil,
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { Date() },
        calendar: Calendar = .current
    ) {
        self.purchases = purchases
        self.defaults = defaults
        self.now = now
        self.calendar = calendar
        self.mixStore = mixStore ?? MixStore(defaults: defaults)
        self.timer = timer ?? SleepTimerController()
        self.breathing = breathing ?? BreathingGuideController(defaults: defaults)
        if let stored = Self.loadLevels(defaults: defaults, key: levelsKey) {
            levels = stored
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
        if let minutes = defaults.object(forKey: timerKey) as? Int,
           AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) {
            self.timer.choose(minutes)
        }
        bindTimer()
        bindBreathing()
    }

    func startIfNeeded() {
        guard !didStart else { return }
        didStart = true
        IntentBridge.attach(self)
        purchases.start()
        installSessionHandlers()
        nowPlaying.install(
            onPlay: { [weak self] in self?.play() },
            onPause: { [weak self] in self?.pause(resumeLater: false) },
            onToggle: { [weak self] in self?.togglePlayback() }
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
        let wasSounding = (levels[sound] ?? 0) > MixLoad.audibleThreshold
        if !wasSounding, next > MixLoad.audibleThreshold,
           soundingLayers.count >= Self.maxSimultaneousLayers {
            return .capReached
        }
        levels[sound] = next
        isPlayingFallback = false
        loadedMixName = nil
        loadedMixBaseName = nil
        loadedMixRecipe = nil
        loadedMixWasStripped = false
        activeHouseMix = nil
        if sound == .ocean { oceanBeforeTide = nil }
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
        }
        return .applied
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
        SaleGate.isOpen(at: now(), calendar: calendar, nightSession: isNightSession)
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

    /// The page keeps one ink from now on (C40). Called when the person
    /// comes back from the Night screen.
    func beginNightSession() {
        isNightSession = true
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

    func togglePlayback() {
        if isPlaying {
            pause(resumeLater: false)
        } else {
            play()
        }
    }

    /// `userInitiated` is false when the system brings audio back (end of an
    /// interruption, media-services reset). The breathing guide then continues
    /// its window instead of starting a fresh fifteen minutes on someone asleep.
    func play(userInitiated: Bool = true) {
        startIfNeeded()
        audioError = nil
        resumeAfterInterruption = false
        if userInitiated, isSilent {
            // Nothing would sound: an empty mix, or one whose every layer
            // needs Pro. The instrument always sounds: the fallback layer
            // comes up as a real level and the mix keeps its name.
            writeLevel(Self.fallbackSound, Self.fallbackLevel)
            isPlayingFallback = true
        }
        // The guide publishes before the engine starts, so the first command
        // the render thread reads already carries the breath (and its epoch),
        // and before the timer, whose fade callback may release it again.
        if userInitiated {
            startBreathingIfEnabled()
        } else {
            resumeBreathingIfEnabled()
        }
        do {
            try engine.start(gains: currentGains())
            isPlaying = true
            pauseCause = nil
            startFailures = 0
            purchases.startTrialIfNeeded()
            timer.start()
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        } catch {
            endPlayback(engineAction: .none, canDowngrade: true)
            pauseCause = nil
            noteStartFailure()
        }
    }

    /// One more start that did not sound. The page reads the count and says
    /// more with each one.
    private func noteStartFailure() {
        startFailures += 1
        audioError = String(localized: "pagina.error.inicio")
    }

    /// `cause` decides how long the bed takes to leave: the person's own
    /// pause is never a cut (`PlaybackFade.pause`); an interruption and a
    /// lost output have their own, shorter fades.
    func pause(resumeLater: Bool, cause: PauseCause = .person) {
        if resumeLater {
            if isPlaying {
                resumeAfterInterruption = true
            }
        } else {
            resumeAfterInterruption = false
        }
        guard isPlaying else { return }
        // An interruption that intends to resume is not the end of the night:
        // a trial that ran out meanwhile waits until the session really ends.
        endPlayback(engineAction: .stop(fadeOut: cause.fade), canDowngrade: !resumeAfterInterruption)
        pauseCause = cause
    }

    func selectTimer(minutes: Int?) {
        if let minutes, !AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) {
            offerPro()
            return
        }
        timer.choose(minutes)
        if let minutes {
            defaults.set(minutes, forKey: timerKey)
            if isPlaying {
                timer.start()
            }
        } else {
            defaults.removeObject(forKey: timerKey)
        }
    }

    /// Drops a Pro-only timer if the entitlement is gone, and stops playback
    /// when that timer was already counting.
    func clampTimerToEntitlement() {
        guard let minutes = timer.selectedMinutes else { return }
        guard !AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) else { return }
        let wasCounting = timer.remaining != nil
        selectTimer(minutes: nil)
        if wasCounting {
            pause(resumeLater: false)
        }
    }

    func saveCurrent(name: String) -> SaveMixResult {
        let result = mixStore.save(name: name, levels: levels, hasFullAccess: purchases.hasFullAccess)
        switch result {
        case .saved(let mix):
            loadedMixName = mix.name
            loadedMixBaseName = mix.name
            loadedMixRecipe = levels
            loadedMixWasStripped = false
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
        var next = Self.defaultLevels()
        for level in mix.levels {
            next[level.sound] = level.value
        }
        let load = MixLoad(levels: next, hasFullAccess: purchases.hasFullAccess)
        levels = next
        activeHouseMix = nil
        setLoadedMix(name: mix.name, load: load)
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        }
        return load.isTrimmed
    }

    func suggestedMixName() -> String {
        MixStore.defaultName(mixStore.mixes.count + 1)
    }

    /// Every whole replacement of `levels` by a mix ends here: the title
    /// follows the mix as it was loaded, and an ocean level the tide meant
    /// to put back belongs to the mix that is gone.
    private func setLoadedMix(name: String, load: MixLoad) {
        loadedMixBaseName = name
        loadedMixRecipe = load.levels
        loadedMixName = load.title(name: name)
        loadedMixWasStripped = load.isTrimmed
        oceanBeforeTide = nil
        isPlayingFallback = false
        mixRevision += 1
    }

    // MARK: House mixes, Shortcuts, Night

    /// Replaces the mix with a house mix, without starting playback. A house
    /// mix is never refused and never raises the paywall: without full access
    /// its Pro layers keep their levels, stay muted, and the name says what
    /// it plays without.
    ///
    /// Every entry point that can start a night reads the trial clock first:
    /// a trial that ran out while the app was suspended must not let one more
    /// Pro night through because the scene has not become active yet.
    @discardableResult
    func loadHouseMix(_ mix: HouseMix) -> MixLoad {
        purchases.refreshAccess(canDowngrade: !isPlaying)
        let load = mix.load(hasFullAccess: purchases.hasFullAccess)
        levels = load.levels
        activeHouseMix = mix
        setLoadedMix(name: mix.localizedName, load: load)
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        }
        return load
    }

    /// Loads a house mix and plays it. With nothing playing and no layer
    /// left to hear, it does not start a silent night.
    @discardableResult
    func playHouseMix(_ mix: HouseMix) -> IntentOutcome {
        let load = loadHouseMix(mix)
        if isPlaying { return .started }
        if load.isSilent { return .nothingToPlay }
        play()
        return audioError == nil ? .started : .failed
    }

    /// Shortcuts: play one sound on its own. A Pro sound needs full access;
    /// without it nothing changes and no paywall is raised, because the
    /// request may come by voice in the dark. The intent answers in words
    /// instead. `play()` does the one-time setup, so a refused request has
    /// no side effects.
    @discardableResult
    func playSound(_ sound: SoundID) -> IntentOutcome {
        purchases.refreshAccess(canDowngrade: !isPlaying)
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else {
            return .needsPro
        }
        var next = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        next[sound] = Self.soloSoundLevel
        levels = next
        activeHouseMix = nil
        // One sound on its own is named after the sound and has no recipe to
        // be trimmed from: it is never "Ocean · without Ocean".
        loadedMixName = sound.localizedName
        loadedMixBaseName = sound.localizedName
        loadedMixRecipe = nil
        loadedMixWasStripped = false
        oceanBeforeTide = nil
        isPlayingFallback = false
        mixRevision += 1
        persistLevels()
        return startOrUpdate()
    }

    /// Length the timer Shortcut runs: the one asked for, else the one
    /// already chosen in the app, else `fallbackTimerMinutes`.
    func timerMinutes(requested: Int?) -> Int {
        requested ?? timer.selectedMinutes ?? Self.fallbackTimerMinutes
    }

    /// Shortcuts: start the timer and the bed. A length outside the allowed
    /// range, or a Pro length without access, leaves the current timer
    /// alone, and a silent mix is not started. Only a length that was asked
    /// for becomes the stored choice; with none, the chosen one (or the
    /// fallback) runs tonight and the stored choice is not touched.
    @discardableResult
    func startTimer(minutes requested: Int?) -> IntentOutcome {
        if let refusal = armTimer(minutes: requested) { return refusal }
        if isPlaying { return .started }
        play()
        return audioError == nil ? .started : .failed
    }

    /// Everything `startTimer` does short of starting the engine. Returns the
    /// refusal, or nil once the timer is set.
    func armTimer(minutes requested: Int?) -> IntentOutcome? {
        purchases.refreshAccess(canDowngrade: !isPlaying)
        let minutes = timerMinutes(requested: requested)
        guard (1...AccessPolicy.maxTimerMinutes).contains(minutes) else { return .outOfRange }
        guard AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) else {
            return .needsPro
        }
        if !isPlaying && isSilent { return .nothingToPlay }
        if requested != nil {
            selectTimer(minutes: minutes)
        } else {
            timer.choose(minutes)
            if isPlaying { timer.start() }
        }
        return nil
    }

    /// Shortcuts: stop. Also cancels a resume that was waiting for the end of
    /// an interruption. Reports when there was nothing to stop.
    func stopFromShortcut() -> IntentOutcome {
        let wasActive = isPlaying || resumeAfterInterruption
        pause(resumeLater: false)
        return wasActive ? .stopped : .nothingPlaying
    }

    /// Covers the interface with the Night screen, starting the current mix
    /// if it was paused. Night never chooses, changes or stores a sleep
    /// timer: a timer the person already chose starts with playback as usual,
    /// and with none chosen the bed plays until it is stopped. It does not
    /// start a silent night, and it does not touch brightness or the idle
    /// timer.
    @discardableResult
    func enterBedtime() -> BedtimeEntryOutcome {
        switch BedtimeScreenPolicy.entry(isPlaying: isPlaying, isSilent: isSilent) {
        case .nothingToPlay:
            return .nothingToPlay
        case .enter(let startsPlayback):
            if startsPlayback {
                play()
            }
            guard isPlaying else { return .audioFailed }
            isBedtime = true
            return .entered
        }
    }

    /// Back to the page, which is the night page from now on (C40).
    func leaveBedtime() {
        guard isBedtime else { return }
        isBedtime = false
        beginNightSession()
    }

    private func startOrUpdate() -> IntentOutcome {
        if isPlaying {
            engine.updateGains(currentGains())
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
            return .started
        }
        play()
        return audioError == nil ? .started : .failed
    }

    /// Outside the app the mix goes by the title the page shows, so a
    /// trimmed mix says what is not playing there too.
    var nowPlayingTitle: String {
        if let loadedMixName, !loadedMixName.isEmpty {
            return loadedMixName
        }
        return String(localized: "nowplaying.title")
    }

    var isSilent: Bool {
        currentGainsTotal() <= 0.001
    }

    /// Access changed (purchase, restore, revocation, trial end applied).
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

    /// Switches the tide on or off. Takes effect at once when playing. Turning
    /// it on with the ocean silent raises the ocean so the tide can be heard.
    func setBreathingEnabled(_ enabled: Bool) {
        if enabled, !breathingIsIncluded {
            offerPro()
            return
        }
        guard breathing.settings.isEnabled != enabled else { return }
        breathing.settings.isEnabled = enabled
        if enabled, (levels[.ocean] ?? 0) < 0.05 {
            oceanBeforeTide = levels[.ocean] ?? 0
            writeLevel(.ocean, 0.5)
            showBreathingNote(String(localized: "breath.oceanRaised"))
        } else if !enabled, let previous = oceanBeforeTide, abs((levels[.ocean] ?? 0) - 0.5) < 0.001 {
            oceanBeforeTide = nil
            writeLevel(.ocean, previous)
        }
        guard isPlaying else { return }
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
    /// ocean raise and its undo).
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

    /// Every way playback ends goes through here: user pause, timer
    /// completion, media-services reset and a failed start. It stops the
    /// guide, pauses the timer, updates Now Playing and, when the session is
    /// really over (`canDowngrade`), lets a trial that ran out while the bed
    /// was playing finally apply.
    private func endPlayback(engineAction: EngineAction, canDowngrade: Bool) {
        if case .stop(let seconds) = engineAction {
            engine.stop(fadeOut: seconds)
        }
        isPlaying = false
        timer.pause()
        breathing.end()
        nowPlaying.update(isPlaying: false, title: nowPlayingTitle)
        purchases.refreshAccess(canDowngrade: canDowngrade)
    }

    private func bindTimer() {
        timer.onFade = { [weak self] seconds in
            self?.engine.fadeOut(over: seconds)
            self?.breathing.release(over: seconds)
        }
        timer.onComplete = { [weak self] in
            guard let self else { return }
            self.endPlayback(engineAction: .stop(fadeOut: 0.01), canDowngrade: true)
            // The night is over: the page is silent again, not paused.
            self.pauseCause = nil
        }
    }

    private func installSessionHandlers() {
        sessionObserver.onInterruptionBegan = { [weak self] in
            self?.pause(resumeLater: true, cause: .system)
        }
        sessionObserver.onInterruptionEnded = { [weak self] shouldResume in
            guard let self else { return }
            if shouldResume, self.resumeAfterInterruption {
                self.play(userInitiated: false)
            } else {
                // The session is over after all: apply a pending trial end.
                self.purchases.refreshAccess(canDowngrade: !self.isPlaying)
            }
            self.resumeAfterInterruption = false
        }
        sessionObserver.onHeadphonesUnplugged = { [weak self] in
            self?.pause(resumeLater: false, cause: .lostOutput)
        }
        sessionObserver.onRouteChange = { [weak self] in
            guard let self, self.isPlaying else { return }
            try? self.engine.retargetSampleRateIfNeeded(gains: self.currentGains())
        }
        sessionObserver.onMediaServicesReset = { [weak self] in
            guard let self else { return }
            let shouldResume = self.isPlaying
            self.engine.invalidateGraph()
            self.endPlayback(engineAction: .none, canDowngrade: !shouldResume)
            if shouldResume {
                self.play(userInitiated: false)
            }
        }
        sessionObserver.start()
    }

    private func currentGains() -> SoundGains {
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
}
#endif
