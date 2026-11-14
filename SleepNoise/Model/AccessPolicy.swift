import Foundation

/// Free tier: white, pink, brown, rain, a 15 or 30 minute timer, and one saved mix.
/// Pro unlocks fan, ocean, any timer up to six hours, and unlimited mixes.
enum AccessPolicy {
    static let proProductID = "com.cesareme.sleepnoise.pro"
    static let freeSavedMixLimit = 1
    static let freeTimerMinutes: Set<Int> = [15, 30]
    static let maxTimerMinutes = 360

    static func soundIsIncluded(_ sound: SoundID, isPro: Bool) -> Bool {
        if isPro { return true }
        switch sound {
        case .white, .pink, .brown, .rain:
            return true
        case .fan, .ocean:
            return false
        }
    }

    static func timerIsIncluded(minutes: Int, isPro: Bool) -> Bool {
        guard (1...maxTimerMinutes).contains(minutes) else { return false }
        if isPro { return true }
        return freeTimerMinutes.contains(minutes)
    }

    static func canSave(existingCount: Int, isPro: Bool) -> Bool {
        if isPro { return true }
        return existingCount < freeSavedMixLimit
    }
}
