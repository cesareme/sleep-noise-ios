import XCTest
@testable import SleepNoise

/// The hour that reads "one" (S-08): Spanish says "a la 1:30" and
/// "a las 3:42". Red if a sentence that says an hour puts "las" before
/// the one, in 24 hours or in 12.
final class HourPhraseTests: XCTestCase {
    private func date(_ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: hour, minute: minute))!
    }

    /// The short time of a region, as the app shows it.
    private func clock(_ identifier: String) -> (Date) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.locale = Locale(identifier: identifier)
        style.timeZone = TimeZone(identifier: "UTC")!
        return { $0.formatted(style) }
    }

    /// The Spanish of the catalog, read from the checkout.
    private func spanish() throws -> (String) -> String {
        let values = try CatalogSource.values(CatalogSource.interface).filter { $0.language == "es" }
        let table = Dictionary(values.map { ($0.key, $0.text) }, uniquingKeysWith: { first, _ in first })
        return { table[$0] ?? "MISSING \($0)" }
    }

    func testTheHourThatReadsOne() {
        for time in ["1:30", "01:30", "1:00", "1:30 p. m.", "1:30 PM", "1:30\u{202F}a.\u{00A0}m.", "午後1:30"] {
            XCTAssertTrue(HourPhrase.readsOne(time), time)
        }
        for time in ["13:30", "0:30", "00:45", "11:30", "10:01", "12:01 AM", "21:00", "3:42", ""] {
            XCTAssertFalse(HourPhrase.readsOne(time), time)
        }
        XCTAssertEqual(HourPhrase.key("noche.estado.funde", at: "1:30"), "noche.estado.funde.una")
        XCTAssertEqual(HourPhrase.key("noche.estado.funde", at: "13:30"), "noche.estado.funde")
    }

    /// Every key that says an hour has its ".una", and nothing else has
    /// one. In Spanish the two differ only in the article; in English
    /// they say the same.
    func testEveryHourKeyHasItsOne() throws {
        let strings = try CatalogSource.strings(CatalogSource.interface)
        let values = try CatalogSource.values(CatalogSource.interface)
        func text(_ key: String, _ language: String) -> String? {
            values.first { $0.key == key && $0.language == language }?.text
        }
        let suffixed = strings.keys.filter { $0.hasSuffix(HourPhrase.oneSuffix) }
        XCTAssertEqual(Set(suffixed), Set(HourPhrase.keys.map { $0 + HourPhrase.oneSuffix }))
        for key in HourPhrase.keys {
            let one = key + HourPhrase.oneSuffix
            let plural = try XCTUnwrap(text(key, "es"), key)
            XCTAssertTrue(plural.contains(" las %") || plural.hasPrefix("hasta las %"), plural)
            XCTAssertEqual(text(one, "es"), plural.replacingOccurrences(of: " las %", with: " la %"), key)
            XCTAssertEqual(text(one, "en"), text(key, "en"), key)
        }
        // No other Spanish value fixes "las" before something the code fills in.
        for value in values where value.language == "es" && value.text.contains(" las %") {
            XCTAssertTrue(HourPhrase.keys.contains(value.key), value.place)
        }
    }

    /// 01:30 and 13:30, in 24 hours (Spain) and in 12 (Spanish in the
    /// United States), through every sentence of the app that says an hour.
    func testSpanishSaysLaBeforeTheOne() throws {
        let localized = try spanish()
        let spain = clock("es_ES")
        let twelve = clock("es_US")
        let locale = Locale(identifier: "es_ES")
        XCTAssertEqual(spain(date(1, 30)), "1:30")
        XCTAssertEqual(spain(date(13, 30)), "13:30")
        XCTAssertTrue(twelve(date(13, 30)).hasPrefix("1:30"), twelve(date(13, 30)))

        // The page.
        XCTAssertEqual(
            PageStatus.playingFadesAt(date(1, 30)).text(localized: localized, time: spain, locale: locale),
            "Sonando · se funde a la 1:30"
        )
        XCTAssertEqual(
            PageStatus.playingFadesAt(date(13, 30)).text(localized: localized, time: spain, locale: locale),
            "Sonando · se funde a las 13:30"
        )
        XCTAssertEqual(
            PageStatus.playingUntil(date(1, 0)).text(localized: localized, time: spain, locale: locale),
            "Sonando · hasta la 1:00"
        )
        XCTAssertEqual(
            PageStatus.playingUntil(date(7, 0)).text(localized: localized, time: spain, locale: locale),
            "Sonando · hasta las 7:00"
        )
        XCTAssertTrue(
            PageStatus.playingFadesAt(date(13, 30)).text(localized: localized, time: twelve, locale: locale)
                .hasPrefix("Sonando · se funde a la 1:30")
        )

        // Night.
        XCTAssertEqual(
            NightStatus.fadesAt(date(1, 30)).text(localized: localized, time: spain, locale: locale),
            "Se funde a la 1:30"
        )
        XCTAssertEqual(
            NightStatus.until(date(1, 0)).text(localized: localized, time: spain, locale: locale), "hasta la 1:00"
        )
        XCTAssertEqual(
            NightStatus.ended(at: date(1, 42)).text(localized: localized, time: spain, locale: locale),
            "Terminó a la 1:42"
        )
        XCTAssertEqual(
            NightStatus.ended(at: date(3, 42)).text(localized: localized, time: spain, locale: locale),
            "Terminó a las 3:42"
        )

        // The timer.
        XCTAssertEqual(
            TimerSheetText.line(.counting(minutes: 45, endsAt: date(1, 30)), localized: localized, time: spain, locale: locale),
            "Se funde a la 1:30"
        )
        XCTAssertEqual(
            TimerSheetText.line(.pausedBlanket(endsAt: date(1, 0)), localized: localized, time: spain, locale: locale),
            "Hasta la 1:00"
        )
        XCTAssertTrue(
            TimerSheetText.blanketDetail(hour: date(1, 0), localized: localized, time: spain, locale: locale)
                .hasPrefix("hasta la 1:00 · ")
        )
        XCTAssertTrue(
            TimerSheetText.blanketDetail(hour: date(7, 0), localized: localized, time: spain, locale: locale)
                .hasPrefix("hasta las 7:00 · ")
        )

        // The tide.
        XCTAssertEqual(
            TideSheetText.recedes(status: .guiding(rate: 6), at: date(1, 27), localized: localized, time: spain),
            "Se retira a la 1:27"
        )
        XCTAssertEqual(
            TideSheetText.recedes(status: .guiding(rate: 6), at: date(23, 27), localized: localized, time: spain),
            "Se retira a las 23:27"
        )
    }
}
