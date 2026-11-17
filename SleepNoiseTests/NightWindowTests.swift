import XCTest
@testable import SleepNoise

final class NightWindowTests: XCTestCase {
    private func calendar(_ zone: String) throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: zone))
        return calendar
    }

    private func date(
        _ year: Int, _ month: Int, _ day: Int,
        _ hour: Int, _ minute: Int, _ second: Int = 0,
        in calendar: Calendar
    ) throws -> Date {
        let components = DateComponents(
            year: year, month: month, day: day, hour: hour, minute: minute, second: second
        )
        return try XCTUnwrap(calendar.date(from: components))
    }

    // Red if the next border is not the first 21:00 or 07:00 after the
    // moment, or if a border answers itself: whoever waits for it would
    // never wake, or would spin.
    func testNextBorderIsTheFirstEdgeAfterTheMoment() throws {
        let madrid = try calendar("Europe/Madrid")
        let cases: [((Int, Int, Int), (Int, Int))] = [
            ((17, 12, 0), (17, 21)),
            ((17, 20, 59), (17, 21)),
            ((17, 21, 0), (18, 7)),
            ((18, 3, 10), (18, 7)),
            ((18, 7, 0), (18, 21)),
        ]
        for (from, to) in cases {
            let moment = try date(2026, 11, from.0, from.1, from.2, in: madrid)
            let border = NightWindow.nextBorder(after: moment, calendar: madrid)
            XCTAssertEqual(border, try date(2026, 11, to.0, to.1, 0, in: madrid), "\(from)")
            XCTAssertGreaterThan(border, moment)
            XCTAssertNotEqual(
                NightWindow.contains(border, calendar: madrid),
                NightWindow.contains(border.addingTimeInterval(-1), calendar: madrid),
                "\(from): the window changes at the border"
            )
        }
    }

    // Red if either edge moves or flips: 21:00:00 must be inside, 07:00:00 outside.
    func testWindowEdges() throws {
        let madrid = try calendar("Europe/Madrid")
        let cases: [(Int, Int, Int, Bool)] = [
            (20, 59, 59, false),
            (21, 0, 0, true),
            (23, 59, 59, true),
            (0, 0, 0, true),
            (6, 59, 59, true),
            (7, 0, 0, false),
            (12, 0, 0, false)
        ]
        for (hour, minute, second, expected) in cases {
            let moment = try date(2026, 11, 16, hour, minute, second, in: madrid)
            XCTAssertEqual(
                NightWindow.contains(moment, calendar: madrid), expected,
                "\(hour):\(minute):\(second)"
            )
        }
    }

    // Red if `contains` ignores its calendar and reads another time zone.
    func testWindowUsesTheGivenCalendar() throws {
        let utc = try calendar("UTC")
        let moment = try date(2026, 11, 16, 20, 30, in: utc)
        XCTAssertTrue(NightWindow.contains(moment, calendar: try calendar("Europe/Madrid")))
        XCTAssertFalse(NightWindow.contains(moment, calendar: try calendar("America/Los_Angeles")))
        XCTAssertFalse(NightWindow.contains(moment, calendar: utc))
    }

    // Red if the window is computed from elapsed time instead of the local
    // hour: the skipped and the repeated hour must both stay inside, and
    // both edges must sit on the local clock of a 23 h and of a 25 h day.
    func testWindowOnClockChangeNights() throws {
        let madrid = try calendar("Europe/Madrid")
        let edges: [(Int, Int, Int, Bool)] = [
            (6, 59, 59, true),
            (7, 0, 0, false),
            (20, 59, 59, false),
            (21, 0, 0, true)
        ]
        for (month, day) in [(3, 29), (10, 25)] {
            let base = try date(2026, month, day, 0, 30, in: madrid)
            for minute in 0...240 {
                let moment = base.addingTimeInterval(TimeInterval(minute) * 60)
                XCTAssertTrue(
                    NightWindow.contains(moment, calendar: madrid),
                    "\(day)-\(month) +\(minute) min"
                )
            }
            for (hour, minute, second, expected) in edges {
                let moment = try date(2026, month, day, hour, minute, second, in: madrid)
                XCTAssertEqual(
                    NightWindow.contains(moment, calendar: madrid), expected,
                    "\(day)-\(month) \(hour):\(minute):\(second)"
                )
            }
        }
    }

    // Red if `isNight` reads the system clock instead of the closure.
    func testIsNightReadsTheInjectedClock() throws {
        let madrid = try calendar("Europe/Madrid")
        let night = try date(2026, 11, 16, 23, 0, in: madrid)
        let day = try date(2026, 11, 16, 12, 0, in: madrid)
        XCTAssertTrue(NightWindow.isNight(calendar: madrid, now: { night }))
        XCTAssertFalse(NightWindow.isNight(calendar: madrid, now: { day }))
    }
}
