import Foundation

/// What loading a mix gives at an access level, for a house mix or a saved one.
///
/// A mix with Pro layers and no full access loads trimmed: it plays without
/// those layers and its title says so ("Sea and wind · without Ocean"). There
/// is no outcome here that asks for the Pro sheet, so loading can never open
/// it. The Pro layers keep their levels in `levels`; only `audibleLevels`
/// leaves them out, so nothing is lost and buying later brings the mix back
/// whole.
///
/// Which layers need Pro is asked of `AccessPolicy` (or of the rule passed
/// in), never listed here.
struct MixLoad: Equatable {
    /// A layer at or below this level is not part of the mix.
    static let audibleThreshold: Float = 0.001

    static let titleKey = "mezcla.nombre.sin"
    static let lastPairKey = "pagina.capas.ni"

    /// Every layer of the mix at its level. This is what the mixer holds.
    let levels: [SoundID: Float]
    /// What may play: `levels` with the layers that need Pro at zero.
    let audibleLevels: [SoundID: Float]
    /// The layers left out, loudest first.
    let omitted: [SoundID]

    var isTrimmed: Bool { !omitted.isEmpty }

    /// Nothing is left to play: an empty mix, or every layer needs Pro.
    var isSilent: Bool {
        !audibleLevels.values.contains { $0 > Self.audibleThreshold }
    }

    init(
        levels: [SoundID: Float],
        hasFullAccess: Bool,
        isIncluded: (SoundID, Bool) -> Bool = AccessPolicy.soundIsIncluded
    ) {
        var audible = levels
        var omitted: [SoundID] = []
        for sound in SoundID.allCases {
            guard (levels[sound] ?? 0) > Self.audibleThreshold, !isIncluded(sound, hasFullAccess) else { continue }
            audible[sound] = 0
            omitted.append(sound)
        }
        self.levels = levels
        audibleLevels = audible
        // Loudest first; `SoundID.allCases` order between equal levels.
        self.omitted = omitted.enumerated().sorted { left, right in
            let (a, b) = (levels[left.element] ?? 0, levels[right.element] ?? 0)
            return a == b ? left.offset < right.offset : a > b
        }.map(\.element)
    }

    /// The name the page shows: the mix's own name when it is whole, and
    /// "<name> · without <layers>" when it is trimmed. `soundName` and
    /// `localized` default to the string catalog.
    func title(
        name: String,
        soundName: (SoundID) -> String = { $0.localizedName },
        localized: (String) -> String = { String(localized: String.LocalizationValue($0)) }
    ) -> String {
        guard isTrimmed else { return name }
        return String(
            format: localized(Self.titleKey),
            name,
            Self.list(omitted.map(soundName), lastPair: localized(Self.lastPairKey))
        )
    }

    /// "A", "A or B", "A, B or C": the last two joined by the `lastPair`
    /// format, the ones before by commas.
    static func list(_ names: [String], lastPair: String) -> String {
        guard names.count > 1 else { return names.first ?? "" }
        let head = names.dropLast().joined(separator: ", ")
        return String(format: lastPair, head, names[names.count - 1])
    }
}
