import Foundation

/// Six at once (C19): the one rule for how many layers sound.
///
/// Of the layers above zero that the access level includes, the six with
/// the highest level sound. The others wait: each keeps the level it has,
/// in the live mix and wherever it is stored, and does not sound, like a
/// Pro layer without access. When one of the six goes to zero, or stops
/// being included, the next one by level comes in.
///
/// The rule is a function of the levels and the access, with no memory, so
/// it holds whatever road led there: a saved mix or a house mix with more
/// than six layers, a Shortcut, the levels an earlier version stored, Pro
/// layers kept at a level when access comes back, or the trial ending the
/// other way round. Nothing stored is rewritten for it.
///
/// A level is compared as the whole percent the row shows and the mix
/// keeps, not as the fraction a finger passes through on its way: what is
/// heard in the middle of a drag is what is left when the finger lifts.
/// Two layers at the same percent: the one that comes first in
/// `SoundID.allCases` sounds. That order is the order of the stored ids and
/// never changes, so the same mix always sounds the same way.
enum LayerCap {
    /// The most layers that sound at once.
    static let limit = 6

    /// The level as the whole percent a row shows. The same arithmetic as
    /// `LevelMath.percent`, which lives with the design.
    static func percent(_ level: Float) -> Int {
        guard level == level else { return 0 }
        return Int((min(1, max(0, level)) * 100).rounded())
    }

    /// The layers above zero that are included, the highest level first.
    /// Equal percents keep the order of `SoundID.allCases`.
    static func ranked(_ levels: [SoundID: Float], isIncluded: (SoundID) -> Bool) -> [SoundID] {
        SoundID.allCases
            .filter { (levels[$0] ?? 0) > MixLoad.audibleThreshold && isIncluded($0) }
            .enumerated()
            .sorted { left, right in
                let (a, b) = (percent(levels[left.element] ?? 0), percent(levels[right.element] ?? 0))
                return a == b ? left.offset < right.offset : a > b
            }
            .map(\.element)
    }

    /// The layers that sound: the first `limit` of `ranked`.
    static func sounding(_ levels: [SoundID: Float], isIncluded: (SoundID) -> Bool) -> Set<SoundID> {
        Set(ranked(levels, isIncluded: isIncluded).prefix(limit))
    }

    /// The layers that wait, the next one to come in first: included, above
    /// zero and beyond the first `limit`.
    static func waiting(_ levels: [SoundID: Float], isIncluded: (SoundID) -> Bool) -> [SoundID] {
        Array(ranked(levels, isIncluded: isIncluded).dropFirst(limit))
    }
}
