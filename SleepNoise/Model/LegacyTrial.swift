import Foundation

/// The seven-day trial of the builds before the seven-night one. It began
/// with the first Play and lived in `UserDefaults`.
///
/// The rule for an install that comes from there: what it had is what it
/// keeps. A legacy trial that had begun becomes the record of the new trial
/// as it stood, with the time it had consumed, so a trial in progress goes on
/// to its own end and one that ran out stays over. Either way the trial
/// counts as used: "Start the trial" is not offered again. A legacy trial
/// that never began (no Play yet) leaves nothing behind, and the install is a
/// new one.
enum LegacyTrial {
    static let startedAtKey = "sleepnoise.trial.startedAt.v1"
    static let lastSeenKey = "sleepnoise.trial.lastSeen.v1"
    static let consumedKey = "sleepnoise.trial.consumed.v1"

    /// The record the legacy keys amount to, or nil when that trial never
    /// began.
    static func record(in defaults: UserDefaults) -> TrialRecord? {
        guard let startedAt = defaults.object(forKey: startedAtKey) as? Date else { return nil }
        let lastSeen = defaults.object(forKey: lastSeenKey) as? Date ?? startedAt
        return TrialRecord(
            startedAt: startedAt,
            lastSeen: lastSeen,
            consumed: max(0, defaults.double(forKey: consumedKey))
        )
    }

    /// Moves a legacy trial into `storage`, once. A record already there
    /// rules, readable or not (`createTrial` never writes over one). The
    /// legacy keys are only removed once the storage holds a record, so a
    /// write that fails is tried again at the next launch.
    static func migrate(from defaults: UserDefaults, to storage: TrialStorage) {
        guard let legacy = record(in: defaults) else { return }
        guard storage.loadTrial() != nil || storage.createTrial(legacy) else { return }
        defaults.removeObject(forKey: startedAtKey)
        defaults.removeObject(forKey: lastSeenKey)
        defaults.removeObject(forKey: consumedKey)
    }
}
