import Foundation

/// What the seven-night trial stores. `consumed` is counted as it is observed:
/// every observation adds the wall-clock time elapsed since the one before.
///
/// Keep it backward compatible: a field added later must be optional, or a
/// record stored by an older build stops decoding and reads as "no trial".
struct TrialRecord: Codable, Equatable {
    var startedAt: Date
    var lastSeen: Date
    var consumed: TimeInterval
}

/// Where the trial record lives. The app uses the Keychain
/// (`KeychainTrialStorage`); tests and previews use `InMemoryTrialStorage`.
protocol TrialStorage {
    func loadTrial() -> TrialRecord?
    /// Writes the first record. Fails, and writes nothing, when there is one
    /// already, readable or not: this is what keeps a trial from running twice.
    func createTrial(_ record: TrialRecord) -> Bool
    /// Replaces the record of a trial that has started.
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

    func createTrial(_ record: TrialRecord) -> Bool {
        guard self.record == nil else { return false }
        self.record = record
        saveCount += 1
        return true
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
/// - Nothing is sold at night (C08): callers must not offer or call `start`
///   inside `NightWindow`.
/// - It lasts 7 × 86 400 s from that tap.
/// - It is evaluated only when a sound session starts. If the seven days run
///   out at 03:10 with sound playing, nothing changes until the next start.
/// - The change to `.ended` is never announced inside `NightWindow` (08
///   §2.5): most sessions start there, so the note waits for daytime.
/// - Winding the clock back never gives time back. It can still stretch the
///   trial: an observation with the clock behind the last one consumes
///   nothing and moves the reference point. `observe(now:)` at launch and on
///   return to the foreground narrows that gap; it does not close it. Someone
///   who sets the date back before opening the app every evening keeps the
///   trial open: the first observation already sees the false clock. Closing
///   it needs a clock the person cannot set (open, see ESTADO.md).
///
/// The type reads no clock of its own: every moment is passed in.
struct NightTrial {
    static let nights = 7
    static let length: TimeInterval = TimeInterval(nights) * 86_400

    private(set) var record: TrialRecord?
    /// The answer of the last evaluation. Only `init`, `start(now:)` and
    /// `evaluateAtSessionStart(now:)` change it; `observe(now:)` does not.
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

    /// Starts the trial. Returns `false` and grants nothing when there is a
    /// record already (a trial that ended does not run twice) or when the
    /// record cannot be created. The write is create-only, so a record that
    /// could not be read is never overwritten by a fresh one.
    ///
    /// Callers must not offer or call this inside `NightWindow` (C08).
    @discardableResult
    mutating func start(now: Date) -> Bool {
        guard record == nil else { return false }
        let fresh = TrialRecord(startedAt: now, lastSeen: now, consumed: 0)
        guard storage.createTrial(fresh) else { return false }
        record = fresh
        grantsFullAccess = true
        return true
    }

    /// Counts the time elapsed since the last observation and saves it,
    /// without touching `grantsFullAccess`: the answer still changes only at
    /// the next session start. Meant for launch and return to the foreground,
    /// so that the real clock is sampled between sessions and a clock wound
    /// back before every Play cannot hold the trial open on its own. Without
    /// a record it does nothing.
    mutating func observe(now: Date) {
        guard var current = record else { return }
        if now > current.lastSeen {
            current.consumed += now.timeIntervalSince(current.lastSeen)
        }
        if now != current.lastSeen {
            current.lastSeen = now
            record = current
            storage.saveTrial(current)
        }
    }

    /// Counts the time elapsed since the last evaluation and answers whether
    /// the trial still grants full access. Without a record it returns `false`
    /// and saves nothing: Play never starts the trial.
    ///
    /// Callers must not call this when resuming after an interruption or for Small Hours.
    /// The function cannot know either; it is a contract for whoever wires it.
    @discardableResult
    mutating func evaluateAtSessionStart(now: Date) -> Bool {
        observe(now: now)
        guard let record else { return false }
        grantsFullAccess = record.consumed < Self.length
        return grantsFullAccess
    }

    /// Reads the storage again when there is no record in memory. A read can
    /// fail (the Keychain before the first unlock) and look like "no trial":
    /// launch, the return to the foreground and every session start ask
    /// again, so a trial that is running is not lost for the whole launch.
    /// Returns whether a record appeared.
    @discardableResult
    mutating func reloadIfMissing() -> Bool {
        guard record == nil, let stored = storage.loadTrial() else { return false }
        record = stored
        grantsFullAccess = stored.consumed < Self.length
        return true
    }

    /// The figure of "trial · n nights left": the nights that are not over
    /// yet and begin (21:00, `NightWindow.startHour`) before the trial runs
    /// out. The night in progress counts until 07:00, so the figure does not
    /// drop in the middle of a night; it drops in the morning. Never more
    /// than `nights`. `nil` before the trial starts and once it has ended.
    ///
    /// 1 is the last night. 0 is the day the trial runs out: it is still
    /// active until its hour, but no night is left, so no figure is shown
    /// (08 §9.3, settled this way; the owner confirms). A trial whose time
    /// is up and has not been evaluated yet answers 0 as well.
    func nightsRemaining(now: Date, calendar: Calendar = .current) -> Int? {
        guard status == .active, let record else { return nil }
        let used = record.consumed + max(0, now.timeIntervalSince(record.lastSeen))
        // Not clamped: a trial that is over and not evaluated ended before now.
        let end = now.addingTimeInterval(Self.length - used)
        var day = Self.nightDay(of: now, calendar: calendar)
        var count = 0
        while count < Self.nights {
            guard let start = calendar.date(
                bySettingHour: NightWindow.startHour, minute: 0, second: 0, of: day
            ), start < end else { break }
            count += 1
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return count
    }

    /// The local day a night began on: before `NightWindow.endHour` it is
    /// still the night of the day before. Reads the local hour, like
    /// `NightWindow`, so a clock change does not move it.
    private static func nightDay(of date: Date, calendar: Calendar) -> Date {
        let day = calendar.startOfDay(for: date)
        guard calendar.component(.hour, from: date) < NightWindow.endHour else { return day }
        return calendar.date(byAdding: .day, value: -1, to: day) ?? day
    }
}
