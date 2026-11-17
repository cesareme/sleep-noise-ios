import XCTest
@testable import SleepNoise

final class SmallHoursRecipeTests: XCTestCase {
    private let recipe = SmallHoursRecipe.standard

    // Red if any of the eight decided values changes (C05).
    func testStandardRecipeMatchesTheDecision() {
        XCTAssertEqual(recipe.sound, .ocean)
        XCTAssertEqual(recipe.level, 0.3, accuracy: 0.000_1)
        XCTAssertEqual(recipe.breathsPerMinute, 8)
        XCTAssertEqual(recipe.duration, 1_200)
        XCTAssertEqual(recipe.fadeIn, 3)
        XCTAssertEqual(recipe.tideGuideEnd, 630)
        XCTAssertEqual(recipe.tideDissolveEnd, 780)
        XCTAssertEqual(recipe.finalFade, 300)
        XCTAssertEqual(recipe.finalFadeStart, 900)
    }

    // Red if two stages overlap, for example the tide still dissolving when
    // the closing fade begins.
    func testTimelineIsOrdered() {
        XCTAssertGreaterThan(recipe.fadeIn, 0)
        XCTAssertLessThan(recipe.fadeIn, recipe.tideGuideEnd)
        XCTAssertLessThan(recipe.tideGuideEnd, recipe.tideDissolveEnd)
        XCTAssertLessThanOrEqual(recipe.tideDissolveEnd, recipe.finalFadeStart)
        XCTAssertLessThan(recipe.finalFadeStart, recipe.duration)
    }

    // Red if an interval closes on the wrong side or negative time is not
    // treated as the start.
    func testPhaseEdges() {
        XCTAssertEqual(recipe.phase(at: -5), .tideGuiding)
        XCTAssertEqual(recipe.phase(at: 629.9), .tideGuiding)
        XCTAssertEqual(recipe.phase(at: 630), .tideDissolving)
        XCTAssertEqual(recipe.phase(at: 779.9), .tideDissolving)
        XCTAssertEqual(recipe.phase(at: 780), .plainSea)
        XCTAssertEqual(recipe.phase(at: 900), .windingDown)
        XCTAssertEqual(recipe.phase(at: 1_199.9), .windingDown)
        XCTAssertEqual(recipe.phase(at: 1_200), .finished)
        XCTAssertEqual(recipe.phase(at: 5_000), .finished)
    }

    // Red if minutes are rounded down or to nearest, or go below zero.
    func testMinutesLeftCountsDown() {
        XCTAssertEqual(recipe.minutesLeft(at: 0), 20)
        XCTAssertEqual(recipe.minutesLeft(at: 1), 20)
        XCTAssertEqual(recipe.minutesLeft(at: 60), 19)
        XCTAssertEqual(recipe.minutesLeft(at: 1_199), 1)
        XCTAssertEqual(recipe.minutesLeft(at: 1_200), 0)
        XCTAssertEqual(recipe.minutesLeft(at: 2_000), 0)
        XCTAssertEqual(recipe.minutesLeft(at: -30), 20)
    }

    // Red if the winding-down figure shows before the last five minutes or
    // after the session has ended.
    func testWindingDownMinutes() {
        XCTAssertNil(recipe.windingDownMinutes(at: 899))
        XCTAssertEqual(recipe.windingDownMinutes(at: 900), 5)
        XCTAssertEqual(recipe.windingDownMinutes(at: 901), 5)
        XCTAssertEqual(recipe.windingDownMinutes(at: 960), 4)
        XCTAssertEqual(recipe.windingDownMinutes(at: 1_199), 1)
        XCTAssertNil(recipe.windingDownMinutes(at: 1_200))
    }
}
