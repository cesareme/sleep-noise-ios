import Combine
import Foundation

/// Saved mixes. The mixer mutates this on the main thread.
final class MixStore: ObservableObject {
    @Published private(set) var mixes: [SavedMix] = []

    private let defaults: UserDefaults
    private let storageKey = "sleepnoise.mixes.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func save(name: String, levels: [SoundID: Float], isPro: Bool) -> SaveMixResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .emptyName }
        guard AccessPolicy.canSave(existingCount: mixes.count, isPro: isPro) else {
            return .needsPro
        }
        let mix = SavedMix(
            id: UUID(),
            name: String(trimmed.prefix(40)),
            levels: SoundID.allCases.map { sound in
                MixLevel(sound: sound, value: min(1, max(0, levels[sound] ?? 0)))
            },
            createdAt: Date()
        )
        mixes.insert(mix, at: 0)
        persist()
        return .saved(mix)
    }

    func delete(_ id: UUID) {
        mixes.removeAll { $0.id == id }
        persist()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        guard let decoded = try? JSONDecoder().decode([SavedMix].self, from: data) else { return }
        mixes = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(mixes) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
