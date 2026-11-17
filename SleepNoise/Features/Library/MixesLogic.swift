import Foundation

/// The name a mix gets from its layers when the person gave it none (copy
/// guide §4.2): what the save field starts with for a mix that is still
/// "Tonight". It only lists what is in the mix and promises nothing.
///
/// One layer is its name ("Pink"), two are "Pink and rain", three "Pink,
/// rain and wind", four or more "Pink and 3 more". The first layer keeps its
/// capital; the rest are part of a phrase. With no layer above zero the name
/// is "Tonight".
enum MixAutoName {
    static let pairKey = "pagina.capas.y"
    static let threeKey = "mezcla.nombre.auto.3"
    static let moreKey = "mezcla.nombre.auto.mas"

    /// The order the Layers sheet lists them in: colours, then beds.
    static let order = PageLayers.colors + PageLayers.beds

    /// The layers above zero, in the order the name reads them. A Pro layer
    /// that keeps a level without access is one of them: a save keeps it.
    static func layers(_ levels: [SoundID: Float]) -> [SoundID] {
        order.filter { (levels[$0] ?? 0) > MixLoad.audibleThreshold }
    }

    static func name(
        levels: [SoundID: Float],
        soundName: (SoundID) -> String = { $0.localizedName },
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> String {
        let present = layers(levels)
        let names = present.enumerated().map { index, sound in
            index == 0 ? soundName(sound) : soundName(sound).lowercased(with: locale)
        }
        switch names.count {
        case 0: return localized(PageTitle.liveKey)
        case 1: return names[0]
        case 2: return String(format: localized(pairKey), names[0], names[1])
        case 3: return String(format: localized(threeKey), names[0], names[1], names[2])
        default: return String(format: localized(moreKey), locale: locale, names[0], Int64(names.count - 1))
        }
    }
}

/// The recipe line of a mix (08 §2.1): its layers above zero, loudest
/// first, as a name in lower case and a whole number ("rain 55 · pink 20").
/// Only levels: a mix keeps no timer and no tide (C20).
///
/// A layer that needs Pro without access is said at the end, in the same
/// ink and in words ("· ocean is Pro"). Nothing is struck through and
/// nothing is dimmed: the recipe is the whole mix, and that is what a save
/// keeps.
struct MixRecipe: Equatable {
    struct Layer: Equatable {
        let sound: SoundID
        let percent: Int
    }

    static let layerKey = "mezclas.receta.capa"
    static let proKey = "mezclas.receta.pro"
    static let separatorKey = "mezclas.receta.separador"
    static let spokenProKey = "ax.receta.pro"

    /// Loudest first; `SoundID.allCases` order between equal levels.
    let layers: [Layer]
    /// The layers that do not sound at this access level, loudest first.
    let needsPro: [SoundID]

    var isEmpty: Bool { layers.isEmpty }

    init(levels: [SoundID: Float], hasFullAccess: Bool) {
        let load = MixLoad(levels: levels, hasFullAccess: hasFullAccess)
        layers = SoundID.allCases.enumerated()
            .filter { (levels[$0.element] ?? 0) > MixLoad.audibleThreshold }
            .sorted { left, right in
                let (a, b) = (levels[left.element] ?? 0, levels[right.element] ?? 0)
                return a == b ? left.offset < right.offset : a > b
            }
            .map { Layer(sound: $0.element, percent: LevelMath.percent(levels[$0.element] ?? 0)) }
        needsPro = load.omitted
    }

    /// The segments of the line, in order: one per layer, then one per layer
    /// that needs Pro. `namesPro` is false on the night page, where "is
    /// Pro" and "requires Pro" do not exist (copy guide §3): the recipe is
    /// only its layers there.
    func segments(
        namesPro: Bool = true,
        soundName: (SoundID) -> String = { $0.localizedName },
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> [String] {
        layers.map { layer in
            String(
                format: localized(Self.layerKey),
                locale: locale,
                soundName(layer.sound).lowercased(with: locale),
                Int64(layer.percent)
            )
        } + (namesPro ? needsPro : []).map { sound in
            String(format: localized(Self.proKey), soundName(sound).lowercased(with: locale))
        }
    }

    /// The line as it is set (mock-up, plate 14). A segment never breaks
    /// inside ("rain 50", "fan is Pro") and the separator opens the
    /// segment after it, so a second line reads "· fan is Pro": the
    /// clause whole, and no line ends with a dot.
    ///
    /// `loosePro` is for the largest text size, where the longest clause
    /// is wider than the column: only its last two words stay together.
    func text(
        namesPro: Bool = true,
        loosePro: Bool = false,
        soundName: (SoundID) -> String = { $0.localizedName },
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> String {
        let all = segments(namesPro: namesPro, soundName: soundName, localized: localized, locale: locale)
        let tied = all.enumerated().map { index, segment in
            loosePro && index >= layers.count ? LineTies.tail(segment) : LineTies.whole(segment)
        }
        return LineTies.joined(tied, separator: localized(Self.separatorKey))
    }

    /// What VoiceOver reads: the layers as a list, and "ocean requires Pro"
    /// instead of the phrase on screen.
    func spoken(
        namesPro: Bool = true,
        soundName: (SoundID) -> String = { $0.localizedName },
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> String {
        let parts = layers.map { layer in
            String(
                format: localized(Self.layerKey),
                locale: locale,
                soundName(layer.sound).lowercased(with: locale),
                Int64(layer.percent)
            )
        } + (namesPro ? needsPro : []).map { sound in
            String(format: localized(Self.spokenProKey), soundName(sound).lowercased(with: locale))
        }
        return parts.joined(separator: ", ")
    }
}

/// Which mix a row, a Shortcut or the stored identity points at. The string
/// form is what Shortcuts keep, so it is frozen by a test: `house:<raw
/// value>` and `saved:<UUID>`.
enum MixReference: Hashable {
    case house(HouseMix)
    case saved(UUID)

    private static let housePrefix = "house:"
    private static let savedPrefix = "saved:"

    var stableID: String {
        switch self {
        case .house(let mix): return Self.housePrefix + mix.rawValue
        case .saved(let id): return Self.savedPrefix + id.uuidString
        }
    }

    init?(stableID: String) {
        if stableID.hasPrefix(Self.housePrefix),
           let mix = HouseMix(rawValue: String(stableID.dropFirst(Self.housePrefix.count))) {
            self = .house(mix)
        } else if stableID.hasPrefix(Self.savedPrefix),
                  let id = UUID(uuidString: String(stableID.dropFirst(Self.savedPrefix.count))) {
            self = .saved(id)
        } else {
            return nil
        }
    }
}

/// What the Mixes sheet lists (03 §5, surface 12): the person's mixes with
/// the live one first while it has no name of its own, then the four of the
/// house. Pure, so the sheet only draws it.
struct MixesList: Equatable {
    struct Row: Equatable, Identifiable {
        let reference: MixReference
        let name: String
        let recipe: MixRecipe
        /// This is the loaded mix, as it was loaded, and it is sounding.
        let isSounding: Bool

        var id: String { reference.stableID }
    }

    /// The live mix as the first row of "yours": only while it is "Tonight"
    /// and has something in it. A mix loaded as it was saved is its own row.
    struct Live: Equatable {
        let recipe: MixRecipe
        /// A fourth mix without access: the row says "pro" and a save is a
        /// request for the Pro sheet, which the night refuses.
        let needsPro: Bool
    }

    struct Input {
        var saved: [SavedMix] = []
        var levels: [SoundID: Float] = [:]
        /// The mix that is loaded as it was: nil once a level is edited.
        var loaded: MixReference?
        var isPlaying = false
        var hasFullAccess = false
    }

    let live: Live?
    let yours: [Row]
    let house: [Row]

    /// "Yours" has nothing in it: the sentence that says where a mix is
    /// saved from takes the place of the section's rows.
    var showsEmptyNote: Bool { live == nil && yours.isEmpty }

    init(_ input: Input, houseName: (HouseMix) -> String = { $0.localizedName }) {
        let liveRecipe = MixRecipe(levels: input.levels, hasFullAccess: input.hasFullAccess)
        if input.loaded == nil, !liveRecipe.isEmpty {
            live = Live(
                recipe: liveRecipe,
                needsPro: !AccessPolicy.canSave(
                    existingCount: input.saved.count,
                    hasFullAccess: input.hasFullAccess
                )
            )
        } else {
            live = nil
        }
        yours = input.saved.map { mix in
            let reference = MixReference.saved(mix.id)
            return Row(
                reference: reference,
                name: mix.name,
                recipe: MixRecipe(levels: mix.levelsBySound, hasFullAccess: input.hasFullAccess),
                isSounding: input.isPlaying && input.loaded == reference
            )
        }
        house = HouseMix.allCases.map { mix in
            let reference = MixReference.house(mix)
            return Row(
                reference: reference,
                name: houseName(mix),
                recipe: MixRecipe(levels: mix.levelsBySound(), hasFullAccess: input.hasFullAccess),
                isSounding: input.isPlaying && input.loaded == reference
            )
        }
    }

    /// What VoiceOver reads for a row: the name and the recipe as a list.
    static func spokenLabel(name: String, recipe: String) -> String {
        recipe.isEmpty ? name : "\(name), \(recipe)"
    }
}
