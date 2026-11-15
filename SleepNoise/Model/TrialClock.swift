import Foundation

/// Local, card-free trial: everything is unlocked until the trial has consumed
/// `AccessPolicy.trialDays` days, then the free tier applies.
///
/// The clock does not start at install. It starts the first time the person
/// presses Play, after the first-launch card has told them how long the trial
/// lasts, what stays free afterwards and what Pro costs. Until then every
/// feature is open: nothing can be heard without Play, so nothing is given away.
///
/// Time is counted as it is observed: every evaluation adds the wall-clock time
/// elapsed since the previous one to `consumed`. Winding the clock back only
/// moves the reference point, it never gives time back; setting the clock far
/// ahead before the first Play and then correcting it does not pin the trial
/// open either, because the next observation simply resumes counting from the
/// corrected clock. A clock jumped forward consumes those days; that is rare
/// and cheaper than a rule that strands honest people.
///
/// All of it lives in `UserDefaults`, so a reinstall starts over. That is
/// accepted for 1.0; the alternative (Keychain) survives reinstalls but also
/// survives the person changing their mind about the app, which feels worse.
struct TrialClock {
    static let startedAtKey = "sleepnoise.trial.startedAt.v1"
    static let lastSeenKey = "sleepnoise.trial.lastSeen.v1"
    static let consumedKey = "sleepnoise.trial.consumed.v1"

    private(set) var startedAt: Date?
    private(set) var lastSeen: Date?
    private(set) var consumed: TimeInterval
    let length: TimeInterval
    private let defaults: UserDefaults?

    init(defaults: UserDefaults, days: Int = AccessPolicy.trialDays) {
        self.defaults = defaults
        length = TimeInterval(days) * 86_400
        startedAt = defaults.object(forKey: Self.startedAtKey) as? Date
        lastSeen = defaults.object(forKey: Self.lastSeenKey) as? Date
        consumed = defaults.double(forKey: Self.consumedKey)
    }

    init(startedAt: Date?, consumed: TimeInterval = 0, days: Int = AccessPolicy.trialDays) {
        defaults = nil
        length = TimeInterval(days) * 86_400
        self.startedAt = startedAt
        lastSeen = startedAt
        self.consumed = consumed
    }

    var hasStarted: Bool { startedAt != nil }

    /// Records the start if there is none yet.
    mutating func start(now: Date = Date()) {
        guard startedAt == nil else { return }
        startedAt = now
        lastSeen = now
        consumed = 0
        defaults?.set(now, forKey: Self.startedAtKey)
        defaults?.set(now, forKey: Self.lastSeenKey)
        defaults?.set(0.0, forKey: Self.consumedKey)
    }

    /// Adds the time elapsed since the last observation. Call it whenever the
    /// trial is evaluated (launch, foreground, playback end, store events).
    mutating func observe(now: Date = Date()) {
        guard startedAt != nil else { return }
        if let lastSeen, now > lastSeen {
            consumed += now.timeIntervalSince(lastSeen)
            defaults?.set(consumed, forKey: Self.consumedKey)
        }
        if lastSeen == nil || now != lastSeen {
            lastSeen = now
            defaults?.set(now, forKey: Self.lastSeenKey)
        }
    }

    /// Time the trial has used up at `now`, without recording it.
    func consumedTime(now: Date = Date()) -> TimeInterval {
        guard startedAt != nil else { return 0 }
        guard let lastSeen, now > lastSeen else { return consumed }
        return consumed + now.timeIntervalSince(lastSeen)
    }

    /// Not started yet, or less than `length` consumed.
    func isActive(now: Date = Date()) -> Bool {
        guard startedAt != nil else { return true }
        return consumedTime(now: now) < length
    }

    /// Whole days left, rounded up: `nil` before the trial starts and once it
    /// is over.
    func daysRemaining(now: Date = Date()) -> Int? {
        guard startedAt != nil else { return nil }
        let left = length - consumedTime(now: now)
        guard left > 0 else { return nil }
        return max(1, Int((left / 86_400).rounded(.up)))
    }
}
