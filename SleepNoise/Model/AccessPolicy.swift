import Foundation

/// Free tier: white, pink, brown, rain, a 15, 30 or 60 minute timer, and one
/// saved mix. Full access (purchased Pro, or the local seven-day trial) unlocks
/// fan, ocean, thunder, campfire, brook, wind, cabin, the breathing tide, any
/// timer up to six hours, and unlimited mixes.
///
/// `hasFullAccess` is `PurchaseManager.hasFullAccess`: purchased OR trial active.
enum AccessPolicy {
    static let proProductID = "com.cesareme.sleepnoise.pro"
    static let freeSavedMixLimit = 1
    static let freeTimerMinutes: Set<Int> = [15, 30, 60]
    static let maxTimerMinutes = 360
    static let trialDays = 7

    static func soundIsIncluded(_ sound: SoundID, hasFullAccess: Bool) -> Bool {
        if hasFullAccess { return true }
        switch sound {
        case .white, .pink, .brown, .rain:
            return true
        case .fan, .ocean, .thunder, .campfire, .stream, .wind, .cabin:
            return false
        }
    }

    static func timerIsIncluded(minutes: Int, hasFullAccess: Bool) -> Bool {
        guard (1...maxTimerMinutes).contains(minutes) else { return false }
        if hasFullAccess { return true }
        return freeTimerMinutes.contains(minutes)
    }

    static func canSave(existingCount: Int, hasFullAccess: Bool) -> Bool {
        if hasFullAccess { return true }
        return existingCount < freeSavedMixLimit
    }

    static func breathingIsIncluded(hasFullAccess: Bool) -> Bool {
        hasFullAccess
    }
}
