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
    /// Layers without access, scrolled to its end: the last beds, a Pro
    /// one that keeps its level, and the notes over the bar.
    case layersEnd
    /// The engine did not start.
    case error
    /// It did not start twice, and three times: the next rungs of the line.
    case error2
    case error3
    /// The page at an accessibility text size.
    case largeType
    /// The Layers sheet opened from the night page: one ink, title included.
    case nightLayers
    /// Playing with the tide on, by day.
    case tide
    /// The night page with the tide on.
    case nightTide

    // The timer sheet over the page.
    /// First use, nothing playing: "Until I sleep", 45 minutes.
    case timerRest
    /// "Until I sleep" counting.
    case timerAsleep
    /// A blanket until seven.
    case timerBlanket
    /// Inside the final fade.
    case timerFading
    /// Paused with time left.
    case timerPaused
    /// The wheel of lengths open.
    case timerLength
    /// The time picker of the blanket open.
    case timerHour
    /// Opened from the night page: one ink.
    case timerNight

    // The tide sheet over the page.
    /// Off, with access.
    case tideRest
    /// Guiding at the pace chosen.
    case tideGuiding
    /// Guiding with "Descent": it begins at twelve a minute.
    case tideDescent
    /// Letting go.
    case tideDissolving
    /// Without access: "pro" beside the title.
    case tideLocked
    /// Opened from the night page: one ink.
    case tideNight

    var opensTimer: Bool {
        switch self {
        case .timerRest, .timerAsleep, .timerBlanket, .timerFading, .timerPaused, .timerLength,
             .timerHour, .timerNight:
            return true
        default:
            return false
        }
    }

    var opensTide: Bool {
        switch self {
        case .tideRest, .tideGuiding, .tideDescent, .tideDissolving, .tideLocked, .tideNight: return true
        default: return false
        }
    }

    /// Staged in the small hours, on the night page.
    var isNight: Bool {
        switch self {
        case .night, .nightLayers, .nightTide, .timerNight, .tideNight: return true
        default: return false
        }
    }
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
        case .layers, .layersSix, .layersCap, .layersEnd, .nightLayers: return true
        default: return false
        }
    }

    /// The sheet a staged launch opens over the page.
    static var initialSheet: PageSheet? {
        guard let state else { return nil }
        if opensLayers { return .layers }
        if state.opensTimer { return .timer }
        if state.opensTide { return .tide }
        return nil
    }

    /// The timer sheet opens with the control of its mode unfolded.
    static var opensTimerControl: Bool {
        state == .timerLength || state == .timerHour
    }

    /// Layers opens at the end of its content.
    static var scrollsLayersToEnd: Bool { state == .layersEnd }

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
        case "accessibility4": return .accessibility4
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

    /// The clock a staged launch runs on. It stands still unless a state
    /// moves it (to land inside the final fade of the timer).
    final class Clock: @unchecked Sendable {
        var date = Date()
    }

    private static let stageClock = Clock()

    /// Midday on a fixed date, or 02:14 the next night, local time.
    static func clock(for state: PageDebugState) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 17
        components.hour = state.isNight ? 2 : 12
        components.minute = state.isNight ? 14 : 0
        return Calendar.current.date(from: components) ?? Date()
    }

    static func make(_ state: PageDebugState) -> (PurchaseManager, MixerModel) {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        let purchases = PurchaseManager(defaults: defaults)
        if state == .layersSix || state == .layersEnd || state == .tideLocked {
            // The trial ran out long ago and nothing was bought.
            let start = Date().addingTimeInterval(-30 * 86_400)
            purchases.startTrialIfNeeded(now: start)
            purchases.refreshAccess(now: start.addingTimeInterval(8 * 86_400), canDowngrade: true)
        }
        let clock = stageClock
        clock.date = Self.clock(for: state)
        let model = MixerModel(purchases: purchases, defaults: defaults, now: { clock.date })

        switch state {
        case .rest, .playingTwo, .layers, .error, .error2, .error3, .largeType,
             .timerRest, .tideRest, .tideLocked:
            break
        case .timerAsleep, .timerFading, .timerPaused, .timerLength:
            model.chooseTimer(.untilAsleep(TimerChoice.defaultMinutes))
        case .timerBlanket, .timerHour:
            model.chooseTimer(.blanket(hour: TimerChoice.defaultEndHour))
        case .timerNight:
            model.chooseTimer(.untilAsleep(90))
            model.beginNightSession()
        case .tideGuiding, .tideDissolving:
            model.setBreathingEnabled(true)
        case .tideDescent:
            var settings = model.breathing.settings
            settings.descends = true
            model.updateBreathing(settings)
            model.setBreathingEnabled(true)
        case .tideNight:
            model.setBreathingEnabled(true)
            model.beginNightSession()
        case .playingFive:
            setLevels(model, [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .pink: 0.3, .brown: 0.2])
        case .night:
            model.selectTimer(minutes: 90)
            model.beginNightSession()
        case .timer:
            model.selectTimer(minutes: 45)
        case .nightLayers:
            model.beginNightSession()
        case .tide:
            model.setBreathingEnabled(true)
        case .nightTide:
            model.setBreathingEnabled(true)
            model.beginNightSession()
        case .layersSix:
            // Ocean was saved at 50 while the trial lasted; it keeps it.
            setLevels(model, [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .white: 0.15, .pink: 0.3, .brown: 0.2])
        case .layersCap:
            setLevels(model, [.rain: 0.45, .wind: 0.25, .ocean: 0.5, .thunder: 0.2, .pink: 0.3, .brown: 0.2])
        case .layersEnd:
            // Thunder was saved at 20 while the trial lasted; it keeps it.
            setLevels(model, [.rain: 0.45, .wind: 0.25, .thunder: 0.2, .pink: 0.3])
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
        case .rest, .layersSix, .layersEnd, .timerRest, .timerHour, .timerLength, .tideRest, .tideLocked:
            break
        case .timerFading:
            if !model.isPlaying { model.play() }
            // Eight minutes from the end: the final fade is under way.
            stageClock.date.addTimeInterval(TimeInterval((TimerChoice.defaultMinutes - 8) * 60))
            model.timer.tick()
        case .timerPaused:
            if !model.isPlaying { model.play() }
            stageClock.date.addTimeInterval(7 * 60)
            model.timer.tick()
            model.pause()
        case .tideDissolving:
            if !model.isPlaying { model.play() }
            model.breathing.release(over: 10 * 60)
        case .error:
            model.debugFailStart()
        case .error2:
            for _ in 0..<2 { model.debugFailStart() }
        case .error3:
            for _ in 0..<3 { model.debugFailStart() }
        case .playingTwo, .playingFive, .night, .timer, .layers, .layersCap, .largeType,
             .nightLayers, .tide, .nightTide, .timerAsleep, .timerBlanket, .timerNight,
             .tideGuiding, .tideDescent, .tideNight:
            if !model.isPlaying { model.play() }
        }
    }
}
#endif
