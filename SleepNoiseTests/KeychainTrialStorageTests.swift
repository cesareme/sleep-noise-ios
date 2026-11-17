import Security
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

    // Red if `createTrial` writes over an item that is already there.
    func testCreateNeverOverwrites() {
        let storage = makeStorage()
        defer { storage.removeTrial() }

        let first = TrialRecord(startedAt: start, lastSeen: start, consumed: 0)
        XCTAssertTrue(storage.createTrial(first))
        XCTAssertEqual(storage.loadTrial(), first)

        let later = start.addingTimeInterval(30 * 86_400)
        XCTAssertFalse(storage.createTrial(TrialRecord(startedAt: later, lastSeen: later, consumed: 0)))
        XCTAssertEqual(storage.loadTrial(), first)

        // An evaluation still updates the record that is there.
        let seen = TrialRecord(startedAt: start, lastSeen: later, consumed: 30 * 86_400)
        XCTAssertTrue(storage.saveTrial(seen))
        XCTAssertEqual(storage.loadTrial(), seen)
    }

    // Red if the item becomes synchronizable or gets another accessibility
    // class, on either of the two paths that add it: the state must not leave
    // the device.
    func testItemStaysOnThisDevice() throws {
        let record = TrialRecord(startedAt: start, lastSeen: start, consumed: 0)
        let writes: [(String, (KeychainTrialStorage) -> Bool)] = [
            ("create", { $0.createTrial(record) }),
            ("save", { $0.saveTrial(record) })
        ]
        for (name, write) in writes {
            let storage = makeStorage()
            defer { storage.removeTrial() }
            XCTAssertTrue(write(storage), name)

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: storage.service,
                kSecAttrAccount as String: KeychainTrialStorage.account,
                kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
                kSecReturnAttributes as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var item: CFTypeRef?
            XCTAssertEqual(SecItemCopyMatching(query as CFDictionary, &item), errSecSuccess, name)
            let attributes = try XCTUnwrap(item as? [String: Any], name)
            XCTAssertEqual(
                attributes[kSecAttrAccessible as String] as? String,
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String,
                name
            )
            let synchronizable = attributes[kSecAttrSynchronizable as String] as? Bool ?? false
            XCTAssertFalse(synchronizable, name)
        }
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
