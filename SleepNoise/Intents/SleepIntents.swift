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

    /// The saved mixes, for the entity query. The Shortcuts app may ask
    /// before the interface exists: the list is then read from where it is
    /// stored.
    static var mixStore: MixStore {
        mixer?.mixStore ?? MixStore()
    }
}

/// The one thing a playback Shortcut says (copy guide §5e.17): the sound did
/// not start. When it works, the sound is the answer and nothing is said.
enum IntentFailure: Error, CustomLocalizedStringResourceConvertible {
    case soundDidNotStart

    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource("siri.error")
    }
}

// MARK: - A mix by name

/// A mix a Shortcut can name: the person's saved mixes and the four of the
/// house (C18, C43). The id is `MixReference.stableID`, which a stored
/// Shortcut keeps.
struct MixEntity: AppEntity, Equatable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("atajo.parametro.mezcla")
    )
    static var defaultQuery = MixEntityQuery()

    let id: String
    /// A saved mix goes by the name the person wrote, in any language; a
    /// house mix by its name in the language the app speaks.
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    var reference: MixReference? { MixReference(stableID: id) }

    init(_ reference: MixReference, name: String) {
        id = reference.stableID
        self.name = name
    }

    /// Every mix that can be asked for: yours first, then the house's.
    static func all(saved: [SavedMix]) -> [MixEntity] {
        saved.map { MixEntity(.saved($0.id), name: $0.name) }
            + HouseMix.allCases.map { MixEntity(.house($0), name: $0.localizedName) }
    }

    /// The mixes whose name contains what was said, whatever its capitals
    /// and accents. A name said in full comes first.
    static func matching(_ text: String, in mixes: [MixEntity]) -> [MixEntity] {
        let wanted = folded(text)
        guard !wanted.isEmpty else { return [] }
        let found = mixes.filter { folded($0.name).contains(wanted) }
        return found.filter { folded($0.name) == wanted } + found.filter { folded($0.name) != wanted }
    }

    private static func folded(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
    }
}

struct MixEntityQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [MixEntity] {
        let all = MixEntity.all(saved: IntentBridge.mixStore.mixes)
        return identifiers.compactMap { id in all.first { $0.id == id } }
    }

    @MainActor
    func entities(matching string: String) async throws -> [MixEntity] {
        MixEntity.matching(string, in: MixEntity.all(saved: IntentBridge.mixStore.mixes))
    }

    @MainActor
    func suggestedEntities() async throws -> [MixEntity] {
        MixEntity.all(saved: IntentBridge.mixStore.mixes)
    }
}

// MARK: - The modes of the timer

/// The two ways a night ends by itself, and none, as a Shortcut names them.
/// A phrase can only carry an enumeration or an entity, never a number.
enum ShortcutTimerMode: String, AppEnum {
    case untilAsleep
    case blanket
    case off

    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("temporizador.titulo")
    )

    static var caseDisplayRepresentations: [ShortcutTimerMode: DisplayRepresentation] = [
        .untilAsleep: DisplayRepresentation(
            title: LocalizedStringResource("temporizador.dormirme"),
            synonyms: [LocalizedStringResource("atajo.modo.dormirme.sinonimo")]
        ),
        .blanket: DisplayRepresentation(
            title: LocalizedStringResource("temporizador.manto"),
            synonyms: [LocalizedStringResource("atajo.modo.manto.sinonimo")]
        ),
        .off: DisplayRepresentation(
            title: LocalizedStringResource("temporizador.apagado"),
            synonyms: [LocalizedStringResource("atajo.modo.apagado.sinonimo")]
        )
    ]

    var mode: TimerMode {
        switch self {
        case .untilAsleep: return .untilAsleep
        case .blanket: return .blanket
        case .off: return .off
        }
    }
}

// MARK: - The five intents (PLAN-SIMPLE §4.3, surface 24)
//
// None of them raises the Pro sheet or starts a trial: what needs Pro
// without access does not sound, and nothing is said about it. The ones that
// start the sound bring the app forward (`openAppWhenRun`), as they did
// before: changing that has to be tried on a real iPhone first.

/// Plays the last mix, with the timer the person chose. If something is
/// already sounding, nothing changes.
struct PlayLastMixIntent: AppIntent {
    static var title: LocalizedStringResource = "atajo.reproducir.titulo"
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let mixer = IntentBridge.mixer, mixer.playFromShortcut() == .started else {
            throw IntentFailure.soundDidNotStart
        }
        return .result()
    }
}

/// Pausing needs no interface: it runs in the background and never brings
/// the app to the front of a dark bedroom. While audio plays the process is
/// alive and the bridge is attached; with no mixer there is nothing playing.
/// It says nothing, also when nothing was playing.
struct PauseIntent: AppIntent {
    static var title: LocalizedStringResource = "atajo.pausa.titulo"
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult {
        _ = IntentBridge.mixer?.pauseFromShortcut()
        return .result()
    }
}

/// Loads a mix by name, one of the person's or one of the house, and plays
/// it. A mix with Pro layers and no access plays what there is.
struct PlayMixIntent: AppIntent {
    static var title: LocalizedStringResource = "atajo.mezcla.titulo"
    static var openAppWhenRun = true

    @Parameter(
        title: LocalizedStringResource("atajo.parametro.mezcla"),
        requestValueDialog: IntentDialog(LocalizedStringResource("siri.mezcla.cual"))
    )
    var mix: MixEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Play \(\.$mix)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let mixer = IntentBridge.mixer else { throw IntentFailure.soundDidNotStart }
        guard let reference = mix.reference else { throw mixIsGone }
        switch mixer.playMixFromShortcut(reference) {
        case .started:
            return .result()
        case .notFound:
            // Deleted since the Shortcut was written: ask which one.
            throw mixIsGone
        case .stopped, .nothingPlaying, .applied, .failed:
            throw IntentFailure.soundDidNotStart
        }
    }

    private var mixIsGone: Error {
        $mix.needsValueError(IntentDialog(LocalizedStringResource("siri.mezcla.cual")))
    }
}

/// Sets the timer the way its sheet does: the mode, with the length or the
/// hour that mode already had. The whole timer is free (C03). "Until I
/// sleep" and "Blanket" start the mix if it was at rest; "Off" only sets it.
/// `minutes` is for the Shortcuts editor and is never part of a phrase.
struct SetTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "temporizador.titulo"
    static var openAppWhenRun = true

    @Parameter(title: LocalizedStringResource("atajo.parametro.modo"))
    var mode: ShortcutTimerMode

    @Parameter(
        title: LocalizedStringResource("atajo.parametro.minutos"),
        inclusiveRange: (1, 360)
    )
    var minutes: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Set the timer to \(\.$mode)") {
            \.$minutes
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let mixer = IntentBridge.mixer,
              mixer.setTimerFromShortcut(mode: mode.mode, minutes: minutes) != .failed
        else { throw IntentFailure.soundDidNotStart }
        return .result()
    }
}

/// Small Hours (C05, C27): the fixed recipe, twenty minutes, for everyone.
/// It never asks for Pro and never starts a trial, at any hour.
struct SmallHoursIntent: AppIntent {
    static var title: LocalizedStringResource = "madrugada.titulo"
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let mixer = IntentBridge.mixer, mixer.startSmallHours() == .started else {
            throw IntentFailure.soundDidNotStart
        }
        return .result()
    }
}

/// The phrases live in `AppShortcuts.xcstrings`, in English and Spanish, and
/// every one of them names the app with `${applicationName}` (C10).
struct SleepNoiseShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .navy

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlayLastMixIntent(),
            phrases: [
                "Play \(.applicationName)",
                "Start \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("atajo.reproducir.titulo"),
            systemImageName: "play.fill"
        )
        AppShortcut(
            intent: PauseIntent(),
            phrases: [
                "Pause \(.applicationName)",
                "Stop \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("atajo.pausa.titulo"),
            systemImageName: "pause.fill"
        )
        AppShortcut(
            intent: PlayMixIntent(),
            phrases: [
                "Play \(\.$mix) in \(.applicationName)",
                "Play the \(\.$mix) mix in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("atajo.mezcla.titulo"),
            systemImageName: "square.stack"
        )
        AppShortcut(
            intent: SetTimerIntent(),
            phrases: [
                "Set \(\.$mode) in \(.applicationName)",
                "\(.applicationName) \(\.$mode)"
            ],
            shortTitle: LocalizedStringResource("temporizador.titulo"),
            systemImageName: "timer"
        )
        AppShortcut(
            intent: SmallHoursIntent(),
            phrases: [
                "Small hours in \(.applicationName)",
                "Start Small hours in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("madrugada.titulo"),
            systemImageName: "water.waves"
        )
    }
}
