import Foundation

/// Which layers the page shows, and in what order (spec 05 §2.0).
///
/// The page shows the layers of the loaded mix that are above zero: beds
/// first, then colours, as many as there are rows. What does not fit is a
/// number on the "All layers" row. The Layers sheet keeps its own order,
/// colours and then beds.
///
/// The set is chosen when a mix loads and when the Layers sheet closes, not
/// while a finger is on a row: a row dragged to zero keeps its place, so it
/// can be brought back, and nothing on the page changes position.
enum PageLayers {
    /// The three noise colours, in the order the Layers sheet lists them.
    static let colors: [SoundID] = [.white, .pink, .brown]
    /// The beds: the two free ones first, then the rest in `SoundID` order.
    static let beds: [SoundID] = [.rain, .wind, .fan, .ocean, .thunder, .campfire, .brook, .cabin]
    /// The page: beds first. What is turned down at three in the morning is
    /// a layer with events, not the noise under it.
    static let pageOrder: [SoundID] = beds + colors

    /// Rows on a full-height screen at the regular text sizes.
    static let fullCapacity = 3

    /// Layers above zero, in page order. A Pro layer that keeps a level
    /// without access is one of them: its row says "pro · 30".
    static func present(_ levels: [SoundID: Float]) -> [SoundID] {
        pageOrder.filter { (levels[$0] ?? 0) > MixLoad.audibleThreshold }
    }

    /// The rows of the page for these levels: the first `capacity` layers
    /// above zero.
    static func rows(_ levels: [SoundID: Float], capacity: Int) -> [SoundID] {
        Array(present(levels).prefix(max(0, capacity)))
    }

    /// How many layers above zero have no row: the "and 2 more" of the
    /// "All layers" row. Zero means the row shows no value.
    static func more(_ levels: [SoundID: Float], rows: [SoundID]) -> Int {
        present(levels).filter { !rows.contains($0) }.count
    }

    /// A layer that came up on its own (Play on an empty mix raises pink)
    /// takes the first empty row. With no row free it has none: it sounds,
    /// it is in the Layers sheet, and the state line names it.
    static func adding(_ sound: SoundID, to rows: [SoundID], capacity: Int) -> [SoundID] {
        guard !rows.contains(sound), rows.count < capacity else { return rows }
        return rows + [sound]
    }

    /// Rows that fit: three on a tall screen, two on a short one or from the
    /// first accessibility text size, one from the third (05 §2.13, §5d).
    static func capacity(fullHeight: Double, isAccessibilitySize: Bool, isLargestSizes: Bool) -> Int {
        if isLargestSizes { return 1 }
        if isAccessibilitySize { return 2 }
        return fullHeight < 800 ? 2 : fullCapacity
    }
}

/// The name of the live mix (reconciliation §3, C39): the loaded mix's name,
/// trimmed part included, while it is loaded as it was; "Tonight" as soon as
/// a level is edited or when nothing was loaded.
enum PageTitle {
    static let liveKey = "mezcla.nombre.vacio"

    static func text(
        loadedMixName: String?,
        localized: (String) -> String = { Localized.string($0) }
    ) -> String {
        guard let loadedMixName, !loadedMixName.isEmpty else { return localized(liveKey) }
        return loadedMixName
    }
}

/// The state line of the page: what is happening, in words (copy guide §3).
/// Never a colour, never a badge.
enum PageStatus: Equatable {
    /// Nothing sounds and nothing is paused.
    case silent
    /// Nothing would sound: every layer of the mix needs Pro.
    case silentAllPro
    case playing
    /// Playing with the sleep timer counting: when it ends.
    case playingFadesAt(Date)
    /// Playing under a blanket: the hour it sounds until.
    case playingUntil(Date)
    /// The final fade of the timer is running: whole minutes left.
    case fading(minutes: Int)
    /// Playing without the Pro layers of the mix, loudest first.
    case playingWithout([SoundID])
    /// Play raised the fallback layer because nothing else would sound.
    case playingFallback(SoundID, percent: Int)
    /// The night came back on the speaker, turned down to the cap (C49):
    /// the session level, until the next touch.
    case playingAt(percent: Int)
    case paused
    /// Paused because the output went away, or from the headphones.
    case pausedHeadphones
    /// Paused by a call (C48).
    case pausedCall
    /// The engine did not start. The line is a button that tries again;
    /// `attempt` is 1, 2, or 3 and more.
    case error(attempt: Int)

    struct Input: Equatable {
        var isPlaying = false
        var pauseCause: PauseCause?
        /// Starts that failed in a row. Zero when the last one worked.
        var startFailures = 0
        var timerEndsAt: Date?
        /// The timer is a blanket: it ends at an hour the person chose.
        var timerEndsAtAnHour = false
        var timerIsFading = false
        var timerRemaining: TimeInterval?
        /// Pro layers above zero that do not sound, loudest first.
        var omitted: [SoundID] = []
        /// No layer would sound at this access level.
        var isSilent = false
        var isPlayingFallback = false
        /// The night page says nothing about Pro.
        var isNightSession = false
        /// The output that went away was a pair of headphones, as far as
        /// the system tells. Anything else is just "Paused".
        var lostOutputWasHeadphones = true
        /// The session level to say after a resume capped for the speaker.
        var cappedLevelNote: Int?
    }

    static func resolve(_ input: Input) -> PageStatus {
        if input.isPlaying {
            if input.timerIsFading {
                let seconds = max(0, input.timerRemaining ?? 0)
                return .fading(minutes: max(1, Int((seconds / 60).rounded(.up))))
            }
            if let percent = input.cappedLevelNote { return .playingAt(percent: percent) }
            if input.isPlayingFallback {
                return .playingFallback(
                    MixerModel.fallbackSound,
                    percent: Int((MixerModel.fallbackLevel * 100).rounded())
                )
            }
            if let end = input.timerEndsAt {
                return input.timerEndsAtAnHour ? .playingUntil(end) : .playingFadesAt(end)
            }
            if !input.omitted.isEmpty { return .playingWithout(input.omitted) }
            return .playing
        }
        if input.startFailures > 0 { return .error(attempt: min(3, input.startFailures)) }
        switch input.pauseCause {
        case .headphones: return .pausedHeadphones
        case .lostOutput: return input.lostOutputWasHeadphones ? .pausedHeadphones : .paused
        case .call: return .pausedCall
        case .person, .system: return .paused
        case nil: break
        }
        if input.isSilent, !input.omitted.isEmpty, !input.isNightSession { return .silentAllPro }
        return .silent
    }

    /// The line retries the start when tapped.
    var isRetry: Bool {
        if case .error = self { return true }
        return false
    }

    /// The words, from the catalog. `time` formats the hour the timer ends:
    /// the short time of the system by default.
    func text(
        localized: (String) -> String = { Localized.string($0) },
        soundName: (SoundID) -> String = { $0.localizedName },
        time: (Date) -> String = { $0.formatted(date: .omitted, time: .shortened) },
        locale: Locale = .current
    ) -> String {
        switch self {
        case .silent:
            return localized("pagina.estado.silencio")
        case .silentAllPro:
            return localized("pagina.estado.silencio.pro")
        case .playing:
            return localized("pagina.estado.sonando")
        case .playingFadesAt(let date):
            let hour = time(date)
            return String(format: localized(HourPhrase.key("pagina.estado.sonando.funde", at: hour)), hour)
        case .playingUntil(let date):
            let hour = time(date)
            return String(format: localized(HourPhrase.key("pagina.estado.sonando.hasta", at: hour)), hour)
        case .fading(let minutes):
            return String(format: localized("pagina.estado.fundiendo"), locale: locale, Int64(minutes))
        case .playingWithout(let sounds):
            // In the name the layer is capitalised; here it is a phrase.
            let names = sounds.map { soundName($0).lowercased(with: locale) }
            let list = MixLoad.list(names, lastPair: localized(MixLoad.lastPairKey))
            return String(format: localized("pagina.estado.sonando.sin"), list)
        case .playingFallback(let sound, let percent):
            return String(
                format: localized("pagina.estado.sonando.defecto"),
                locale: locale,
                soundName(sound).lowercased(with: locale),
                Int64(percent)
            )
        case .playingAt(let percent):
            return String(format: localized("estado.volumen"), locale: locale, Int64(percent))
        case .paused:
            return localized("pagina.estado.pausa")
        case .pausedHeadphones:
            return localized("estado.pausa.auriculares")
        case .pausedCall:
            return localized("pagina.estado.pausa.llamada")
        case .error(let attempt):
            switch attempt {
            case ...1: return localized("pagina.error.inicio")
            case 2: return localized("pagina.error.inicio.2")
            default: return localized("pagina.error.inicio.3")
            }
        }
    }

    /// What VoiceOver reads: the same words with the separators as pauses.
    static func spoken(_ text: String) -> String {
        text.replacingOccurrences(of: " · ", with: ", ")
    }

    /// The error line as it is set (05 §2.12): one sentence per line. A
    /// single long sentence keeps its last three words together instead, so
    /// the second line is never one word on its own. `bindsTail` is off at
    /// the accessibility text sizes, where three words may not fit a line.
    static func errorLines(_ text: String, bindsTail: Bool = true) -> String {
        if let stop = text.range(of: ". ") {
            return text.replacingCharacters(in: stop, with: ".\n")
        }
        guard bindsTail else { return text }
        var words = text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        guard words.count > 4 else { return text }
        let tail = words.suffix(3).joined(separator: "\u{00A0}")
        words.removeLast(3)
        return (words + [tail]).joined(separator: " ")
    }
}

/// The header of the page: the trial as a state word (08 §2.4).
///
/// It appears only once the trial has begun (C07): the first screen of a
/// new install says nothing about a trial. While it runs it says how many
/// nights are left, and "last night" on the last one. On the day the trial
/// runs out no night is left, so there is no figure and no word. After it,
/// "always free" for the first free sessions, then nothing. Bought: nothing.
/// It is shown only while something may be sold: never inside the night
/// window, on the night page or in Small Hours (C08). The page passes
/// `MixerModel.canSell`.
enum PageTrialWord {
    static let nightsLeftKey = "pro.prueba.estado"
    static let lastNightKey = "pro.prueba.estado.ultima"
    static let alwaysFreeKey = "pro.prueba.estado.gratis"

    static func text(
        trial: TrialState,
        isPro: Bool,
        showsAlwaysFree: Bool = false,
        canSell: Bool = true,
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> String? {
        guard !isPro, canSell else { return nil }
        let words: String
        switch trial {
        case .notStarted:
            return nil
        case .active(let nights) where nights >= 2:
            words = String.localizedStringWithFormat(localized(nightsLeftKey), nights)
        case .active(let nights) where nights == 1:
            words = localized(lastNightKey)
        case .active:
            return nil
        case .ended:
            guard showsAlwaysFree else { return nil }
            words = localized(alwaysFreeKey)
        }
        // State words are small caps: written in lower case.
        return words.lowercased(with: locale)
    }

    static let spokenNightsLeftKey = "ax.prueba.cabecera"

    /// What VoiceOver reads: the figure in a sentence of its own ("Trial,
    /// five nights left") and the separators as pauses.
    static func spoken(
        trial: TrialState,
        isPro: Bool,
        showsAlwaysFree: Bool = false,
        canSell: Bool = true,
        localized: (String) -> String = { Localized.string($0) },
        locale: Locale = .current
    ) -> String? {
        guard let text = text(
            trial: trial,
            isPro: isPro,
            showsAlwaysFree: showsAlwaysFree,
            canSell: canSell,
            localized: localized,
            locale: locale
        ) else { return nil }
        if case .active(let nights) = trial, nights >= 2 {
            return String.localizedStringWithFormat(localized(spokenNightsLeftKey), nights)
        }
        return PageStatus.spoken(text)
    }
}

/// The two things the page says once about the trial (08 §2.4), by day and
/// in silence, never at night: the model decides when (`visibleTrialNote`).
///
/// The last night is a sentence in the place of the state line, until the
/// Play. The end is a note under the state line with "Got it". Neither is a
/// sheet, a notification or a count.
enum PageTrialNote {
    static let lastNightKey = "prueba.ultima"
    static let endedKey = "prueba.terminada"
    static let dismissKey = "comun.entendido"

    /// The sentence that takes the state line. Only "Silent" gives way to
    /// it: a pause, an error or a mix that would not sound say what they
    /// have to say first.
    static func statusLine(
        _ note: TrialNote?,
        status: PageStatus,
        localized: (String) -> String = { Localized.string($0) }
    ) -> String? {
        guard note == .lastNight, status == .silent else { return nil }
        return localized(lastNightKey)
    }

    /// The note under the state line, with its "Got it".
    static func footnote(
        _ note: TrialNote?,
        localized: (String) -> String = { Localized.string($0) }
    ) -> String? {
        note == .ended ? localized(endedKey) : nil
    }
}
