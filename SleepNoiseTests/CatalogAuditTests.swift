import XCTest
@testable import SleepNoise

/// The string catalogs as a whole (S-08): complete in English and Spanish,
/// the same placeholders in both, plurals where a figure counts something,
/// no key nobody reads, no key read that is not there, and no text of the
/// interface written in Swift.
final class CatalogAuditTests: XCTestCase {
    // MARK: Complete in both languages

    func testEveryKeyIsInEnglishAndSpanishAndNothingElse() throws {
        for catalog in CatalogSource.catalogs {
            let strings = try CatalogSource.strings(catalog)
            XCTAssertGreaterThan(strings.count, 4, "\(catalog) should have been read")
            for (key, entry) in strings {
                let languages = Set(CatalogSource.localizations(entry).keys)
                XCTAssertEqual(languages, Set(CatalogSource.languages), "\(catalog) \(key)")
            }
        }
    }

    func testEveryValueIsTranslatedAndSaysSomething() throws {
        for value in try CatalogSource.allValues() {
            XCTAssertEqual(value.state, "translated", value.place)
            XCTAssertFalse(value.text.trimmingCharacters(in: .whitespaces).isEmpty, value.place)
        }
    }

    /// A key of the interface is written by hand: a key the compiler found
    /// ("extracted") would be English used as its own key, a string that was
    /// never given a name.
    func testEveryKeyOfTheInterfaceIsWrittenByHand() throws {
        for (key, entry) in try CatalogSource.strings(CatalogSource.interface) {
            XCTAssertEqual(entry["extractionState"] as? String, "manual", key)
        }
    }

    func testNoValueHasStraySpaces() throws {
        for value in try CatalogSource.allValues() {
            XCTAssertEqual(value.text, value.text.trimmingCharacters(in: .whitespacesAndNewlines), value.place)
            XCTAssertFalse(value.text.contains("  "), value.place)
            XCTAssertFalse(value.text.contains("..."), "\(value.place): the ellipsis is one character")
        }
    }

    // MARK: Placeholders

    /// What the code fills in is the same in both languages: the same
    /// specifiers, in the same order unless they are numbered.
    func testFormatSpecifiersMatchAcrossLanguages() throws {
        let values = try CatalogSource.values(CatalogSource.interface)
        let byKey = Dictionary(grouping: values, by: \.key)
        var compared = 0
        for (key, forms) in byKey {
            // The form every count reaches: "other", or the only one.
            func reference(_ language: String) -> [String]? {
                forms.first { $0.language == language && ($0.form ?? "other") == "other" }
                    .map { CatalogSource.specifiers(in: $0.text) }
            }
            let english = try XCTUnwrap(reference("en"), key)
            let spanish = try XCTUnwrap(reference("es"), key)
            let isNumbered = (english + spanish).contains { $0.contains("$") }
            if isNumbered {
                XCTAssertEqual(english.sorted(), spanish.sorted(), key)
                XCTAssertTrue((english + spanish).allSatisfy { $0.contains("$") }, "\(key): all numbered or none")
            } else {
                XCTAssertEqual(english, spanish, key)
            }
            // A plural form may leave the figure out ("1 night left"), and
            // nothing else.
            for form in forms where form.form != nil {
                let other = form.language == "en" ? english : spanish
                let own = CatalogSource.specifiers(in: form.text)
                XCTAssertTrue(Set(own).isSubset(of: Set(other)), form.place)
                XCTAssertGreaterThanOrEqual(own.count, other.count - 1, form.place)
            }
            if !english.isEmpty { compared += 1 }
        }
        XCTAssertGreaterThan(compared, 40)
    }

    /// Two arguments of different kinds are numbered, so a translation may
    /// reorder them.
    func testMixedArgumentsAreNumbered() throws {
        for value in try CatalogSource.values(CatalogSource.interface) {
            let specifiers = CatalogSource.specifiers(in: value.text)
            let kinds = Set(specifiers.map { $0.replacingOccurrences(of: #"\d+\$"#, with: "", options: .regularExpression) })
            if kinds.count > 1 {
                XCTAssertTrue(specifiers.allSatisfy { $0.contains("$") }, value.place)
            }
        }
    }

    /// Every phrase Siri is trained with names the app, and a phrase in
    /// Spanish asks for the same parameters as its key.
    func testShortcutPhrasesKeepTheirParameters() throws {
        let values = try CatalogSource.values(CatalogSource.shortcuts)
        XCTAssertGreaterThanOrEqual(values.count, 20)
        for value in values {
            let expected = Set(CatalogSource.parameters(in: value.key))
            let found = CatalogSource.parameters(in: value.text)
            XCTAssertEqual(Set(found), expected, value.place)
            XCTAssertEqual(found.count, Set(found).count, "\(value.place): a parameter twice")
            XCTAssertTrue(found.contains("${applicationName}"), value.place)
        }
        // The two parameter summaries live in the interface catalog.
        for value in try CatalogSource.values(CatalogSource.interface) where value.key.contains("${") {
            XCTAssertEqual(
                CatalogSource.parameters(in: value.text), CatalogSource.parameters(in: value.key), value.place
            )
        }
    }

    // MARK: Plurals

    private static let countedInEnglish =
        #"%(?:\d+\$)?(?:lld|d) (?:more )?(?:minutes?|nights?|days?|hours?|layers?|mix(?:es)?|breaths?|times?)\b"#
    private static let countedInSpanish =
        #"(?:\bquedan? )?%(?:\d+\$)?(?:lld|d) (?:minutos?|noches?|días?|horas?|capas?|mezclas?|respiraciones|veces)\b|\bquedan? %"#

    /// Where a figure counts minutes or nights in words, the string varies
    /// by plural: "1 minute left", never "1 minutes left". "min" is an
    /// abbreviation and does not vary.
    func testAFigureThatCountsSomethingIsPlural() throws {
        let strings = try CatalogSource.strings(CatalogSource.interface)
        var plurals = 0
        for value in try CatalogSource.values(CatalogSource.interface) {
            let pattern = value.language == "en" ? Self.countedInEnglish : Self.countedInSpanish
            let counts = !CatalogSource.matches(of: pattern, in: value.text, options: .caseInsensitive).isEmpty
            let entry = try XCTUnwrap(strings[value.key])
            if counts {
                for language in CatalogSource.languages {
                    XCTAssertTrue(CatalogSource.isPlural(entry, language: language), "\(value.place): \(value.text)")
                }
            }
            if value.form != nil { plurals += 1 }
        }
        XCTAssertGreaterThanOrEqual(plurals, 28, "seven plural keys, two forms, two languages")
    }

    func testEveryPluralHasOneAndOtherInBothLanguages() throws {
        let values = try CatalogSource.values(CatalogSource.interface).filter { $0.form != nil }
        for (key, forms) in Dictionary(grouping: values, by: \.key) {
            for language in CatalogSource.languages {
                let found = Set(forms.filter { $0.language == language }.compactMap(\.form))
                XCTAssertEqual(found, ["one", "other"], "\(key) [\(language)]")
            }
        }
    }

    /// A plural is resolved by `String.localizedStringWithFormat`. Through
    /// `Localized.format` (a plain `String(format:)`) it would come out as
    /// its "other" form whatever the count.
    func testPluralKeysAreNeverFormattedWithoutTheLocale() throws {
        let strings = try CatalogSource.strings(CatalogSource.interface)
        let plurals = Set(strings.filter { CatalogSource.isPlural($0.value, language: "en") }.keys)
        XCTAssertFalse(plurals.isEmpty)
        for literal in try SwiftSources.literals() where plurals.contains(literal.text) {
            XCTAssertFalse(literal.before.hasSuffix("Localized.format("), "\(literal.place): \(literal.text)")
            XCTAssertFalse(literal.before.hasSuffix("String(format:"), "\(literal.place): \(literal.text)")
        }
    }

    // MARK: Keys and code

    /// Keys the code builds from a value instead of writing them out.
    private static var builtKeys: Set<String> {
        // `SoundID.detailKey`: "capas.\(rawValue).detalle".
        Set(SoundID.allCases.map(\.detailKey))
    }

    /// The literals a release build compiles.
    private func shippedLiterals() throws -> [SourceLiteral] {
        let literals = try SwiftSources.literals()
        XCTAssertGreaterThan(literals.count, 500, "the sources should have been read")
        return literals.filter { !$0.isDebugOnly }
    }

    func testNoKeyIsAnOrphan() throws {
        let literals = try shippedLiterals()
        let written = Set(literals.map(\.text)).union(literals.map(\.asIntentKey)).union(Self.builtKeys)
        for catalog in CatalogSource.catalogs {
            for key in try CatalogSource.strings(catalog).keys.sorted() {
                XCTAssertTrue(written.contains(key), "\(catalog) \(key) is read by no code")
            }
        }
    }

    /// The code that turns a literal into text people read.
    private static let readsTheCatalog = [
        #"\b(?:Text|Label|Button|Toggle|TextField|SecureField|Picker|Section|Menu|Link|NavigationLink|Stepper)\($"#,
        #"\b(?:LocalizedStringResource|LocalizedStringKey|IntentDialog|Summary|LocalizationValue)\($"#,
        #"\.(?:navigationTitle|alert|confirmationDialog|accessibilityLabel|accessibilityValue|accessibilityHint)\($"#,
        #"(?:String\(localized:|stringLiteral:|accessibilityAction\(named:|Localized\.string\(|Localized\.format\(|\blocalized\()$"#,
        #"LocalizedStringResource =$"#,
        #"phrases: \[(?: "S",)*$"#,
    ]

    private static func readsTheCatalog(_ literal: SourceLiteral) -> Bool {
        readsTheCatalog.contains {
            literal.before.range(of: $0, options: .regularExpression) != nil
        }
    }

    /// A literal that is not text for anyone: an identifier for UI tests,
    /// the name of a symbol, a storage key.
    private static func isAnIdentifier(_ literal: SourceLiteral) -> Bool {
        literal.before.range(
            of: #"(?:accessibilityIdentifier\([^)]*|identifier:|ID =|systemName:[^)]*|systemImageName:|glyph:)$"#,
            options: .regularExpression
        ) != nil
    }

    func testEveryKeyTheCodeReadsExists() throws {
        let interface = Set(try CatalogSource.strings(CatalogSource.interface).keys)
        let phrases = Set(try CatalogSource.strings(CatalogSource.shortcuts).keys)
        // The values of both catalogs: a phrase of an App Shortcut is
        // written in the code once per variant, and only the first is a key.
        let phraseValues = Set(try CatalogSource.values(CatalogSource.shortcuts).filter { $0.language == "en" }.map(\.text))
        let known = interface.union(phrases).union(phraseValues)
        let namespaces = Set(interface.compactMap { $0.split(separator: ".").first.map(String.init) })
        var checked = 0
        for literal in try shippedLiterals() {
            if Self.readsTheCatalog(literal) {
                checked += 1
                XCTAssertTrue(
                    known.contains(literal.text) || known.contains(literal.asIntentKey),
                    "\(literal.place): \"\(literal.text)\" is shown to people and is not in a catalog"
                )
                continue
            }
            // Anything shaped like a key of ours ("pro.pie"), wherever it
            // is written: a constant, a `return`, a list.
            let looksLikeAKey = literal.text.range(
                of: #"^[a-z_0-9]+(\.[a-z_0-9]+)+$"#, options: .regularExpression
            ) != nil
            let namespace = literal.text.split(separator: ".").first.map(String.init) ?? ""
            if looksLikeAKey, namespaces.contains(namespace), !Self.isAnIdentifier(literal) {
                checked += 1
                XCTAssertTrue(interface.contains(literal.text), "\(literal.place): \(literal.text) is not in the catalog")
            }
        }
        XCTAssertGreaterThan(checked, 250)
    }

    /// Nothing people read or hear is written in Swift: a sentence in a
    /// literal, or a word handed over as it is (`Text(verbatim: "Name")`),
    /// is a string that skipped the catalog and its Spanish.
    func testNoTextOfTheInterfaceIsWrittenInSwift() throws {
        let known = Set(try CatalogSource.allValues().filter { $0.language == "en" }.map(\.text))
            .union(try CatalogSource.strings(CatalogSource.interface).keys)
        for literal in try shippedLiterals() {
            let plain = literal.plain
            if literal.before.hasSuffix("verbatim:") {
                // What is composed from catalog strings and figures.
                XCTAssertNil(
                    plain.rangeOfCharacter(from: .letters),
                    "\(literal.place): \"\(literal.text)\" is text written in code"
                )
            }
            // Two words in a row is a sentence.
            let isProse = plain.range(of: #"\p{L}{2,},? \p{L}{2,}"#, options: .regularExpression) != nil
            if isProse {
                XCTAssertTrue(
                    known.contains(literal.text) || known.contains(literal.asIntentKey),
                    "\(literal.place): \"\(literal.text)\" is a sentence written in code"
                )
            }
        }
    }

    /// The reader of Swift sees what it should: a planted sentence and a
    /// planted identifier, in and out of a debug block.
    func testTheReaderOfSwiftTellsCodeFromDebugAndComments() {
        let source = """
        // Text("in a comment")
        struct Sample: View {
            var body: some View {
                Text("pro.pie") /* Text("in a block") */
                #if DEBUG
                Text(verbatim: "Only in debug")
                #else
                Text(verbatim: "In release \\(count)")
                #endif
                Image(systemName: "play.fill").accessibilityIdentifier("pro.title")
            }
        }
        #Preview { Text("A preview") }
        """
        let literals = SwiftSources.literals(in: source, file: "Sample.swift")
        XCTAssertEqual(literals.map(\.text), [
            "pro.pie", "Only in debug", "In release \\(count)", "play.fill", "pro.title", "A preview",
        ])
        XCTAssertEqual(literals.map(\.isDebugOnly), [false, true, false, false, false, true])
        XCTAssertEqual(literals.map(\.line), [4, 6, 8, 10, 10, 13])
        XCTAssertTrue(Self.readsTheCatalog(literals[0]))
        XCTAssertTrue(literals[2].before.hasSuffix("verbatim:"))
        XCTAssertEqual(literals[2].plain, "In release ")
        XCTAssertTrue(Self.isAnIdentifier(literals[3]))
        XCTAssertTrue(Self.isAnIdentifier(literals[4]))
        let phrase = SourceLiteral(
            file: "", line: 1, text: "Play \\(\\.$mix) in \\(.applicationName)", before: "phrases: [", isDebugOnly: false
        )
        XCTAssertEqual(phrase.asIntentKey, "Play ${mix} in ${applicationName}")
        XCTAssertTrue(Self.readsTheCatalog(phrase))
    }

    // MARK: The old split

    /// The surfaces that were removed took their strings with them, and no
    /// string still tells the split of the first version: a timer capped
    /// at an hour, one saved mix, four free sounds, a trial counted in
    /// days that starts with Play.
    func testNothingOfTheOldSplitRemains() throws {
        let removed = [
            "timer.", "breath.", "paywall.", "trial.", "mixes.", "intent.", "shortcut.", "bedtime.",
            "settings.", "common.close", "nowplaying.title",
        ]
        for key in try CatalogSource.strings(CatalogSource.interface).keys {
            for prefix in removed {
                XCTAssertFalse(key.hasPrefix(prefix), "\(key) belongs to something that was removed")
            }
        }
        let old = [
            "en": [
                #"\b60\b"#, #"\bone (saved )?mix\b"#, #"\bfour\b"#, #"\bdays\b|\bday (left|trial)\b"#, #"\bfirst play\b"#,
                #"\bcustom\b"#, #"\bwhen you (press|tap) play\b"#,
            ],
            "es": [
                #"\b60\b"#, #"\buna (sola )?mezcla guardada\b"#, #"\bcuatro\b"#, #"\bdías\b|\bdía de prueba\b"#, #"\bprimer play\b"#,
                #"\ba medida\b"#, #"\bal pulsar play\b"#,
            ],
        ]
        for value in try CatalogSource.allValues() {
            for pattern in old[value.language] ?? [] {
                XCTAssertTrue(
                    CatalogSource.matches(of: pattern, in: value.copy, options: .caseInsensitive).isEmpty,
                    "\(value.place): \(value.text)"
                )
            }
        }
    }

    // MARK: The fixed vocabulary

    /// The names the reconciliation fixes (§3), as people read them.
    func testTheFixedNamesAreTheOnesOfTheGuide() throws {
        let values = try CatalogSource.values(CatalogSource.interface)
        func text(_ key: String, _ language: String) -> String? {
            values.first { $0.key == key && $0.language == language }?.text
        }
        let names: [(String, String, String)] = [
            ("temporizador.manto", "Blanket", "Manto"),
            ("temporizador.dormirme", "Until I sleep", "Hasta dormirme"),
            ("madrugada.titulo", "Small hours", "Madrugada"),
            ("marea.titulo", "Tide", "Marea"),
            ("marea.descenso", "Descent", "Descenso"),
            ("capas.titulo", "Layers", "Capas"),
            ("mezclas.titulo", "Mixes", "Mezclas"),
            ("mezcla.nombre.vacio", "Tonight", "Esta noche"),
            ("barra.noche", "Night", "Noche"),
            ("lo_que_no_hay.titulo", "What's not here", "Lo que no hay"),
            ("pro.restaurar", "Restore purchase", "Restaurar compra"),
            ("pro.prueba.estado.gratis", "always free", "gratis siempre"),
        ]
        for (key, english, spanish) in names {
            XCTAssertEqual(text(key, "en"), english, key)
            XCTAssertEqual(text(key, "es"), spanish, key)
        }
    }
}
