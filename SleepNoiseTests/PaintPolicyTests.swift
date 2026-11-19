import XCTest
@testable import SleepNoise

/// The one rule of the house paint (exploration 12 §3): by day, off the
/// night page, with the accessibility switches off. Everything else is the
/// row without paint.
final class PaintPolicyTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Madrid")!
        return calendar
    }()

    private func at(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 19, hour: hour, minute: minute))!
    }

    private func shows(
        _ date: Date, nightSession: Bool = false, reduceTransparency: Bool = false, increaseContrast: Bool = false
    ) -> Bool {
        PaintPolicy.showsHousePaint(
            now: date,
            nightSession: nightSession,
            reduceTransparency: reduceTransparency,
            increaseContrast: increaseContrast,
            calendar: calendar
        )
    }

    func testByDayWithNothingOnThePaintShows() {
        XCTAssertTrue(shows(at(7)))
        XCTAssertTrue(shows(at(12)))
        XCTAssertTrue(shows(at(18, 42)))
        XCTAssertTrue(shows(at(20, 59)))
    }

    /// The same border as the sale (C08, `NightWindow`): 21:00 is in,
    /// 07:00 is out.
    func testInsideTheNightWindowNothingLightsTheRoom() {
        XCTAssertFalse(shows(at(21)))
        XCTAssertFalse(shows(at(21, 30)))
        XCTAssertFalse(shows(at(23, 59)))
        XCTAssertFalse(shows(at(0)))
        XCTAssertFalse(shows(at(3, 7)))
        XCTAssertFalse(shows(at(6, 59)))
    }

    /// The night page is one ink whatever the hour (C40).
    func testTheNightPageNeverPaints() {
        XCTAssertFalse(shows(at(12), nightSession: true))
        XCTAssertFalse(shows(at(2), nightSession: true))
    }

    func testReduceTransparencyAndIncreaseContrastTurnThePaintOff() {
        XCTAssertFalse(shows(at(12), reduceTransparency: true))
        XCTAssertFalse(shows(at(12), increaseContrast: true))
        XCTAssertFalse(shows(at(12), reduceTransparency: true, increaseContrast: true))
    }

    /// The rule reads the window through `NightWindow`, so moving the one
    /// constant moves both.
    func testTheRuleFollowsNightWindow() {
        for hour in 0..<24 {
            let date = at(hour, 30)
            XCTAssertEqual(shows(date), !NightWindow.contains(date, calendar: calendar), "\(hour):30")
        }
    }

    /// The text of a painted row starts 20 pt from the band, as the mock-up
    /// lays it: 84 pt from the edge.
    func testThePaintedRowKeepsTheMarginBetweenBandAndText() {
        XCTAssertEqual(HousePaint.textGap, Grid.margin)
        XCTAssertEqual(HousePaint.textLeading, 84)
    }

    /// The staged captures of the paint sit where the rule needs them: the
    /// evening one inside the window on the day page, the rest by day.
    @MainActor
    func testTheStagedPaintStatesSitOnTheRightSideOfTheRule() {
        XCTAssertTrue(NightWindow.contains(PageStage.clock(for: .mixesPaintEvening)))
        XCTAssertFalse(PageDebugState.mixesPaintEvening.isNight)
        for state in [PageDebugState.mixesPaint, .mixesPaintContrast, .mixesPaintAX3, .mixesPaintAX5, .storeMixes] {
            XCTAssertFalse(NightWindow.contains(PageStage.clock(for: state)), "\(state)")
            XCTAssertFalse(state.isNight, "\(state)")
            XCTAssertTrue(state.opensMixes, "\(state)")
        }
    }
}
