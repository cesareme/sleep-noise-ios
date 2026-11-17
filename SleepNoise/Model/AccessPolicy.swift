import Foundation

/// Who gets what (C03, C04, C05).
///
/// Free, always: white, pink, brown, rain and wind; the whole timer, any
/// length up to the technical ceiling; three saved mixes. The free list only
/// grows.
///
/// Full access (purchased Pro, or the local trial while it runs) adds ocean,
/// fan, thunder, campfire, brook, cabin, the breathing tide and saved mixes
/// without a limit.
///
/// One carve-out: in Small Hours the tide plays for everyone, as part of a
/// fixed recipe that sells nothing.
///
/// `hasFullAccess` is `PurchaseManager.hasFullAccess`: purchased OR trial active.
enum AccessPolicy {
    static let proProductID = "com.cesareme.sleepnoise.pro"
    /// The sounds of the free tier (C04). Sounds are added, never removed.
    static let freeSounds: Set<SoundID> = [.white, .pink, .brown, .rain, .wind]
    static let freeSavedMixLimit = 3
    /// Technical ceiling of the timer, the same for everyone.
    static let maxTimerMinutes = 360
    static let trialDays = 7

    static func soundIsIncluded(_ sound: SoundID, hasFullAccess: Bool) -> Bool {
        hasFullAccess || freeSounds.contains(sound)
    }

    /// The timer is free in full (C03): the answer only says whether the
    /// length is in range. `hasFullAccess` stays in the signature for the
    /// callers that predate that decision.
    static func timerIsIncluded(minutes: Int, hasFullAccess: Bool) -> Bool {
        (1...maxTimerMinutes).contains(minutes)
    }

    static func canSave(existingCount: Int, hasFullAccess: Bool) -> Bool {
        if hasFullAccess { return true }
        return existingCount < freeSavedMixLimit
    }

    /// The tide as a control of the mixer: Pro.
    static func breathingIsIncluded(hasFullAccess: Bool) -> Bool {
        hasFullAccess
    }

    /// The tide for a given session: Pro, except in Small Hours, where it
    /// plays for everyone (C05).
    static func breathingIsIncluded(hasFullAccess: Bool, inSmallHours: Bool) -> Bool {
        hasFullAccess || inSmallHours
    }
}
