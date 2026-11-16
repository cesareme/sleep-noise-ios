import AppIntents
import Foundation

/// The running mixer, so a Shortcut can reach the same engine and the same
/// entitlement checks as the screen. Attached from `AppRoot` at launch.
@MainActor
enum IntentBridge {
    static weak var mixer: MixerModel?

    static func attach(_ mixer: MixerModel) {
        self.mixer = mixer
    }
}

enum IntentSound: String, AppEnum {
    case white, pink, brown, rain, fan, ocean, thunder, campfire, stream, wind, cabin

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("intent.sound.type"))

    static var caseDisplayRepresentations: [IntentSound: DisplayRepresentation] = [
        .white: DisplayRepresentation(title: LocalizedStringResource("sound.white")),
        .pink: DisplayRepresentation(title: LocalizedStringResource("sound.pink")),
        .brown: DisplayRepresentation(title: LocalizedStringResource("sound.brown")),
        .rain: DisplayRepresentation(title: LocalizedStringResource("sound.rain")),
        .fan: DisplayRepresentation(title: LocalizedStringResource("sound.fan")),
        .ocean: DisplayRepresentation(title: LocalizedStringResource("sound.ocean")),
        .thunder: DisplayRepresentation(title: LocalizedStringResource("sound.thunder")),
        .campfire: DisplayRepresentation(title: LocalizedStringResource("sound.campfire")),
        .stream: DisplayRepresentation(title: LocalizedStringResource("sound.stream")),
        .wind: DisplayRepresentation(title: LocalizedStringResource("sound.wind")),
        .cabin: DisplayRepresentation(title: LocalizedStringResource("sound.cabin"))
    ]

    var soundID: SoundID {
        SoundID(rawValue: rawValue) ?? .brown
    }
}

enum IntentPreset: String, AppEnum {
    case deepSleep, focus, steadyRain, baby, storm, cabin, campfire, brook, nightWind, shore

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("intent.preset.type"))

    static var caseDisplayRepresentations: [IntentPreset: DisplayRepresentation] = [
        .deepSleep: DisplayRepresentation(title: LocalizedStringResource("preset.deepSleep")),
        .focus: DisplayRepresentation(title: LocalizedStringResource("preset.focus")),
        .steadyRain: DisplayRepresentation(title: LocalizedStringResource("preset.steadyRain")),
        .baby: DisplayRepresentation(title: LocalizedStringResource("preset.baby")),
        .storm: DisplayRepresentation(title: LocalizedStringResource("preset.storm")),
        .cabin: DisplayRepresentation(title: LocalizedStringResource("preset.cabin")),
        .campfire: DisplayRepresentation(title: LocalizedStringResource("preset.campfire")),
        .brook: DisplayRepresentation(title: LocalizedStringResource("preset.brook")),
        .nightWind: DisplayRepresentation(title: LocalizedStringResource("preset.nightWind")),
        .shore: DisplayRepresentation(title: LocalizedStringResource("preset.shore"))
    ]

    var preset: SoundPreset {
        SoundPreset(rawValue: rawValue) ?? .deepSleep
    }
}

struct PlaySoundIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.playSound.title"
    static var description = IntentDescription(LocalizedStringResource("intent.playSound.description"))
    static var openAppWhenRun = true

    @Parameter(title: LocalizedStringResource("intent.param.sound"))
    var sound: IntentSound

    static var parameterSummary: some ParameterSummary {
        Summary("Play \(\.$sound)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let mixer = IntentBridge.mixer else {
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.unavailable")))
        }
        switch mixer.playSound(sound.soundID) {
        case .started:
            let line = String(format: String(localized: "intent.playedSoundFormat"), sound.soundID.localizedName)
            return .result(dialog: IntentDialog(stringLiteral: line))
        case .needsPro:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.needsPro")))
        case .failed, .stopped:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.failed")))
        }
    }
}

struct PlayPresetIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.playPreset.title"
    static var description = IntentDescription(LocalizedStringResource("intent.playPreset.description"))
    static var openAppWhenRun = true

    @Parameter(title: LocalizedStringResource("intent.param.preset"))
    var preset: IntentPreset

    static var parameterSummary: some ParameterSummary {
        Summary("Play \(\.$preset)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let mixer = IntentBridge.mixer else {
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.unavailable")))
        }
        switch mixer.playPreset(preset.preset) {
        case .started:
            let line = String(format: String(localized: "intent.playedPresetFormat"), preset.preset.localizedName)
            return .result(dialog: IntentDialog(stringLiteral: line))
        case .needsPro:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.needsPro")))
        case .failed, .stopped:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.failed")))
        }
    }
}

struct StartSleepTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.timer.title"
    static var description = IntentDescription(LocalizedStringResource("intent.timer.description"))
    static var openAppWhenRun = true

    @Parameter(title: LocalizedStringResource("intent.param.minutes"), default: 60, inclusiveRange: 1...360)
    var minutes: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Start a \(\.$minutes) minute timer")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let mixer = IntentBridge.mixer else {
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.unavailable")))
        }
        switch mixer.startTimer(minutes: minutes) {
        case .started:
            let line = String(format: String(localized: "intent.timerStartedFormat"), Int64(minutes))
            return .result(dialog: IntentDialog(stringLiteral: line))
        case .needsPro:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.needsPro")))
        case .failed, .stopped:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.failed")))
        }
    }
}

struct StopPlaybackIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.stop.title"
    static var description = IntentDescription(LocalizedStringResource("intent.stop.description"))
    static var openAppWhenRun = true

    static var parameterSummary: some ParameterSummary {
        Summary("Stop")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let mixer = IntentBridge.mixer else {
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.unavailable")))
        }
        _ = mixer.stopFromShortcut()
        return .result(dialog: IntentDialog(LocalizedStringResource("intent.stopped")))
    }
}

struct SleepNoiseShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .navy

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlaySoundIntent(),
            phrases: [
                "Play \(\.$sound) in \(.applicationName)",
                "Start \(\.$sound) with \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut.playSound"),
            systemImageName: "play.fill"
        )
        AppShortcut(
            intent: PlayPresetIntent(),
            phrases: [
                "Play \(\.$preset) in \(.applicationName)",
                "Start \(\.$preset) with \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut.playPreset"),
            systemImageName: "moon.stars.fill"
        )
        AppShortcut(
            intent: StartSleepTimerIntent(),
            phrases: [
                "Start sleep timer in \(.applicationName)",
                "Start a \(\.$minutes) minute sleep timer in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut.timer"),
            systemImageName: "timer"
        )
        AppShortcut(
            intent: StopPlaybackIntent(),
            phrases: [
                "Stop \(.applicationName)",
                "Pause \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut.stop"),
            systemImageName: "stop.fill"
        )
    }
}
