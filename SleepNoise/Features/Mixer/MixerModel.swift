import Combine
import Foundation

@MainActor
final class MixerModel: ObservableObject {
    @Published var levels: [SoundID: Float]
    @Published private(set) var isPlaying = false
    @Published var audioError: String?
    @Published var showPaywall = false
    @Published private(set) var loadedMixName: String?
    /// A saved mix was loaded with fan or ocean muted because they need Pro.
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

    /// Loads a saved mix. Fan and ocean are muted (their levels are kept)
    /// when they are not included; the mixer shows a note instead of a sheet.
    @discardableResult
    func apply(_ mix: SavedMix) -> Bool {
        var next = Self.defaultLevels()
        for level in mix.levels {
            next[level.sound] = level.value
        }
        var stripped = false
        for sound in SoundID.allCases where !AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) {
            if (next[sound] ?? 0) > 0.001 {
                stripped = true
            }
        }
        levels = next
        loadedMixName = mix.name
        loadedMixWasStripped = stripped
        persistLevels()
        if isPlaying {
            engine.updateGains(currentGains())
        }
        return stripped
    }

    func suggestedMixName() -> String {
        String(format: String(localized: "mixes.defaultNameFormat"), Int64(mixStore.mixes.count + 1))
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
        if purchases.hasFullAccess {
            loadedMixWasStripped = false
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
