#if DEBUG
import SwiftUI

/// Debug builds only: fixes the state of the page for the reference
/// captures. Not a product path.
///
/// Launch with `-pageState <name>` (see `PageDebugState`). A staged launch
/// reads and writes a scratch defaults suite, never the real one, and runs
/// on a pinned clock: midday, or the small hours for `night`. Add
/// `-silentOutput` so the engine renders and meters without making a sound,
/// and `-pageType <size>` to force a Dynamic Type size.
enum PageDebugState: String, CaseIterable {
    /// First use: the house mix as it loads, nothing playing.
    case rest
    /// Playing the first-use mix: two layers.
    case playingTwo
    /// Playing five layers: three rows and "and 2 more".
    case playingFive
    /// The night page: one ink, nothing to sell.
    case night
    /// Playing with the sleep timer counting.
    case timer
    /// The Layers sheet over the page.
    case layers
    /// Layers without access: five free layers and a Pro one that keeps
    /// its level.
    case layersSix
    /// Layers with six sounding and the seventh refused.
    case layersCap
    /// The engine did not start.
    case error
    /// The page at an accessibility text size.
    case largeType
}

enum PageArguments {
    private static var arguments: [String] { ProcessInfo.processInfo.arguments }

    private static func value(after flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static var state: PageDebugState? {
        value(after: "-pageState").flatMap(PageDebugState.init(rawValue:))
    }

    static var opensLayers: Bool {
        switch state {
        case .layers, .layersSix, .layersCap: return true
        default: return false
        }
    }

    /// The row that shows "Six at once" from the start, for the capture.
    static var capNoteSound: SoundID? {
        state == .layersCap ? .white : nil
    }

    static var dynamicType: DynamicTypeSize? {
        switch value(after: "-pageType") {
        case "xSmall": return .xSmall
        case "large": return .large
        case "xLarge": return .xLarge
        case "xxxLarge": return .xxxLarge
        case "accessibility1": return .accessibility1
        case "accessibility2": return .accessibility2
        case "accessibility3": return .accessibility3
        case "accessibility5": return .accessibility5
        default: return state == .largeType ? .accessibility2 : nil
        }
    }
}

/// Forces the text size a capture asks for; otherwise the system's.
struct DebugDynamicType: ViewModifier {
    func body(content: Content) -> some View {
        if let size = PageArguments.dynamicType {
            content.dynamicTypeSize(size)
        } else {
            content
        }
    }
}

/// Builds the model a staged launch runs on.
@MainActor
enum PageStage {
    static let suiteName = "sleepnoise.debug.page"

    /// Midday on a fixed date, or 02:14 the next night, local time.
    static func clock(for state: PageDebugState) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 17
        components.hour = state == .night ? 2 : 12
        components.minute = state == .night ? 14 : 0
        return Calendar.current.date(from: components) ?? Date()
    }

    static func make(_ state: PageDebugState) -> (PurchaseManager, MixerModel) {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        let purchases = PurchaseManager(defaults: defaults)
        if state == .layersSix {
            // The trial ran out long ago and nothing was bought.
            let start = Date().addingTimeInterval(-30 * 86_400)
            purchases.startTrialIfNeeded(now: start)
            purchases.refreshAccess(now: start.addingTimeInterval(8 * 86_400), canDowngrade: true)
        }
        let pinned = clock(for: state)
        let model = MixerModel(purchases: purchases, defaults: defaults, now: { pinned })

        switch state {
        case .rest, .playingTwo, .layers, .error, .largeType:
            break
        case .playingFive:
            setLevels(model, [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .pink: 0.3, .brown: 0.2])
        case .night:
            model.selectTimer(minutes: 90)
            model.beginNightSession()
        case .timer:
            model.selectTimer(minutes: 45)
        case .layersSix:
            // Ocean was saved at 50 while the trial lasted; it keeps it.
            setLevels(model, [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .white: 0.15, .pink: 0.3, .brown: 0.2])
        case .layersCap:
            setLevels(model, [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .thunder: 0.2, .pink: 0.3, .brown: 0.2])
        }
        return (purchases, model)
    }

    /// Lays the levels down as an edited mix ("Tonight"). Written straight
    /// into the model: a Pro layer keeps a level here without asking for
    /// the Pro sheet.
    private static func setLevels(_ model: MixerModel, _ levels: [SoundID: Float]) {
        for sound in SoundID.allCases {
            model.levels[sound] = levels[sound] ?? 0
        }
        // One real edit: the mix loses the name it loaded with and is stored.
        model.setLevel(.rain, levels[.rain] ?? 0)
    }

    /// What a staged page does once it is on screen.
    static func didAppear(_ model: MixerModel) {
        guard let state = PageArguments.state else { return }
        switch state {
        case .rest, .layersSix:
            break
        case .error:
            model.debugFailStart()
        case .playingTwo, .playingFive, .night, .timer, .layers, .layersCap, .largeType:
            if !model.isPlaying { model.play() }
        }
    }
}
#endif
