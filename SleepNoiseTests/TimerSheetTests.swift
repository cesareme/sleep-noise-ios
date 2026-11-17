import XCTest
@testable import SleepNoise

/// What the timer sheet and the timer row say (surface 8), without a view.
final class TimerSheetTextTests: XCTestCase {
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    private func time(_ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 18
        components.hour = hour
        components.minute = minute
        return utc.date(from: components) ?? Date(timeIntervalSinceReferenceDate: 0)
    }

    /// The Spanish of the copy guide, so the phrases can be read whole.
    private let spanish: [String: String] = [
        "comun.min": "%lld min",
        "comun.min.quedan": "quedan %lld min",
        "pagina.estado.pausa": "En pausa",
        "noche.estado.funde": "Se funde a las %@",
        "noche.estado.fundiendo": "Fundiendo · %lld min",
        "temporizador.dormirme": "Hasta dormirme",
        "temporizador.dormirme.detalle": "%lld min · se funde al final",
        "temporizador.manto.detalle": "hasta las %1$@ · baja un poco a los %2$lld min",
        "temporizador.duracion": "Duración",
        "temporizador.hora": "Hora",
        "temporizador.apagado": "Apagado",
        "temporizador.estado.dormirme": "Hasta dormirme · %lld min",
        "temporizador.estado.manto": "Manto · hasta las %@",
        "ax.temporizador.valor": "%1$@, %2$@",
        "temporizador.cabecera.fundiendo": "Fundiendo",
        "temporizador.cabecera.manto": "Baja un poco a los %lld min",
        "noche.estado.hasta": "hasta las %@",
        "ax.anuncio.quedan": "Quedan %lld minutos",
        "ax.anuncio.hasta": "Hasta las %@"
    ]

    private var lookup: (String) -> String {
        { [spanish] key in spanish[key] ?? "?\(key)?" }
    }

    private var clock: (Date) -> String {
        { [utc] date in
            let parts = utc.dateComponents([.hour, .minute], from: date)
            return String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
        }
    }

    private let locale = Locale(identifier: "es_ES")

    private func figure(_ head: TimerSheetText.Head) -> String {
        TimerSheetText.figure(head, localized: lookup, time: clock, locale: locale)
    }

    private func line(_ head: TimerSheetText.Head, dipIsAhead: Bool = false) -> String {
        TimerSheetText.line(head, dipIsAhead: dipIsAhead, localized: lookup, time: clock, locale: locale)
    }

    // MARK: The block above the list

    func testNothingIsCountedAtRestOrWithTheTimerOff() {
        // First use: a timer is chosen, but no night has begun.
        XCTAssertNil(TimerSheetText.head(.init(choice: .firstUse)))
        // Off, even with what a count left behind.
        XCTAssertNil(TimerSheetText.head(.init(
            choice: .off, endsAt: time(3, 42), remaining: 600, hasCount: true
        )))
    }

    func testUntilAsleepSaysMinutesLeftAndTheHourItEnds() throws {
        let head = try XCTUnwrap(TimerSheetText.head(.init(
            choice: .untilAsleep(45), endsAt: time(3, 42), remaining: 37 * 60 + 20, hasCount: true
        )))
        XCTAssertEqual(head, .counting(minutes: 38, endsAt: time(3, 42)))
        XCTAssertEqual(figure(head), "38 min", "only the number: no seconds, no sentence")
        XCTAssertEqual(line(head), "Se funde a las 03:42")
        XCTAssertEqual(
            TimerSheetText.spoken(head, localized: lookup, time: clock, locale: locale),
            "38 min. Se funde a las 03:42"
        )
    }

    func testTheMinutesAreWholeAndNeverZero() {
        XCTAssertEqual(TimerSheetText.minutes(45 * 60), 45)
        XCTAssertEqual(TimerSheetText.minutes(44 * 60 + 1), 45)
        XCTAssertEqual(TimerSheetText.minutes(59), 1)
        XCTAssertEqual(TimerSheetText.minutes(0.2), 1)
        XCTAssertEqual(TimerSheetText.minutes(-3), 1)
    }

    func testABlanketSaysItsHourNotALength() throws {
        let head = try XCTUnwrap(TimerSheetText.head(.init(
            choice: .blanket(hour: 7), endsAt: time(7), remaining: 5 * 3_600, hasCount: true, fixedEnd: time(7)
        )))
        XCTAssertEqual(head, .blanket(endsAt: time(7)))
        XCTAssertEqual(figure(head), "07:00")
        // The line never says the hour again: only the dip, while it is
        // still to come. Once it has come, or when it never will, nothing.
        XCTAssertEqual(line(head, dipIsAhead: true), "Baja un poco a los 45 min")
        XCTAssertEqual(line(head, dipIsAhead: false), " ")
        XCTAssertFalse(line(head, dipIsAhead: true).contains("07:00"))
        XCTAssertFalse(figure(head).contains("min"), "a blanket has no length in minutes")
        XCTAssertEqual(
            TimerSheetText.spoken(head, dipIsAhead: false, localized: lookup, time: clock, locale: locale),
            "07:00"
        )
    }

    /// The hour as a figure never carries "AM" or "PM", whatever the
    /// region: the sentences keep the system's short time.
    func testTheHourAsAFigureHasNoSuffix() {
        let seven = time(7)
        let figure = TimerSheetText.figureClock(seven)
        XCTAssertFalse(figure.uppercased().contains("AM"))
        XCTAssertFalse(figure.uppercased().contains("PM"))
        XCTAssertFalse(figure.contains("a. m."), figure)
        XCTAssertTrue(figure.contains(":"), figure)
        XCTAssertEqual(NightScreen.clock(seven), figure, "Night draws the same figure")
        // Whatever the region writes around the digits goes; the digits stay.
        XCTAssertEqual(TimerSheetText.withoutDayPeriod("7:05 AM"), "7:05")
        XCTAssertEqual(TimerSheetText.withoutDayPeriod("2:14\u{202F}PM"), "2:14")
        XCTAssertEqual(TimerSheetText.withoutDayPeriod("2:14 p.\u{00A0}m."), "2:14")
        XCTAssertEqual(TimerSheetText.withoutDayPeriod("午前7:05"), "7:05")
        XCTAssertEqual(TimerSheetText.withoutDayPeriod("07:00"), "07:00", "24 hours: as it was")
    }

    func testTheFinalFadeIsSaidInWordsInEitherMode() throws {
        for choice in [TimerChoice.untilAsleep(45), .blanket(hour: 7)] {
            let head = try XCTUnwrap(TimerSheetText.head(.init(
                choice: choice, endsAt: time(3, 42), remaining: 7 * 60 + 30, isFading: true,
                fadingMinutes: 8, hasCount: true, fixedEnd: choice.mode == .blanket ? time(3, 42) : nil
            )))
            XCTAssertEqual(head, .fading(minutes: 8))
            XCTAssertEqual(figure(head), "8 min")
            XCTAssertEqual(line(head), "Fundiendo", "the figure already says how long")
        }
    }

    func testAPauseKeepsWhatIsLeftAndABlanketKeepsItsHour() throws {
        let asleep = try XCTUnwrap(TimerSheetText.head(.init(
            choice: .untilAsleep(45), remaining: 38 * 60, hasCount: true
        )))
        XCTAssertEqual(asleep, .paused(minutes: 38))
        XCTAssertEqual(figure(asleep), "En pausa")
        XCTAssertEqual(line(asleep), "Quedan 38 min", "a line of its own begins with a capital")

        let blanket = try XCTUnwrap(TimerSheetText.head(.init(
            choice: .blanket(hour: 7), remaining: 999, hasCount: true, fixedEnd: time(7)
        )))
        XCTAssertEqual(blanket, .pausedBlanket(endsAt: time(7)))
        XCTAssertEqual(figure(blanket), "En pausa")
        XCTAssertEqual(line(blanket), "Hasta las 07:00", "the hour, once, with a capital")
    }

    // MARK: Rows

    func testTheRowsOfTheModesSayTheirSetting() {
        XCTAssertEqual(
            TimerSheetText.asleepDetail(.untilAsleep(45), localized: lookup, locale: locale),
            "45 min · se funde al final"
        )
        let choice = TimerChoice.blanket(hour: 6, minute: 30)
        let hour = TimerSheetText.blanketHour(choice, on: time(23), calendar: utc)
        XCTAssertEqual(clock(hour), "06:30")
        XCTAssertEqual(
            TimerSheetText.blanketDetail(hour: hour, localized: lookup, time: clock, locale: locale),
            "hasta las 06:30 · baja un poco a los 45 min"
        )
    }

    /// AGENTS §5.2: the figure in a string comes from the code.
    func testTheMinutesOfTheBlanketDipComeFromTheTimer() {
        let text = TimerSheetText.blanketDetail(
            hour: time(7), localized: { _ in "%1$@|%2$lld" }, time: clock, locale: locale
        )
        XCTAssertEqual(text, "07:00|\(Int(TimerMath.blanketDipAfter / 60))")
    }

    func testTheControlFollowsTheModeAndOffHasNone() throws {
        let hour = time(7)
        let length = try XCTUnwrap(TimerSheetText.control(
            .untilAsleep(90), hour: hour, localized: lookup, time: clock, locale: locale
        ))
        XCTAssertEqual(length.title, "Duración")
        XCTAssertEqual(length.value, "90 min")
        let blanket = try XCTUnwrap(TimerSheetText.control(
            .blanket(hour: 7), hour: hour, localized: lookup, time: clock, locale: locale
        ))
        XCTAssertEqual(blanket.title, "Hora")
        XCTAssertEqual(blanket.value, "07:00")
        XCTAssertNil(TimerSheetText.control(.off, hour: hour, localized: lookup, time: clock, locale: locale))
    }

    func testTheWheelGoesToTheCeilingInFivesAndKeepsAnOddLength() {
        let lengths = TimerSheetText.lengths(including: 45)
        XCTAssertEqual(lengths.first, 5)
        XCTAssertEqual(lengths.last, AccessPolicy.maxTimerMinutes)
        XCTAssertEqual(lengths.count, AccessPolicy.maxTimerMinutes / 5)
        XCTAssertTrue(lengths.allSatisfy { $0 % 5 == 0 })

        // A Shortcut may have asked for any minute: the wheel can show it.
        let odd = TimerSheetText.lengths(including: 7)
        XCTAssertEqual(Array(odd.prefix(3)), [5, 7, 10])
        XCTAssertEqual(odd.count, lengths.count + 1)
        XCTAssertEqual(TimerSheetText.lengths(including: 0), lengths)
        XCTAssertEqual(TimerSheetText.lengths(including: 9_999), lengths)
    }

    func testTheTimerRowSaysTheSettingInEveryMode() {
        let hour = time(7)
        func setting(_ choice: TimerChoice) -> String {
            TimerSheetText.setting(choice, hour: hour, localized: lookup, time: clock, locale: locale)
        }
        XCTAssertEqual(setting(.firstUse), "Hasta dormirme · 45 min")
        XCTAssertEqual(setting(.blanket(hour: 7)), "Manto · hasta las 07:00")
        XCTAssertEqual(setting(.off), "Apagado")
    }

    func testVoiceOverGetsTheMinutesLeftOnlyWhileUntilAsleepCounts() {
        let counting = TimerSheetText.Input(
            choice: .untilAsleep(45), endsAt: time(3, 42), remaining: 38 * 60, hasCount: true
        )
        XCTAssertEqual(
            TimerSheetText.settingSpokenValue(counting, localized: lookup, locale: locale),
            "Hasta dormirme, Quedan 38 minutos"
        )
        XCTAssertNil(TimerSheetText.settingSpokenValue(.init(choice: .firstUse), localized: lookup, locale: locale))
        XCTAssertNil(TimerSheetText.settingSpokenValue(
            .init(choice: .untilAsleep(45), remaining: 600, hasCount: true), localized: lookup, locale: locale
        ), "paused: the row says the setting")
        XCTAssertNil(TimerSheetText.settingSpokenValue(
            .init(choice: .blanket(hour: 7), endsAt: time(7), remaining: 600, hasCount: true, fixedEnd: time(7)),
            localized: lookup,
            locale: locale
        ), "a blanket already says its hour")
    }

    func testFifteenMoreIsAnnouncedAsMinutesOrAsTheNewHour() {
        XCTAssertEqual(
            TimerSheetText.extensionAnnouncement(
                .init(choice: .untilAsleep(45), endsAt: time(3, 57), remaining: 53 * 60, hasCount: true),
                localized: lookup,
                time: clock
            ),
            "Quedan 53 minutos"
        )
        XCTAssertEqual(
            TimerSheetText.extensionAnnouncement(
                .init(choice: .blanket(hour: 7), endsAt: time(7, 15), remaining: 60, hasCount: true, fixedEnd: time(7, 15)),
                localized: lookup,
                time: clock
            ),
            "Hasta las 07:15"
        )
        XCTAssertNil(TimerSheetText.extensionAnnouncement(.init(choice: .firstUse), localized: lookup, time: clock))
    }

    // MARK: The state line of the page

    func testABlanketIsSaidAsAnHourOnTheStateLine() {
        var input = PageStatus.Input(isPlaying: true, timerEndsAt: time(7))
        XCTAssertEqual(PageStatus.resolve(input), .playingFadesAt(time(7)))
        input.timerEndsAtAnHour = true
        XCTAssertEqual(PageStatus.resolve(input), .playingUntil(time(7)))
        let text = PageStatus.playingUntil(time(7)).text(
            localized: { $0 == "pagina.estado.sonando.hasta" ? "Sonando · hasta las %@" : $0 },
            time: clock
        )
        XCTAssertEqual(text, "Sonando · hasta las 07:00")
        // The final fade still wins: it is what is happening.
        input.timerIsFading = true
        input.timerRemaining = 8 * 60
        XCTAssertEqual(PageStatus.resolve(input), .fading(minutes: 8))
    }
}

/// The catalog behind the timer: both languages, and no word of Pro.
final class TimerCatalogTests: XCTestCase {
    static let keys = [
        "temporizador.titulo", "temporizador.dormirme", "temporizador.dormirme.detalle",
        "temporizador.manto", "temporizador.manto.detalle", "temporizador.apagado",
        "temporizador.duracion", "temporizador.hora", "temporizador.estado.dormirme",
        "temporizador.estado.manto", "temporizador.nota", "comun.min", "comun.min.quedan",
        "comun.mas15", "noche.estado.funde", "noche.estado.fundiendo",
        "pagina.estado.sonando.hasta", "ax.temporizador.valor", "ax.duracion.pista",
        "temporizador.cabecera.fundiendo", "temporizador.cabecera.manto", "noche.estado.hasta",
        "ax.mas15", "ax.anuncio.quedan", "ax.anuncio.hasta"
    ]

    static func catalog() throws -> [String: Any] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SleepNoise/Resources/Localizable.xcstrings")
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        return try XCTUnwrap(root["strings"] as? [String: Any])
    }

    /// Every string under a "value" key, at any depth.
    static func values(in node: Any?) -> [String] {
        guard let dictionary = node as? [String: Any] else { return [] }
        return dictionary.flatMap { key, child -> [String] in
            if key == "value", let text = child as? String { return [text] }
            return values(in: child)
        }
    }

    static func values(_ key: String, _ language: String, in strings: [String: Any]) -> [String] {
        let localizations = (strings[key] as? [String: Any])?["localizations"] as? [String: Any]
        return values(in: localizations?[language])
    }

    func testEveryTimerStringExistsInBothLanguages() throws {
        let strings = try Self.catalog()
        for key in Self.keys {
            for language in ["en", "es"] {
                let found = Self.values(key, language, in: strings)
                XCTAssertFalse(found.isEmpty, "\(key) [\(language)] is missing")
                XCTAssertFalse(found.contains { $0.isEmpty }, "\(key) [\(language)] is empty")
            }
        }
    }

    /// C03: the whole timer is free, and the word "pro" does not appear in
    /// it, in any mode, length or note.
    func testTheWordProDoesNotAppearInTheTimer() throws {
        let strings = try Self.catalog()
        for key in Self.keys {
            for language in ["en", "es"] {
                for value in Self.values(key, language, in: strings) {
                    let words = value.lowercased().split { !$0.isLetter }.map(String.init)
                    XCTAssertFalse(words.contains("pro"), "\(key) [\(language)]: \(value)")
                }
            }
        }
    }

    /// The old sheets went with their strings.
    func testTheStringsOfTheOldSheetsAreGone() throws {
        let strings = try Self.catalog()
        let dead = strings.keys.filter { $0.hasPrefix("timer.") || $0.hasPrefix("breath.") }
        XCTAssertEqual(dead.sorted(), [])
    }

    /// The lengths and hours the sheet shows carry no seconds and no Spanish
    /// "timer" (copy guide §0.5).
    func testSpanishNeverSaysTimer() throws {
        let strings = try Self.catalog()
        for key in Self.keys {
            for value in Self.values(key, "es", in: strings) {
                XCTAssertFalse(value.lowercased().contains("timer"), "\(key): \(value)")
            }
        }
    }
}

/// The sheet over the real model, on doubles.
@MainActor
final class TimerSheetModelTests: XCTestCase {
    private func input(_ night: NightHarness) -> TimerSheetText.Input {
        TimerSheetText.Input(night.model.timer)
    }

    func testTheFirstNightOpensOnUntilAsleepFortyFive() throws {
        let night = try NightHarness(at: NightHarness.time(23))
        XCTAssertEqual(input(night).choice, .firstUse)
        XCTAssertEqual(input(night).choice.mode, .untilAsleep)
        XCTAssertEqual(input(night).choice.minutes, 45)
        XCTAssertNil(TimerSheetText.head(input(night)), "nothing counts before Play")
        XCTAssertFalse(night.model.canExtendTimer, "+15 never creates a timer")
        XCTAssertNil(MixerModel.storedTimer(defaults: night.defaults), "the default is not a choice")
    }

    func testPlayCountsAndFifteenMoreMovesTheHour() throws {
        let start = NightHarness.time(23)
        let night = try NightHarness(at: start)
        night.model.play()
        XCTAssertEqual(
            TimerSheetText.head(input(night)),
            .counting(minutes: 45, endsAt: start.addingTimeInterval(45 * 60))
        )
        XCTAssertTrue(night.model.canExtendTimer)

        night.clock.now = start.addingTimeInterval(7 * 60)
        night.model.timer.tick()
        XCTAssertEqual(
            TimerSheetText.head(input(night)),
            .counting(minutes: 38, endsAt: start.addingTimeInterval(45 * 60))
        )

        XCTAssertTrue(night.model.extendTimer())
        XCTAssertEqual(
            TimerSheetText.head(input(night)),
            .counting(minutes: 53, endsAt: start.addingTimeInterval(60 * 60))
        )
    }

    func testChoosingAModeIsStoredAndCountsAtOnce() throws {
        let start = NightHarness.time(23)
        let night = try NightHarness(at: start)
        night.model.play()

        // Blanket: until the next seven o'clock.
        night.model.chooseTimer(night.model.timer.choice.with(mode: .blanket))
        let seven = NightHarness.time(day: 18, 7)
        XCTAssertEqual(TimerSheetText.head(input(night)), .blanket(endsAt: seven))
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.mode, .blanket)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.minutes, 45, "the length is kept for later")

        // Off: nothing left to count or to extend, and it is a choice.
        night.model.chooseTimer(night.model.timer.choice.with(mode: .off))
        XCTAssertNil(TimerSheetText.head(input(night)))
        XCTAssertFalse(night.model.canExtendTimer)
        XCTAssertEqual(MixerModel.storedTimer(defaults: night.defaults)?.mode, .off)
        XCTAssertTrue(night.model.isPlaying, "choosing a timer never stops the night")

        // Back to "Until I sleep": the length it had.
        night.model.chooseTimer(night.model.timer.choice.with(mode: .untilAsleep))
        XCTAssertEqual(
            TimerSheetText.head(input(night)),
            .counting(minutes: 45, endsAt: start.addingTimeInterval(45 * 60))
        )
    }

    func testAPausedNightShowsWhatIsLeft() throws {
        let start = NightHarness.time(23)
        let night = try NightHarness(at: start)
        night.model.play()
        night.clock.now = start.addingTimeInterval(7 * 60)
        night.model.timer.tick()
        night.model.pause()
        XCTAssertEqual(TimerSheetText.head(input(night)), .paused(minutes: 38))
        XCTAssertTrue(night.model.canExtendTimer)
    }

    /// Nothing in the timer depends on access (C03): the sheet is the same
    /// for someone whose trial ran out, at night included.
    func testTheTimerIsTheSameWithoutAccess() throws {
        let start = NightHarness.time(23)
        let night = try NightHarness(at: start, free: true)
        XCTAssertFalse(night.purchases.hasFullAccess)
        var long = TimerChoice.untilAsleep(AccessPolicy.maxTimerMinutes)
        night.model.chooseTimer(long)
        night.model.play()
        XCTAssertEqual(input(night).choice.minutes, AccessPolicy.maxTimerMinutes)
        XCTAssertEqual(TimerSheetText.head(input(night)), .counting(
            minutes: AccessPolicy.maxTimerMinutes,
            endsAt: start.addingTimeInterval(TimeInterval(AccessPolicy.maxTimerMinutes * 60))
        ))
        long = long.with(mode: .blanket)
        night.model.chooseTimer(long)
        XCTAssertEqual(input(night).choice.mode, .blanket)
        XCTAssertTrue(night.model.extendTimer())
        XCTAssertFalse(night.model.showPaywall, "nothing in the timer asks for Pro")
    }
}
