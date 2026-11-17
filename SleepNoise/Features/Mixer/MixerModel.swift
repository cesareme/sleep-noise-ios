import Combine
import Foundation

@MainActor
final class MixerModel: ObservableObject {
    @Published var levels: [SoundID: Float]
    @Published private(set) var isPlaying = false
    @Published var audioError: String?
    @Published var showPaywall = false
    @Published private(set) var loadedMixName: String?
    /// Preset last applied, until the person edits a level.
    @Published private(set) var activePreset: SoundPreset?
    /// Night screen is covering the interface. Audio keeps running when this
    /// turns off.
    @Published private(set) var isBedtime = false
    /// The loaded mix or preset has layers that are muted because they need Pro.
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
    private let levelsKey = "sleepnoise.levels.v1"
    private let timerKey = "sleepnoise.timerMinutes.v1"
    /// Length the timer Shortcut uses when none was asked for or chosen.
    static let fallbackTimerMinutes = 60
    private var didStart = false
    private var resumeAfterInterruption = false
    private var noteTask: Task<Void, Never>?
    /// Ocean level before the tide raised it, restored if the tide is switched
    /// off again before the slider is touched.
    private var oceanBeforeTide: Float?

    init(
        purchases: PurchaseManager,
        mixStore: MixStore? = nil,
        timer: SleepTimerController? = nil,
        breathing: BreathingGuideController? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.purchases = purchases
        self.defaults = defaults
        self.mixStore = mixStore ?? MixStore(defaults: defaults)
        self.timer = timer ?? SleepTimerController()
        self.breathing = breathing ?? BreathingGuideController(defaults: defaults)
        levels = Self.loadLevels(defaults: defaults, key: levelsKey) ?? Self.defaultLevels()
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

    func setLevel(_ sound: SoundID, _ value: Float) {
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else {
            showPaywall = true
            return
        }
        levels[sound] = min(1, max(0, value))
        loadedMixName = nil
        loadedMixWasStripped = false
        activePreset = nil
        if sound == .ocean { oceanBeforeTide = nil }
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
        }
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
            purchases.startTrialIfNeeded()
            timer.start()
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        } catch {
            endPlayback(engineAction: .none, canDowngrade: true)
            audioError = String(localized: "error.audio")
        }
    }

    func pause(resumeLater: Bool) {
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
        endPlayback(engineAction: .stop(fadeOut: 0.04), canDowngrade: !resumeAfterInterruption)
    }

    func selectTimer(minutes: Int?) {
        if let minutes, !AccessPolicy.timerIsIncluded(minutes: minutes, hasFullAccess: purchases.hasFullAccess) {
            showPaywall = true
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
            loadedMixWasStripped = false
        case .needsPro:
            showPaywall = true
        case .emptyName:
            break
        }
        return result
    }

    /// Loads a saved mix. Pro layers are muted (their levels are kept) when
    /// they are not included; the mixer shows a note instead of a sheet.
    @discardableResult
    func apply(_ mix: SavedMix) -> Bool {
        var next = Self.defaultLevels()
        for level in mix.levels {
            next[level.sound] = level.value
        }
        let stripped = Self.hasMutedLayers(next, hasFullAccess: purchases.hasFullAccess)
        levels = next
        loadedMixName = mix.name
        loadedMixWasStripped = stripped
        activePreset = nil
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
        }
        return stripped
    }

    func suggestedMixName() -> String {
        String(format: String(localized: "mixes.defaultNameFormat"), Int64(mixStore.mixes.count + 1))
    }

    // MARK: Presets, Shortcuts, Night

    /// Shortcuts: replace the mix with a preset and start playback. A preset
    /// with Pro layers needs full access; without it nothing changes and no
    /// paywall is raised, because the request may come by voice in the dark.
    /// The intent answers in words instead. `play()` does the one-time setup,
    /// so a refused request has no side effects.
    ///
    /// Every Shortcut entry point reads the trial clock first: a trial that
    /// ran out while the app was suspended must not let one more Pro night
    /// through because the scene has not become active yet.
    @discardableResult
    func playPreset(_ preset: SoundPreset) -> IntentOutcome {
        purchases.refreshAccess(canDowngrade: !isPlaying)
        switch PresetLibrary.apply(preset, hasFullAccess: purchases.hasFullAccess) {
        case .needsPro:
            return .needsPro
        case .levels(let next):
            levels = next
            activePreset = preset
            loadedMixName = preset.localizedName
            loadedMixWasStripped = false
            persistLevels()
            return startOrUpdate()
        }
    }

    /// Shortcuts: play one sound on its own. Same rule as `playPreset`.
    @discardableResult
    func playSound(_ sound: SoundID) -> IntentOutcome {
        purchases.refreshAccess(canDowngrade: !isPlaying)
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else {
            return .needsPro
        }
        var next = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        next[sound] = PresetLibrary.engagedLevel
        levels = next
        activePreset = nil
        loadedMixName = sound.localizedName
        loadedMixWasStripped = false
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

    func leaveBedtime() {
        isBedtime = false
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
        // A mix or preset that was whole during the trial is a stripped one
        // once the trial ends: say so instead of keeping its name as if
        // nothing had changed. A Pro preset is no longer the one playing.
        loadedMixWasStripped = loadedMixName != nil
            && Self.hasMutedLayers(levels, hasFullAccess: purchases.hasFullAccess)
        if let preset = activePreset, preset.requiresFullAccess, !purchases.hasFullAccess {
            activePreset = nil
        }
        guard isPlaying else { return }
        engine.updateGains(currentGains())
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
            showPaywall = true
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
        }
    }

    private func installSessionHandlers() {
        sessionObserver.onInterruptionBegan = { [weak self] in
            self?.pause(resumeLater: true)
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
            self?.pause(resumeLater: false)
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
        guard let data = defaults.data(forKey: key) else { return nil }
        guard let payload = try? JSONDecoder().decode([MixLevel].self, from: data) else { return nil }
        var levels = defaultLevels()
        for entry in payload {
            levels[entry.sound] = min(1, max(0, entry.value))
        }
        return levels
    }

    private static func defaultLevels() -> [SoundID: Float] {
        var levels = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        levels[.pink] = 0.65
        return levels
    }
}
