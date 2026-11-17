import XCTest
@testable import SleepNoise

private let tie = "\u{00A0}"

/// Where the words of a line may break: what the final adjustment of S-06
/// fixed after looking at the captures.
final class LineTiesTests: XCTestCase {
    func testAShortPhraseNeverBreaksInside() {
        XCTAssertEqual(LineTies.whole("rain 50"), "rain\(tie)50")
        XCTAssertEqual(LineTies.whole("fan is Pro"), "fan\(tie)is\(tie)Pro")
        XCTAssertEqual(LineTies.whole("rain"), "rain")
    }

    func testALongPhraseKeepsItsLastTwoWordsTogether() {
        XCTAssertEqual(LineTies.tail("ventilador es Pro"), "ventilador es\(tie)Pro")
        XCTAssertEqual(LineTies.tail("Pro"), "Pro")
    }

    func testTheDotOpensTheSegmentAfterIt() {
        // A break is only possible before a dot: a line never ends with one.
        XCTAssertEqual(LineTies.joined(["a", "b", "c"]), "a ·\(tie)b ·\(tie)c")
        XCTAssertEqual(LineTies.joined(["a"]), "a")
        XCTAssertEqual(LineTies.joined([]), "")
    }

    func testAPhraseOfTheCatalogIsSetWithItsDotsLeading() {
        XCTAssertEqual(LineTies.dotLeads("En pausa · auriculares"), "En pausa ·\(tie)auriculares")
        XCTAssertEqual(LineTies.dotLeads("Small hours · 20 min"), "Small hours ·\(tie)20\(tie)min")
        XCTAssertEqual(LineTies.dotLeads("Sonando · al 40"), "Sonando ·\(tie)al\(tie)40")
        XCTAssertEqual(LineTies.dotLeads("a · b c · d e"), "a ·\(tie)b\(tie)c ·\(tie)d\(tie)e")
        // Nothing to tie: the phrase is left as the catalog has it.
        XCTAssertEqual(LineTies.dotLeads("Se funde a las 03:42"), "Se funde a las 03:42")
        XCTAssertEqual(LineTies.dotLeads(""), "")
    }

    func testTheWordsAreTheSameOnceTheTiesAreSpaces() {
        for text in ["En pausa · auriculares", "Madrugada · 20 min", "Fundiendo · 8 min", "Sonando"] {
            XCTAssertEqual(LineTies.dotLeads(text).replacingOccurrences(of: tie, with: " "), text)
        }
    }

    func testAParagraphIsSetOneSentencePerLine() {
        XCTAssertEqual(
            LineTies.sentences("Puedes apagar la pantalla. El sonido sigue."),
            ["Puedes apagar la pantalla.", "El sonido sigue."]
        )
        XCTAssertEqual(LineTies.sentences("One. Two. Three."), ["One.", "Two.", "Three."])
        XCTAssertEqual(LineTies.sentences("Hold to go back"), ["Hold to go back"])
        XCTAssertEqual(LineTies.sentences(""), [])
    }

    /// The first-time sentence of Night is two sentences in both languages,
    /// so Night sets it in two lines and not as a paragraph that wraps.
    func testTheFirstSentenceOfNightIsTwoLinesInBothLanguages() throws {
        let strings = try TimerCatalogTests.catalog()
        let expected = [
            "es": ["Puedes apagar la pantalla.", "El sonido sigue."],
            "en": ["You can turn the screen off.", "The sound keeps playing."],
        ]
        for (language, lines) in expected {
            let value = try XCTUnwrap(TimerCatalogTests.values("noche.primera", language, in: strings).first)
            XCTAssertEqual(LineTies.sentences(value), lines, language)
        }
    }

    /// Every state and action of the night that carries a dot can only
    /// break before it, in both languages.
    func testTheWordsOfTheNightBreakBeforeTheirDot() throws {
        let strings = try TimerCatalogTests.catalog()
        let keys = [
            "noche.estado.fundiendo", "estado.volumen", "estado.pausa.auriculares",
            "pagina.estado.pausa.llamada", "madrugada.estado",
        ]
        for key in keys {
            for language in ["en", "es"] {
                let value = try XCTUnwrap(TimerCatalogTests.values(key, language, in: strings).first, key)
                let text = String(format: value, locale: Locale(identifier: "en_US_POSIX"), Int64(20))
                let set = LineTies.dotLeads(text)
                XCTAssertTrue(text.contains(" · "), "\(key) [\(language)] carries a dot")
                XCTAssertFalse(set.contains("· "), "\(key) [\(language)]: no break after the dot")
                XCTAssertTrue(set.contains(" ·\(tie)"), "\(key) [\(language)]: the break is before it")
                let last = try XCTUnwrap(set.components(separatedBy: " ·\(tie)").last)
                XCTAssertFalse(last.contains(" "), "\(key) [\(language)]: what follows the dot stays whole")
            }
        }
    }

    // MARK: Small Hours

    /// The figure says the minutes; the words under it do not say them
    /// again (C60 keeps the name of the state, "Winding down").
    func testWindingDownDoesNotRepeatTheFigure() throws {
        let strings = try TimerCatalogTests.catalog()
        XCTAssertEqual(TimerCatalogTests.values("madrugada.retirada.palabra", "es", in: strings), ["Se retira"])
        XCTAssertEqual(TimerCatalogTests.values("madrugada.retirada.palabra", "en", in: strings), ["Winding down"])
        XCTAssertTrue(
            TimerCatalogTests.values("madrugada.retirada", "es", in: strings).isEmpty,
            "the phrase with the figure in it is not set anywhere"
        )

        let winding = SmallHoursStatus.windingDown(minutes: 4)
        let posix = Locale(identifier: "en_US_POSIX")
        let word = try XCTUnwrap(winding.word(
            localized: { $0 == "madrugada.retirada.palabra" ? "Winding down" : $0 }, locale: posix
        ))
        XCTAssertEqual(word, "Winding down")
        XCTAssertNil(word.rangeOfCharacter(from: .decimalDigits))
        XCTAssertEqual(winding.figure(localized: { _ in "%lld min" }, locale: posix), "4 min")
        // VoiceOver still says both, in one sentence.
        XCTAssertEqual(
            winding.spoken(localized: { $0 == "ax.madrugada.retirada" ? "winding, %lld left" : $0 }),
            "winding, 4 left"
        )
    }

    // MARK: The recipe of a mix

    private func lookup(_ key: String) -> String {
        switch key {
        case MixRecipe.proKey: return "%@ es Pro"
        case MixRecipe.layerKey: return "%1$@ %2$lld"
        default: return "·"
        }
    }

    private let names: (SoundID) -> String = { sound in
        switch sound {
        case .rain: return "Lluvia"
        case .fan: return "Ventilador"
        case .brown: return "Marrón"
        default: return sound.rawValue
        }
    }

    /// Mock-up, plate 14: "lluvia 50 · ventilador 30 · marrón 20" and, on
    /// its own line, "· ventilador es Pro".
    func testTheClauseOfProGoesToTheNextLineWhole() {
        let recipe = MixRecipe(levels: [.rain: 0.5, .fan: 0.3, .brown: 0.2], hasFullAccess: false)
        let text = recipe.text(soundName: names, localized: lookup, locale: Locale(identifier: "es_ES"))
        XCTAssertEqual(
            text,
            "lluvia\(tie)50 ·\(tie)ventilador\(tie)30 ·\(tie)marrón\(tie)20 ·\(tie)ventilador\(tie)es\(tie)Pro"
        )
        // The only places a line can break are the spaces before a dot.
        let pieces = text.components(separatedBy: " ")
        XCTAssertEqual(pieces.count, 4)
        XCTAssertTrue(pieces.dropFirst().allSatisfy { $0.hasPrefix("·\(tie)") })
        XCTAssertEqual(pieces.last, "·\(tie)ventilador\(tie)es\(tie)Pro")
        XCTAssertEqual(text.replacingOccurrences(of: tie, with: " "), "lluvia 50 · ventilador 30 · marrón 20 · ventilador es Pro")
    }

    /// At the largest text size the clause may be wider than the column:
    /// it may break after the name, and "es Pro" stays together.
    func testAtTheLargestSizeTheClauseOnlyKeepsItsTail() {
        let recipe = MixRecipe(levels: [.rain: 0.5, .fan: 0.3], hasFullAccess: false)
        let text = recipe.text(loosePro: true, soundName: names, localized: lookup, locale: Locale(identifier: "es_ES"))
        XCTAssertEqual(text, "lluvia\(tie)50 ·\(tie)ventilador\(tie)30 ·\(tie)ventilador es\(tie)Pro")
        // The layers are not loosened, and the night recipe has no clause.
        let night = recipe.text(namesPro: false, loosePro: true, soundName: names, localized: lookup, locale: Locale(identifier: "es_ES"))
        XCTAssertEqual(night, "lluvia\(tie)50 ·\(tie)ventilador\(tie)30")
    }

    // MARK: The water line

    func testAMovingLineLandsOnWholePixels() {
        XCTAssertEqual(Grid.pixelRound(58.4, displayScale: 3), 58 + 1.0 / 3, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelRound(58.2, displayScale: 3), 58 + 1.0 / 3, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelRound(58.1, displayScale: 3), 58, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelRound(58.3, displayScale: 2), 58.5, accuracy: 0.0001)
        XCTAssertEqual(Grid.pixelRound(118, displayScale: 3), 118, "the ends of the course do not move")
        XCTAssertEqual(Grid.pixelRound(0, displayScale: 3), 0)
        XCTAssertEqual(Grid.pixelRound(7.4, displayScale: 0), 7, "a scale of zero counts as one")
        // Every level of the breath gives a whole number of pixels.
        for step in 0...200 {
            let offset = TideLine.offset(level: Float(step) / 200)
            let pixels = Grid.pixelRound(offset, displayScale: 3) * 3
            XCTAssertEqual(pixels, pixels.rounded(), accuracy: 0.0001)
            XCTAssertLessThanOrEqual(abs(Grid.pixelRound(offset, displayScale: 3) - offset), 1.0 / 6 + 0.0001)
        }
    }
}
