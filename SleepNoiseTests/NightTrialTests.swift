import XCTest
@testable import SleepNoise

/// A storage that can lose a read or refuse a write, over a real one.
final class FaultyTrialStorage: TrialStorage {
    let inner: InMemoryTrialStorage
    var failsToRead = false
    var failsToWrite = false

    init(inner: InMemoryTrialStorage = InMemoryTrialStorage()) {
        self.inner = inner
    }

    func loadTrial() -> TrialRecord? {
        failsToRead ? nil : inner.loadTrial()
    }

    func createTrial(_ record: TrialRecord) -> Bool {
        failsToWrite ? false : inner.createTrial(record)
    }

    @discardableResult
    func saveTrial(_ record: TrialRecord) -> Bool {
        failsToWrite ? false : inner.saveTrial(record)
    }
}

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

    /// Day 0: 16-11-2026 20:00 in Europe/Madrid, outside `NightWindow`. The
    /// trial is never offered at night, so it cannot start later than this.
    private func day0() throws -> Date {
        try november(16, 20, 0)
    }

    // Red if Play (a session start) begins the trial or writes a record.
    func testNotStartedGrantsNothing() throws {
        let storage = InMemoryTrialStorage()
        var trial = NightTrial(storage: storage)
        XCTAssertEqual(trial.status, .notStarted)
        XCTAssertFalse(trial.grantsFullAccess)
        XCTAssertFalse(trial.evaluateAtSessionStart(now: try day0()))
        trial.observe(now: try day0())
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

    // Red if `start` grants access without a stored record, or writes a
    // fresh record over one it could not read (a second trial).
    func testStartGrantsNothingWhenTheRecordCannotBeCreated() throws {
        let start = try day0()

        let readOnly = FaultyTrialStorage()
        readOnly.failsToWrite = true
        var unsaved = NightTrial(storage: readOnly)
        XCTAssertFalse(unsaved.start(now: start))
        XCTAssertEqual(unsaved.status, .notStarted)
        XCTAssertFalse(unsaved.grantsFullAccess)
        XCTAssertNil(unsaved.record)

        // A trial that ended is in the storage, but this launch cannot read it.
        let spent = TrialRecord(startedAt: start, lastSeen: start, consumed: 8 * day)
        let unreadable = FaultyTrialStorage(inner: InMemoryTrialStorage(record: spent))
        unreadable.failsToRead = true
        var second = NightTrial(storage: unreadable)
        XCTAssertEqual(second.status, .notStarted)
        XCTAssertFalse(second.start(now: start.addingTimeInterval(30 * day)))
        XCTAssertFalse(second.grantsFullAccess)
        XCTAssertEqual(unreadable.inner.record, spent)
        XCTAssertEqual(unreadable.inner.saveCount, 0)
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

    // Red if `observe` stops counting, stops saving or changes the answer
    // before the next session start. The first half writes down the limit
    // that is left without it: a clock wound back before every Play.
    func testObserveCountsBetweenSessionsWithoutChangingTheAnswer() throws {
        let start = try day0()
        let hour: TimeInterval = 3_600
        let storage = InMemoryTrialStorage()
        var trial = NightTrial(storage: storage)
        trial.start(now: start)

        // Known limit: the same wrong moment at every session start.
        for _ in 0..<3 {
            XCTAssertTrue(trial.evaluateAtSessionStart(now: start.addingTimeInterval(hour)))
        }
        XCTAssertEqual(try XCTUnwrap(trial.record).consumed, hour, accuracy: 0.001)

        // The real clock, seen once at launch or in the foreground, counts.
        trial.observe(now: start.addingTimeInterval(8 * day))
        XCTAssertEqual(try XCTUnwrap(storage.record).consumed, 8 * day, accuracy: 0.001)
        XCTAssertTrue(trial.grantsFullAccess)
        XCTAssertEqual(trial.status, .active)

        // Once the real clock has been seen, winding it back before Play
        // no longer helps. Winding it back before the app is opened still
        // does: the limit is written in `NightTrial` and in ESTADO.md.
        XCTAssertFalse(trial.evaluateAtSessionStart(now: start.addingTimeInterval(hour)))
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

    // Red if the figure counts 24 h blocks, drops at midnight in the middle
    // of a night, counts a night the trial does not reach, or ignores time
    // not yet evaluated. The start is by day: the trial is never offered
    // inside `NightWindow`.
    func testNightsRemainingCountsTheNightsThatAreLeft() throws {
        let calendar = try madrid()
        var trial = NightTrial(storage: InMemoryTrialStorage())
        trial.start(now: try november(16, 20, 0))

        XCTAssertEqual(trial.nightsRemaining(now: try november(16, 20, 0), calendar: calendar), 7)
        XCTAssertEqual(trial.nightsRemaining(now: try november(16, 23, 0), calendar: calendar), 7)
        // Still the first night: the figure does not change at midnight.
        XCTAssertEqual(trial.nightsRemaining(now: try november(17, 0, 30), calendar: calendar), 7)
        XCTAssertEqual(trial.nightsRemaining(now: try november(17, 6, 59), calendar: calendar), 7)
        // It changes in the morning, when that night is over.
        XCTAssertEqual(trial.nightsRemaining(now: try november(17, 7, 0), calendar: calendar), 6)
        XCTAssertEqual(trial.nightsRemaining(now: try november(17, 23, 30), calendar: calendar), 6)
        XCTAssertEqual(trial.nightsRemaining(now: try november(18, 1, 0), calendar: calendar), 6)
        XCTAssertEqual(trial.nightsRemaining(now: try november(22, 12, 0), calendar: calendar), 1)
        XCTAssertEqual(trial.nightsRemaining(now: try november(22, 23, 30), calendar: calendar), 1)
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 3, 0), calendar: calendar), 1)
    }

    // Red if the day the trial runs out still reads "last night" (08 §9.3):
    // that night a session start finds the trial over. The figure is 0 and
    // the trial is still active until its hour.
    func testNoNightIsLeftOnTheDayTheTrialRunsOut() throws {
        let calendar = try madrid()
        var trial = NightTrial(storage: InMemoryTrialStorage())
        trial.start(now: try november(16, 12, 0))

        XCTAssertEqual(trial.nightsRemaining(now: try november(16, 12, 0), calendar: calendar), 7)
        XCTAssertEqual(trial.nightsRemaining(now: try november(22, 23, 0), calendar: calendar), 1)
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 3, 0), calendar: calendar), 1)

        // The last day, before its hour: active, and no night left.
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 9, 0), calendar: calendar), 0)
        XCTAssertTrue(trial.evaluateAtSessionStart(now: try november(23, 9, 0)))
        XCTAssertEqual(trial.status, .active)
        // Past its hour and not evaluated yet, by day and at night.
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 20, 0), calendar: calendar), 0)
        XCTAssertEqual(trial.nightsRemaining(now: try november(23, 23, 0), calendar: calendar), 0)
        XCTAssertEqual(trial.status, .active)

        XCTAssertFalse(trial.evaluateAtSessionStart(now: try november(23, 23, 0)))
        XCTAssertNil(trial.nightsRemaining(now: try november(23, 23, 0), calendar: calendar))
    }

    // Red if the figure can promise more than the seven nights, or if the
    // hour that the clocks go back adds or removes a night.
    func testTheFigureNeverPassesSevenAndFollowsTheLocalClock() throws {
        let calendar = try madrid()
        // A start inside the night, which the app never allows: eight
        // nights begin before it ends, and the figure still says seven.
        var late = NightTrial(storage: InMemoryTrialStorage())
        late.start(now: try november(16, 23, 0))
        XCTAssertEqual(late.nightsRemaining(now: try november(16, 23, 0), calendar: calendar), 7)

        // Across the end of summer time (25-10-2026 in Madrid): seven times
        // 86 400 s end one hour earlier by the local clock.
        func october(_ day: Int, _ hour: Int) throws -> Date {
            try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour)))
        }
        var autumn = NightTrial(storage: InMemoryTrialStorage())
        autumn.start(now: try october(20, 12))
        XCTAssertEqual(autumn.nightsRemaining(now: try october(20, 12), calendar: calendar), 7)
        XCTAssertEqual(autumn.nightsRemaining(now: try october(26, 12), calendar: calendar), 1)
        XCTAssertEqual(autumn.nightsRemaining(now: try october(27, 8), calendar: calendar), 0)
        XCTAssertFalse(autumn.evaluateAtSessionStart(now: try october(27, 11)))
    }

    // Red if a read that failed at launch leaves a running trial on the
    // free tier for good, or if asking again can hand out a second trial.
    func testAReadThatFailedIsAskedAgain() throws {
        let start = try day0()
        let storage = FaultyTrialStorage()
        var first = NightTrial(storage: storage)
        XCTAssertTrue(first.start(now: start))

        storage.failsToRead = true
        var trial = NightTrial(storage: storage)
        XCTAssertEqual(trial.status, .notStarted)
        XCTAssertFalse(trial.reloadIfMissing(), "still unreadable")
        XCTAssertFalse(trial.start(now: start.addingTimeInterval(day)), "the record is there: no second trial")
        XCTAssertEqual(storage.inner.record?.startedAt, start)

        storage.failsToRead = false
        XCTAssertTrue(trial.reloadIfMissing())
        XCTAssertEqual(trial.status, .active)
        XCTAssertTrue(trial.grantsFullAccess)
        XCTAssertFalse(trial.reloadIfMissing(), "nothing to ask once it is read")
    }
}
