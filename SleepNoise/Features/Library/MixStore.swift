import Combine
import Foundation

/// Saved mixes. The mixer mutates this on the main thread.
///
/// Stored with `MixCodec` (mix format v2) in `UserDefaults`, on the device
/// only. What earlier builds stored under the v1 key is read once, written
/// back as v2 under the new key and left where it was.
final class MixStore: ObservableObject {
    @Published private(set) var mixes: [SavedMix] = []

    static let storageKey = "sleepnoise.mixes.v2"
    static let legacyStorageKey = "sleepnoise.mixes.v1"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func save(name: String, levels: [SoundID: Float], hasFullAccess: Bool) -> SaveMixResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .emptyName }
        guard AccessPolicy.canSave(existingCount: mixes.count, hasFullAccess: hasFullAccess) else {
            return .needsPro
        }
        let mix = MixCodec.normalized(SavedMix(
            id: UUID(),
            name: String(trimmed.prefix(40)),
            levels: SoundID.allCases.map { MixLevel(sound: $0, value: levels[$0] ?? 0) },
            createdAt: Date()
        ))
        mixes.insert(mix, at: 0)
        persist()
        return .saved(mix)
    }

    func delete(_ id: UUID) {
        mixes.removeAll { $0.id == id }
        persist()
    }

    private func load() {
        if let data = defaults.data(forKey: Self.storageKey) {
            mixes = (try? MixCodec.decode(data)) ?? []
            return
        }
        // First launch with the v2 format: bring over what v1 stored.
        guard let legacy = defaults.data(forKey: Self.legacyStorageKey),
              let decoded = try? MixCodec.decode(legacy)
        else { return }
        mixes = decoded
        persist()
    }

    private func persist() {
        guard let data = try? MixCodec.encode(mixes) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
