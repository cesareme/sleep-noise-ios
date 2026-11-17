import Foundation

/// What the Small Hours screen says (03 §5 #11; copy guide §2.6), worked
/// out without a view.
///
/// A figure that goes down by the minute and, during the last five, one
/// word: "Winding down · n min" (C60). Nothing else: no hour, no "Pro", no
/// trial, no name of a mix. Paused, there is no word at all: the figure
/// stands still and the line is gone. When it ends, nothing is said.
enum SmallHoursStatus: Equatable {
    /// The sea, with or without the tide still guiding.
    case playing(minutes: Int)
    /// The last five minutes: the sea is leaving.
    case windingDown(minutes: Int)
    case paused(minutes: Int)
    /// The engine did not start again. A touch tries once more.
    case noSound(minutes: Int)

    struct Input: Equatable {
        var isPlaying = false
        var minutesLeft = 0
        var windingDownMinutes: Int?
        /// Starts that failed in a row. Zero when the last one worked.
        var startFailures = 0
    }

    static func resolve(_ input: Input) -> SmallHoursStatus {
        guard input.isPlaying else {
            return input.startFailures > 0
                ? .noSound(minutes: input.minutesLeft)
                : .paused(minutes: input.minutesLeft)
        }
        if let winding = input.windingDownMinutes { return .windingDown(minutes: winding) }
        return .playing(minutes: input.minutesLeft)
    }

    var minutes: Int {
        switch self {
        case .playing(let minutes), .windingDown(let minutes), .paused(let minutes), .noSound(let minutes):
            return minutes
        }
    }

    var isSounding: Bool {
        switch self {
        case .playing, .windingDown: return true
        case .paused, .noSound: return false
        }
    }

    /// The figure: "14 min".
    func figure(localized: (String) -> String = { Localized.string($0) }, locale: Locale = .current) -> String {
        String(format: localized("madrugada.quedan"), locale: locale, Int64(minutes))
    }

    /// The word under the figure. Nil leaves its line empty.
    func word(localized: (String) -> String = { Localized.string($0) }, locale: Locale = .current) -> String? {
        switch self {
        case .playing, .paused:
            return nil
        case .windingDown(let minutes):
            return String(format: localized("madrugada.retirada"), locale: locale, Int64(minutes))
        case .noSound:
            return localized("noche.estado.sin_sonido")
        }
    }

    /// What VoiceOver reads as the value of the screen.
    func spoken(localized: (String) -> String = { Localized.string($0) }) -> String {
        switch self {
        case .playing(let minutes):
            return String.localizedStringWithFormat(
                localized("ax.madrugada.valor"), minutes, localized("noche.estado.sonando")
            )
        case .paused(let minutes):
            return String.localizedStringWithFormat(
                localized("ax.madrugada.valor"), minutes, localized("noche.estado.pausa")
            )
        case .noSound(let minutes):
            return String.localizedStringWithFormat(
                localized("ax.madrugada.valor"), minutes, localized("noche.estado.sin_sonido")
            )
        case .windingDown(let minutes):
            return String.localizedStringWithFormat(localized("ax.madrugada.retirada"), minutes)
        }
    }

    var hintKey: String {
        switch self {
        case .playing, .windingDown: return "ax.madrugada.pista"
        case .paused: return "ax.madrugada.pista.reanudar"
        case .noSound: return "ax.noche.pista.error"
        }
    }
}

/// The water line of Small Hours: the tide of the recipe, read from the
/// same anchor as the audio (C05).
enum SmallHoursWater {
    /// How much of its course the line keeps `elapsed` seconds into the
    /// session: all of it while the tide guides, less and less while it
    /// dissolves, none once it has gone.
    static func amplitude(elapsed: TimeInterval, recipe: SmallHoursRecipe) -> Float {
        if elapsed <= recipe.tideGuideEnd { return 1 }
        let length = recipe.tideDissolveEnd - recipe.tideGuideEnd
        guard length > 0, elapsed < recipe.tideDissolveEnd else { return 0 }
        return Float((recipe.tideDissolveEnd - elapsed) / length)
    }

    /// Height of the water at an instant, 0 at low tide and 1 at high tide.
    /// The breath is the guiding one whatever the dissolve has done to the
    /// parameters the engine holds: the line only loses height.
    static func level(
        at date: Date,
        anchor: Date?,
        elapsed: TimeInterval,
        recipe: SmallHoursRecipe
    ) -> Float {
        guard let anchor else { return 0 }
        let breath = BreathCurve.value(
            secondsSinceStart: max(0, date.timeIntervalSince(anchor)),
            parameters: .guided(breathsPerMinute: recipe.breathsPerMinute)
        )
        return breath * amplitude(elapsed: elapsed, recipe: recipe)
    }
}
