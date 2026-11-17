import XCTest
@testable import SleepNoise

final class KeychainTrialStorageTests: XCTestCase {
    private let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// A service of its own per test, so nothing leaks between tests or into
    /// the item the app uses.
    private func makeStorage() -> KeychainTrialStorage {
        KeychainTrialStorage(service: "sleepnoise.tests.\(UUID().uuidString)")
    }

    // Red if save does not replace an existing item, or load and save
    // disagree on the encoding.
    func testRoundTrip() {
        let storage = makeStorage()
        defer { storage.removeTrial() }
        XCTAssertNil(storage.loadTrial())

        let first = TrialRecord(startedAt: start, lastSeen: start, consumed: 0)
        XCTAssertTrue(storage.saveTrial(first))
        XCTAssertEqual(storage.loadTrial(), first)

        let second = TrialRecord(
            startedAt: start,
            lastSeen: start.addingTimeInterval(3_600),
            consumed: 3_600
        )
        XCTAssertTrue(storage.saveTrial(second))
        XCTAssertEqual(storage.loadTrial(), second)

        XCTAssertTrue(storage.removeTrial())
        XCTAssertNil(storage.loadTrial())
        XCTAssertTrue(storage.removeTrial(), "removing nothing is not a failure")
    }

    // Red if the query drops `kSecAttrService` and every storage shares one item.
    func testServicesAreIsolated() {
        let one = makeStorage()
        let other = makeStorage()
        defer {
            one.removeTrial()
            other.removeTrial()
        }
        XCTAssertTrue(one.saveTrial(TrialRecord(startedAt: start, lastSeen: start, consumed: 42)))
        XCTAssertNil(other.loadTrial())
        XCTAssertEqual(one.loadTrial()?.consumed, 42)
    }

    // Red if `NightTrial` stops writing through its storage on start or on
    // evaluation.
    func testNightTrialPersistsThroughTheKeychain() {
        let storage = makeStorage()
        defer { storage.removeTrial() }

        var first = NightTrial(storage: storage)
        XCTAssertEqual(first.status, .notStarted)
        XCTAssertTrue(first.start(now: start))

        var second = NightTrial(storage: KeychainTrialStorage(service: storage.service))
        XCTAssertEqual(second.status, .active)
        XCTAssertEqual(second.record?.startedAt, start)
        XCTAssertFalse(second.evaluateAtSessionStart(now: start.addingTimeInterval(8 * 86_400)))

        let third = NightTrial(storage: KeychainTrialStorage(service: storage.service))
        XCTAssertEqual(third.status, .ended)
    }
}
