import XCTest
@testable import SleepNoise

/// The copy lint (S-08): the two black lists of the copy guide (10 §0.4,
/// what is never claimed, and §0.5, the vetoed words) applied to what
/// people read and hear, language by language: the values of both string
/// catalogs, never their keys or comments. With them, the rules that keep
/// figures out of copy: no price, no count of textures, no exclamation
/// marks, no emoji.
///
/// A word that the guide allows in one place is declared here, one by one,
/// with the phrase that makes it right. A declaration that no longer
/// matches anything fails too, so the list cannot rot.
final class CopyLintTests: XCTestCase {
    // MARK: The lists

    /// §0.5, Spanish. Whole words, any case.
    static let vetoedSpanish = [
        "timer", "mix", "preset", "vitalicio", "lifetime", "premium", #"desbloque\w*"#, "unlock",
        "activar pro", #"suscri\w*"#, #"insomn\w*"#, #"ansied\w*"#, #"terap\w*"#, #"clínic\w*"#,
        #"médic\w*"#, #"sanitari\w*"#, #"profund\w*"#, #"relaj\w*"#, #"inteligen\w*"#, #"personaliz\w*"#,
        #"mejora\w*"#, "mejor sueño", #"óptim\w*"#, #"perfect\w*"#, "genial", "increíble", #"mágic\w*"#,
        "protocolo", "sesión de", "módulo", "semana 1", "foco", "concentración", "cerrar", "candados?",
        #"bloquead\w*"#, "oferta", "descuento", #"antes \D{0,4}\d[\d.,]* ?[€$]|antes [€$] ?\d"#,
        "modo noche", "modo madrugada", "luna", "escudo", "tu instrumento", "envolvente", "chips?",
        "perfil de entorno", "lluvia fina", "cama rosa", "mar lento", "noche de fuego", "control fino",
        "tormenta lejana", "v1", "v2", "oleaje", "amanecer", "siesta", "ranuras?", "lanzamiento",
        "once texturas", #"siete (?:\w+ ){0,2}pro"#, "preajustes?",
    ]

    /// §0.5, English. "until I fall asleep" is what the guide means by its
    /// entry `until I sleep`: "Until I sleep" is the name it fixes for the
    /// mode (§0.2, §5e.6, C15), and the long form is the one C15 retired.
    static let vetoedEnglish = [
        "preset", "lifetime", "premium", #"unlock\w*"#, #"subscri\w*"#, #"insomn\w*"#, #"anxiet\w*"#,
        #"therap\w*"#, #"clinic\w*"#, "medical", "deep sleep", #"relax\w*"#, "smart", #"personaliz\w*"#,
        #"improve\w*"#, "better sleep", #"optimi\w*"#, #"perfect\w*"#, "awesome", "amazing", #"magic\w*"#,
        "protocol", "module", "focus", "close", "lock", "locked", "offer", "discount", #"was \$"#,
        "night mode", "dawn", "moon", "shield", "envelope", "chips?", "fine rain", "pink bed", "slow sea",
        "swell", "sunrise", "nap", "slots?", "launch price", "small hours mode", "until I fall asleep",
        "sleep timer",
    ]

    /// §0.4, Spanish: what is never claimed or hinted.
    static let claimsSpanish = [
        #"(?:duerm|dorm|descans)\w* mejor"#, "calidad del sueño", "más rápido", "clínicamente", "científicamente",
        #"probad\w+"#, "sueño profundo", "ondas lentas", "ondas cerebrales", "memoria", #"trata\w*"#,
        #"cura\w*"#, #"alivi\w*"#, #"tratamiento\w*"#, "grado médico", "acúfenos", "tinnitus", "nervio vago",
        "sistema nervioso", "estrés", "fase ligera", "fases", "alarma inteligente", "bebés?",
        #"recomendad\w+"#, #"se adapta\w*"#, "sabe lo que", "tdah", #"umbral\w*"#, #"cuestionario\w*"#,
        #"puntuaci\w+"#, "rachas?", "la mejor", #"inmersiv\w+"#, "a diferencia de", "coherencia cardíaca",
    ]

    /// §0.4, English.
    static let claimsEnglish = [
        #"sleep\w* better"#, #"better (?:night|rest)"#, #"deep(?:er|ly)? sleep"#, #"sleep\w* deep\w*"#,
        "sleep quality", "faster", "clinically", "scientifically", "proven",
        "slow[- ]wave", "brain ?waves?", "memory", #"treat\w*"#, #"cure\w*"#, #"reliev\w*"#, "relief",
        "medical[- ]grade", "tinnitus", "vagus", "nervous system", "stress", "light sleep",
        "sleep stages?", "sleep phases?", "smart alarm", "baby", "babies", "recommended by", "adapts to",
        "knows what", "adhd", "concentration", #"threshold\w*"#, #"questionnaire\w*"#, "scores?",
        "streaks?", "the best", "incredible", "immersive", "unlike", "stay under",
    ]

    /// Initials, with their case.
    static let initials = ["es": #"\bIA\b"#, "en": #"\bAI\b"#]

    /// A price in any form: a currency sign or name, a figure with cents,
    /// or the figure of the price itself. The price people see is
    /// `Product.displayPrice` (C02).
    static let price = #"[€$£¥]|\b\d+[.,]\d\d\b|\b29\b|\b(?:euros?|dollars?|dólar(?:es)?|eur|usd)\b"#

    /// A count of what the catalog has ("eleven textures", "six sounds"):
    /// never in copy (C04). Mixes and nights are counted: "three mixes",
    /// "7 nights".
    static let counts = [
        "es": #"\b(?:\d+|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce|trece|catorce|quince|dieciséis)\s+(?:\w+\s+)?(?:texturas?|sonidos?|ruidos?|colores|camas?)\b"#,
        "en": #"\b(?:\d+|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen)\s+(?:\w+\s+)?(?:textures?|sounds?|noises?|colors?|beds?)\b"#,
    ]

    // MARK: The false positives, one by one

    /// A word of a list that the guide allows in one string, inside one
    /// phrase.
    struct Allowed: Hashable {
        let key: String
        let language: String
        /// The entry of the list, as written there.
        let rule: String
        /// The phrase the word must sit in.
        let within: String
    }

    static let allowed: [Allowed] = [
        // "No subscription. No account. No tracking." (C09): the one place
        // the word may be said, as an absence. The footer and the page.
        Allowed(key: "lo_que_no_hay.pie", language: "es", rule: #"suscri\w*"#, within: "Sin suscripción"),
        Allowed(key: "lo_que_no_hay.pie", language: "en", rule: #"subscri\w*"#, within: "No subscription"),
        Allowed(key: "lo_que_no_hay.lista", language: "es", rule: #"suscri\w*"#, within: "Sin suscripción"),
        Allowed(key: "lo_que_no_hay.lista", language: "en", rule: #"subscri\w*"#, within: "No subscription"),
        // "What's not here" names the score and the streak as things the
        // app does not have.
        Allowed(key: "lo_que_no_hay.lista", language: "es", rule: #"puntuaci\w+"#, within: "Sin puntuación"),
        Allowed(key: "lo_que_no_hay.lista", language: "es", rule: "rachas?", within: "Sin racha"),
        Allowed(key: "lo_que_no_hay.lista", language: "en", rule: "scores?", within: "No score"),
        Allowed(key: "lo_que_no_hay.lista", language: "en", rule: "streaks?", within: "No streak"),
        // The line of use of the ocean: the only place for the word.
        Allowed(key: "capas.ocean.detalle", language: "es", rule: "oleaje", within: "oleaje lento"),
        Allowed(key: "capas.ocean.detalle", language: "en", rule: "swell", within: "slow swell"),
        // Sentences, not buttons: the guide vetoes "Close" as a button.
        Allowed(key: "pagina.error.inicio.2", language: "en", rule: "close", within: "close the app"),
        Allowed(key: "pagina.error.inicio.3", language: "en", rule: "close", within: "Close any app"),
        // A synonym Siri understands for "Until I sleep". Never on screen.
        Allowed(
            key: "atajo.modo.dormirme.sinonimo", language: "en",
            rule: "until I fall asleep", within: "until I fall asleep"
        ),
        // The store listing (docs/store/ficha-*.md) says the same absences
        // as the page: in the description and in the list of capture 6.
        Allowed(key: storeKey, language: "es", rule: #"suscri\w*"#, within: "Sin suscripción"),
        Allowed(key: storeKey, language: "es", rule: #"puntuaci\w+"#, within: "Sin puntuación"),
        Allowed(key: storeKey, language: "es", rule: "rachas?", within: "Sin racha"),
        Allowed(key: storeKey, language: "en", rule: #"subscri\w*"#, within: "No subscription"),
        Allowed(key: storeKey, language: "en", rule: "scores?", within: "No score"),
        Allowed(key: storeKey, language: "en", rule: "streaks?", within: "No streak"),
        // The keywords field is not shown in the store and has no accents.
        Allowed(key: storeKeywordsKey, language: "es", rule: #"suscri\w*"#, within: "sin suscripcion"),
        // Option A of the keywords, the one of document 11, names
        // diagnoses. The owner has not chosen it: option B, without them,
        // is the default (see the note of the field in each listing).
        Allowed(key: storeKeywordsKey, language: "es", rule: #"insomn\w*"#, within: "insomnio"),
        Allowed(key: storeKeywordsKey, language: "en", rule: #"insomn\w*"#, within: "insomnia"),
        Allowed(key: storeKeywordsKey, language: "en", rule: "tinnitus", within: "tinnitus"),
    ]

    /// What a false positive of the store listing is tied to: any block of
    /// text, or a block of keywords.
    static let storeKey = "docs/store"
    static let storeKeywordsKey = "docs/store keywords"

    /// Question marks: only the system's delete confirmation and Siri's
    /// question when it has to choose (guide §0.1, rule 3).
    static let questions: Set<String> = ["mezclas.eliminar.titulo", "siri.mezcla.cual"]

    // MARK: The lint

    struct Finding: Hashable, CustomStringConvertible {
        let place: String
        let rule: String
        let text: String

        var description: String { "\(place) says \"\(rule)\": \(text)" }
    }

    static func rules(_ language: String) -> [String] {
        language == "es" ? vetoedSpanish + claimsSpanish : vetoedEnglish + claimsEnglish
    }

    /// The words of a list found in a text, as whole words.
    static func hits(_ rule: String, in text: String, caseSensitive: Bool = false) -> [Range<String.Index>] {
        let pattern = caseSensitive ? rule : #"(?<![\p{L}\p{N}_])(?:"# + rule + #")(?![\p{L}\p{N}_])"#
        guard let expression = try? NSRegularExpression(
            pattern: pattern, options: caseSensitive ? [] : [.caseInsensitive]
        ) else {
            XCTFail("\(rule) is not a valid expression")
            return []
        }
        return expression.matches(in: text, range: NSRange(text.startIndex..., in: text))
            .compactMap { Range($0.range, in: text) }
    }

    /// Lints one text of one language. `key` is what a declared false
    /// positive is tied to; nil for text outside the catalogs.
    static func lint(_ text: String, language: String, key: String?, place: String) -> (found: [Finding], used: Set<Allowed>) {
        var found: [Finding] = []
        var used: Set<Allowed> = []
        let copy = CatalogSource.withoutPlaceholders(text)
        for rule in rules(language) {
            for hit in hits(rule, in: copy) {
                let excuse = allowed.first { allowed in
                    guard allowed.key == key, allowed.language == language, allowed.rule == rule else { return false }
                    // The word is excused only inside its phrase.
                    return copy.ranges(of: allowed.within).contains { $0.lowerBound <= hit.lowerBound && hit.upperBound <= $0.upperBound }
                }
                if let excuse {
                    used.insert(excuse)
                } else {
                    found.append(Finding(place: place, rule: rule, text: text))
                }
            }
        }
        if let rule = initials[language], !hits(rule, in: copy, caseSensitive: true).isEmpty {
            found.append(Finding(place: place, rule: rule, text: text))
        }
        if !CatalogSource.matches(of: price, in: copy, options: .caseInsensitive).isEmpty || copy.contains("%") {
            found.append(Finding(place: place, rule: "a price or a percentage", text: text))
        }
        if let rule = counts[language], !CatalogSource.matches(of: rule, in: copy, options: .caseInsensitive).isEmpty {
            found.append(Finding(place: place, rule: "a count of textures", text: text))
        }
        if copy.contains("!") || copy.contains("¡") {
            found.append(Finding(place: place, rule: "an exclamation mark", text: text))
        }
        if copy.unicodeScalars.contains(where: isEmoji) {
            found.append(Finding(place: place, rule: "an emoji", text: text))
        }
        return (found, used)
    }

    static func isEmoji(_ scalar: Unicode.Scalar) -> Bool {
        scalar.properties.isEmojiPresentation
            || (0x1F000...0x1FAFF).contains(scalar.value)
            || (0x2600...0x27BF).contains(scalar.value)
            || scalar.value == 0xFE0F
    }

    private func lintCatalogs(_ language: String) throws -> (found: [Finding], used: Set<Allowed>, read: Int) {
        var found: [Finding] = []
        var used: Set<Allowed> = []
        var read = 0
        for value in try CatalogSource.allValues() where value.language == language {
            let result = Self.lint(value.text, language: language, key: value.key, place: value.place)
            found.append(contentsOf: result.found)
            used.formUnion(result.used)
            read += 1
        }
        return (found, used, read)
    }

    /// Every block of text of the store listing of one language: name,
    /// subtitle, promotional text, keywords, description, what is new, the
    /// headlines of the captures and their reserves (guide §0.4: the whole
    /// listing, not only what is composed over the screens).
    private func lintListing(_ language: String) throws -> (found: [Finding], used: Set<Allowed>, read: Int) {
        let name = "ficha-\(language).md"
        let url = CatalogSource.root.appendingPathComponent("docs/store/\(name)")
        let blocks = StoreListing.blocks(try String(contentsOf: url, encoding: .utf8))
        var found: [Finding] = []
        var used: Set<Allowed> = []
        for (index, block) in blocks.enumerated() {
            let result = Self.lint(
                block.text, language: language,
                key: block.isKeywords ? Self.storeKeywordsKey : Self.storeKey,
                place: "\(name), block \(index + 1)"
            )
            found.append(contentsOf: result.found)
            used.formUnion(result.used)
        }
        return (found, used, blocks.count)
    }

    // MARK: Tests

    func testSpanishKeepsOffBothBlackLists() throws {
        let result = try lintCatalogs("es")
        XCTAssertGreaterThan(result.read, 250, "both catalogs should have been read")
        XCTAssertEqual(result.found.map(\.description), [])
    }

    func testEnglishKeepsOffBothBlackLists() throws {
        let result = try lintCatalogs("en")
        XCTAssertGreaterThan(result.read, 250, "both catalogs should have been read")
        XCTAssertEqual(result.found.map(\.description), [])
    }

    /// A false positive that is declared and no longer found is a hole in
    /// the lint waiting for the word to come back somewhere else.
    func testEveryDeclaredFalsePositiveIsStillThere() throws {
        let used = try lintCatalogs("es").used.union(try lintCatalogs("en").used)
            .union(try lintListing("es").used).union(try lintListing("en").used)
        for allowed in Self.allowed {
            XCTAssertTrue(used.contains(allowed), "\(allowed.key) [\(allowed.language)] no longer says \"\(allowed.within)\"")
        }
        XCTAssertEqual(Self.allowed.count, Set(Self.allowed).count)
    }

    /// No question marks, except where the guide puts them.
    func testQuestionsAreOnlyWhereTheGuidePutsThem() throws {
        var asked: Set<String> = []
        for value in try CatalogSource.allValues() where value.text.contains("?") || value.text.contains("¿") {
            XCTAssertTrue(Self.questions.contains(value.key), value.place)
            asked.insert(value.key)
        }
        XCTAssertEqual(asked, Self.questions)
    }

    /// Spanish opens what it closes.
    func testSpanishQuestionsOpenAndClose() throws {
        for value in try CatalogSource.allValues() where value.language == "es" {
            XCTAssertEqual(
                value.text.filter { $0 == "¿" }.count, value.text.filter { $0 == "?" }.count, value.place
            )
        }
    }

    /// The one figure that is the name of something: the seven nights of
    /// the trial, tied to the model. Every other digit in copy comes from
    /// the code as an argument.
    func testNoFigureIsWrittenIntoCopyExceptTheSevenNights() throws {
        let named = ["pro.prueba.empezar": "\(NightTrial.nights)", "comun.mas15": "15"]
        // The plural form of one night and the phrases of Siri carry none.
        for value in try CatalogSource.allValues() {
            let digits = CatalogSource.matches(of: #"\d+"#, in: value.copy)
            if let figure = named[value.key] {
                XCTAssertEqual(digits, [figure], value.place)
            } else if value.key == "pro.prueba.estado", value.form == "one" {
                XCTAssertEqual(digits, ["1"], value.place)
            } else {
                XCTAssertEqual(digits, [], "\(value.place): \(value.text)")
            }
        }
    }

    /// The lint finds what it is there to find.
    func testTheLintCatchesWhatItShould() {
        let cases: [(String, String, String)] = [
            ("Unlock Pro", "en", #"unlock\w*"#),
            ("Desbloquea Pro", "es", #"desbloque\w*"#),
            ("Tu timer", "es", "timer"),
            ("Guarda este mix", "es", "mix"),
            ("A subscription you can cancel", "en", #"subscri\w*"#),
            ("Helps with insomnia", "en", #"insomn\w*"#),
            ("Sueño profundo", "es", #"profund\w*"#),
            ("Mejora tu descanso", "es", #"mejora\w*"#),
            ("Clinically proven", "en", "clinically"),
            ("Powered by AI", "en", #"\bAI\b"#),
            ("Con IA", "es", #"\bIA\b"#),
            ("Until I fall asleep", "en", "until I fall asleep"),
            ("Just 29,99 €", "es", "a price or a percentage"),
            ("Only $4.99", "en", "a price or a percentage"),
            ("40% off", "en", "a price or a percentage"),
            ("Once texturas", "es", "once texturas"),
            ("Eleven textures", "en", "a count of textures"),
            ("Seis sonidos nuevos", "es", "a count of textures"),
            ("Welcome!", "en", "an exclamation mark"),
            ("¡Hola", "es", "an exclamation mark"),
            ("Sleep \u{1F319}", "en", "an emoji"),
            ("Sleep timer", "en", "sleep timer"),
            // The claim as it is most often made.
            ("Para dormir mejor", "es", #"(?:duerm|dorm|descans)\w* mejor"#),
            ("Descansa mejor", "es", #"(?:duerm|dorm|descans)\w* mejor"#),
            ("Duerme mejor esta noche", "es", #"(?:duerm|dorm|descans)\w* mejor"#),
            ("A better night's sleep", "en", #"better (?:night|rest)"#),
            ("Better rest, every night", "en", #"better (?:night|rest)"#),
            ("Sleeping better", "en", #"sleep\w* better"#),
            ("Deeper sleep", "en", #"deep(?:er|ly)? sleep"#),
            ("Sleep deeply", "en", #"sleep\w* deep\w*"#),
            ("Las siete texturas Pro", "es", #"siete (?:\w+ ){0,2}pro"#),
            ("Lock it", "en", "lock"),
        ]
        for (text, language, rule) in cases {
            let rules = Self.lint(text, language: language, key: nil, place: "sample").found.map(\.rule)
            XCTAssertTrue(rules.contains(rule), "\"\(text)\" should trip \"\(rule)\", tripped \(rules)")
        }
        // Whole words: "clock" is not "lock", "premix" is not "mix", and a
        // placeholder is not copy.
        for (text, language) in [
            ("The clock", "en"), ("Until I sleep", "en"), ("Mezcla", "es"), ("Pon ${mix} en ${applicationName}", "es"),
            ("%1$@ at %2$lld", "en"), ("Start the trial · 7 nights", "en"), ("three mixes", "en"),
            ("Small hours", "en"), ("Blanket", "en"), ("Tide", "en"),
            // Seven nights and Pro in the next sentence is not "seven Pro".
            ("Siete noches con todo, sin tarjeta. Después, Pro es un solo pago", "es"),
            ("The sea goes on. Better than nothing is not a claim", "en"),
        ] {
            XCTAssertEqual(Self.lint(text, language: language, key: nil, place: "sample").found, [], text)
        }
        // An excuse holds only in its key and inside its phrase.
        XCTAssertEqual(
            Self.lint("No subscription.", language: "en", key: "lo_que_no_hay.pie", place: "sample").found, []
        )
        XCTAssertFalse(Self.lint("No subscription.", language: "en", key: "pro.pie", place: "sample").found.isEmpty)
        XCTAssertFalse(
            Self.lint("Your subscription.", language: "en", key: "lo_que_no_hay.pie", place: "sample").found.isEmpty
        )
    }

    /// The headlines of the seven store captures (docs/store) go through
    /// the same lint as the app: they are composed over the screens by
    /// scripts/screenshots.sh.
    func testTheStoreHeadlinesPassTheLint() throws {
        for language in CatalogSource.languages {
            let url = CatalogSource.root.appendingPathComponent("docs/store/ficha-\(language).md")
            let headlines = StoreHeadlines.read(try String(contentsOf: url, encoding: .utf8))
            XCTAssertEqual(headlines.count, 7, language)
            for (index, headline) in headlines.enumerated() {
                for text in [headline.title, headline.subtitle].compactMap({ $0 }) {
                    let place = "ficha-\(language).md, capture \(index + 1)"
                    XCTAssertEqual(Self.lint(text, language: language, key: nil, place: place).found, [], text)
                    XCTAssertNil(text.rangeOfCharacter(from: .decimalDigits), "\(place): \(text)")
                }
                // The canvas of the captures (11 §2.2): two lines at most.
                XCTAssertLessThanOrEqual(headline.title.count, 41, headline.title)
            }
            // Only the first and the third carry a second line (11 §2.2). The
            // seventh carries none in 1.0: its reserve line of exploration
            // 12 §5 speaks of paint generated on the device, which is 1.1.
            XCTAssertEqual(
                headlines.map { $0.subtitle != nil }, [true, false, true, false, false, false, false], language
            )
        }
    }

    /// The whole listing of the store, block by block, through the same
    /// lint: the description and the promotional text make the claims a
    /// headline has no room for. Typographic apostrophes and quotation
    /// marks, as in the app.
    func testTheStoreListingsPassTheLint() throws {
        for language in CatalogSource.languages {
            let result = try lintListing(language)
            XCTAssertGreaterThan(result.read, 20, "ficha-\(language).md should have been read")
            XCTAssertEqual(result.found.map(\.description), [], language)
            let url = CatalogSource.root.appendingPathComponent("docs/store/ficha-\(language).md")
            for block in StoreListing.blocks(try String(contentsOf: url, encoding: .utf8)) {
                XCTAssertFalse(block.text.contains("'"), "ficha-\(language).md: \(block.text)")
                XCTAssertFalse(block.text.contains("\""), "ficha-\(language).md: \(block.text)")
            }
        }
    }

    func testTheReaderOfTheListingTakesOnlyBlocksOfText() {
        let blocks = StoreListing.blocks("""
        # Title
        ```text es
        One
        two
        ```
        Prose with 'quotes'.
        ```text es keywords
        a,b
        ```
        ```yaml
        not: copy
        ```
        """)
        XCTAssertEqual(blocks.map(\.text), ["One\ntwo", "a,b"])
        XCTAssertEqual(blocks.map(\.isKeywords), [false, true])
    }

    // MARK: Kept from before S-08

    /// The stems of a diagnosis or a treatment, in either language, in
    /// what people read of either language: values and whole words, never
    /// the keys or the comments of the catalogs ("oscura" is not "cura").
    func testNoMedicalClaimsInEitherLanguage() throws {
        let banned = [
            #"insomn\w*"#, "ansiedad", "anxiety", #"terap\w*"#, #"therap\w*"#, #"treat\w*"#, #"cur[ae]\w*"#,
            "coherencia cardíaca", "stay under",
        ]
        var checked = 0
        for value in try CatalogSource.allValues() {
            checked += 1
            for rule in banned {
                XCTAssertTrue(Self.hits(rule, in: value.copy).isEmpty, "\(value.place) says \"\(rule)\": \(value.text)")
            }
        }
        XCTAssertGreaterThan(checked, 500)
        XCTAssertFalse(Self.hits(#"cur[ae]\w*"#, in: "No cura nada").isEmpty)
        XCTAssertTrue(Self.hits(#"cur[ae]\w*"#, in: "La página oscura").isEmpty)
        XCTAssertTrue(Self.hits(#"treat\w*"#, in: "It retreats by itself").isEmpty)
    }

    /// A mix is never a "preset", and no mix is named after a promise (deep
    /// sleep, focus) or after babies.
    func testNoVetoedMixVocabularyInEitherLanguage() throws {
        let vetoed = [
            "en": ["preset", "deep sleep", "focus", "baby"],
            "es": ["preset", "preajuste", "profund", "concentraci", "bebé"],
        ]
        var checked = 0
        for value in try CatalogSource.allValues() {
            checked += 1
            for word in vetoed[value.language] ?? [] {
                XCTAssertFalse(value.text.lowercased().contains(word), "\(value.place) contains \"\(word)\"")
            }
        }
        XCTAssertGreaterThan(checked, 500)
    }
}

/// The headline and the second line of each store capture, as written in
/// `docs/store/ficha-<language>.md`: under "### Captura N", the first block
/// of text is the headline and the block after "Subtítulo de la captura:"
/// is the second line. scripts/screenshots reads them the same way.
enum StoreHeadlines {
    struct Headline: Equatable {
        var title: String
        var subtitle: String?
    }

    static func read(_ markdown: String) -> [Headline] {
        var headlines: [Headline] = []
        var inCapture = false
        var inBlock = false
        var awaitsSubtitle = false
        var block: [String] = []
        var blocksInCapture = 0
        for line in markdown.components(separatedBy: "\n") {
            if line.hasPrefix("### Captura ") {
                inCapture = true
                blocksInCapture = 0
                awaitsSubtitle = false
                continue
            }
            if line.hasPrefix("## ") { inCapture = false }
            guard inCapture else { continue }
            if line.hasPrefix("```") {
                if inBlock {
                    let text = block.joined(separator: " ")
                    if blocksInCapture == 0 {
                        headlines.append(Headline(title: text, subtitle: nil))
                    } else if awaitsSubtitle, !headlines.isEmpty {
                        headlines[headlines.count - 1].subtitle = text
                        awaitsSubtitle = false
                    }
                    blocksInCapture += 1
                    block = []
                }
                inBlock.toggle()
                continue
            }
            if inBlock {
                block.append(line)
            } else if line.hasPrefix("Subtítulo de la captura:") {
                awaitsSubtitle = true
            }
        }
        return headlines
    }
}

/// The blocks of text of a store listing (`docs/store/ficha-<language>.md`):
/// what is pasted into App Store Connect. A block opens with "```text";
/// its info line says "keywords" for the keywords field.
enum StoreListing {
    struct Block: Equatable {
        var text: String
        var isKeywords: Bool
    }

    static func blocks(_ markdown: String) -> [Block] {
        var blocks: [Block] = []
        var lines: [String]?
        var isOpen = false
        var isKeywords = false
        for line in markdown.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("```") {
                if isOpen {
                    if let lines { blocks.append(Block(text: lines.joined(separator: "\n"), isKeywords: isKeywords)) }
                    lines = nil
                    isOpen = false
                } else {
                    isOpen = true
                    lines = trimmed.hasPrefix("```text") ? [] : nil
                    isKeywords = trimmed.contains("keywords")
                }
            } else if isOpen {
                lines?.append(trimmed)
            }
        }
        return blocks
    }
}
