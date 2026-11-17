import Combine
import Foundation

/// Saved mixes. The mixer mutates this on the main thread.
///
/// Stored with `MixCodec` (mix format v2) in `UserDefaults`, on the device
/// only. What earlier builds stored under the v1 key is read once, written
/// back as v2 under the new key and left where it was.
///
/// Nothing the codec could not read is thrown away by the next save: a
/// document from a later format version, one that is damaged, or one with
/// entries that were skipped is copied as it was to `unreadStorageKey` when
/// the list loads. The list then starts with what could be read.
///
/// Both keys are read from the one `defaults` passed in. A move to another
/// suite (an App Group) needs its own migration from this one.
final class MixStore: ObservableObject {
    @Published private(set) var mixes: [SavedMix] = []

    static let storageKey = "sleepnoise.mixes.v2"
    static let legacyStorageKey = "sleepnoise.mixes.v1"
    /// The last stored document this version could not read in full.
    static let unreadStorageKey = "sleepnoise.mixes.v2.unread"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func save(name: String, levels: [SoundID: Float], hasFullAccess: Bool) -> SaveMixResult {
        let trimmed = MixCodec.cleanName(name)
        guard !trimmed.isEmpty else { return .emptyName }
        guard AccessPolicy.canSave(existingCount: mixes.count, hasFullAccess: hasFullAccess) else {
            return .needsPro
        }
        let mix = MixCodec.normalized(SavedMix(
            id: UUID(),
            name: trimmed,
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

    /// The name a mix gets when it has none: "Mix 3".
    static func defaultName(_ position: Int) -> String {
        String(format: String(localized: "mixes.defaultNameFormat"), Int64(position))
    }

    private func load() {
        if let data = defaults.data(forKey: Self.storageKey) {
            let read = try? MixCodec.read(data)
            if read?.isComplete != true {
                defaults.set(data, forKey: Self.unreadStorageKey)
            }
            mixes = named(read?.mixes ?? [])
            return
        }
        // First launch with the v2 format: bring over what v1 stored. The v1
        // data stays under its key, so nothing skipped here is lost.
        guard let legacy = defaults.data(forKey: Self.legacyStorageKey),
              let decoded = try? MixCodec.decode(legacy)
        else { return }
        mixes = named(decoded)
        persist()
    }

    /// A stored mix whose name came back empty is kept and given the default
    /// name, counting from the oldest end of the list.
    private func named(_ mixes: [SavedMix]) -> [SavedMix] {
        mixes.enumerated().map { index, mix in
            guard mix.name.isEmpty else { return mix }
            var named = mix
            named.name = Self.defaultName(mixes.count - index)
            return named
        }
    }

    private func persist() {
        guard let data = try? MixCodec.encode(mixes) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
