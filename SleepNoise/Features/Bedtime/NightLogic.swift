import CoreGraphics
import Foundation

/// The word of the Night screen (03 §5 #10; copy guide §2.5): what is
/// happening, in words, worked out without a view.
///
/// One word at a time. The end of the night is an hour of the clock, never
/// a count of seconds. Nothing here knows about access or the trial: on the
/// Night screen there is nothing to sell and nothing that says "Pro".
/// "Dimmed" is not a state (C47): it is only how bright the screen is drawn.
enum NightStatus: Equatable {
    /// Playing with no timer.
    case playing
    /// Playing with "Until I sleep" counting: when it ends.
    case fadesAt(Date)
    /// Playing under a blanket: the hour it sounds until.
    case until(Date)
    /// The final fade is running: whole minutes left.
    case fading(minutes: Int)
    /// Just after the vertical drag: the session level (C51).
    case level(percent: Int)
    case paused
    /// Paused because the output went away, or from the headphones.
    case pausedHeadphones
    /// Paused by a call (C48).
    case pausedCall
    /// The night ended by itself: its timer, a long pause, the morning.
    case ended(at: Date)
    /// The engine did not start. A touch tries again.
    case noSound

    struct Input: Equatable {
        var isPlaying = false
        var pauseCause: PauseCause?
        /// Starts that failed in a row. Zero when the last one worked.
        var startFailures = 0
        var timerEndsAt: Date?
        /// The timer is a blanket: it ends at an hour the person chose.
        var timerEndsAtAnHour = false
        var timerIsFading = false
        var fadingMinutes: Int?
        var timerRemaining: TimeInterval?
        /// When the night ended by itself. Nil while one is open.
        var endedAt: Date?
        /// The session level to say, while the note of the drag lasts.
        var levelNote: Int?
    }

    static func resolve(_ input: Input) -> NightStatus {
        if input.isPlaying {
            if let percent = input.levelNote { return .level(percent: percent) }
            if input.timerIsFading {
                let seconds = max(0, input.timerRemaining ?? 0)
                return .fading(minutes: input.fadingMinutes ?? max(1, Int((seconds / 60).rounded(.up))))
            }
            if let end = input.timerEndsAt {
                return input.timerEndsAtAnHour ? .until(end) : .fadesAt(end)
            }
            return .playing
        }
        if input.startFailures > 0 { return .noSound }
        switch input.pauseCause {
        case .lostOutput, .headphones: return .pausedHeadphones
        case .call: return .pausedCall
        case .person, .system: return .paused
        case nil: break
        }
        if let endedAt = input.endedAt { return .ended(at: endedAt) }
        return .paused
    }

    /// The night is over: the screen is no longer a button (a cheek on the
    /// glass must not start anything) and the place of "+15 min" offers
    /// Small Hours (C27).
    var isOver: Bool {
        if case .ended = self { return true }
        return false
    }

    /// The Horizon of Night: continuous while it sounds, absent otherwise.
    var isSounding: Bool {
        switch self {
        case .playing, .fadesAt, .until, .fading, .level: return true
        case .paused, .pausedHeadphones, .pausedCall, .ended, .noSound: return false
        }
    }

    /// What a touch anywhere does.
    enum Touch: Equatable {
        case pause
        case resume
        case retry
        case nothing
    }

    var touch: Touch {
        switch self {
        case .playing, .fadesAt, .until, .fading, .level: return .pause
        case .paused, .pausedHeadphones, .pausedCall: return .resume
        case .noSound: return .retry
        case .ended: return .nothing
        }
    }

    /// The words, from the catalog. `time` formats an hour: the short time
    /// of the system by default.
    func text(
        localized: (String) -> String = { Localized.string($0) },
        time: (Date) -> String = { $0.formatted(date: .omitted, time: .shortened) },
        locale: Locale = .current
    ) -> String {
        switch self {
        case .playing:
            return localized("noche.estado.sonando")
        case .fadesAt(let date):
            return String(format: localized("noche.estado.funde"), time(date))
        case .until(let date):
            return String(format: localized("noche.estado.hasta"), time(date))
        case .fading(let minutes):
            return String(format: localized("noche.estado.fundiendo"), locale: locale, Int64(minutes))
        case .level(let percent):
            return String(format: localized("estado.volumen"), locale: locale, Int64(percent))
        case .paused:
            return localized("noche.estado.pausa")
        case .pausedHeadphones:
            return localized("estado.pausa.auriculares")
        case .pausedCall:
            return localized("pagina.estado.pausa.llamada")
        case .ended(let date):
            return String(format: localized("noche.estado.termino"), time(date))
        case .noSound:
            return localized("noche.estado.sin_sonido")
        }
    }

    /// What VoiceOver reads as the value of the screen: the hour and the
    /// word, as one phrase.
    func spoken(
        clock: String,
        localized: (String) -> String = { Localized.string($0) },
        time: (Date) -> String = { $0.formatted(date: .omitted, time: .shortened) },
        locale: Locale = .current
    ) -> String {
        let words = PageStatus.spoken(text(localized: localized, time: time, locale: locale))
        return String(format: localized("ax.noche.valor"), clock, words)
    }

    /// The hint of the screen. Nil when a touch does nothing.
    var hintKey: String? {
        switch touch {
        case .pause: return "ax.noche.pista"
        case .resume: return "ax.noche.pista.reanudar"
        case .retry: return "ax.noche.pista.error"
        case .nothing: return nil
        }
    }

    /// The word of this state alone, spoken once a touch has brought it.
    var announcementKey: String? {
        switch touch {
        case .pause: return "noche.estado.sonando"
        case .resume: return "noche.estado.pausa"
        case .retry, .nothing: return nil
        }
    }
}

extension NightStatus.Input {
    /// Read from the live model. `levelNote` is the screen's own.
    @MainActor
    init(_ model: MixerModel, levelNote: Int? = nil) {
        let timer = model.timer
        self.init(
            isPlaying: model.isPlaying,
            pauseCause: model.pauseCause,
            startFailures: model.startFailures,
            timerEndsAt: timer.endsAt,
            timerEndsAtAnHour: timer.choice.mode == .blanket,
            timerIsFading: timer.isFading,
            fadingMinutes: timer.fadingMinutes,
            timerRemaining: timer.remaining,
            endedAt: model.sessionEndedAt,
            levelNote: levelNote
        )
    }
}

/// The vertical axis of Night and Small Hours (C51): a finger moving up or
/// down is the session level. Never the system volume.
enum NightAxis {
    /// Points of travel for the whole range: the length of the rule.
    static let travel: CGFloat = 200
    /// One step of the adjustable action of VoiceOver.
    static let step: Float = 0.05

    static func clamp(_ level: Float) -> Float {
        min(1, max(MixerModel.minimumSessionLevel, level))
    }

    /// The level a drag lands on: up is more. `translation` is the height
    /// of the drag, positive downwards, as the system gives it.
    static func level(from start: Float, translation: CGFloat) -> Float {
        clamp(start - Float(translation / travel))
    }

    /// One step up or down, on the grid of steps.
    static func stepped(_ level: Float, up: Bool) -> Float {
        let steps = (level / step).rounded()
        return clamp((steps + (up ? 1 : -1)) * step)
    }

    /// "Playing · at 40": the level as a whole figure.
    static func percent(_ level: Float) -> Int {
        Int((clamp(level) * 100).rounded())
    }

    /// How much of the rule is drawn for a level.
    static func ruleLength(_ level: Float) -> CGFloat {
        travel * CGFloat(clamp(level))
    }
}

/// One finger on the full-screen control (03 §4.5), from down to up.
///
/// A short touch is the button. A finger that stays put between 0.6 and 2 s
/// and then lifts goes back to the page (Night only): a hand or a cheek
/// resting on the glass for longer does nothing. A finger that moves up or
/// down sets the session level. Sideways there is no gesture at all, and
/// there is no double tap.
struct NightTouch: Equatable {
    enum Kind: Equatable {
        /// Down and still inside the slop.
        case undecided
        /// Moving along the vertical axis.
        case level
        /// Moved sideways: nothing will come of it.
        case cancelled
    }

    enum Outcome: Equatable {
        case nothing
        case tap
        case back
    }

    /// A thumb that settles does not "move".
    static let slop = Grid.longPressSlop
    static let longPress = Grid.longPress
    /// Past this a contact is not a gesture.
    static let longestPress: TimeInterval = 2
    /// The drag is vertical when it is within 30° of the vertical axis.
    static let verticalRatio: CGFloat = 0.577

    private(set) var kind = Kind.undecided
    private(set) var startedAt: Date?
    private(set) var startLevel: Float = 1

    var isDown: Bool { startedAt != nil }
    var isAdjustingLevel: Bool { isDown && kind == .level }

    mutating func begin(at date: Date, level: Float) {
        kind = .undecided
        startedAt = date
        startLevel = level
    }

    /// The finger moved. Returns the level to set while it is a vertical
    /// drag, and nil otherwise.
    mutating func move(translation: CGSize) -> Float? {
        guard isDown else { return nil }
        if kind == .undecided {
            let distance = (translation.width * translation.width + translation.height * translation.height)
                .squareRoot()
            guard distance > Self.slop else { return nil }
            let isVertical = abs(translation.width) <= abs(translation.height) * Self.verticalRatio
            kind = isVertical ? .level : .cancelled
        }
        guard kind == .level else { return nil }
        return NightAxis.level(from: startLevel, translation: translation.height)
    }

    /// The finger lifted.
    mutating func end(at date: Date, allowsBack: Bool) -> Outcome {
        defer {
            startedAt = nil
            kind = .undecided
        }
        guard let startedAt, kind == .undecided else { return .nothing }
        let held = date.timeIntervalSince(startedAt)
        if held < Self.longPress { return .tap }
        if held <= Self.longestPress { return allowsBack ? .back : .nothing }
        return .nothing
    }

    /// The system took the touch away.
    mutating func cancel() {
        startedAt = nil
        kind = .undecided
    }

    /// A touch that began too soon after the iPhone woke is not counted.
    static func isGuarded(wokeAt: Date?, touchAt: Date) -> Bool {
        guard let wokeAt else { return false }
        let since = touchAt.timeIntervalSince(wokeAt)
        return since >= 0 && since < BedtimeScreenPolicy.wakeGuard
    }
}

/// Where things sit on Night and Small Hours (spec 07 §2.2 and §2.3, the
/// mock-up frames 12 and 13). Everything hangs from the Horizon, at a third
/// of the whole screen, so the two screens and the page share one line.
struct NightLayout: Equatable {
    var fullHeight: CGFloat

    var horizonY: CGFloat { Grid.horizonY(fullHeight: fullHeight) }

    /// From the Horizon to the top of the clock: 340 on a screen of 852.
    static let clockDrop: CGFloat = 56
    /// From the Horizon to the top of the figure of Small Hours, which
    /// clears the band of the water line: 396 on 852.
    static let figureDrop: CGFloat = 112
    /// Air between the figure, the word and the sentences under it.
    static let lineGap: CGFloat = Grid.inner
    /// Dead channel between two borderless targets (03 §3.5).
    static let channel: CGFloat = Grid.layerChannel
    /// The rule of the level sits this far inside the column's edge.
    static let ruleInset: CGFloat = 21

    var clockTop: CGFloat { horizonY + Self.clockDrop }
    var figureTop: CGFloat { horizonY + Self.figureDrop }
    /// Top of the level rule, which is centred on the Horizon.
    var ruleTop: CGFloat { horizonY - NightAxis.travel / 2 }
}
