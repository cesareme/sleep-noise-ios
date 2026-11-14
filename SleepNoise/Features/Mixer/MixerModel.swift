import Combine
import Foundation

@MainActor
final class MixerModel: ObservableObject {
    @Published var levels: [SoundID: Float]
    @Published private(set) var isPlaying = false
    @Published var audioError: String?
    @Published var showPaywall = false
    @Published private(set) var loadedMixName: String?

    let purchases: PurchaseManager
    let mixStore: MixStore
    let timer: SleepTimerController

    private let engine = SleepAudioEngine()
    private let nowPlaying = NowPlayingController()
    private let sessionObserver = AudioSessionObserver()
    private let defaults: UserDefaults
    private let levelsKey = "sleepnoise.levels.v1"
    private let timerKey = "sleepnoise.timerMinutes.v1"
    private var didStart = false
    private var resumeAfterInterruption = false

    init(
        purchases: PurchaseManager,
        mixStore: MixStore? = nil,
        timer: SleepTimerController? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.purchases = purchases
        self.defaults = defaults
        self.mixStore = mixStore ?? MixStore(defaults: defaults)
        self.timer = timer ?? SleepTimerController()
        levels = Self.loadLevels(defaults: defaults, key: levelsKey) ?? Self.defaultLevels()
        if let minutes = defaults.object(forKey: timerKey) as? Int,
           AccessPolicy.timerIsIncluded(minutes: minutes, isPro: purchases.isPro) || AccessPolicy.freeTimerMinutes.contains(minutes) {
            self.timer.choose(minutes)
        }
        bindTimer()
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
        guard AccessPolicy.soundIsIncluded(sound, isPro: purchases.isPro) else {
            showPaywall = true
            return
        }
        levels[sound] = min(1, max(0, value))
        loadedMixName = nil
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

    func play() {
        audioError = nil
        resumeAfterInterruption = false
        do {
            try engine.start(gains: currentGains())
            isPlaying = true
            timer.start()
            nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
        } catch {
            isPlaying = false
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
        engine.stop(fadeOut: 0.04)
        isPlaying = false
        timer.pause()
        nowPlaying.update(isPlaying: false, title: nowPlayingTitle)
    }

    func selectTimer(minutes: Int?) {
        if let minutes, !AccessPolicy.timerIsIncluded(minutes: minutes, isPro: purchases.isPro) {
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
        guard !AccessPolicy.timerIsIncluded(minutes: minutes, isPro: purchases.isPro) else { return }
        let wasCounting = timer.remaining != nil
        selectTimer(minutes: nil)
        if wasCounting {
            pause(resumeLater: false)
        }
    }

    func saveCurrent(name: String) -> SaveMixResult {
        let result = mixStore.save(name: name, levels: levels, isPro: purchases.isPro)
        switch result {
        case .saved(let mix):
            loadedMixName = mix.name
        case .needsPro:
            showPaywall = true
        case .emptyName:
            break
        }
        return result
    }

    @discardableResult
    func apply(_ mix: SavedMix) -> Bool {
        var next = Self.defaultLevels()
        for level in mix.levels {
            next[level.sound] = level.value
        }
        var stripped = false
        for sound in SoundID.allCases where !AccessPolicy.soundIsIncluded(sound, isPro: purchases.isPro) {
            if (next[sound] ?? 0) > 0.001 {
                stripped = true
            }
            next[sound] = 0
        }
        levels = next
        loadedMixName = mix.name
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

    func refreshEntitledAudio() {
        guard isPlaying else { return }
        engine.updateGains(currentGains())
    }

    private func bindTimer() {
        timer.onFade = { [weak self] seconds in
            self?.engine.fadeOut(over: seconds)
        }
        timer.onComplete = { [weak self] in
            guard let self else { return }
            self.engine.stop(fadeOut: 0.01)
            self.isPlaying = false
            self.nowPlaying.update(isPlaying: false, title: self.nowPlayingTitle)
        }
    }

    private func installSessionHandlers() {
        sessionObserver.onInterruptionBegan = { [weak self] in
            self?.pause(resumeLater: true)
        }
        sessionObserver.onInterruptionEnded = { [weak self] shouldResume in
            guard let self else { return }
            if shouldResume, self.resumeAfterInterruption {
                self.play()
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
            self.isPlaying = false
            if shouldResume {
                self.play()
            }
        }
        sessionObserver.start()
    }

    private func currentGains() -> SoundGains {
        var gains = SoundGains.zero
        for sound in SoundID.allCases {
            let level = levels[sound] ?? 0
            if AccessPolicy.soundIsIncluded(sound, isPro: purchases.isPro) {
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
