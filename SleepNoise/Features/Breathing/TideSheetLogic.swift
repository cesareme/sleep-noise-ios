import Foundation

/// Where the tide stands, in the words of the tide sheet (06 §3). Worked
/// out without a view.
///
/// The state is a word in small caps, and no word at all when the shape
/// already says it: a tide that is off is a still hairline and a switch in
/// its off position.
enum TideStatus: Equatable {
    /// The switch is off, or there is no access: nothing to say.
    case off
    /// The switch is on and nothing sounds yet: Play begins the guide.
    case armed
    /// Guiding at this many breaths a minute: the pace chosen, or the step
    /// of the descent it is on.
    case guiding(rate: Int)
    /// Letting go: each wave a little lower than the one before.
    case dissolving
    /// The night is paused inside the guide's window.
    case paused

    struct Input: Equatable {
        var isEnabled = false
        var isIncluded = true
        var phase = BreathingPhase.idle
        /// The pace being guided, when there is one.
        var guidingRate: Int?
        /// The pace chosen in the sheet.
        var chosenRate = BreathingSettings.calmRate
        /// The night is paused (not over) and the guide's window is open.
        var isPausedInsideWindow = false
    }

    static func resolve(_ input: Input) -> TideStatus {
        guard input.isIncluded, input.isEnabled else { return .off }
        switch input.phase {
        case .guiding:
            return .guiding(rate: input.guidingRate ?? input.chosenRate)
        case .dissolving:
            return .dissolving
        case .idle:
            return input.isPausedInsideWindow ? .paused : .armed
        }
    }

    /// The line is drawn as water, with its two marks, only while there is
    /// a course to mark.
    /// The guide is under way at full weight: the line answers a finger.
    var isGuiding: Bool {
        if case .guiding = self { return true }
        return false
    }

    var showsWater: Bool {
        switch self {
        case .guiding, .dissolving, .paused: return true
        case .off, .armed: return false
        }
    }

    /// The word of the state box. Nil leaves the box empty.
    func word(
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> String? {
        switch self {
        case .off, .armed:
            return nil
        case .guiding(let rate):
            return String(format: localized("marea.estado.guiando.corto"), locale: locale, Int64(rate))
        case .dissolving:
            return localized("marea.estado.disolviendo")
        case .paused:
            return localized("marea.estado.pausa")
        }
    }
}

/// The words of the tide sheet that are not its state.
enum TideSheetText {
    typealias Lookup = (String) -> String

    static let standardLookup: Lookup = { Localized.string($0) }

    /// "Recedes at 23:27": when the guide lets go, as an hour. Only while
    /// the tide has a course; a time consulted at night is never small caps.
    static func recedes(
        status: TideStatus,
        at end: Date?,
        localized: Lookup = standardLookup,
        time: (Date) -> String = { $0.formatted(date: .omitted, time: .shortened) }
    ) -> String? {
        guard status.showsWater, let end else { return nil }
        let hour = time(end)
        return String(format: localized(HourPhrase.key("marea.retira.hora", at: hour)), hour)
    }

    /// The hour the line gives: the end of the guide's own window, or the
    /// end of the night when the timer gets there first. The tide leaves
    /// with the final fade, so it never recedes later than the page says
    /// the sound ends. Nil when the guide has no end of its own.
    static func recedesAt(guideEnd: Date?, timerEnd: Date?) -> Date? {
        guard let guideEnd else { return nil }
        guard let timerEnd else { return guideEnd }
        return min(guideEnd, timerEnd)
    }

    /// The pace on the right of its row and in its menu: "Calm · 6",
    /// "Gentle · 8", or the bare figure for a pace that has no name. The
    /// short form is the one a system menu sets on one line beside its
    /// tick.
    static func paceValue(_ rate: Int, localized: Lookup = standardLookup, locale: Locale = .current) -> String {
        switch rate {
        case BreathingSettings.calmRate:
            return String(format: localized("marea.ritmo.tranquilo.corto"), locale: locale, Int64(rate))
        case BreathingSettings.gentleRate:
            return String(format: localized("marea.ritmo.suave.corto"), locale: locale, Int64(rate))
        default: return String(format: localized("marea.ritmo.exacto"), locale: locale, Int64(rate))
        }
    }

    /// The pace in full, as VoiceOver says it.
    static func paceOption(_ rate: Int, localized: Lookup = standardLookup, locale: Locale = .current) -> String {
        switch rate {
        case BreathingSettings.calmRate:
            return String(format: localized("marea.ritmo.tranquilo"), locale: locale, Int64(rate))
        case BreathingSettings.gentleRate:
            return String(format: localized("marea.ritmo.suave"), locale: locale, Int64(rate))
        default: return String(format: localized("marea.ritmo.exacto"), locale: locale, Int64(rate))
        }
    }

    /// The options of the pace menu: the two with a name, and the current
    /// one when the line was dragged to another.
    static func paceOptions(current: Int) -> [Int] {
        var options = [BreathingSettings.calmRate, BreathingSettings.gentleRate]
        if !options.contains(current), BreathingSettings.rateRange.contains(current) {
            options.append(current)
            options.sort()
        }
        return options
    }

    /// Subtitle of "Descent": the pace it starts at, from the model.
    static func descentDetail(localized: Lookup = standardLookup, locale: Locale = .current) -> String {
        String(format: localized("marea.ritmo"), locale: locale, Int64(BreathingSettings.descentStartRate))
    }

    static func recedesAfterValue(_ minutes: Int, localized: Lookup = standardLookup, locale: Locale = .current) -> String {
        String(format: localized("marea.retira.valor"), locale: locale, Int64(minutes))
    }

    /// The pace a sideways drag of the line lands on: one breath a minute
    /// for every 56 pt, to the right for more, inside the range.
    static func draggedRate(from start: Int, translation: Double) -> Int {
        let steps = Int((translation / pointsPerBreath).rounded(.towardZero))
        return min(BreathingSettings.rateRange.upperBound, max(BreathingSettings.rateRange.lowerBound, start + steps))
    }

    static let pointsPerBreath: Double = 56

    /// What VoiceOver says for the water line: its state, its pace and,
    /// while it guides, when it recedes, as an hour. Nothing in it goes
    /// stale between two draws: the phase of the breath is in the sound,
    /// not here, and an hour does not count down.
    static func spokenLine(
        status: TideStatus,
        chosenRate: Int,
        recedesAt: Date?,
        localized: Lookup = standardLookup,
        time: (Date) -> String = { $0.formatted(date: .omitted, time: .shortened) },
        locale: Locale = .current
    ) -> String {
        func pace(_ rate: Int) -> String {
            String(format: localized("marea.ritmo.exacto"), locale: locale, Int64(rate))
        }
        switch status {
        case .off, .armed:
            return localized("marea.estado.apagada") + ", " + pace(chosenRate)
        case .guiding(let rate):
            guard let recedes = recedes(status: status, at: recedesAt, localized: localized, time: time) else {
                return pace(rate)
            }
            return pace(rate) + ", " + recedes
        case .dissolving:
            return localized("marea.estado.disolviendo")
        case .paused:
            return localized("marea.estado.pausa") + ", " + pace(chosenRate)
        }
    }
}

/// Where a breath stands at an instant, on the clock the audio uses.
enum TideBreath {
    /// Height of the water, 0 at low tide and 1 at high tide.
    static func level(at date: Date, anchor: Date?, parameters: BreathParameters) -> Float {
        guard let anchor else { return 0 }
        return BreathCurve.value(
            secondsSinceStart: max(0, date.timeIntervalSince(anchor)),
            parameters: parameters
        )
    }

    /// The water is rising: the inhale part of the cycle.
    static func isBreathingIn(at date: Date, anchor: Date?, parameters: BreathParameters) -> Bool {
        guard let anchor, parameters.rate > 0 else { return false }
        let cycles = max(0, date.timeIntervalSince(anchor)) * Double(parameters.rate)
        return cycles - cycles.rounded(.down) < Double(parameters.inhale)
    }

    /// Breaths completed since the anchor. The words "breathe in" and
    /// "breathe out" are shown for the first three and then go: there is
    /// no need to watch.
    static func breathsDone(at date: Date, anchor: Date?, parameters: BreathParameters) -> Int {
        guard let anchor, parameters.rate > 0 else { return 0 }
        return Int((max(0, date.timeIntervalSince(anchor)) * Double(parameters.rate)).rounded(.down))
    }

    static let guidedBreaths = 3
}
