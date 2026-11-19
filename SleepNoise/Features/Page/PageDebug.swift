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
///
/// `-pageClock HH:mm`, without `-pageState`, is a normal launch on the real
/// preferences whose clock starts at that hour today and runs from there:
/// the night window, a night that persists and a timer that ends inside
/// it can be walked through by day. The trial is the real one in the
/// Keychain and reads that clock too, so use it on a simulator.
///
/// The six captures of the store (11 §2.3 to §2.8) are `storePlaying`,
/// `storeFirstUse`, `storeLayers`, `storeTide`, `storeNight` and
/// `settingsNotHere`, launched with `-storeShot`, which hides the status
/// bar and the home indicator (11 §2.2). `scripts/screenshots.sh` takes
/// them in both languages.
enum PageDebugState: String, CaseIterable {
    /// First use: the house mix as it loads, nothing playing.
    case rest
    /// The same on a new install as it is: nothing bought, no trial.
    case restFree
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
    /// Layers with a mix of eight: the six highest sound, two wait.
    case layersOver
    /// The page with that mix of eight, playing: its three rows sound, the
    /// two layers that wait have none, and the page says so.
    case pageOver
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

    // The Night screen over the page.
    /// The first time: the two sentences, held on screen.
    case nightEnter
    /// "Until I sleep" counting: "+15 min" in its place.
    case nightTimer
    /// 60 s without a touch: drawn dimmed.
    case nightDimmed
    /// "Keep screen on · Always": awake, and dimmed after its minute.
    case nightKeepOn
    /// A blanket until seven.
    case nightBlanket
    /// No timer: the place of "+15 min" is empty.
    case nightPlain
    /// Inside the final fade.
    case nightFading
    /// Paused by a touch.
    case nightPaused
    /// The earbuds went away: "Keep playing on speaker" above "+15 min".
    case nightSpeaker
    /// Under a finger on the vertical axis: the rule and "Playing · at 40".
    case nightLevel
    /// The timer ran out: "Small hours" in the place of "+15 min".
    case nightEnded
    /// The same night, with the app opened at eight the next morning: the
    /// Night screen has given way to the day page.
    case nightEndedMorning
    /// The sound did not start again.
    case nightError

    // Small Hours over the page.
    /// The first minutes: the tide guides, the water line moves.
    case smallHours
    /// The tide has gone: the plain sea and the Horizon.
    case smallHoursPlain
    /// The last minutes: "Winding down".
    case smallHoursWinding
    /// Paused by a touch.
    case smallHoursPaused

    // The Mixes sheet over the page.
    /// Without access: two saved mixes, the first one loaded and sounding,
    /// and the four of the house.
    case mixes
    /// Nothing saved: the sentence in the place of "yours".
    case mixesEmpty
    /// The alert that saves the live mix, with its name already in.
    case mixesSave
    /// The alert that renames a saved mix.
    case mixesRename
    /// The alert that asks before a saved mix is deleted.
    case mixesDelete
    /// Three saved and no access: the live mix says "pro".
    case mixesFourth
    /// Opened from the night page: one ink.
    case mixesNight
    /// Opened from the night page without access: no recipe says "is Pro".
    case mixesNightFree
    /// The page after loading a house mix with a Pro layer, without access.
    case mixesTrimmed
    /// The same with the longest title of the house: "Brown and fire".
    case mixesTrimmedLong
    /// The earbuds went away on the page: "Keep playing on speaker" on the
    /// second line of the state.
    case pageSpeaker
    /// Back on the speaker, turned down to the cap: "Playing · at 40".
    case pageCapped

    // The trial on the page, by day and in silence.
    /// The trial has just started: "trial · 7 nights left".
    case trialNight1
    /// Two days in: "trial · 5 nights left".
    case trialNight3
    /// The last night: the word, and the sentence in the place of the state.
    case trialNight7
    /// The day it runs out: no night is left, so no word and no figure.
    case trialLastDay
    /// The trial is over: "always free", the note and "Got it".
    case trialNight8
    /// The trial running, with the app opened inside the night window:
    /// the header says nothing.
    case trialAtNight

    // The Pro sheet over the page.
    /// A new install: the price, "Start the trial · 7 nights" and the purchase.
    case proOffer
    /// The same while something is playing.
    case proOfferPlaying
    /// The same over Settings, which stays under it.
    case proOfferSettings
    /// The same over Layers, which stays under it.
    case proOfferLayers
    /// The trial is running or used up: the purchase alone.
    case proTrial
    /// The store has not answered yet: a dash and the purchase disabled.
    case proLoading
    /// The store does not answer.
    case proUnavailable
    /// The system sheet is up: "Buying…".
    case proBuying
    /// Ask to Buy: "Pending".
    case proPending
    /// It failed before any payment, or was cancelled.
    case proFailed
    /// It could not be confirmed.
    case proUnconfirmed
    /// "Looking…": the App Store is being asked.
    case proRestoring
    /// Restore found nothing: the longest line.
    case proNothing
    /// Just bought: "Thank you", held on screen.
    case proThanks
    /// Bought: the receipt.
    case proReceipt
    /// The receipt of a purchase shared by the family.
    case proReceiptFamily
    /// The receipt with the review link in its place (staged: the app has
    /// no App Store id yet).
    case proReceiptReview

    // Settings over the page.
    /// Without Pro, by day: the price on the Pro row.
    case settings
    /// The store has not answered: a dash on the Pro row.
    case settingsLoading
    /// Bought: the receipt line on the Pro row.
    case settingsPro
    /// Bought through the family.
    case settingsFamily
    /// Opened from the night page: one ink, the Pro row is words and
    /// "Restore purchase" is a row of its own under it.
    case settingsNight
    /// The same after "Restore purchase": "Looking…".
    case settingsNightRestoring
    /// The App Store had nothing for this account: the longest line.
    case settingsNightNothing
    /// The purchase came back: "Thank you" under the row, which no longer
    /// answers; the Pro row keeps the name alone until Settings closes.
    case settingsNightRestored
    /// The same with a purchase shared by the family.
    case settingsNightRestoredFamily
    /// The store did not answer.
    case settingsNightStoreAway
    /// The dialog of the Apple Account was closed: no line at all.
    case settingsNightCancelled
    /// "What's not here".
    case settingsNotHere
    /// The end of Mixes: "Settings", its last row.
    case mixesEnd

    // The house paint in Mixes (exploration 12 §6.1), by day and when the
    // rule says no. The staged `mixes` already paints: these are the cases
    // the rule turns on.
    /// By day, without access: the four bands beside their recipes.
    case mixesPaint
    /// Inside the night window on the day page, at 21:30: no band, the row
    /// as it was.
    case mixesPaintEvening
    /// By day with Increase Contrast: no band.
    case mixesPaintContrast
    /// By day at the third accessibility size: the band grows with the row.
    case mixesPaintAX3
    /// The same at the largest size.
    case mixesPaintAX5

    // The captures of the store that no other state stages (11 §3.2).
    /// Capture 1: the house mix playing in the evening, on the second day
    /// of the trial, with the timer of the first use.
    case storePlaying
    /// Capture 2: the page of someone who has bought nothing and started
    /// no trial, at rest, with tonight's mix as document 11 §2.4 draws it:
    /// rain 30 and pink 50.
    case storeFirstUse
    /// Capture 3: Layers with six sounding, during the trial, and the rain
    /// under a finger.
    case storeLayers
    /// Capture 4: the tide sheet guiding at six a minute, held at the rise
    /// of the third breath.
    case storeTide
    /// Capture 5: Night at 3:07 with thirty-five minutes left.
    case storeNight
    /// Capture 7: Mixes by day with the four painted bands of the house,
    /// "Pink and rain" sounding, on the second day of the trial.
    case storeMixes

    var opensMixes: Bool {
        switch self {
        case .mixes, .mixesEmpty, .mixesSave, .mixesRename, .mixesDelete, .mixesFourth, .mixesNight,
             .mixesNightFree, .mixesEnd, .mixesPaint, .mixesPaintEvening, .mixesPaintContrast,
             .mixesPaintAX3, .mixesPaintAX5, .storeMixes:
            return true
        default: return false
        }
    }

    /// The Pro sheet is what the launch shows.
    var opensPro: Bool {
        switch self {
        case .proOffer, .proOfferPlaying, .proOfferSettings, .proOfferLayers, .proTrial, .proLoading,
             .proUnavailable, .proBuying, .proPending,
             .proFailed, .proUnconfirmed, .proRestoring, .proNothing, .proThanks, .proReceipt,
             .proReceiptFamily, .proReceiptReview:
            return true
        default: return false
        }
    }

    var opensSettings: Bool {
        switch self {
        case .settings, .settingsLoading, .settingsPro, .settingsFamily, .settingsNight, .settingsNotHere,
             .proOfferSettings:
            return true
        default: return restoreOutcome != nil
        }
    }

    /// How "Restore purchase" ends in a staged Settings at night, or nil
    /// for a state that does not press it.
    enum RestoreOutcome {
        case looking, nothing, restored, restoredFamily, storeAway, cancelled
    }

    var restoreOutcome: RestoreOutcome? {
        switch self {
        case .settingsNightRestoring: return .looking
        case .settingsNightNothing: return .nothing
        case .settingsNightRestored: return .restored
        case .settingsNightRestoredFamily: return .restoredFamily
        case .settingsNightStoreAway: return .storeAway
        case .settingsNightCancelled: return .cancelled
        default: return nil
        }
    }

    /// The trial as the stage leaves it: how much of it is used, or nil
    /// for a launch without one.
    var trialConsumed: TimeInterval? {
        let day: TimeInterval = 86_400
        switch self {
        case .trialNight1: return 0
        case .storePlaying, .storeLayers, .storeTide, .storeMixes: return day
        case .trialNight3, .trialAtNight, .proTrial: return 2 * day
        case .trialNight7: return 6 * day
        case .trialLastDay: return 6 * day + 18 * 3_600
        case .trialNight8: return NightTrial.length + day
        default: return nil
        }
    }

    /// Staged without access: no trial and nothing bought.
    var isFreeTier: Bool {
        switch self {
        case .layersSix, .layersEnd, .tideLocked, .mixes, .mixesRename, .mixesDelete, .mixesFourth, .mixesTrimmed,
             .mixesTrimmedLong, .mixesNightFree, .mixesEnd, .mixesPaint, .mixesPaintEvening, .mixesPaintContrast,
             .mixesPaintAX3, .mixesPaintAX5, .restFree, .storeFirstUse,
             .proOffer, .proOfferPlaying, .proOfferSettings, .proOfferLayers, .proLoading, .proUnavailable, .proBuying, .proPending, .proFailed,
             .proUnconfirmed, .proRestoring, .proNothing, .proThanks,
             .settings, .settingsLoading, .settingsNight, .settingsNotHere:
            return true
        default:
            // A staged trial is neither Pro nor a new install.
            return trialConsumed != nil || restoreOutcome != nil
        }
    }

    /// The Night screen is what the launch shows.
    var isNightScreen: Bool {
        switch self {
        case .nightEnter, .nightTimer, .nightDimmed, .nightKeepOn, .nightBlanket, .nightPlain,
             .nightFading, .nightPaused, .nightSpeaker, .nightLevel, .nightEnded, .nightEndedMorning,
             .nightError, .storeNight:
            return true
        default:
            return false
        }
    }

    /// Small Hours is what the launch shows.
    var isSmallHours: Bool {
        switch self {
        case .smallHours, .smallHoursPlain, .smallHoursWinding, .smallHoursPaused: return true
        default: return false
        }
    }

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
        case .tideRest, .tideGuiding, .tideDescent, .tideDissolving, .tideLocked, .tideNight, .storeTide:
            return true
        default: return false
        }
    }

    /// Staged in the small hours, on the night page.
    var isNight: Bool {
        switch self {
        case .night, .nightLayers, .nightTide, .timerNight, .tideNight, .mixesNight, .mixesNightFree,
             .trialAtNight, .settingsNight:
            return true
        default: return isNightScreen || isSmallHours || restoreOutcome != nil
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

    /// `-pageClock HH:mm`: how far the clock of a normal launch is moved,
    /// so that it starts at that hour today and runs on. Nil without the
    /// argument or when it is not an hour.
    static var clockOffset: TimeInterval? {
        let real = Date()
        return value(after: "-pageClock")
            .flatMap { clockStart($0, on: real, calendar: .current) }
            .map { $0.timeIntervalSince(real) }
    }

    /// "23:05" on the day of `day`, or nil for anything that is not an
    /// hour and a minute of the clock.
    static func clockStart(_ text: String, on day: Date, calendar: Calendar) -> Date? {
        let parts = text.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0...23).contains(hour), (0...59).contains(minute) else { return nil }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
    }

    static var opensLayers: Bool {
        switch state {
        case .layers, .layersSix, .layersCap, .layersOver, .layersEnd, .nightLayers, .proOfferLayers,
             .storeLayers:
            return true
        default: return false
        }
    }

    /// The sheet a staged launch opens over the page.
    static var initialSheet: PageSheet? {
        guard let state else { return nil }
        if opensLayers { return .layers }
        if state.opensTimer { return .timer }
        if state.opensTide { return .tide }
        if state.opensMixes { return .mixes }
        if state.opensSettings { return .settings }
        return nil
    }

    /// Mixes opens at the end of its content: its last row, or the house
    /// at the largest text size, where "yours" alone fills the screen.
    static var scrollsMixesToEnd: Bool { state == .mixesEnd || state == .mixesPaintAX5 }

    /// The timer sheet opens with the control of its mode unfolded.
    static var opensTimerControl: Bool {
        state == .timerLength || state == .timerHour
    }

    /// Layers opens at the end of its content.
    static var scrollsLayersToEnd: Bool { state == .layersEnd }

    /// A capture for the store: the status bar and the home indicator are
    /// not drawn. The hour, the battery and the signal would be the only
    /// icons of the capture, and they are not the app's (11 §2.2).
    static var isStoreShot: Bool { arguments.contains("-storeShot") }

    /// The row a capture draws as if a finger were on it.
    static var heldLayer: SoundID? {
        state == .storeLayers ? .rain : nil
    }

    /// Seconds into the guide at which a capture holds the breath: the
    /// third one, at 70 % of its rise (four seconds at six a minute).
    static var heldBreath: TimeInterval? {
        state == .storeTide ? 22.8 : nil
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
        case "accessibility4": return .accessibility4
        case "accessibility5": return .accessibility5
        default:
            switch state {
            case .largeType: return .accessibility2
            case .mixesPaintAX3: return .accessibility3
            case .mixesPaintAX5: return .accessibility5
            default: return nil
            }
        }
    }
}

/// What a staged Mixes sheet forces on the house paint.
enum PaintArguments {
    /// Increase Contrast, as if the system had it on: the rule says no
    /// band. The real switch of the simulator reaches the same code.
    static var forcesIncreasedContrast: Bool { PageArguments.state == .mixesPaintContrast }
}

/// What a staged Mixes sheet opens over itself.
enum MixesArguments {
    /// The alert a capture asks for, or nil.
    @MainActor
    static func naming(_ model: MixerModel) -> MixNaming? {
        var naming = MixNaming()
        switch PageArguments.state {
        case .mixesSave:
            naming.beginSave(model)
        case .mixesRename:
            guard let mix = model.mixStore.mixes.first else { return nil }
            naming.beginRename(mix)
        default:
            return nil
        }
        return naming
    }

    /// The mix a capture asks to delete, or nil.
    @MainActor
    static func deleting(_ model: MixerModel) -> SavedMix? {
        PageArguments.state == .mixesDelete ? model.mixStore.mixes.first : nil
    }
}

/// What a staged Night screen needs to know about its own capture.
enum NightArguments {
    /// The rule of the level and its note stay up without a finger.
    static var showsLevelRule: Bool { PageArguments.state == .nightLevel }
    /// The two first-time sentences do not count their seconds.
    static var holdsIntro: Bool { PageArguments.state == .nightEnter }

    /// Writes what Night asked of the idle timer to the console of a
    /// staged launch: a capture cannot show whether the screen will sleep.
    static func note(screenAwake: Bool) {
        guard let state = PageArguments.state, state.isNightScreen || state.isSmallHours else { return }
        print("night.screenAwake=\(screenAwake)")
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
    /// The store of the staged launch, for the states that need it moved
    /// once the sheet is up.
    private static var stageStore: ScriptedProStore?

    /// Midday on a fixed date, or 02:14 the next night, local time. The
    /// captures of the store have their own hours: the evening before the
    /// night window, where the trial still has its word, and 02:57 for
    /// the Night that is looked at ten minutes later.
    static func clock(for state: PageDebugState) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 17
        switch state {
        case .storePlaying, .storeLayers:
            (components.hour, components.minute) = (20, 15)
        case .storeTide:
            (components.hour, components.minute) = (20, 12)
        case .storeNight:
            (components.hour, components.minute) = (2, 57)
        case .storeMixes:
            (components.hour, components.minute) = (20, 15)
        case .mixesPaintEvening:
            // Inside the night window, on the day page.
            (components.hour, components.minute) = (21, 30)
        default:
            components.hour = state.isNight ? 2 : 12
            components.minute = state.isNight ? 14 : 0
        }
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Tonight's mix in capture 2 (11 §2.4): rain 30 and pink 50.
    static let storeFirstUseLevels: [SoundID: Float] = [.rain: 0.3, .pink: 0.5]

    /// The product a staged launch shows. The app itself never writes a
    /// name or a price: these stand in for the App Store in the captures.
    static let stagedProduct = ProProduct(
        displayName: "SleepNoise Pro",
        displayPrice: "29,99 €",
        isFamilyShareable: true
    )

    static func make(_ state: PageDebugState) -> (PurchaseManager, MixerModel) {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        // A staged launch never touches the Keychain or the App Store: the
        // trial lives in memory and the store answers what the stage says.
        // Without access is a new install: no trial, nothing bought. With
        // access is Pro bought, so the header stays empty.
        let store = ScriptedProStore(product: stagedProduct)
        let now = clock(for: state)
        if !state.isFreeTier {
            let isShared = state == .proReceiptFamily || state == .settingsFamily
            // Bought the day before the capture.
            let receipt = ProReceipt(purchaseDate: now.addingTimeInterval(-86_400), isFamilyShared: isShared)
            store.entitlement = .entitled(receipt)
            defaults.set(true, forKey: PurchaseManager.cacheKey)
            defaults.set(receipt.purchaseDate, forKey: PurchaseManager.purchasedAtKey)
            defaults.set(receipt.isFamilyShared, forKey: PurchaseManager.familySharedKey)
        }
        switch state {
        case .proLoading, .settingsLoading:
            store.hangs = true
        case .proUnavailable:
            store.failsToLoad = true
        case .proBuying:
            store.holdsPurchase = true
        case .proPending:
            store.purchaseResult = .pending
        case .proFailed:
            store.purchaseResult = .failed
        case .proUnconfirmed:
            store.purchaseResult = .unconfirmed
        case .proThanks:
            store.purchaseResult = .purchased(ProReceipt(purchaseDate: now, isFamilyShared: false))
        default:
            break
        }
        let trialStorage = InMemoryTrialStorage()
        if let consumed = state.trialConsumed {
            // A trial that is used up is found over at this launch, and
            // its note becomes due.
            _ = trialStorage.createTrial(TrialRecord(
                startedAt: now.addingTimeInterval(-consumed), lastSeen: now, consumed: consumed
            ))
            // Started on this install: its end is news here.
            defaults.set(false, forKey: PurchaseManager.endEvaluatedKey)
        }
        let purchases = PurchaseManager(
            defaults: defaults,
            trialStorage: trialStorage,
            store: store,
            now: now
        )
        stageStore = store
        if state != .nightEnter {
            // Only one capture is the first Night of the install.
            defaults.set(true, forKey: MixerModel.nightIntroKey)
        }
        let clock = stageClock
        clock.date = Self.clock(for: state)
        let model = MixerModel(purchases: purchases, defaults: defaults, now: { clock.date })

        switch state {
        case .rest, .restFree, .playingTwo, .layers, .error, .error2, .error3, .largeType,
             .timerRest, .tideRest, .tideLocked, .mixesEmpty, .mixesTrimmed, .mixesTrimmedLong,
             .pageSpeaker, .pageCapped,
             .trialNight1, .trialNight3, .trialNight7, .trialLastDay, .trialNight8, .trialAtNight,
             .proOffer, .proOfferPlaying, .proOfferSettings, .proOfferLayers, .proTrial, .proLoading, .proUnavailable, .proBuying, .proPending,
             .proFailed, .proUnconfirmed, .proRestoring, .proNothing, .proThanks, .proReceipt,
             .proReceiptFamily, .proReceiptReview,
             .settings, .settingsLoading, .settingsPro, .settingsFamily, .settingsNotHere,
             .nightEnter, .nightTimer, .nightDimmed, .nightFading, .nightPaused, .nightSpeaker,
             .nightLevel, .nightEnded, .nightEndedMorning, .nightError, .storePlaying, .storeNight,
             .smallHours, .smallHoursPlain, .smallHoursWinding, .smallHoursPaused:
            // Night shows the timer of the first use: 45 minutes.
            break
        case .storeFirstUse:
            // Not the house mix that capture 1 plays: two free layers at
            // other levels, so the first two captures of the store do not
            // show the same page twice.
            setLevels(model, storeFirstUseLevels)
        case .storeLayers:
            // Six at once: the five free ones and the ocean, which the
            // trial opens. Rain is the one under the finger.
            setLevels(model, [.white: 0.2, .pink: 0.65, .brown: 0.2, .rain: 0.52, .wind: 0.3, .ocean: 0.3])
        case .storeTide:
            // The ocean is already in the mix, so the tide raises nothing.
            setLevels(model, [.pink: 0.65, .rain: 0.4, .ocean: 0.3])
            model.setBreathingEnabled(true)
        case .nightKeepOn:
            model.setKeepScreenOn(.always)
        case .nightBlanket:
            model.chooseTimer(.blanket(hour: TimerChoice.defaultEndHour))
        case .nightPlain:
            model.chooseTimer(TimerChoice.firstUse.with(mode: .off))
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
        case .nightLayers, .settingsNight, .settingsNightRestoring, .settingsNightNothing,
             .settingsNightRestored, .settingsNightRestoredFamily, .settingsNightStoreAway,
             .settingsNightCancelled:
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
        case .layersOver, .pageOver:
            // A mix saved by a version without the cap. White and brown
            // are the lowest: they keep their level and wait.
            setLevels(model, [
                .white: 0.15, .pink: 0.3, .brown: 0.1, .rain: 0.45, .wind: 0.25,
                .ocean: 0.5, .thunder: 0.2, .campfire: 0.35,
            ])
            if state == .pageOver {
                // No timer: the state line is free to name the layers
                // that wait. With one it says the hour, and the "All
                // layers" row alone says "Six at once".
                model.chooseTimer(TimerChoice.firstUse.with(mode: .off))
            }
        case .layersEnd:
            // Thunder was saved at 20 while the trial lasted; it keeps it.
            setLevels(model, [.rain: 0.45, .wind: 0.25, .thunder: 0.2, .pink: 0.3])
        case .mixes, .mixesRename, .mixesDelete, .mixesNight, .mixesNightFree, .mixesEnd,
             .mixesPaint, .mixesPaintEvening, .mixesPaintContrast, .mixesPaintAX3, .mixesPaintAX5:
            // The first of the person's mixes is the one that is loaded.
            if let hotel = saveMixes(model, count: 2) {
                model.apply(hotel)
            }
            if state == .mixesNight || state == .mixesNightFree { model.beginNightSession() }
        case .storeMixes:
            // Two of the person's own above the house; the house mix of
            // capture 1 is the one that sounds (`didAppear`).
            saveMixes(model, count: 2)
        case .mixesSave:
            setLevels(model, [.rain: 0.45, .wind: 0.25, .pink: 0.3])
        case .mixesFourth:
            saveMixes(model, count: AccessPolicy.freeSavedMixLimit)
            setLevels(model, [.rain: 0.45, .wind: 0.25, .pink: 0.3])
        }
        return (purchases, model)
    }

    /// Mixes saved while the trial lasted, as a person would name them: the
    /// second one keeps a Pro layer. Returns the first of the list.
    @discardableResult
    private static func saveMixes(_ model: MixerModel, count: Int) -> SavedMix? {
        let mixes: [(String, [SoundID: Float])] = [
            ("Hotel", [.rain: 0.45, .brown: 0.3]),
            ("Ventilador y lluvia", [.rain: 0.5, .fan: 0.3, .brown: 0.2]),
            ("Verano con ventana", [.wind: 0.35, .white: 0.15]),
        ]
        // A save goes to the top of the list: the last one saved is first.
        for (name, levels) in mixes.prefix(count).reversed() {
            _ = model.mixStore.save(name: name, levels: levels, hasFullAccess: true)
        }
        return model.mixStore.mixes.first
    }

    /// Lays the levels down as an edited mix ("Tonight"). Written straight
    /// into the model: a Pro layer keeps a level here without asking for
    /// the Pro sheet.
    private static func setLevels(_ model: MixerModel, _ levels: [SoundID: Float]) {
        // One real edit first: the mix loses the name it loaded with. A
        // level written as it was is not an edit, so this one always moves.
        model.setLevel(.rain, (model.levels[.rain] ?? 0) > 0.5 ? 0 : 1)
        for sound in SoundID.allCases {
            model.levels[sound] = levels[sound] ?? 0
        }
    }

    /// Moves the pinned clock of a staged Night or Small Hours and lets
    /// what counts time see it. The screen was just touched: it is not
    /// drawn dimmed.
    private static func move(_ model: MixerModel, by seconds: TimeInterval) {
        stageClock.date.addTimeInterval(seconds)
        model.timer.tick()
        model.smallHours.tick()
        model.noteBedtimeTouch()
    }

    /// Sets the staged store for the answer the capture is of, just before
    /// Settings presses "Restore purchase".
    static func stageRestore() {
        guard let outcome = PageArguments.state?.restoreOutcome, let store = stageStore else { return }
        switch outcome {
        case .looking:
            // "Looking…" lasts for as long as the App Store takes.
            store.hangs = true
        case .nothing:
            store.syncResult = .synced
        case .restored, .restoredFamily:
            // Bought the day before the capture.
            store.entitlementAfterSync = .entitled(ProReceipt(
                purchaseDate: stageClock.date.addingTimeInterval(-86_400),
                isFamilyShared: outcome == .restoredFamily
            ))
        case .storeAway:
            store.syncResult = .unavailable
        case .cancelled:
            store.syncResult = .cancelled
        }
    }

    /// What a staged page does once it is on screen.
    static func didAppear(_ model: MixerModel) {
        guard let state = PageArguments.state else { return }
        switch state {
        case .rest, .restFree, .storeFirstUse, .layersSix, .layersEnd, .timerRest, .timerHour, .timerLength,
             .tideRest, .tideLocked, .mixesEmpty,
             .trialNight1, .trialNight3, .trialNight7, .trialLastDay, .trialNight8, .trialAtNight,
             .settings, .settingsLoading, .settingsPro, .settingsFamily, .settingsNight, .settingsNotHere,
             .settingsNightRestoring, .settingsNightNothing, .settingsNightRestored,
             .settingsNightRestoredFamily, .settingsNightStoreAway, .settingsNightCancelled:
            // Settings presses its own "Restore purchase" (`stageRestore`).
            break
        case .proOffer, .proTrial, .proLoading, .proUnavailable, .proReceipt, .proReceiptFamily,
             .proReceiptReview:
            model.offerPro()
        case .proOfferPlaying:
            if !model.isPlaying { model.play() }
            model.offerPro()
        case .proOfferSettings, .proOfferLayers:
            Task { @MainActor in
                // Once the sheet that stays under it is up.
                try? await Task.sleep(for: .milliseconds(1200))
                model.offerPro()
            }
        case .proBuying, .proPending, .proFailed, .proUnconfirmed, .proThanks:
            model.offerPro()
            let purchases = model.purchases
            Task { @MainActor in
                // Once the sheet is up and the store has given its price.
                try? await Task.sleep(for: .milliseconds(1200))
                await purchases.purchase()
            }
        case .proRestoring, .proNothing:
            model.offerPro()
            let purchases = model.purchases
            let holds = state == .proRestoring
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(1200))
                // "Looking…" lasts for as long as the App Store takes.
                stageStore?.hangs = holds
                await purchases.restore()
            }
        case .mixesTrimmed:
            // "Sea and wind" without access: it plays without the ocean and
            // its name says so. Never a sheet.
            model.playMix(.house(.seaAndWind))
        case .mixesTrimmedLong:
            model.playMix(.house(.brownAndFire))
        case .storeMixes:
            model.playMix(.house(.pinkAndRain))
        case .pageSpeaker:
            if !model.isPlaying { model.play() }
            model.debugLoseOutput()
        case .pageCapped:
            if !model.isPlaying { model.play() }
            model.debugLoseOutput()
            model.continueOnSpeaker()
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
        case .nightEnter, .nightTimer, .nightBlanket, .nightPlain:
            model.enterBedtime()
        case .storeNight:
            model.enterBedtime()
            // Ten minutes in: 3:07, and it fades at 3:42.
            move(model, by: 10 * 60)
        case .storeTide:
            if !model.isPlaying { model.play() }
            model.breathing.debugHeldBreath = PageArguments.heldBreath
        case .nightDimmed, .nightKeepOn:
            model.enterBedtime()
            // Once the scene is active, which counts as a touch: its
            // minute goes by.
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1))
                stageClock.date.addTimeInterval(BedtimeScreenPolicy.dimDelay + 1)
                model.refreshBedtimeDimming()
            }
        case .nightFading:
            model.enterBedtime()
            move(model, by: TimeInterval((TimerChoice.defaultMinutes - 8) * 60))
        case .nightPaused:
            model.enterBedtime()
            move(model, by: 7 * 60)
            model.pause()
        case .nightSpeaker:
            model.enterBedtime()
            move(model, by: 7 * 60)
            model.debugLoseOutput()
        case .nightLevel:
            model.enterBedtime()
            model.setSessionLevel(0.4)
        case .nightEnded:
            model.enterBedtime()
            // The timer runs out: the night ends by itself.
            move(model, by: TimeInterval(TimerChoice.defaultMinutes * 60 + 1))
        case .nightEndedMorning:
            model.enterBedtime()
            move(model, by: TimeInterval(TimerChoice.defaultMinutes * 60 + 1))
            Task { @MainActor in
                // "Ended at" is on screen; then the app is opened at
                // eight, with nothing running in between.
                try? await Task.sleep(for: .seconds(1))
                stageClock.date = Calendar.current.date(
                    bySettingHour: 8, minute: 0, second: 0, of: stageClock.date
                ) ?? stageClock.date
                model.appDidBecomeActive()
            }
        case .nightError:
            model.enterBedtime()
            model.pause()
            model.debugFailStart()
        case .smallHours:
            model.startSmallHours()
        case .smallHoursPlain:
            model.startSmallHours()
            move(model, by: 14 * 60)
        case .smallHoursWinding:
            model.startSmallHours()
            move(model, by: 16 * 60)
        case .smallHoursPaused:
            model.startSmallHours()
            move(model, by: 6 * 60)
            model.pause()
        case .error:
            model.debugFailStart()
        case .error2:
            for _ in 0..<2 { model.debugFailStart() }
        case .error3:
            for _ in 0..<3 { model.debugFailStart() }
        case .playingTwo, .playingFive, .night, .timer, .layers, .layersCap, .layersOver, .pageOver,
             .largeType, .storePlaying, .storeLayers,
             .nightLayers, .tide, .nightTide, .timerAsleep, .timerBlanket, .timerNight,
             .tideGuiding, .tideDescent, .tideNight,
             .mixes, .mixesSave, .mixesRename, .mixesDelete, .mixesFourth, .mixesNight, .mixesNightFree,
             .mixesEnd, .mixesPaint, .mixesPaintEvening, .mixesPaintContrast, .mixesPaintAX3, .mixesPaintAX5:
            if !model.isPlaying { model.play() }
        }
    }
}
#endif
