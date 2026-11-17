import XCTest
@testable import SleepNoise

/// What happens when an interruption ends. Every date is built on a fixed
/// calendar; nothing reads the clock or the time zone of the machine.
final class InterruptionPolicyTests: XCTestCase {
    private func calendar(_ zone: String = "Europe/Madrid") throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: zone))
        return calendar
    }

    /// A wall-clock time on 18 November 2026 (or the given day), in `calendar`.
    private func at(
        _ hour: Int, _ minute: Int, _ second: Int = 0,
        day: Int = 18, month: Int = 11,
        in calendar: Calendar
    ) throws -> Date {
        let parts = DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute, second: second)
        return try XCTUnwrap(calendar.date(from: parts))
    }

    private let resume = InterruptionOutcome.resume(fadeIn: 3)

    func testMorningWindowHours() throws {
        let madrid = try calendar()
        for hour in 0..<24 {
            let inside = (5...10).contains(hour)
            XCTAssertEqual(MorningWindow.contains(try at(hour, 0, in: madrid), calendar: madrid), inside, "\(hour):00")
            XCTAssertEqual(MorningWindow.contains(try at(hour, 59, 59, in: madrid), calendar: madrid), inside, "\(hour):59")
        }
        XCTAssertEqual(MorningWindow.startHour, 5)
        XCTAssertEqual(MorningWindow.endHour, 11)
        XCTAssertEqual(InterruptionPolicy.resumeFadeIn, 3)
        XCTAssertEqual(InterruptionPolicy.longestPause, 20 * 60)
    }

    func testMorningWindowUsesTheGivenCalendar() throws {
        // 05:30 UTC is inside the window in UTC, and the evening before in
        // Los Angeles.
        let utc = try calendar("UTC")
        let instant = try at(5, 30, in: utc)
        XCTAssertTrue(MorningWindow.contains(instant, calendar: utc))
        XCTAssertFalse(MorningWindow.contains(instant, calendar: try calendar("America/Los_Angeles")))

        let call = Interruption(
            kind: .call, beganAt: instant, endedAt: instant.addingTimeInterval(60), wasPlaying: true, fixedEnd: nil
        )
        XCTAssertEqual(InterruptionPolicy.outcome(of: call, calendar: utc), .endSession)
        XCTAssertEqual(InterruptionPolicy.outcome(of: call, calendar: try calendar("America/Los_Angeles")), resume)
    }

    func testWithAFixedEndTheWindowOpensOneHourBeforeIt() throws {
        let madrid = try calendar()
        let cases: [(end: (Int, Int), time: (Int, Int, Int), inside: Bool)] = [
            // Night set to end at 07:00: the window opens at 06:00.
            ((7, 0), (5, 30, 0), false),
            ((7, 0), (5, 59, 59), false),
            ((7, 0), (6, 0, 0), true),
            ((7, 0), (6, 59, 0), true),
            ((7, 0), (7, 30, 0), true),
            // An early shift: 04:30 moves the window to 03:30.
            ((4, 30), (3, 29, 59), false),
            ((4, 30), (3, 30, 0), true),
            // Someone who sleeps until 13:00 is still asleep at 08:00.
            ((13, 0), (8, 0, 0), false),
            ((13, 0), (10, 59, 0), false),
            ((13, 0), (12, 0, 0), true),
        ]
        for (end, time, inside) in cases {
            let fixedEnd = try at(end.0, end.1, in: madrid)
            let date = try at(time.0, time.1, time.2, in: madrid)
            XCTAssertEqual(
                MorningWindow.contains(date, fixedEnd: fixedEnd, calendar: madrid), inside,
                "end \(end), at \(time)"
            )
        }
        XCTAssertEqual(MorningWindow.leadBeforeFixedEnd, 3_600)
    }

    func testOutcomeTable() throws {
        struct Row {
            let name: String
            let kind: InterruptionKind
            let from: (Int, Int, Int)
            let to: (Int, Int, Int)
            var wasPlaying = true
            var fixedEnd: (Int, Int)?
            let expected: InterruptionOutcome
        }
        let rows = [
            // Outside the morning window everything resumes with a 3 s fade.
            Row(name: "Siri at three", kind: .system, from: (3, 0, 0), to: (3, 2, 0), expected: resume),
            Row(name: "short call at three", kind: .call, from: (3, 0, 0), to: (3, 4, 0), expected: resume),
            Row(name: "evening call", kind: .call, from: (23, 10, 0), to: (23, 12, 0), expected: resume),
            Row(name: "midday", kind: .system, from: (14, 0, 0), to: (14, 1, 0), expected: resume),

            // A call never ends the night, however long. Anything else that
            // kept it paused for twenty minutes has ended it.
            Row(name: "long call", kind: .call, from: (1, 0, 0), to: (2, 45, 0), expected: resume),
            Row(name: "19:59 of another app", kind: .system, from: (1, 0, 0), to: (1, 19, 59), expected: resume),
            Row(name: "20:00 of another app", kind: .system, from: (1, 0, 0), to: (1, 20, 0), expected: .endSession),
            Row(name: "an hour of another app", kind: .system, from: (1, 0, 0), to: (2, 0, 0), expected: .endSession),

            // Inside the window nothing resumes: it may be the alarm.
            Row(name: "the alarm", kind: .system, from: (6, 45, 0), to: (6, 46, 0), expected: .endSession),
            Row(name: "a call in the morning", kind: .call, from: (6, 45, 0), to: (6, 50, 0), expected: .endSession),
            Row(name: "late morning", kind: .system, from: (10, 59, 0), to: (10, 59, 30), expected: .endSession),

            // Edges: 05:00 is inside, 11:00 is not.
            Row(name: "ends before five", kind: .system, from: (4, 59, 0), to: (4, 59, 59), expected: resume),
            Row(name: "ends at five", kind: .system, from: (4, 59, 30), to: (5, 0, 0), expected: .endSession),
            Row(name: "begins at five", kind: .system, from: (5, 0, 0), to: (5, 0, 20), expected: .endSession),
            Row(name: "begins at eleven", kind: .system, from: (11, 0, 0), to: (11, 1, 0), expected: resume),
            Row(name: "begins before eleven", kind: .call, from: (10, 59, 50), to: (11, 5, 0), expected: .endSession),
            Row(name: "crosses five", kind: .call, from: (4, 50, 0), to: (5, 10, 0), expected: .endSession),
            Row(name: "covers the whole morning", kind: .call, from: (4, 0, 0), to: (11, 30, 0), expected: .endSession),

            // A lost output never resumes from here.
            Row(name: "AirPods out at two", kind: .routeDisconnected, from: (2, 0, 0), to: (2, 1, 0), expected: .stayPaused),
            Row(name: "AirPods out for half an hour", kind: .routeDisconnected, from: (2, 0, 0), to: (2, 30, 0),
                expected: .endSession),
            Row(name: "AirPods out in the morning", kind: .routeDisconnected, from: (6, 30, 0), to: (6, 31, 0),
                expected: .endSession),

            // A night that was already paused is left alone.
            Row(name: "paused before, at three", kind: .call, from: (3, 0, 0), to: (3, 5, 0), wasPlaying: false,
                expected: .stayPaused),
            Row(name: "paused before, the alarm", kind: .system, from: (6, 45, 0), to: (6, 46, 0), wasPlaying: false,
                expected: .stayPaused),

            // With a fixed end the window is the hour before it, and only that.
            Row(name: "07:00 night, 05:30", kind: .system, from: (5, 30, 0), to: (5, 31, 0), fixedEnd: (7, 0),
                expected: resume),
            Row(name: "07:00 night, 05:59", kind: .system, from: (5, 59, 0), to: (5, 59, 59), fixedEnd: (7, 0),
                expected: resume),
            Row(name: "07:00 night, crosses 06:00", kind: .system, from: (5, 59, 0), to: (6, 0, 0), fixedEnd: (7, 0),
                expected: .endSession),
            Row(name: "07:00 night, the alarm", kind: .system, from: (6, 45, 0), to: (6, 46, 0), fixedEnd: (7, 0),
                expected: .endSession),
            Row(name: "07:00 night, a call at 06:30", kind: .call, from: (6, 30, 0), to: (6, 33, 0), fixedEnd: (7, 0),
                expected: .endSession),
            Row(name: "07:00 night, a call at three", kind: .call, from: (3, 0, 0), to: (3, 30, 0), fixedEnd: (7, 0),
                expected: resume),
            Row(name: "13:00 night, 08:00", kind: .system, from: (8, 0, 0), to: (8, 1, 0), fixedEnd: (13, 0),
                expected: resume),
            Row(name: "13:00 night, 12:05", kind: .system, from: (12, 5, 0), to: (12, 6, 0), fixedEnd: (13, 0),
                expected: .endSession),
            Row(name: "04:30 night, 03:40", kind: .system, from: (3, 40, 0), to: (3, 41, 0), fixedEnd: (4, 30),
                expected: .endSession),
            Row(name: "04:30 night, 03:00", kind: .system, from: (3, 0, 0), to: (3, 5, 0), fixedEnd: (4, 30),
                expected: resume),
        ]
        let madrid = try calendar()
        for row in rows {
            let interruption = Interruption(
                kind: row.kind,
                beganAt: try at(row.from.0, row.from.1, row.from.2, in: madrid),
                endedAt: try at(row.to.0, row.to.1, row.to.2, in: madrid),
                wasPlaying: row.wasPlaying,
                fixedEnd: try row.fixedEnd.map { try at($0.0, $0.1, in: madrid) }
            )
            XCTAssertEqual(InterruptionPolicy.outcome(of: interruption, calendar: madrid), row.expected, row.name)
        }
    }

    /// Whatever the kind, the hour or the length: inside the window nothing
    /// resumes, and a lost output or a night that was paused never does.
    func testNothingResumesInTheMorningAndALostOutputNeverDoes() throws {
        let madrid = try calendar()
        let midnight = try at(0, 0, in: madrid)
        for kind in InterruptionKind.allCases {
            for wasPlaying in [true, false] {
                for startMinute in stride(from: 0, to: 24 * 60, by: 7) {
                    for length in [5, 90, 19 * 60, 45 * 60] as [TimeInterval] {
                        let began = midnight.addingTimeInterval(Double(startMinute) * 60)
                        let ended = began.addingTimeInterval(length)
                        let outcome = InterruptionPolicy.outcome(
                            of: Interruption(kind: kind, beganAt: began, endedAt: ended, wasPlaying: wasPlaying, fixedEnd: nil),
                            calendar: madrid
                        )
                        let label = "\(kind) at minute \(startMinute) for \(length) s, playing \(wasPlaying)"
                        let morning = MorningWindow.contains(began, calendar: madrid)
                            || MorningWindow.contains(ended, calendar: madrid)
                        if morning || kind == .routeDisconnected || !wasPlaying {
                            XCTAssertNotEqual(outcome, resume, label)
                        }
                        if !wasPlaying {
                            XCTAssertEqual(outcome, .stayPaused, label)
                        } else if morning {
                            XCTAssertEqual(outcome, .endSession, label)
                        } else if kind == .call {
                            XCTAssertEqual(outcome, resume, label)
                        }
                    }
                }
            }
        }
    }

    func testClockChangeNights() throws {
        // 29 March and 25 October 2026 in Madrid: the night is an hour
        // shorter or longer, the window is still five to eleven on the wall.
        let madrid = try calendar()
        for (month, day) in [(3, 29), (10, 25)] {
            let edges: [(Int, Int, InterruptionOutcome)] = [
                (4, 30, resume), (5, 0, .endSession), (10, 59, .endSession), (11, 0, resume),
            ]
            for (hour, minute, expected) in edges {
                let began = try at(hour, minute, day: day, month: month, in: madrid)
                let outcome = InterruptionPolicy.outcome(
                    of: Interruption(
                        kind: .system, beganAt: began, endedAt: began.addingTimeInterval(30), wasPlaying: true, fixedEnd: nil
                    ),
                    calendar: madrid
                )
                XCTAssertEqual(outcome, expected, "\(day)/\(month) \(hour):\(minute)")
            }
            // Walk the night minute by minute from 00:30: nothing before 05:00
            // on the wall clock is inside, on either night.
            let base = try at(0, 30, day: day, month: month, in: madrid)
            for minute in 0..<360 {
                let date = base.addingTimeInterval(Double(minute) * 60)
                let hour = madrid.component(.hour, from: date)
                XCTAssertEqual(MorningWindow.contains(date, calendar: madrid), hour >= 5, "\(day)/\(month) +\(minute) min")
            }
        }
    }

    func testAnInterruptionThatEndsBeforeItBeganIsStillJudgedByTheClock() throws {
        // The clock was set back meanwhile: no negative length, same window.
        let madrid = try calendar()
        let backwards = Interruption(
            kind: .system, beganAt: try at(3, 30, in: madrid), endedAt: try at(3, 0, in: madrid), wasPlaying: true, fixedEnd: nil
        )
        XCTAssertEqual(backwards.duration, 0)
        XCTAssertEqual(InterruptionPolicy.outcome(of: backwards, calendar: madrid), resume)
        XCTAssertTrue(MorningWindow.touches(from: try at(5, 10, in: madrid), to: try at(4, 50, in: madrid), calendar: madrid))
    }

    // MARK: Tracker

    func testTrackerReadsTheInjectedClock() throws {
        let madrid = try calendar()
        var clock = try at(3, 0, in: madrid)
        var tracker = InterruptionTracker(calendar: madrid, now: { clock })

        XCTAssertFalse(tracker.isOpen)
        XCTAssertEqual(tracker.ended(), .stayPaused, "an end with nothing open changes nothing")

        tracker.began(.system, wasPlaying: true)
        XCTAssertTrue(tracker.isOpen)
        XCTAssertEqual(tracker.beganAt, clock)
        clock = try at(3, 2, in: madrid)
        XCTAssertEqual(tracker.ended(), resume)
        XCTAssertFalse(tracker.isOpen)
        XCTAssertEqual(tracker.ended(), .stayPaused, "it resolves once")

        // The same two minutes at a quarter to seven end the night.
        clock = try at(6, 45, in: madrid)
        tracker.began(.system, wasPlaying: true)
        clock = try at(6, 47, in: madrid)
        XCTAssertEqual(tracker.ended(), .endSession)

        // Half past five resumes when the night is set to end at 07:00...
        clock = try at(5, 30, in: madrid)
        tracker.began(.system, wasPlaying: true)
        clock = try at(5, 31, in: madrid)
        XCTAssertEqual(tracker.ended(fixedEnd: try at(7, 0, in: madrid)), resume)
        // ...and ends it when there is no fixed end.
        clock = try at(5, 30, in: madrid)
        tracker.began(.system, wasPlaying: true)
        clock = try at(5, 31, in: madrid)
        XCTAssertEqual(tracker.ended(), .endSession)

        // A night that was paused before stays paused.
        clock = try at(3, 0, in: madrid)
        tracker.began(.call, wasPlaying: false)
        clock = try at(3, 1, in: madrid)
        XCTAssertEqual(tracker.ended(), .stayPaused)
    }

    func testTrackerLearnsTheKindLate() throws {
        let madrid = try calendar()
        var clock = try at(1, 0, in: madrid)
        var tracker = InterruptionTracker(calendar: madrid, now: { clock })

        // The call observer speaks after `.began`: forty minutes of "system"
        // would end the night, forty minutes of call do not.
        tracker.began(.system, wasPlaying: true)
        tracker.note(.call)
        XCTAssertEqual(tracker.kind, .call)
        clock = try at(1, 40, in: madrid)
        XCTAssertEqual(tracker.ended(), resume)

        // A second `.began` keeps the first start.
        clock = try at(1, 0, in: madrid)
        tracker.began(.system, wasPlaying: true)
        clock = try at(1, 15, in: madrid)
        tracker.began(.system, wasPlaying: false)
        XCTAssertEqual(tracker.beganAt, try at(1, 0, in: madrid))
        clock = try at(1, 21, in: madrid)
        XCTAssertEqual(tracker.ended(), .endSession, "twenty-one minutes from the first start")

        // The output going away during a call outranks the call: it must
        // not come back by itself.
        clock = try at(2, 0, in: madrid)
        tracker.began(.call, wasPlaying: true)
        tracker.note(.routeDisconnected)
        tracker.note(.call)
        tracker.note(.system)
        XCTAssertEqual(tracker.kind, .routeDisconnected)
        clock = try at(2, 5, in: madrid)
        XCTAssertEqual(tracker.ended(), .stayPaused)

        tracker.note(.call)
        XCTAssertNil(tracker.kind, "nothing to note with nothing open")
    }
}
