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

    /// Any failure or unreadable data reads as "no trial".
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

    @discardableResult
    func saveTrial(_ record: TrialRecord) -> Bool {
        guard let data = try? JSONEncoder().encode(record) else { return false }
        let update: [String: Any] = [kSecValueData as String: data]
        var status = SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)
        if status == errSecItemNotFound {
            var attributes = baseQuery
            attributes[kSecValueData as String] = data
            attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            status = SecItemAdd(attributes as CFDictionary, nil)
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
