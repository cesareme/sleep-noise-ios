import XCTest
@testable import SleepNoise

/// The arithmetic of the timer, as tables (C03, C22, C31).
final class TimerMathTests: XCTestCase {
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return utc.date(from: components) ?? Date(timeIntervalSinceReferenceDate: 0)
    }

    func testTheFinalFadeIsAQuarterOfTheNightUpToFifteenMinutes() {
        let rows: [(minutes: Double, fade: Double)] = [
            (1, 15), (10, 150), (20, 300), (30, 450),
            // C31: ten to fifteen minutes from forty minutes up.
            (40, 600), (45, 675), (50, 750), (60, 900), (90, 900), (360, 900), (600, 900),
        ]
        for row in rows {
            XCTAssertEqual(
                TimerMath.fadeDuration(totalSeconds: row.minutes * 60), row.fade, accuracy: 0.001,
                "\(row.minutes) min"
            )
        }
        XCTAssertEqual(TimerMath.longestFade, 900)
    }

    func testTheBlanketEndsAtTheNextTimeTheClockReadsItsHour() {
        let rows: [(start: Date, hour: Int, minute: Int, end: Date)] = [
            (time(23, 30), 7, 0, time(day: 18, 7)),
            (time(0, 10), 7, 0, time(7)),
            (time(6, 59), 7, 0, time(7)),
            // On the hour itself it is the next day's: a blanket of a whole day.
            (time(7), 7, 0, time(day: 18, 7)),
            (time(7, 5), 7, 0, time(day: 18, 7)),
            (time(22), 6, 45, time(day: 18, 6, 45)),
            (time(13), 13, 30, time(13, 30)),
        ]
        for row in rows {
            XCTAssertEqual(
                TimerMath.blanketEnd(after: row.start, hour: row.hour, minute: row.minute, calendar: utc),
                row.end,
                "from \(row.start) to \(row.hour):\(row.minute)"
            )
        }
    }

    func testTheBlanketDipIsSixDecibelsAfterFortyFiveMinutes() {
        XCTAssertEqual(TimerMath.blanketDipAfter, 45 * 60)
        XCTAssertEqual(TimerMath.blanketDipDecibels, -6)
        XCTAssertEqual(TimerMath.blanketDipGain, 0.501_187, accuracy: 0.000_01)
        XCTAssertEqual(TimerMath.blanketDipRamp, 60)
        XCTAssertEqual(TimerMath.extensionSeconds, 15 * 60)
    }

    func testFadingMinutesAreWholeAndNeverZero() {
        let rows: [(seconds: Double, minutes: Int)] = [
            (900, 15), (899.5, 15), (840.1, 15), (840, 14), (61, 2), (60, 1), (59, 1), (0.2, 1), (0, 1), (-4, 1),
        ]
        for row in rows {
            XCTAssertEqual(TimerMath.fadingMinutes(remaining: row.seconds), row.minutes, "\(row.seconds) s")
        }
    }

    func testFadeLevelFollowsTheCurveOfTheEngine() {
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 900, fade: 600), 1, "before the fade")
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 600, fade: 600), 1)
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 300, fade: 600), 0.5, accuracy: 0.000_1)
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 150, fade: 600), 0.156_25, accuracy: 0.000_1)
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 0, fade: 600), 0)
        XCTAssertEqual(TimerMath.fadeLevel(remaining: -3, fade: 600), 0)
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 10, fade: 0), 1, "no fade to be inside of")
        // The same curve the render state draws: what is heard after
        // `1 - remaining / fade` of a fade to silence.
        var ramp = SampleRamp(1)
        ramp.begin(to: 0, samples: 6_000)
        for _ in 0..<4_500 { ramp.advance() }
        XCTAssertEqual(TimerMath.fadeLevel(remaining: 150, fade: 600), ramp.value, accuracy: 0.000_1)
    }

    func testAChoiceKeepsItsFieldsInRange() {
        XCTAssertEqual(TimerChoice.firstUse.mode, .untilAsleep)
        XCTAssertEqual(TimerChoice.firstUse.minutes, 45)
        XCTAssertEqual(TimerChoice.firstUse.untilAsleepMinutes, 45)
        XCTAssertEqual(TimerChoice.untilAsleep(0).minutes, 1)
        XCTAssertEqual(TimerChoice.untilAsleep(9_999).minutes, AccessPolicy.maxTimerMinutes)
        XCTAssertEqual(TimerChoice.blanket(hour: 31, minute: 75).endHour, 23)
        XCTAssertEqual(TimerChoice.blanket(hour: 31, minute: 75).endMinute, 59)
        XCTAssertNil(TimerChoice.blanket(hour: 7).untilAsleepMinutes)
        XCTAssertNil(TimerChoice.off.untilAsleepMinutes)
        // Changing the mode keeps the length and the hour as they were left.
        let blanket = TimerChoice(mode: .blanket, minutes: 90, endHour: 6, endMinute: 30)
        let asleep = blanket.with(mode: .untilAsleep)
        XCTAssertEqual(asleep.minutes, 90)
        XCTAssertEqual(asleep.with(mode: .blanket), blanket)
        XCTAssertEqual(TimerMode.allCases, [.off, .untilAsleep, .blanket], "no nap in 1.0 (C30)")
    }

    func testAChoiceSurvivesItsOwnCoding() throws {
        for choice in [TimerChoice.firstUse, .off, .untilAsleep(360), .blanket(hour: 6, minute: 45)] {
            let data = try JSONEncoder().encode(choice)
            XCTAssertEqual(try JSONDecoder().decode(TimerChoice.self, from: data), choice)
        }
    }
}

/// The timer against a clock that the test moves (C03, C22, C31, C47).
@MainActor
final class SleepTimerControllerTests: XCTestCase {
    private final class Clock {
        var now: Date
        init(_ now: Date) { self.now = now }
    }

    /// What the timer asked for, in order.
    private final class Log {
        var fades: [TimeInterval] = []
        var cancelled = 0
        var dips: [(gain: Float, ramp: TimeInterval)] = []
        var completed = 0
    }

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = day
        components.hour = hour
        components.minute = minute
        return utc.date(from: components) ?? Date(timeIntervalSinceReferenceDate: 0)
    }

    private func make(_ choice: TimerChoice, at start: Date) -> (SleepTimerController, Clock, Log) {
        let clock = Clock(start)
        let log = Log()
        let timer = SleepTimerController(choice: choice, now: { clock.now }, calendar: utc, ticks: false)
        timer.onFade = { log.fades.append($0) }
        timer.onFadeCancelled = { log.cancelled += 1 }
        timer.onBlanketDip = { log.dips.append(($0, $1)) }
        timer.onComplete = { log.completed += 1 }
        return (timer, clock, log)
    }

    /// Moves the clock second by second, ticking as the run loop would.
    private func run(_ timer: SleepTimerController, _ clock: Clock, seconds: Int) {
        for _ in 0..<seconds {
            clock.now += 1
            timer.tick()
        }
    }

    // MARK: Until I sleep

    func testUntilAsleepCountsItsLengthAndFadesAtTheEnd() {
        let (timer, clock, log) = make(.untilAsleep(45), at: time(23))
        XCTAssertNil(timer.remaining)
        XCTAssertNil(timer.endsAt)
        XCTAssertFalse(timer.hasCount)
        XCTAssertEqual(timer.fadeLevel, 1)

        timer.start()
        XCTAssertEqual(timer.endsAt, time(23, 45), "the end is said as an hour")
        XCTAssertEqual(timer.remaining, 2_700)
        XCTAssertTrue(timer.hasCount)
        XCTAssertFalse(timer.isFading)
        XCTAssertNil(timer.fixedEnd, "only a blanket has a fixed end")

        // 45 minutes fade their last 11 min 15 s.
        run(timer, clock, seconds: 2_700 - 676)
        XCTAssertFalse(timer.isFading)
        XCTAssertEqual(log.fades, [])
        XCTAssertEqual(timer.fadeLevel, 1)
        run(timer, clock, seconds: 1)
        XCTAssertTrue(timer.isFading)
        XCTAssertEqual(log.fades, [675], "asked once, for exactly what is left")
        XCTAssertEqual(timer.fadingMinutes, 12)
        run(timer, clock, seconds: 15)
        XCTAssertEqual(timer.fadingMinutes, 11)

        run(timer, clock, seconds: 300)
        XCTAssertEqual(log.fades.count, 1, "the engine counts the fade; nobody asks again")
        XCTAssertEqual(timer.fadeLevel, TimerMath.fadeLevel(remaining: 360, fade: 675), accuracy: 0.000_1)

        run(timer, clock, seconds: 359)
        XCTAssertEqual(log.completed, 0)
        XCTAssertEqual(timer.fadingMinutes, 1, "never zero minutes")
        run(timer, clock, seconds: 1)
        XCTAssertEqual(log.completed, 1)
        XCTAssertNil(timer.remaining)
        XCTAssertNil(timer.endsAt)
        XCTAssertFalse(timer.isFading)
        XCTAssertNil(timer.fadingMinutes)
        XCTAssertFalse(timer.hasCount)
        XCTAssertEqual(timer.choice, .untilAsleep(45), "the choice outlives the night")
        // Nothing else was ever asked of the sound.
        XCTAssertEqual(log.dips.count, 0)
        XCTAssertEqual(log.cancelled, 0)
    }

    func testEveryLengthUpToTheCeilingRunsWhole() {
        for minutes in [1, 15, 45, 60, 90, AccessPolicy.maxTimerMinutes] {
            let (timer, clock, log) = make(.untilAsleep(minutes), at: time(22))
            timer.start()
            let fade = TimerMath.fadeDuration(totalSeconds: Double(minutes * 60))
            XCTAssertEqual(timer.endsAt, time(22).addingTimeInterval(Double(minutes * 60)), "\(minutes)")
            clock.now = time(22).addingTimeInterval(Double(minutes * 60) - fade - 1)
            timer.tick()
            XCTAssertEqual(log.fades, [], "\(minutes): not early")
            clock.now += 1
            timer.tick()
            XCTAssertEqual(log.fades, [fade], "\(minutes)")
            clock.now = time(22).addingTimeInterval(Double(minutes * 60))
            timer.tick()
            XCTAssertEqual(log.completed, 1, "\(minutes)")
        }
    }

    func testItPublishesOnceASecondAtMost() {
        let (timer, clock, _) = make(.untilAsleep(45), at: time(23))
        var published = 0
        let watch = timer.objectWillChange.sink { published += 1 }
        defer { watch.cancel() }
        timer.start()
        let afterStart = published
        // A run loop that fires four times a second.
        for _ in 0..<40 {
            clock.now += 0.25
            timer.tick()
        }
        XCTAssertLessThanOrEqual(published - afterStart, 10, "ten seconds, ten changes at most")
        XCTAssertGreaterThanOrEqual(published - afterStart, 9)
        // Ticks with the clock standing still publish nothing.
        let settled = published
        for _ in 0..<20 { timer.tick() }
        XCTAssertEqual(published, settled)
    }

    func testTheCountDoesNotDependOnTheTicks() {
        // The app was not in front for half an hour and nothing ticked: the
        // first tick lands on the right state, because the end is a date.
        let (timer, clock, log) = make(.untilAsleep(45), at: time(23))
        timer.start()
        clock.now = time(23, 40)
        timer.tick()
        XCTAssertTrue(timer.isFading)
        XCTAssertEqual(log.fades, [300], "the fade that is left, not the whole one")
        XCTAssertEqual(timer.remaining, 300)
        XCTAssertEqual(timer.fadingMinutes, 5)
        clock.now = time(23, 50)
        timer.tick()
        XCTAssertEqual(log.completed, 1, "a tick after the end ends it")
    }

    func testAPauseStopsTheCountAndTheSameNightPicksItUp() {
        let (timer, clock, log) = make(.untilAsleep(45), at: time(23))
        timer.start()
        run(timer, clock, seconds: 600)
        timer.pause()
        XCTAssertNil(timer.endsAt)
        XCTAssertEqual(timer.remaining, 2_100)
        XCTAssertTrue(timer.hasCount)
        // Ten minutes in pause do not count.
        clock.now += 600
        timer.tick()
        XCTAssertEqual(timer.remaining, 2_100)
        timer.start()
        XCTAssertEqual(timer.endsAt, time(23, 55))
        XCTAssertEqual(timer.remaining, 2_100)
        XCTAssertEqual(log.completed, 0)

        // The night is over: the next start is a whole one.
        timer.reset()
        XCTAssertFalse(timer.hasCount)
        XCTAssertNil(timer.remaining)
        timer.start()
        XCTAssertEqual(timer.remaining, 2_700)
    }

    func testResumingInsideTheFinalFadeRisesToWhereTheFadeStands() {
        let (timer, clock, log) = make(.untilAsleep(40), at: time(23))
        timer.start()
        run(timer, clock, seconds: 2_100)
        XCTAssertEqual(log.fades, [600])
        // Five minutes into the ten of the fade.
        XCTAssertEqual(timer.fadeLevel, 0.5, accuracy: 0.000_1)
        timer.pause()
        XCTAssertFalse(timer.isFading, "paused is not fading")
        XCTAssertEqual(timer.fadeLevel, 0.5, accuracy: 0.000_1, "the level the bed comes back to")

        clock.now += 120
        timer.start(risingOver: 0.8)
        XCTAssertTrue(timer.isFading)
        XCTAssertEqual(timer.fadingMinutes, 5)
        XCTAssertEqual(timer.fadeLevel, 0.5, accuracy: 0.000_1)
        XCTAssertEqual(log.fades.count, 1, "start asks nothing of the engine by itself")
        // The bed is still rising: asking for the fade now would start it
        // from silence.
        clock.now += 0.5
        timer.tick()
        XCTAssertEqual(log.fades.count, 1)
        clock.now += 0.5
        timer.tick()
        XCTAssertEqual(log.fades.count, 2)
        XCTAssertEqual(log.fades[1], 299, accuracy: 0.001, "the rest of the fade, from where it stands")
        run(timer, clock, seconds: 299)
        XCTAssertEqual(log.completed, 1)

        // A slower rise (three seconds after an interruption) waits longer.
        let (other, otherClock, otherLog) = make(.untilAsleep(40), at: time(23))
        other.start()
        run(other, otherClock, seconds: 2_100)
        other.pause()
        other.start(risingOver: InterruptionPolicy.resumeFadeIn)
        run(other, otherClock, seconds: 3)
        XCTAssertEqual(otherLog.fades.count, 1)
        run(other, otherClock, seconds: 1)
        XCTAssertEqual(otherLog.fades.count, 2)
    }

    func testANightPausedOnItsLastSecondStartsAWholeOne() {
        let (timer, clock, _) = make(.untilAsleep(15), at: time(23))
        timer.start()
        clock.now = time(23, 15).addingTimeInterval(-0.5)
        timer.pause()
        timer.start()
        XCTAssertEqual(timer.remaining, 900)
    }

    // MARK: +15 min

    func testExtendAddsFifteenMinutesToTheEnd() {
        let (timer, clock, log) = make(.untilAsleep(45), at: time(23))
        XCTAssertFalse(timer.extend(), "nothing counts yet: it never creates a timer (C47)")
        XCTAssertNil(timer.remaining)

        timer.start()
        run(timer, clock, seconds: 60)
        XCTAssertTrue(timer.extend())
        XCTAssertEqual(timer.endsAt, time(0, 0).addingTimeInterval(86_400), "23:45 becomes midnight")
        XCTAssertEqual(timer.remaining, 2_700 + 900 - 60)
        // No ceiling: it is there to be pressed again.
        for _ in 0..<30 { XCTAssertTrue(timer.extend()) }
        XCTAssertEqual(timer.remaining, 2_700 + 31 * 900 - 60)
        XCTAssertEqual(log.cancelled, 0, "there was no fade to call off")

        // Paused, it adds to what is left.
        timer.pause()
        XCTAssertTrue(timer.extend())
        XCTAssertEqual(timer.remaining, 2_700 + 32 * 900 - 60)
    }

    func testExtendInsideTheFinalFadeCallsItOff() {
        let (timer, clock, log) = make(.untilAsleep(45), at: time(23))
        timer.start()
        run(timer, clock, seconds: 2_400)
        XCTAssertTrue(timer.isFading)
        XCTAssertEqual(log.fades.count, 1)

        XCTAssertTrue(timer.extend())
        XCTAssertEqual(log.cancelled, 1, "the level comes back")
        XCTAssertFalse(timer.isFading)
        XCTAssertNil(timer.fadingMinutes)
        XCTAssertEqual(timer.fadeLevel, 1)
        XCTAssertEqual(timer.endsAt, time(0, 0).addingTimeInterval(86_400))
        XCTAssertEqual(timer.remaining, 1_200)

        // And the fade comes again, as long as before, at the new end.
        run(timer, clock, seconds: 1_200 - 676)
        XCTAssertEqual(log.fades.count, 1)
        run(timer, clock, seconds: 1)
        XCTAssertEqual(log.fades.count, 2)
        XCTAssertEqual(log.fades[1], 675)
        run(timer, clock, seconds: 675)
        XCTAssertEqual(log.completed, 1)
    }

    func testOffHasNothingToCountOrExtend() {
        let (timer, clock, log) = make(.off, at: time(23))
        timer.start()
        XCTAssertNil(timer.remaining)
        XCTAssertNil(timer.endsAt)
        XCTAssertFalse(timer.extend())
        XCTAssertFalse(timer.hasCount)
        run(timer, clock, seconds: 7_200)
        XCTAssertEqual(log.completed, 0)
        XCTAssertEqual(log.fades, [])
    }

    // MARK: Blanket

    func testTheBlanketSoundsUntilItsHourAndEasesDownOnce() {
        let (timer, clock, log) = make(.blanket(hour: 7), at: time(23, 30))
        timer.start()
        let end = time(day: 18, 7)
        XCTAssertEqual(timer.endsAt, end, "the end is an hour, not a length")
        XCTAssertEqual(timer.fixedEnd, end)
        XCTAssertNil(timer.selectedMinutes)
        XCTAssertEqual(timer.blanketGain, 1)

        // 44 min 59 s: nothing yet.
        run(timer, clock, seconds: 45 * 60 - 1)
        XCTAssertEqual(log.dips.count, 0)
        run(timer, clock, seconds: 1)
        XCTAssertEqual(log.dips.count, 1)
        XCTAssertEqual(log.dips[0].gain, TimerMath.blanketDipGain)
        XCTAssertEqual(log.dips[0].ramp, 60, "a slow ramp, never a step")
        XCTAssertEqual(timer.blanketGain, TimerMath.blanketDipGain)

        // The rest of the night: no second dip, no fade until 06:45.
        clock.now = time(day: 18, 6, 44)
        timer.tick()
        XCTAssertEqual(log.dips.count, 1)
        XCTAssertEqual(log.fades, [])
        XCTAssertFalse(timer.isFading)
        clock.now = time(day: 18, 6, 45)
        timer.tick()
        XCTAssertEqual(log.fades, [900])
        XCTAssertTrue(timer.isFading)
        XCTAssertEqual(timer.fadingMinutes, 15)
        clock.now = end
        timer.tick()
        XCTAssertEqual(log.completed, 1)
        XCTAssertNil(timer.fixedEnd)
        XCTAssertEqual(timer.blanketGain, 1, "the next night starts whole")
    }

    func testAPauseDoesNotMoveTheHourOfTheBlanket() {
        let (timer, clock, log) = make(.blanket(hour: 7), at: time(23, 30))
        timer.start()
        run(timer, clock, seconds: 600)
        timer.pause()
        XCTAssertNil(timer.endsAt, "nothing is said to end while it is paused")
        XCTAssertEqual(timer.fixedEnd, time(day: 18, 7), "but the morning window still knows the hour")
        clock.now += 300
        timer.start()
        XCTAssertEqual(timer.endsAt, time(day: 18, 7))

        // The dip that came due during a pause is simply there: no ramp is
        // asked for, the level is in place when the bed rises.
        timer.pause()
        clock.now = time(0, 30).addingTimeInterval(86_400)
        XCTAssertEqual(timer.blanketGain, 1)
        timer.start()
        XCTAssertEqual(timer.blanketGain, TimerMath.blanketDipGain)
        XCTAssertEqual(log.dips.count, 0)
        run(timer, clock, seconds: 120)
        XCTAssertEqual(log.dips.count, 0)
    }

    func testABlanketWhoseHourPassedInPauseBeginsANewNight() {
        let (timer, clock, _) = make(.blanket(hour: 7), at: time(6, 50))
        timer.start()
        XCTAssertEqual(timer.endsAt, time(7))
        timer.pause()
        clock.now = time(7, 2)
        timer.start()
        XCTAssertEqual(timer.endsAt, time(day: 18, 7), "not a night that ends as it starts")
    }

    func testAShortBlanketFadesAQuarterAndDoesNotDip() {
        // 40 minutes to the hour: ten of fade, and the 45 minutes of the
        // dip never come.
        let (timer, clock, log) = make(.blanket(hour: 7), at: time(6, 20))
        timer.start()
        clock.now = time(6, 49, second: 59)
        timer.tick()
        XCTAssertEqual(log.fades, [])
        clock.now = time(6, 50)
        timer.tick()
        XCTAssertEqual(log.fades, [600])
        clock.now = time(7)
        timer.tick()
        XCTAssertEqual(log.completed, 1)
        XCTAssertEqual(log.dips.count, 0)
    }

    func testExtendMovesTheHourOfTheBlanketForTonight() {
        let (timer, clock, _) = make(.blanket(hour: 7), at: time(23, 30))
        XCTAssertFalse(timer.extend(), "no night yet")
        timer.start()
        XCTAssertTrue(timer.extend())
        XCTAssertEqual(timer.endsAt, time(day: 18, 7, 15))
        XCTAssertEqual(timer.fixedEnd, time(day: 18, 7, 15))
        XCTAssertEqual(timer.choice, .blanket(hour: 7), "the choice is not rewritten")
        // Paused, too.
        run(timer, clock, seconds: 60)
        timer.pause()
        XCTAssertTrue(timer.extend())
        XCTAssertEqual(timer.fixedEnd, time(day: 18, 7, 30))
    }

    // MARK: Choosing

    func testANewChoiceEndsWhateverWasCounting() {
        let (timer, clock, log) = make(.untilAsleep(45), at: time(23))
        timer.start()
        run(timer, clock, seconds: 2_400)
        XCTAssertTrue(timer.isFading)
        timer.choose(.blanket(hour: 7))
        XCTAssertEqual(timer.choice, .blanket(hour: 7))
        XCTAssertFalse(timer.isFading)
        XCTAssertNil(timer.remaining)
        XCTAssertFalse(timer.hasCount)
        XCTAssertEqual(timer.fadeLevel, 1)
        run(timer, clock, seconds: 3_600)
        XCTAssertEqual(log.completed, 0, "the old count is gone")
        timer.start()
        XCTAssertEqual(timer.endsAt, time(day: 18, 7))
    }
}

private extension SleepTimerControllerTests {
    func time(day: Int = 17, _ hour: Int, _ minute: Int, second: Int) -> Date {
        time(day: day, hour, minute).addingTimeInterval(TimeInterval(second))
    }
}
