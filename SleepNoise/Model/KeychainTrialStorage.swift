import Foundation
import Security

/// The trial record in the Keychain (C07), so that deleting and reinstalling
/// the app does not hand out a second trial.
///
/// One generic password item, stored as JSON. It is not synchronizable and has
/// no access group: the state never leaves the device.
struct KeychainTrialStorage: TrialStorage {
    static let defaultService = "sleepnoise.trial.v1"
    static let account = "seven-nights"

    let service: String

    init(service: String = KeychainTrialStorage.defaultService) {
        self.service = service
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Self.account
        ]
    }

    private func newItem(_ data: Data) -> [String: Any] {
        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return attributes
    }

    /// Any failure or unreadable data reads as "no trial". That alone never
    /// hands out a second trial: `createTrial` refuses to write over an item.
    func loadTrial() -> TrialRecord? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(TrialRecord.self, from: data)
    }

    /// Add only: `errSecDuplicateItem` (an item is there, readable or not) and
    /// every other failure answer `false` and leave the Keychain as it was.
    func createTrial(_ record: TrialRecord) -> Bool {
        guard let data = try? JSONEncoder().encode(record) else { return false }
        return SecItemAdd(newItem(data) as CFDictionary, nil) == errSecSuccess
    }

    @discardableResult
    func saveTrial(_ record: TrialRecord) -> Bool {
        guard let data = try? JSONEncoder().encode(record) else { return false }
        let update: [String: Any] = [kSecValueData as String: data]
        var status = SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)
        if status == errSecItemNotFound {
            status = SecItemAdd(newItem(data) as CFDictionary, nil)
        }
        return status == errSecSuccess
    }

    /// Tests only. A started trial is never removed in the app.
    @discardableResult
    func removeTrial() -> Bool {
        let status = SecItemDelete(baseQuery as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
