import Foundation

/// What the timer sheet and the timer row say (03 §5 #8), worked out
/// without a view. The whole timer is free (C03): nothing here knows about
/// access, and the word "pro" cannot come out of it.
///
/// The end of a night is always an hour of the clock ("Fades at 03:42"),
/// never a count of seconds. Every word comes from the catalog and every
/// figure from the timer.
enum TimerSheetText {
    typealias Lookup = (String) -> String
    typealias Clock = (Date) -> String

    static let standardLookup: Lookup = { Localized.string($0) }
    /// The short time of the system: 24 hours or AM/PM as the person set it.
    static let standardClock: Clock = { $0.formatted(date: .omitted, time: .shortened) }
    /// The hour as a figure: the clock of Night and the hour of a blanket
    /// at 56 pt and more. Never with "AM" or "PM": at that size the suffix
    /// is as many lit pixels again and says nothing a sentence does not
    /// (07 §2.2.2; the sentences keep the system's short time).
    static let figureClock: Clock = {
        withoutDayPeriod($0.formatted(date: .omitted, time: .shortened))
    }

    /// The short time of the system without its "AM", "p. m." or "午前",
    /// whichever side it is written on. The digits stay as the region
    /// writes them ("7:05", never "07:05" where it does not).
    static func withoutDayPeriod(_ time: String) -> String {
        time.trimmingCharacters(in: CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: ".")))
    }

    /// What the block above the list shows while a night is being counted.
    enum Head: Equatable {
        /// "Until I sleep" counting: whole minutes left and when it ends.
        case counting(minutes: Int, endsAt: Date)
        /// A blanket: it sounds until an hour.
        case blanket(endsAt: Date)
        /// The final fade, in either mode.
        case fading(minutes: Int)
        /// "Until I sleep" paused: what is left waits.
        case paused(minutes: Int)
        /// A blanket paused: its hour does not move.
        case pausedBlanket(endsAt: Date)
    }

    /// Where the timer stands, as the sheet needs it.
    struct Input: Equatable {
        var choice: TimerChoice
        var endsAt: Date?
        var remaining: TimeInterval?
        var isFading = false
        var fadingMinutes: Int?
        var hasCount = false
        /// The hour a blanket ends tonight. It survives a pause.
        var fixedEnd: Date?
        /// The blanket has not eased the level down yet, and will before
        /// its hour.
        var blanketDipIsAhead = false
    }

    /// Whole minutes left, never under one while there is a count.
    static func minutes(_ remaining: TimeInterval) -> Int {
        max(1, Int((max(0, remaining) / 60).rounded(.up)))
    }

    static func head(_ input: Input) -> Head? {
        guard input.hasCount, input.choice.mode != .off else { return nil }
        if let end = input.endsAt {
            if input.isFading {
                return .fading(minutes: input.fadingMinutes ?? minutes(input.remaining ?? 0))
            }
            if input.choice.mode == .blanket { return .blanket(endsAt: end) }
            return .counting(minutes: minutes(input.remaining ?? 0), endsAt: end)
        }
        if input.choice.mode == .blanket {
            return input.fixedEnd.map { .pausedBlanket(endsAt: $0) }
        }
        return input.remaining.map { .paused(minutes: minutes($0)) }
    }

    /// The figure: a number of minutes or an hour, or "Paused". Only that;
    /// the sentence goes on the line under it.
    static func figure(
        _ head: Head,
        localized: Lookup = standardLookup,
        time: Clock = figureClock,
        locale: Locale = .current
    ) -> String {
        switch head {
        case .counting(let minutes, _), .fading(let minutes):
            return String(format: localized("comun.min"), locale: locale, Int64(minutes))
        case .blanket(let end):
            return time(end)
        case .paused, .pausedBlanket:
            return localized("pagina.estado.pausa")
        }
    }

    /// The line under the figure. It never says again what the figure
    /// already says, and it always begins with a capital: when it ends as
    /// an hour under a count of minutes; under the hour of a blanket, the
    /// dip that is still to come, and after it nothing; "Fading" under the
    /// minutes of the fade.
    static func line(
        _ head: Head,
        dipIsAhead: Bool = false,
        localized: Lookup = standardLookup,
        time: Clock = standardClock,
        locale: Locale = .current
    ) -> String {
        switch head {
        case .counting(_, let end):
            let hour = time(end)
            return String(format: localized(HourPhrase.key("noche.estado.funde", at: hour)), hour)
        case .blanket:
            guard dipIsAhead else { return " " }
            return String(
                format: localized("temporizador.cabecera.manto"),
                locale: locale,
                Int64((TimerMath.blanketDipAfter / 60).rounded())
            )
        case .pausedBlanket(let end):
            // The figure says "Paused": the line says the hour, which a
            // pause does not move.
            let hour = time(end)
            return sentence(
                String(format: localized(HourPhrase.key("noche.estado.hasta", at: hour)), hour), locale: locale
            )
        case .fading:
            return localized("temporizador.cabecera.fundiendo")
        case .paused(let minutes):
            return sentence(String.localizedStringWithFormat(localized("comun.min.quedan"), minutes), locale: locale)
        }
    }

    /// A phrase the catalog writes for the middle of a line ("until 7:00",
    /// "38 min left"), set as a line of its own: with a capital.
    static func sentence(_ words: String, locale: Locale = .current) -> String {
        words.prefix(1).capitalized(with: locale) + words.dropFirst()
    }

    /// What VoiceOver reads for the block: figure and line as one phrase.
    static func spoken(
        _ head: Head,
        dipIsAhead: Bool = false,
        localized: Lookup = standardLookup,
        time: Clock = standardClock,
        locale: Locale = .current
    ) -> String {
        // Spoken, an hour keeps what the system says of it, AM and PM too.
        let figure = figure(head, localized: localized, time: time, locale: locale)
        let line = line(head, dipIsAhead: dipIsAhead, localized: localized, time: time, locale: locale)
            .trimmingCharacters(in: .whitespaces)
        return PageStatus.spoken(line.isEmpty ? figure : figure + ". " + line)
    }

    // MARK: Rows

    /// The hour of a blanket as a date of `day`, to be formatted like any
    /// other time.
    static func blanketHour(_ choice: TimerChoice, on day: Date, calendar: Calendar) -> Date {
        calendar.date(bySettingHour: choice.endHour, minute: choice.endMinute, second: 0, of: day) ?? day
    }

    /// Subtitle of "Until I sleep": "45 min · fades out at the end".
    static func asleepDetail(
        _ choice: TimerChoice,
        localized: Lookup = standardLookup,
        locale: Locale = .current
    ) -> String {
        String(format: localized("temporizador.dormirme.detalle"), locale: locale, Int64(choice.minutes))
    }

    /// Subtitle of "Blanket": "until 07:00 · eases down after 45 min". The
    /// minutes are the timer's own (`TimerMath.blanketDipAfter`).
    static func blanketDetail(
        hour: Date,
        localized: Lookup = standardLookup,
        time: Clock = standardClock,
        locale: Locale = .current
    ) -> String {
        let end = time(hour)
        return String(
            format: localized(HourPhrase.key("temporizador.manto.detalle", at: end)),
            locale: locale,
            end,
            Int64((TimerMath.blanketDipAfter / 60).rounded())
        )
    }

    /// The control of the chosen mode: its name and its value. "Off" has
    /// none; the row keeps its room, empty.
    static func control(
        _ choice: TimerChoice,
        hour: Date,
        localized: Lookup = standardLookup,
        time: Clock = standardClock,
        locale: Locale = .current
    ) -> (title: String, value: String)? {
        switch choice.mode {
        case .off:
            return nil
        case .untilAsleep:
            return (
                localized("temporizador.duracion"),
                String(format: localized("comun.min"), locale: locale, Int64(choice.minutes))
            )
        case .blanket:
            return (localized("temporizador.hora"), time(hour))
        }
    }

    /// The lengths of the wheel: five minutes to the ceiling in steps of
    /// five, plus the current one when it is not among them (a Shortcut may
    /// have asked for any minute).
    static func lengths(including current: Int) -> [Int] {
        var all = Array(stride(from: 5, through: AccessPolicy.maxTimerMinutes, by: 5))
        if !all.contains(current), (1...AccessPolicy.maxTimerMinutes).contains(current) {
            all.append(current)
            all.sort()
        }
        return all
    }

    /// The timer row of the page: the setting, never the count.
    static func setting(
        _ choice: TimerChoice,
        hour: Date,
        localized: Lookup = standardLookup,
        time: Clock = standardClock,
        locale: Locale = .current
    ) -> String {
        switch choice.mode {
        case .off:
            return localized("temporizador.apagado")
        case .untilAsleep:
            return String(format: localized("temporizador.estado.dormirme"), locale: locale, Int64(choice.minutes))
        case .blanket:
            let end = time(hour)
            return String(format: localized(HourPhrase.key("temporizador.estado.manto", at: end)), end)
        }
    }

    /// What VoiceOver adds to the timer row while "Until I sleep" counts:
    /// the mode and the minutes left. A blanket already says its hour.
    static func settingSpokenValue(
        _ input: Input,
        localized: Lookup = standardLookup,
        locale: Locale = .current
    ) -> String? {
        guard input.choice.mode == .untilAsleep, input.endsAt != nil, let remaining = input.remaining else {
            return nil
        }
        // The minutes as the announcement of "+15 min" says them, so one
        // minute is "1 minute left" and not "1 minutes".
        return String(
            format: localized("ax.temporizador.valor"),
            localized("temporizador.dormirme"),
            String.localizedStringWithFormat(localized("ax.anuncio.quedan"), minutes(remaining))
        )
    }

    /// Spoken after "+15 min": the minutes left now, or the new hour of a
    /// blanket.
    static func extensionAnnouncement(
        _ input: Input,
        localized: Lookup = standardLookup,
        time: Clock = standardClock
    ) -> String? {
        guard input.hasCount else { return nil }
        if input.choice.mode == .blanket {
            return (input.endsAt ?? input.fixedEnd).map { end in
                let hour = time(end)
                return String(format: localized(HourPhrase.key("ax.anuncio.hasta", at: hour)), hour)
            }
        }
        return input.remaining.map {
            String.localizedStringWithFormat(localized("ax.anuncio.quedan"), minutes($0))
        }
    }
}

extension TimerSheetText.Input {
    /// Read from the live timer.
    @MainActor
    init(_ timer: SleepTimerController) {
        self.init(
            choice: timer.choice,
            endsAt: timer.endsAt,
            remaining: timer.remaining,
            isFading: timer.isFading,
            fadingMinutes: timer.fadingMinutes,
            hasCount: timer.hasCount,
            fixedEnd: timer.fixedEnd,
            blanketDipIsAhead: timer.blanketDipIsAhead
        )
    }
}
