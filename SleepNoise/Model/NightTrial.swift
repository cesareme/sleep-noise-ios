import Foundation

/// What the seven-night trial stores. `consumed` is counted as it is observed,
/// the same arithmetic as `TrialClock.observe`.
struct TrialRecord: Codable, Equatable {
    var startedAt: Date
    var lastSeen: Date
    var consumed: TimeInterval
}

/// Where the trial record lives. The app uses the Keychain
/// (`KeychainTrialStorage`); tests and previews use `InMemoryTrialStorage`.
protocol TrialStorage {
    func loadTrial() -> TrialRecord?
    @discardableResult func saveTrial(_ record: TrialRecord) -> Bool
}

/// In-memory double for tests and previews.
final class InMemoryTrialStorage: TrialStorage {
    private(set) var record: TrialRecord?
    private(set) var saveCount = 0

    init(record: TrialRecord? = nil) {
        self.record = record
    }

    func loadTrial() -> TrialRecord? {
        record
    }

    @discardableResult
    func saveTrial(_ record: TrialRecord) -> Bool {
        self.record = record
        saveCount += 1
        return true
    }
}

enum NightTrialStatus: Equatable {
    case notStarted
    case active
    case ended
}

/// The local trial of seven nights (C07).
///
/// - It only starts from the "Start the trial · 7 nights" button of the Pro
///   sheet: never with Play, at launch or from an intent. Before that it
///   grants nothing; the person is on the free tier.
/// - It lasts 7 × 86 400 s from that tap.
/// - It is evaluated only when a sound session starts. If the seven days run
///   out at 03:10 with sound playing, nothing changes until the next start.
/// - Winding the clock back never gives time back.
///
/// The type reads no clock of its own: every moment is passed in.
struct NightTrial {
    static let nights = 7
    static let length: TimeInterval = TimeInterval(nights) * 86_400

    private(set) var record: TrialRecord?
    /// The answer of the last evaluation. Only `init`, `start(now:)` and
    /// `evaluateAtSessionStart(now:)` change it.
    private(set) var grantsFullAccess: Bool
    private let storage: TrialStorage

    var status: NightTrialStatus {
        guard record != nil else { return .notStarted }
        return grantsFullAccess ? .active : .ended
    }

    /// Loads the stored record. Does not read any clock: a trial whose time
    /// ran out while the app was closed still reads as active until the next
    /// session start evaluates it.
    init(storage: TrialStorage) {
        self.storage = storage
        let stored = storage.loadTrial()
        record = stored
        grantsFullAccess = stored.map { $0.consumed < Self.length } ?? false
    }

    /// Starts the trial. Returns `false` and writes nothing when there is a
    /// record already: a trial that ended does not run twice.
    @discardableResult
    mutating func start(now: Date) -> Bool {
        guard record == nil else { return false }
        let fresh = TrialRecord(startedAt: now, lastSeen: now, consumed: 0)
        record = fresh
        storage.saveTrial(fresh)
        grantsFullAccess = true
        return true
    }

    /// Counts the time elapsed since the last evaluation and answers whether
    /// the trial still grants full access. Without a record it returns `false`
    /// and saves nothing: Play never starts the trial.
    ///
    /// Callers must not call this when resuming after an interruption or for Small Hours.
    /// The function cannot know either; it is a contract for whoever wires it.
    @discardableResult
    mutating func evaluateAtSessionStart(now: Date) -> Bool {
        guard var current = record else { return false }
        if now > current.lastSeen {
            current.consumed += now.timeIntervalSince(current.lastSeen)
        }
        if now != current.lastSeen {
            current.lastSeen = now
            record = current
            storage.saveTrial(current)
        }
        grantsFullAccess = current.consumed < Self.length
        return grantsFullAccess
    }

    /// The figure of "trial · n nights left": calendar days between today and
    /// the day the trial runs out, never less than 1 while it is active.
    /// `nil` before the trial starts and once it has ended.
    ///
    /// The figure has an open question in the design notes, which is why it
    /// lives in this one function and nothing else derives from it.
    func nightsRemaining(now: Date, calendar: Calendar = .current) -> Int? {
        guard status == .active, let record else { return nil }
        let used = record.consumed + max(0, now.timeIntervalSince(record.lastSeen))
        let left = max(0, Self.length - used)
        let end = now.addingTimeInterval(left)
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: end)
        ).day ?? 0
        return max(1, days)
    }
}
