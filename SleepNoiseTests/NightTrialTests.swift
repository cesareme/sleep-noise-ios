import XCTest
@testable import SleepNoise

final class NightTrialTests: XCTestCase {
    private let day: TimeInterval = 86_400

    private func madrid() throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Madrid"))
        return calendar
    }

    /// A moment in November 2026, Europe/Madrid.
    private func november(_ dayOfMonth: Int, _ hour: Int, _ minute: Int) throws -> Date {
        let components = DateComponents(year: 2026, month: 11, day: dayOfMonth, hour: hour, minute: minute)
        return try XCTUnwrap(try madrid().date(from: components))
    }

    /// Day 0: 16-11-2026 23:00 in Europe/Madrid.
    private func day0() throws -> Date {
        try november(16, 23, 0)
    }

    // Red if Play (a session start) begins the trial or writes a record.
    func testNotStartedGrantsNothing() throws {
        let storage = InMemoryTrialStorage()
        var trial = NightTrial(storage: storage)
        XCTAssertEqual(trial.status, .notStarted)
        XCTAssertFalse(trial.grantsFullAccess)
        XCTAssertFalse(trial.evaluateAtSessionStart(now: try day0()))
        XCTAssertEqual(storage.saveCount, 0)
        XCTAssertNil(storage.record)
        XCTAssertNil(trial.nightsRemaining(now: try day0(), calendar: try madrid()))
    }

    // Red if a second `start` overwrites the record or restarts the count.
    func testStartIsExplicitAndHappensOnce() throws {
        let storage = InMemoryTrialStorage()
        var trial = NightTrial(storage: storage)
        let start = try day0()
        XCTAssertTrue(trial.start(now: start))
        XCTAssertEqual(storage.saveCount, 1)
        XCTAssertEqual(trial.status, .active)
        XCTAssertTrue(trial.grantsFullAccess)
        XCTAssertEqual(trial.record, TrialRecord(startedAt: start, lastSeen: start, consumed: 0))

        XCTAssertFalse(trial.start(now: start.addingTimeInterval(day)))
        XCTAssertEqual(storage.saveCount, 1)
        XCTAssertEqual(trial.record?.startedAt, start)
        XCTAssertEqual(storage.record?.startedAt, start)
    }

    // Red if the length is not exactly 7 × 86 400 s or the comparison is `<=`.
    func testEndsAfterSevenTimesTwentyFourHours() throws {
        let start = try day0()
        var lastSecond = NightTrial(storage: InMemoryTrialStorage())
        lastSecond.start(now: start)
        XCTAssertTrue(lastSecond.evaluateAtSessionStart(now: start.addingTimeInterval(7 * day - 1)))
        XCTAssertEqual(lastSecond.status, .active)

        var over = NightTrial(storage: InMemoryTrialStorage())
        over.start(now: start)
        XCTAssertFalse(over.evaluateAtSessionStart(now: start.addingTimeInterval(7 * day)))
        XCTAssertEqual(over.status, .ended)
        XCTAssertFalse(over.grantsFullAccess)
    }

    // Red if anything other than a session start (a read, a status query)
    // ends the trial while sound may be playing.
    func testNothingChangesBetweenSessionStarts() throws {
        let start = try day0()
        let storage = InMemoryTrialStorage()
        var trial = NightTrial(storage: storage)
        trial.start(now: start)
        XCTAssertTrue(trial.evaluateAtSessionStart(now: start.addingTimeInterval(6 * day)))
        let saves = storage.saveCount

        // Day 8 arrives with the sound still on: reading does not evaluate.
        let later = start.addingTimeInterval(8 * day)
        XCTAssertNotNil(trial.nightsRemaining(now: later, calendar: try madrid()))
        XCTAssertTrue(trial.grantsFullAccess)
        XCTAssertEqual(trial.status, .active)
        XCTAssertEqual(storage.saveCount, saves)

        XCTAssertFalse(trial.evaluateAtSessionStart(now: later))
        XCTAssertFalse(trial.grantsFullAccess)
        XCTAssertEqual(trial.status, .ended)
    }

    // Red if winding the clock back subtracts from `consumed` or resets it.
    func testClockSetBackDoesNotExtendTheTrial() throws {
        let start = try day0()
        var trial = NightTrial(storage: InMemoryTrialStorage())
        trial.start(now: start)
        XCTAssertTrue(trial.evaluateAtSessionStart(now: start.addingTimeInterval(6 * day)))
        XCTAssertTrue(trial.evaluateAtSessionStart(now: start.addingTimeInterval(day)))
        XCTAssertEqual(try XCTUnwrap(trial.record).consumed, 6 * day, accuracy: 0.001)
        XCTAssertEqual(trial.record?.lastSeen, start.addingTimeInterval(day))
        XCTAssertFalse(trial.evaluateAtSessionStart(now: start.addingTimeInterval(2 * day + 1)))
        XCTAssertEqual(trial.status, .ended)
    }

    // Red if `start` accepts a trial that already ran out.
    func testEndedTrialDoesNotRestart() throws {
        let start = try day0()
        let storage = InMemoryTrialStorage()
        var trial = NightTrial(storage: storage)
        trial.start(now: start)
        trial.evaluateAtSessionStart(now: start.addingTimeInterval(8 * day))
        XCTAssertEqual(trial.status, .ended)
        let saves = storage.saveCount

        XCTAssertFalse(trial.start(now: start.addingTimeInterval(30 * day)))
        XCTAssertEqual(trial.status, .ended)
        XCTAssertFalse(trial.grantsFullAccess)
        XCTAssertEqual(trial.record?.startedAt, start)
        XCTAssertEqual(storage.saveCount, saves)
    }

    // Red if the state is kept in the struct only, or `init` forgets that a
    // stored trial has run out.
    func testStateSurvivesANewInstance() throws {
        let start = try day0()
        let storage = InMemoryTrialStorage()
        var first = NightTrial(storage: storage)
        first.start(now: start)
        first.evaluateAtSessionStart(now: start.addingTimeInterval(2 * day))

        var second = NightTrial(storage: storage)
        XCTAssertEqual(second.record, first.record)
        XCTAssertEqual(second.status, .active)
        XCTAssertTrue(second.grantsFullAccess)

        second.evaluateAtSessionStart(now: start.addingTimeInterval(9 * day))
        let third = NightTrial(storage: storage)
        XCTAssertEqual(third.status, .ended)
        XCTAssertFalse(third.grantsFullAccess)
    }

    // Red if the figure counts 24 h blocks instead of calendar nights, loses
    // the floor of 1, or ignores time not yet evaluated.
    func testNightsRemainingFollowsTheCalendar() throws {
        let calendar = try madrid()
        var trial = NightTrial(storage: InMemoryTrialStorage())
        trial.start(now: try day0())

        XCTAssertEqual(trial.nightsRemaining(now: try day0(), calendar: calendar), 7)
        XCTAssertEqual(trial.nightsRemaining(now: try november(17, 23, 30), calendar: calendar), 6)
        XCTAssertEqual(trial.nightsRemaining(now: try november(18, 1, 0), calendar: calendar), 5)
        XCTAssertEqual(trial.nightsRemaining(now: try november(22, 23, 30), calendar: calendar), 1)
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 22, 0), calendar: calendar), 1)
        // Past the end but not evaluated yet: still active, so still 1.
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 23, 30), calendar: calendar), 1)
        XCTAssertEqual(trial.status, .active)
    }
}
