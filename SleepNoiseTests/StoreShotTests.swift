import XCTest
@testable import SleepNoise

/// The captures of the store (S-08): what scripts/screenshots.sh launches
/// is what the app can stage, at the hours the copy on screen needs.
final class StoreShotTests: XCTestCase {
    /// The `"NN-name:state"` entries of the script, in its order.
    private func shots() throws -> [(name: String, state: String)] {
        let url = CatalogSource.root.appendingPathComponent("scripts/screenshots.sh")
        let script = try String(contentsOf: url, encoding: .utf8)
        return CatalogSource.matches(of: #""\d\d-[a-z-]+:[A-Za-z0-9]+""#, in: script).map { entry in
            let parts = entry.dropFirst().dropLast().split(separator: ":").map(String.init)
            return (parts[0], parts[1])
        }
    }

    func testEveryStateTheScriptLaunchesExists() throws {
        let shots = try shots()
        XCTAssertEqual(shots.map(\.name), [
            "01-page-playing", "02-first-use", "03-layers", "04-tide", "05-night", "06-not-here",
        ])
        for shot in shots {
            XCTAssertNotNil(PageDebugState(rawValue: shot.state), "\(shot.name): -pageState \(shot.state)")
        }
    }

    /// The trial has its word on the page only outside the night window,
    /// and the Night of the store is a night.
    @MainActor
    func testTheStoreHoursSitOnTheRightSideOfTheNightWindow() {
        for state in [PageDebugState.storePlaying, .storeLayers, .storeTide] {
            XCTAssertFalse(NightWindow.contains(PageStage.clock(for: state)), "\(state)")
        }
        XCTAssertTrue(NightWindow.contains(PageStage.clock(for: .storeNight)))
        XCTAssertTrue(PageDebugState.storeNight.isNightScreen)
    }

    /// What the store shows playing with a Pro layer or the tide is the
    /// second day of the trial, never a purchase; the first use is the
    /// free level, without a trial.
    func testTheStoreStatesAreATrialAndANewInstall() {
        for state in [PageDebugState.storePlaying, .storeLayers, .storeTide] {
            XCTAssertEqual(state.trialConsumed, 86_400, "\(state)")
            XCTAssertTrue(state.isFreeTier, "\(state)")
        }
        XCTAssertNil(PageDebugState.storeFirstUse.trialConsumed)
        XCTAssertTrue(PageDebugState.storeFirstUse.isFreeTier)
        XCTAssertTrue(PageDebugState.settingsNotHere.opensSettings)
        XCTAssertTrue(PageDebugState.storeTide.opensTide)
    }

    /// The first two captures are the first two the store shows, side by
    /// side in the search results: they are not the same page twice. The
    /// second is tonight's mix at other levels, not the house mix that the
    /// first one plays.
    @MainActor
    func testTheFirstTwoCapturesDoNotShowTheSameMix() {
        func percents(_ levels: [SoundID: Float]) -> [SoundID: Int] {
            levels.mapValues { Int(($0 * 100).rounded()) }
        }
        // Capture 1 plays the house mix as it loads.
        let playing = percents(Dictionary(
            uniqueKeysWithValues: HouseMix.pinkAndRain.recipe.map { ($0.sound, $0.value) }
        ))
        let firstUse = percents(PageStage.storeFirstUseLevels)
        XCTAssertEqual(firstUse, [.rain: 30, .pink: 50])
        XCTAssertEqual(Set(playing.keys), Set(firstUse.keys))
        for sound in playing.keys {
            XCTAssertNotEqual(playing[sound], firstUse[sound], "\(sound)")
        }
    }

    /// The script creates the simulator it uses and deletes it however it
    /// ends: it never picks one by name, which may be someone else's.
    func testTheScriptWorksOnASimulatorOfItsOwn() throws {
        let url = CatalogSource.root.appendingPathComponent("scripts/screenshots.sh")
        let script = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(script.contains("xcrun simctl create"))
        XCTAssertTrue(script.contains("xcrun simctl delete"))
        XCTAssertTrue(script.contains("trap cleanup EXIT"))
        XCTAssertFalse(script.contains("SN_SHOT_SIM"), "a simulator is never chosen by its name")
    }
}
