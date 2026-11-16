import XCTest
@testable import SleepNoise

final class AccessPolicyTests: XCTestCase {
    func testFreeSounds() {
        for sound in [SoundID.white, .pink, .brown, .rain] {
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: false))
        }
        XCTAssertFalse(AccessPolicy.soundIsIncluded(.fan, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.soundIsIncluded(.ocean, hasFullAccess: false))
        for sound in SoundID.allCases {
            XCTAssertTrue(AccessPolicy.soundIsIncluded(sound, hasFullAccess: true))
        }
    }

    func testTimerGate() {
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 15, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 30, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 60, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 90, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 45, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.breathingIsIncluded(hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.breathingIsIncluded(hasFullAccess: true))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 0, hasFullAccess: true))
        XCTAssertFalse(AccessPolicy.timerIsIncluded(minutes: 361, hasFullAccess: true))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 45, hasFullAccess: true))
        XCTAssertTrue(AccessPolicy.timerIsIncluded(minutes: 360, hasFullAccess: true))
    }

    func testSavedMixGate() {
        XCTAssertTrue(AccessPolicy.canSave(existingCount: 0, hasFullAccess: false))
        XCTAssertFalse(AccessPolicy.canSave(existingCount: 1, hasFullAccess: false))
        XCTAssertTrue(AccessPolicy.canSave(existingCount: 40, hasFullAccess: true))
    }
}

final class TimerFormatTests: XCTestCase {
    func testFadeWindow() {
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 15 * 60), 20, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 8 * 60), 20, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 60), 15, accuracy: 0.001)
        XCTAssertEqual(TimerMath.fadeDuration(totalSeconds: 10), 5, accuracy: 0.001)
    }

    func testClockFormat() {
        XCTAssertEqual(TimeFormat.clock(0), "0:00")
        XCTAssertEqual(TimeFormat.clock(65), "1:05")
        XCTAssertEqual(TimeFormat.clock(3_661), "1:01:01")
    }
}

final class MixStoreTests: XCTestCase {
    func testFreeTierKeepsASingleMixAndProDoesNot() throws {
        let defaults = try makeDefaults()
        let store = MixStore(defaults: defaults)
        let first = store.save(name: "  Night  ", levels: [.pink: 0.4, .fan: 1.5], hasFullAccess: false)
        guard case .saved(let mix) = first else {
            return XCTFail("Expected the first mix to save")
        }
        XCTAssertEqual(mix.name, "Night")
        XCTAssertEqual(mix.value(for: .pink), 0.4, accuracy: 0.000_1)
        XCTAssertEqual(mix.value(for: .fan), 1, accuracy: 0.000_1)

        XCTAssertEqual(store.save(name: "Second", levels: [.rain: 0.2], hasFullAccess: false), .needsPro)
        XCTAssertEqual(store.mixes.count, 1)

        guard case .saved = store.save(name: "Second", levels: [.brown: -3], hasFullAccess: true) else {
            return XCTFail("Pro should save another mix")
        }
        XCTAssertEqual(store.mixes[0].value(for: .brown), 0, accuracy: 0.000_1)

        let reloaded = MixStore(defaults: defaults)
        XCTAssertEqual(reloaded.mixes.map(\.name), ["Second", "Night"])

        reloaded.delete(reloaded.mixes[0].id)
        reloaded.delete(reloaded.mixes[0].id)
        XCTAssertTrue(reloaded.mixes.isEmpty)

        let fresh = MixStore(defaults: defaults)
        guard case .saved = fresh.save(name: "Again", levels: [.white: 0.2], hasFullAccess: false) else {
            return XCTFail("Deleting the free mix should open the slot")
        }
        XCTAssertEqual(fresh.mixes.count, 1)
    }

    func testEmptyNameIsRejected() throws {
        let store = MixStore(defaults: try makeDefaults())
        XCTAssertEqual(store.save(name: "   ", levels: [.pink: 1], hasFullAccess: true), .emptyName)
        XCTAssertTrue(store.mixes.isEmpty)
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
