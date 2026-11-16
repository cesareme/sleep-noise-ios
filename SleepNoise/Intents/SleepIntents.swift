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
    case white, pink, brown, rain, fan, ocean, thunder, campfire, brook, wind, cabin

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
        .brook: DisplayRepresentation(title: LocalizedStringResource("sound.brook")),
        .wind: DisplayRepresentation(title: LocalizedStringResource("sound.wind")),
        .cabin: DisplayRepresentation(title: LocalizedStringResource("sound.cabin"))
    ]

    var soundID: SoundID {
        SoundID(rawValue: rawValue) ?? .brown
    }
}

/// What Siri says back. A request that needs Pro is answered in words that
/// name what is free; a Shortcut never raises the paywall.
enum IntentReply {
    static func playing(_ sound: SoundID) -> String {
        String(format: String(localized: "intent.playedSoundFormat"), sound.localizedName)
    }

    static func soundNeedsPro(_ sound: SoundID) -> String {
        let free = SoundID.allCases
            .filter { AccessPolicy.soundIsIncluded($0, hasFullAccess: false) }
            .map(\.localizedName)
        return String(
            format: String(localized: "intent.soundNeedsProFormat"),
            sound.localizedName,
            ListFormatter.localizedString(byJoining: free)
        )
    }

    static func timerStarted(minutes: Int) -> String {
        String(format: String(localized: "intent.timerStartedFormat"), Int64(minutes))
    }

    /// The free lengths come from the gate itself, so the reply cannot drift
    /// from `AccessPolicy` and does not depend on how the gate is stored.
    static func timerNeedsPro(minutes: Int) -> String {
        let free = (1...AccessPolicy.maxTimerMinutes)
            .filter { AccessPolicy.timerIsIncluded(minutes: $0, hasFullAccess: false) }
            .map { String($0) }
        return String(
            format: String(localized: "intent.timerNeedsProFormat"),
            Int64(minutes),
            ListFormatter.localizedString(byJoining: free)
        )
    }

    static func timerOutOfRange() -> String {
        String(format: String(localized: "intent.timerOutOfRangeFormat"), Int64(AccessPolicy.maxTimerMinutes))
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
        let id = sound.soundID
        switch mixer.playSound(id) {
        case .started:
            return .result(dialog: IntentDialog(stringLiteral: IntentReply.playing(id)))
        case .needsPro:
            return .result(dialog: IntentDialog(stringLiteral: IntentReply.soundNeedsPro(id)))
        case .failed, .stopped, .nothingPlaying, .nothingToPlay, .outOfRange:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.failed")))
        }
    }
}

/// With no length given (the spoken phrase gives none) the timer the person
/// already chose in the app is used, and 60 minutes when there is none; that
/// fallback is for tonight only and is not stored. Only a length written into
/// the Shortcut replaces the stored choice.
struct StartSleepTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.timer.title"
    static var description = IntentDescription(LocalizedStringResource("intent.timer.description"))
    static var openAppWhenRun = true

    @Parameter(
        title: LocalizedStringResource("intent.param.minutes"),
        inclusiveRange: (1, 360)
    )
    var minutes: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Start a \(\.$minutes) minute timer")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let mixer = IntentBridge.mixer else {
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.unavailable")))
        }
        let length = mixer.timerMinutes(requested: minutes)
        switch mixer.startTimer(minutes: minutes) {
        case .started:
            return .result(dialog: IntentDialog(stringLiteral: IntentReply.timerStarted(minutes: length)))
        case .needsPro:
            return .result(dialog: IntentDialog(stringLiteral: IntentReply.timerNeedsPro(minutes: length)))
        case .outOfRange:
            return .result(dialog: IntentDialog(stringLiteral: IntentReply.timerOutOfRange()))
        case .nothingToPlay:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.nothingToPlay")))
        case .failed, .stopped, .nothingPlaying:
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.failed")))
        }
    }
}

/// Stopping needs no interface: it runs in the background and never brings
/// the app to the front of a dark bedroom. While audio plays the process is
/// alive and the bridge is attached; with no mixer there is nothing playing.
struct StopPlaybackIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.stop.title"
    static var description = IntentDescription(LocalizedStringResource("intent.stop.description"))
    static var openAppWhenRun = false

    static var parameterSummary: some ParameterSummary {
        Summary("Stop")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let mixer = IntentBridge.mixer, mixer.stopFromShortcut() == .stopped else {
            return .result(dialog: IntentDialog(LocalizedStringResource("intent.nothingPlaying")))
        }
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
            intent: StartSleepTimerIntent(),
            phrases: [
                "Start sleep timer in \(.applicationName)"
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
