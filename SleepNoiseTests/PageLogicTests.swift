import XCTest
@testable import SleepNoise

/// The logic of the page, apart from its drawing: which layers have a row
/// and in what order, the "and N more", the name of the live mix, the state
/// line and what VoiceOver says.
final class PageLogicTests: XCTestCase {
    private func bundle(_ language: String) -> Bundle {
        let main = Bundle(for: MixStore.self)
        guard let url = main.url(forResource: language, withExtension: "lproj"),
              let bundle = Bundle(url: url)
        else {
            XCTFail("no \(language).lproj in the app bundle")
            return main
        }
        return bundle
    }

    private func catalog(_ language: String) -> (String) -> String {
        let bundle = bundle(language)
        return { bundle.localizedString(forKey: $0, value: "<missing \($0)>", table: nil) }
    }

    private func levels(_ pairs: [SoundID: Float]) -> [SoundID: Float] {
        var all = Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0)) })
        for (sound, level) in pairs { all[sound] = level }
        return all
    }

    // MARK: Rows

    func testBedsComeFirstThenColours() {
        // The first-use mix: rain before pink, whatever their levels.
        let mix = levels([.pink: 0.9, .rain: 0.1])
        XCTAssertEqual(PageLayers.rows(mix, capacity: 3), [.rain, .pink])
        XCTAssertEqual(PageLayers.more(mix, rows: [.rain, .pink]), 0)

        let every = levels(Dictionary(uniqueKeysWithValues: SoundID.allCases.map { ($0, Float(0.5)) }))
        XCTAssertEqual(
            PageLayers.present(every),
            [.rain, .wind, .fan, .ocean, .thunder, .campfire, .brook, .cabin, .white, .pink, .brown]
        )
    }

    func testThreeRowsAndTheRestIsANumber() {
        let mix = levels([.brown: 0.2, .pink: 0.3, .ocean: 0.5, .wind: 0.25, .rain: 0.45])
        let rows = PageLayers.rows(mix, capacity: 3)
        XCTAssertEqual(rows, [.rain, .wind, .ocean])
        XCTAssertEqual(PageLayers.more(mix, rows: rows), 2)

        // Four layers: what falls off the page is a colour, not a bed.
        let four = levels([.pink: 0.3, .ocean: 0.5, .wind: 0.25, .rain: 0.45])
        XCTAssertEqual(PageLayers.rows(four, capacity: 3), [.rain, .wind, .ocean])
        XCTAssertEqual(PageLayers.more(four, rows: [.rain, .wind, .ocean]), 1)

        // Fewer rows on a short screen or with large text.
        XCTAssertEqual(PageLayers.rows(mix, capacity: 2), [.rain, .wind])
        XCTAssertEqual(PageLayers.more(mix, rows: [.rain, .wind]), 3)
        XCTAssertEqual(PageLayers.rows(mix, capacity: 1), [.rain])
        XCTAssertEqual(PageLayers.rows(mix, capacity: 0), [])
        XCTAssertEqual(PageLayers.rows(levels([:]), capacity: 3), [], "an empty mix has empty rows")
        XCTAssertEqual(PageLayers.more(levels([:]), rows: []), 0)
    }

    func testRowCapacityByScreenAndTextSize() {
        XCTAssertEqual(PageLayers.capacity(fullHeight: 852, isAccessibilitySize: false, isLargestSizes: false), 3)
        XCTAssertEqual(PageLayers.capacity(fullHeight: 874, isAccessibilitySize: false, isLargestSizes: false), 3)
        XCTAssertEqual(PageLayers.capacity(fullHeight: 667, isAccessibilitySize: false, isLargestSizes: false), 2)
        XCTAssertEqual(PageLayers.capacity(fullHeight: 852, isAccessibilitySize: true, isLargestSizes: false), 2)
        XCTAssertEqual(PageLayers.capacity(fullHeight: 852, isAccessibilitySize: true, isLargestSizes: true), 1)
    }

    func testARowDraggedToZeroKeepsItsPlace() {
        // The rows were chosen with rain sounding. Rain goes to zero under a
        // finger: the page does not choose again, so its row is still there
        // to bring it back, and the count only speaks of what has no row.
        let before = levels([.rain: 0.45, .wind: 0.25, .ocean: 0.5, .pink: 0.3])
        let rows = PageLayers.rows(before, capacity: 3)
        var after = before
        after[.rain] = 0
        XCTAssertEqual(rows, [.rain, .wind, .ocean])
        XCTAssertEqual(PageLayers.more(after, rows: rows), 1, "pink still has no row")
        // Chosen again (a mix loads, the Layers sheet closes): pink gets it.
        XCTAssertEqual(PageLayers.rows(after, capacity: 3), [.wind, .ocean, .pink])
    }

    func testAProLayerThatKeepsALevelHasARow() {
        // Access is not asked here: the row says "pro · 50" and stays.
        let mix = levels([.ocean: 0.5, .wind: 0.2])
        XCTAssertEqual(PageLayers.rows(mix, capacity: 3), [.wind, .ocean])
    }

    func testTheFallbackLayerTakesTheFirstEmptyRow() {
        XCTAssertEqual(PageLayers.adding(.pink, to: [], capacity: 3), [.pink])
        XCTAssertEqual(PageLayers.adding(.pink, to: [.ocean], capacity: 3), [.ocean, .pink])
        XCTAssertEqual(PageLayers.adding(.pink, to: [.rain, .pink], capacity: 3), [.rain, .pink], "once")
        XCTAssertEqual(
            PageLayers.adding(.pink, to: [.rain, .wind, .ocean], capacity: 3), [.rain, .wind, .ocean],
            "no row free: it sounds and the state line names it"
        )
    }

    func testTheLayersSheetListsEveryTextureOnce() {
        let listed = PageLayers.colors + PageLayers.beds
        XCTAssertEqual(listed.count, SoundID.allCases.count)
        XCTAssertEqual(Set(listed), Set(SoundID.allCases))
        XCTAssertEqual(PageLayers.colors, [.white, .pink, .brown])
        // The free beds first, then the rest as `SoundID` lists them.
        XCTAssertEqual(PageLayers.beds, [.rain, .wind, .fan, .ocean, .thunder, .campfire, .brook, .cabin])
        XCTAssertEqual(PageLayers.pageOrder, PageLayers.beds + PageLayers.colors)
    }

    // MARK: Name

    func testTheLiveMixIsCalledTonightUntilAMixIsLoaded() {
        let (english, spanish) = (catalog("en"), catalog("es"))
        XCTAssertEqual(PageTitle.text(loadedMixName: nil, localized: english), "Tonight")
        XCTAssertEqual(PageTitle.text(loadedMixName: nil, localized: spanish), "Esta noche")
        XCTAssertEqual(PageTitle.text(loadedMixName: "", localized: spanish), "Esta noche")
        XCTAssertEqual(PageTitle.text(loadedMixName: "Hotel", localized: spanish), "Hotel")
        // A trimmed mix arrives with its honest title already.
        XCTAssertEqual(
            PageTitle.text(loadedMixName: "Mar y viento · sin Océano", localized: spanish),
            "Mar y viento · sin Océano"
        )
    }

    // MARK: State line

    func testStateLineByState() {
        typealias Input = PageStatus.Input
        let end = Date(timeIntervalSinceReferenceDate: 800_000_000)

        XCTAssertEqual(PageStatus.resolve(Input()), .silent)
        XCTAssertEqual(PageStatus.resolve(Input(isPlaying: true)), .playing)
        XCTAssertEqual(PageStatus.resolve(Input(isPlaying: true, timerEndsAt: end)), .playingFadesAt(end))
        XCTAssertEqual(
            PageStatus.resolve(Input(isPlaying: true, omitted: [.thunder, .ocean])),
            .playingWithout([.thunder, .ocean])
        )
        XCTAssertEqual(PageStatus.resolve(Input(pauseCause: .person)), .paused)
        XCTAssertEqual(PageStatus.resolve(Input(pauseCause: .system)), .paused)
        XCTAssertEqual(PageStatus.resolve(Input(pauseCause: .lostOutput)), .pausedHeadphones)
        XCTAssertEqual(PageStatus.resolve(Input(pauseCause: .headphones)), .pausedHeadphones)
        XCTAssertEqual(PageStatus.resolve(Input(pauseCause: .call)), .pausedCall)

        // The final fade outranks everything; whole minutes, never zero.
        XCTAssertEqual(
            PageStatus.resolve(Input(
                isPlaying: true, timerEndsAt: end, timerIsFading: true, timerRemaining: 12, omitted: [.ocean]
            )),
            .fading(minutes: 1)
        )
        XCTAssertEqual(
            PageStatus.resolve(Input(isPlaying: true, timerIsFading: true, timerRemaining: 8 * 60 - 1)),
            .fading(minutes: 8)
        )
        // A layer that came up on its own is said before the hour.
        XCTAssertEqual(
            PageStatus.resolve(Input(isPlaying: true, timerEndsAt: end, isPlayingFallback: true)),
            .playingFallback(.pink, percent: 40)
        )
        // With a timer, the hour; what the mix plays without is in its name.
        XCTAssertEqual(
            PageStatus.resolve(Input(isPlaying: true, timerEndsAt: end, omitted: [.ocean])),
            .playingFadesAt(end)
        )
    }

    func testStateLineWhenNothingSounds() {
        typealias Input = PageStatus.Input
        // A mix whose every layer needs Pro says so by day, and only by day.
        XCTAssertEqual(PageStatus.resolve(Input(omitted: [.ocean], isSilent: true)), .silentAllPro)
        XCTAssertEqual(
            PageStatus.resolve(Input(omitted: [.ocean], isSilent: true, isNightSession: true)), .silent
        )
        XCTAssertEqual(PageStatus.resolve(Input(isSilent: true)), .silent, "an empty mix is just silent")
        XCTAssertEqual(PageStatus.resolve(Input(omitted: [.ocean])), .silent, "something else would sound")

        // A failed start: the ladder stops at the third step.
        XCTAssertEqual(PageStatus.resolve(Input(startFailures: 1)), .error(attempt: 1))
        XCTAssertEqual(PageStatus.resolve(Input(startFailures: 2)), .error(attempt: 2))
        XCTAssertEqual(PageStatus.resolve(Input(startFailures: 7)), .error(attempt: 3))
        XCTAssertTrue(PageStatus.error(attempt: 1).isRetry)
        XCTAssertFalse(PageStatus.paused.isRetry)
        // Once it sounds, the failure is forgotten.
        XCTAssertEqual(PageStatus.resolve(Input(isPlaying: true, startFailures: 0)), .playing)
    }

    func testStateLineWordsInEnglishAndSpanish() {
        let end = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let rows: [(PageStatus, String, String)] = [
            (.silent, "Silent", "En silencio"),
            (.silentAllPro, "Silent · this mix is Pro", "En silencio · esta mezcla es Pro"),
            (.playing, "Playing", "Sonando"),
            (.playingFadesAt(end), "Playing · fades at 03:42", "Sonando · se funde a las 03:42"),
            (.fading(minutes: 8), "Playing · fading · 8 min", "Sonando · fundiendo · 8 min"),
            (.playingWithout([.thunder]), "Playing · without thunder", "Sonando · sin trueno"),
            (.playingWithout([.ocean, .thunder]), "Playing · without ocean or thunder",
             "Sonando · sin océano ni trueno"),
            (.playingFallback(.pink, percent: 40), "Playing · pink at 40", "Sonando · rosa a 40"),
            (.paused, "Paused", "En pausa"),
            (.pausedHeadphones, "Paused · headphones", "En pausa · auriculares"),
            (.pausedCall, "Paused · call", "En pausa · llamada"),
            (.error(attempt: 1), "Couldn't start the sound. Tap to try again.",
             "No se ha podido iniciar el sonido. Toca para reintentar."),
            (.error(attempt: 2), "If it still won't play, close the app and open it again.",
             "Si sigue sin sonar, cierra la app y vuelve a abrirla."),
            (.error(attempt: 3), "Close any app using the microphone and try again.",
             "Cierra las apps que usen el micrófono y vuelve a intentarlo."),
        ]
        for (language, column) in [("en", 1), ("es", 2)] {
            let strings = catalog(language)
            for row in rows {
                let text = row.0.text(
                    localized: strings,
                    soundName: { strings($0.nameKey) },
                    time: { _ in "03:42" },
                    locale: Locale(identifier: language)
                )
                XCTAssertEqual(text, column == 1 ? row.1 : row.2, "\(row.0) in \(language)")
            }
        }
    }

    func testStateLineIsSpokenWithPausesNotDots() {
        XCTAssertEqual(PageStatus.spoken("Sonando · se funde a las 03:42"), "Sonando, se funde a las 03:42")
        XCTAssertEqual(PageStatus.spoken("Playing · fading · 8 min"), "Playing, fading, 8 min")
        XCTAssertEqual(PageStatus.spoken("En pausa"), "En pausa")
        XCTAssertEqual(PageStatus.spoken("Mar y viento · sin Océano"), "Mar y viento, sin Océano")
    }

    // MARK: Trial word

    func testTrialWordSaysTheTrialTheAppHasToday() {
        for (language, five, last) in [
            ("en", "trial · 5 days", "trial · last day"),
            ("es", "prueba · 5 días", "prueba · último día"),
        ] {
            let strings = catalog(language)
            let locale = Locale(identifier: language)
            func word(_ trial: TrialState, isPro: Bool = false) -> String? {
                PageTrialWord.text(trial: trial, isPro: isPro, localized: strings, locale: locale)
            }
            XCTAssertNil(word(.notStarted), "the first screen says nothing about a trial")
            XCTAssertEqual(word(.active(daysRemaining: 5)), five, language)
            XCTAssertEqual(word(.active(daysRemaining: 1)), last, language)
            XCTAssertNil(word(.ended), "after the trial the header is empty")
            XCTAssertNil(word(.active(daysRemaining: 5), isPro: true), "bought: no mention")
        }
    }

    // MARK: Accessibility

    func testLayerRowsSpeakTheLinesOfTheCopyGuide() {
        let expected: [(SoundID, String, String)] = [
            (.white, "White, even hiss", "Blanco, siseo parejo"),
            (.pink, "Pink, soft and balanced", "Rosa, suave y equilibrado"),
            (.brown, "Brown, low rumble", "Marrón, retumbo grave"),
            (.rain, "Rain, on the roof", "Lluvia, sobre el tejado"),
            (.wind, "Wind, through trees", "Viento, entre árboles"),
            (.fan, "Fan, distant fan", "Ventilador, ventilador lejano"),
            (.ocean, "Ocean, slow swell", "Océano, oleaje lento"),
            (.thunder, "Thunder, distant, no strikes nearby", "Trueno, lejano, sin rayos cerca"),
            (.campfire, "Campfire, embers, no crackle", "Hoguera, brasas, sin chasquidos"),
            (.brook, "Brook, water over stones", "Arroyo, agua sobre piedras"),
            (.cabin, "Cabin, aircraft at cruise", "Cabina, avión en crucero"),
        ]
        XCTAssertEqual(Set(expected.map(\.0)), Set(SoundID.allCases))
        for (language, column) in [("en", 1), ("es", 2)] {
            let strings = catalog(language)
            for row in expected {
                let speech = LevelRuleSpeech(
                    name: strings(row.0.nameKey),
                    subtitle: strings(row.0.detailKey),
                    level: 0.5,
                    bundle: bundle(language)
                )
                XCTAssertEqual(speech.label, column == 1 ? row.1 : row.2)
            }
        }
        let strings = catalog("es")
        var ocean = LevelRuleSpeech(
            name: strings(SoundID.ocean.nameKey), subtitle: strings(SoundID.ocean.detailKey),
            level: 0.5, isLocked: true, bundle: bundle("es")
        )
        XCTAssertEqual(ocean.label, "Océano, oleaje lento, requiere Pro")
        XCTAssertEqual(ocean.value, "en silencio, nivel guardado 50")
        XCTAssertEqual(ocean.lockedWord, "pro · 50")
        // On the night page nothing says "requires Pro": the row is named
        // like any other and its value still says it is silent.
        ocean.namesPro = false
        XCTAssertEqual(ocean.label, "Océano, oleaje lento")
        XCTAssertEqual(ocean.value, "en silencio, nivel guardado 50")
        ocean.namesPro = true
        ocean.isLocked = false
        XCTAssertEqual(ocean.value, "50 por ciento")
    }

    // MARK: Error line

    func testTheErrorLineIsOneSentencePerLineAndNeverLeavesAWordAlone() {
        for language in ["en", "es"] {
            let strings = catalog(language)
            // First failure: two sentences, one per line.
            let first = PageStatus.errorLines(strings("pagina.error.inicio"))
            XCTAssertEqual(first.components(separatedBy: "\n").count, 2, language)
            XCTAssertFalse(first.contains(". "), language)
            // The next ones are one long sentence: its last three words stay
            // together, so no line is a single word.
            for key in ["pagina.error.inicio.2", "pagina.error.inicio.3"] {
                let text = strings(key)
                let set = PageStatus.errorLines(text)
                XCTAssertFalse(set.contains("\n"), key)
                XCTAssertEqual(set.components(separatedBy: "\u{00A0}").count, 3, "\(key) in \(language)")
                XCTAssertEqual(set.replacingOccurrences(of: "\u{00A0}", with: " "), text, "same words")
                // At the accessibility sizes three words may not fit a line.
                XCTAssertEqual(PageStatus.errorLines(text, bindsTail: false), text)
            }
        }
        XCTAssertEqual(PageStatus.errorLines("One. Two."), "One.\nTwo.")
        XCTAssertEqual(PageStatus.errorLines("Too short here"), "Too short here")
    }

    func testEveryPageStringExistsInBothLanguages() {
        let keys = [
            "mezcla.nombre.vacio", "pagina.estado.silencio", "pagina.estado.silencio.pro",
            "pagina.estado.sonando", "pagina.estado.sonando.funde", "pagina.estado.sonando.sin",
            "pagina.estado.sonando.defecto", "pagina.estado.fundiendo", "pagina.estado.pausa",
            "estado.pausa.auriculares", "pagina.estado.pausa.llamada", "madrugada.titulo",
            "pagina.error.inicio", "pagina.error.inicio.2",
            "pagina.error.inicio.3", "capas.todas", "capas.mas", "capas.tope", "barra.mezclas",
            "marea.titulo", "marea.estado.apagada.pro", "marea.estado.guiando.corto",
            "marea.estado.disolviendo", "temporizador.titulo", "temporizador.apagado",
            "temporizador.estado.dormirme", "mezcla.menu.guardar", "mezcla.guardar.campo",
            "capas.titulo", "capas.seccion.colores", "capas.seccion.camas", "capas.nota", "capas.cero",
            "ax.mas.pista", "ax.nombre.pista", "ax.nombre.pista.noche", "ax.accion.guardar",
            "ax.accion.volver.dia", "ax.marea.off.pro", "ax.marea.pista.pro", "ax.prueba.pista",
            "ax.reintentar", "trial.chip.daysFormat",
            "mezcla.guardar.titulo", "common.save", "common.cancel",
            "mezcla.menu.guardar.pro", "ax.guardar.pro", "ax.guardar.pro.pista", "marea.oceano.subido",
        ] + SoundID.allCases.flatMap { [$0.nameKey, $0.detailKey] }
        for language in ["en", "es"] {
            let strings = catalog(language)
            for key in keys {
                let value = strings(key)
                XCTAssertFalse(value.hasPrefix("<missing"), "\(key) is missing in \(language)")
                XCTAssertFalse(value.isEmpty, key)
            }
        }
        let (english, spanish) = (bundle("en"), bundle("es"))
        XCTAssertEqual(Localized.format("capas.mas", bundle: spanish, Int64(2)), "y 2 más")
        XCTAssertEqual(Localized.format("capas.mas", bundle: english, Int64(2)), "and 2 more")
        XCTAssertEqual(Localized.string("capas.tope", bundle: spanish), "Seis a la vez")
        XCTAssertEqual(Localized.string("capas.tope", bundle: english), "Six at once")
        XCTAssertEqual(
            Localized.format("temporizador.estado.dormirme", bundle: spanish, Int64(45)), "Hasta dormirme · 45 min"
        )
        XCTAssertEqual(Localized.format("marea.estado.guiando.corto", bundle: english, Int64(6)), "guiding · 6 per minute")
        // Subtitles are lines of use, written in lower case.
        for sound in SoundID.allCases {
            for language in ["en", "es"] {
                let subtitle = catalog(language)(sound.detailKey)
                XCTAssertEqual(subtitle, subtitle.lowercased(), "\(sound.rawValue) in \(language)")
            }
        }
    }

    // MARK: Geometry

    func testTheHorizonSitsAtAThirdAndTheHeadFillsTheRoomAboveIt() {
        let tall = PageMetrics(fullHeight: 852, topInset: 59)
        XCTAssertEqual(tall.horizonY, 284)
        XCTAssertEqual(tall.headHeight, 284 - 12 - 59)
        XCTAssertEqual(tall.headerTop, 5, "the trial word at y 64")
        XCTAssertFalse(tall.isShort)

        let short = PageMetrics(fullHeight: 667, topInset: 20)
        XCTAssertEqual(short.horizonY, 224)
        XCTAssertEqual(short.headerTop, 8, "at y 28 on a short screen")
        XCTAssertTrue(short.isShort)
        XCTAssertLessThan(short.airOverTide, tall.airOverTide)

        // Everything under the Horizon fits above the bar on both.
        for (metrics, rows, bottomInset) in [(tall, 3, CGFloat(34)), (short, 2, CGFloat(0))] {
            let under = metrics.airUnderHorizon + Grid.layerRow * CGFloat(rows) + Grid.row
                + metrics.airOverTide + Grid.rowSubtitle + Grid.row
            let bandBottom = metrics.horizonY + Grid.horizonBand / 2
            let barTop = metrics.fullHeight - bottomInset - PageBar.height
            XCTAssertLessThanOrEqual(bandBottom + under, barTop, "height \(metrics.fullHeight)")
        }
    }
}

/// What the model adds for the page: the first-use mix, the cap of six
/// layers and the gate that keeps the Pro sheet away at night. Nothing here
/// starts the audio engine.
@MainActor
final class PageModelTests: XCTestCase {
    private let day0 = Date(timeIntervalSinceReferenceDate: 700_000_000)

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    /// A moment at `hour`:`minute` UTC.
    private func time(_ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 17
        components.hour = hour
        components.minute = minute
        return utc.date(from: components) ?? day0
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private final class Clock {
        var now: Date
        init(_ now: Date) { self.now = now }
    }

    /// `free`: the trial ran out and nothing was bought.
    private func makeModel(free: Bool, clock: Clock, defaults: UserDefaults? = nil) throws -> MixerModel {
        let defaults = try defaults ?? makeDefaults()
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        if free {
            purchases.startTrialIfNeeded(now: day0)
            purchases.refreshAccess(now: day0.addingTimeInterval(8 * 86_400), canDowngrade: true)
        }
        XCTAssertEqual(purchases.hasFullAccess, !free)
        return MixerModel(purchases: purchases, defaults: defaults, now: { clock.now }, calendar: utc)
    }

    // MARK: First use

    func testFirstUseLoadsPinkAndRainAsItIs() throws {
        for free in [false, true] {
            let model = try makeModel(free: free, clock: Clock(time(12)))
            let mix = HouseMix.pinkAndRain
            XCTAssertEqual(model.levels, mix.levelsBySound())
            XCTAssertEqual(model.activeHouseMix, mix)
            XCTAssertEqual(model.loadedMixName, mix.localizedName, "both layers are free: never trimmed")
            XCTAssertFalse(model.loadedMixWasStripped)
            XCTAssertEqual(PageTitle.text(loadedMixName: model.loadedMixName), mix.localizedName)
            XCTAssertEqual(PageLayers.rows(model.levels, capacity: 3), [.rain, .pink])
            XCTAssertFalse(model.isSilent)
            XCTAssertFalse(model.isPlaying, "the app opens at rest")
            XCTAssertNil(model.pauseCause)
            XCTAssertFalse(model.showPaywall)
        }
    }

    func testAnEditedMixIsTonightAndComesBackAsItWasLeft() throws {
        let defaults = try makeDefaults()
        let model = try makeModel(free: false, clock: Clock(time(12)), defaults: defaults)
        XCTAssertEqual(model.setLevel(.rain, 0.3), .applied)
        XCTAssertNil(model.loadedMixName)
        XCTAssertNil(model.activeHouseMix)
        XCTAssertEqual(PageTitle.text(loadedMixName: model.loadedMixName), Localized.string("mezcla.nombre.vacio"))

        // Next launch: the stored levels, not the house mix again.
        let purchases = PurchaseManager(defaults: defaults, now: day0)
        let next = MixerModel(purchases: purchases, defaults: defaults)
        XCTAssertEqual(next.levels[.rain], 0.3)
        XCTAssertEqual(next.levels[.pink], HouseMix.pinkAndRain.levelsBySound()[.pink])
        XCTAssertNil(next.loadedMixName)
        XCTAssertNil(next.activeHouseMix)
    }

    // MARK: Six at once

    func testTheSeventhLayerIsNotAdded() throws {
        let model = try makeModel(free: false, clock: Clock(time(12)))
        XCTAssertEqual(MixerModel.maxSimultaneousLayers, 6)
        // Pink and rain are in; four more make six.
        for sound in [SoundID.wind, .ocean, .brown, .thunder] {
            XCTAssertEqual(model.setLevel(sound, 0.3), .applied, sound.rawValue)
        }
        XCTAssertEqual(model.soundingLayers.count, 6)

        let before = model.levels
        XCTAssertEqual(model.setLevel(.campfire, 0.4), .capReached)
        XCTAssertEqual(model.levels, before, "nothing moved")
        XCTAssertFalse(model.showPaywall, "the cap sells nothing")

        // A layer that already sounds still moves, up and down.
        XCTAssertEqual(model.setLevel(.ocean, 0.9), .applied)
        XCTAssertEqual(model.setLevel(.ocean, 0.1), .applied)
        // A layer at zero may stay at zero.
        XCTAssertEqual(model.setLevel(.campfire, 0), .applied)
        // One goes out, another may come in.
        XCTAssertEqual(model.setLevel(.thunder, 0), .applied)
        XCTAssertEqual(model.setLevel(.campfire, 0.4), .applied)
        XCTAssertEqual(model.soundingLayers.count, 6)
        XCTAssertEqual(model.setLevel(.thunder, 0.2), .capReached)
    }

    func testAProLayerThatDoesNotSoundIsNotCounted() throws {
        let model = try makeModel(free: true, clock: Clock(time(12)))
        // Saved while the trial lasted; it keeps its level and stays muted.
        model.levels[.ocean] = 0.5
        model.levels[.thunder] = 0.3
        for sound in [SoundID.wind, .white, .brown] {
            XCTAssertEqual(model.setLevel(sound, 0.3), .applied, sound.rawValue)
        }
        XCTAssertEqual(Set(model.soundingLayers), [.rain, .pink, .wind, .white, .brown])
        XCTAssertEqual(model.levels[.ocean], 0.5)
        // The page still gives the muted layers a row.
        XCTAssertEqual(PageLayers.rows(model.levels, capacity: 3), [.rain, .wind, .ocean])
    }

    // MARK: Nothing is sold at night

    func testSaleGateFollowsTheNightWindow() {
        let calendar = utc
        XCTAssertTrue(SaleGate.isOpen(at: time(12), calendar: calendar))
        XCTAssertTrue(SaleGate.isOpen(at: time(20, 59), calendar: calendar))
        XCTAssertFalse(SaleGate.isOpen(at: time(21), calendar: calendar))
        XCTAssertFalse(SaleGate.isOpen(at: time(3, 42), calendar: calendar))
        XCTAssertFalse(SaleGate.isOpen(at: time(6, 59), calendar: calendar))
        XCTAssertTrue(SaleGate.isOpen(at: time(7), calendar: calendar))
        // The night page sells nothing at any hour.
        XCTAssertFalse(SaleGate.isOpen(at: time(12), calendar: calendar, nightSession: true))
    }

    /// Every way the model has of asking for the Pro sheet, tried by day and
    /// at night on a model without access.
    func testNoPathOpensTheProSheetAtNight() throws {
        let clock = Clock(time(12))
        let model = try makeModel(free: true, clock: clock)
        for index in 1...AccessPolicy.freeSavedMixLimit {
            guard case .saved = model.saveCurrent(name: "Mix \(index)") else {
                return XCTFail("the free tier keeps \(AccessPolicy.freeSavedMixLimit) mixes")
            }
        }
        let paths: [(String, (MixerModel) -> Void)] = [
            ("the request itself", { $0.offerPro() }),
            ("a Pro layer", { XCTAssertEqual($0.setLevel(.thunder, 0.5), .needsPro) }),
            ("the tide", { $0.setBreathingEnabled(true) }),
            ("one mix too many", { XCTAssertEqual($0.saveCurrent(name: "One more"), .needsPro) }),
        ]

        for (name, path) in paths {
            clock.now = time(12)
            XCTAssertTrue(model.canSell)
            path(model)
            XCTAssertTrue(model.showPaywall, "\(name): by day the sheet goes up")
            model.dismissPro()
            XCTAssertFalse(model.showPaywall)

            for night in [time(21), time(23, 30), time(3, 42), time(6, 59)] {
                clock.now = night
                XCTAssertFalse(model.canSell)
                path(model)
                XCTAssertFalse(model.showPaywall, "\(name): nothing opens at night")
            }
        }
        // Nothing was queued for the morning (C08).
        clock.now = time(7)
        XCTAssertTrue(model.canSell)
        XCTAssertFalse(model.showPaywall)
        // And nothing was written on the way: the level asked for was dropped.
        XCTAssertEqual(model.levels[.thunder], 0)
        XCTAssertFalse(model.breathing.settings.isEnabled)
    }

    func testTheNightPageSellsNothingUntilThePersonLeavesIt() throws {
        let clock = Clock(time(12))
        let model = try makeModel(free: true, clock: clock)
        XCTAssertFalse(model.isNightSession)
        model.beginNightSession()
        XCTAssertTrue(model.isNightSession)
        XCTAssertFalse(model.canSell, "midday, but the page came from Night")
        model.offerPro()
        XCTAssertEqual(model.setLevel(.ocean, 0.5), .needsPro)
        XCTAssertFalse(model.showPaywall)

        // No clock ends it (C40): morning comes and it is still the night page.
        clock.now = time(9)
        XCTAssertTrue(model.isNightSession)
        XCTAssertFalse(model.canSell)

        model.endNightSession()
        XCTAssertFalse(model.isNightSession)
        XCTAssertTrue(model.canSell)
        model.offerPro()
        XCTAssertTrue(model.showPaywall)
    }

    /// The whole timer is free (C03): no length sells anything, at any hour.
    func testTheTimerNeverOpensTheProSheet() throws {
        let clock = Clock(time(12))
        let model = try makeModel(free: true, clock: clock)
        for hour in [12, 23] {
            clock.now = time(hour)
            model.selectTimer(minutes: AccessPolicy.maxTimerMinutes)
            XCTAssertEqual(model.timer.selectedMinutes, AccessPolicy.maxTimerMinutes)
            // Out of range: ignored, and the choice stays.
            model.selectTimer(minutes: AccessPolicy.maxTimerMinutes + 1)
            model.selectTimer(minutes: 0)
            XCTAssertEqual(model.timer.selectedMinutes, AccessPolicy.maxTimerMinutes)
            XCTAssertFalse(model.showPaywall, "hour \(hour)")
            model.selectTimer(minutes: nil)
            XCTAssertNil(model.timer.selectedMinutes)
        }
    }

    /// The gate is not only for new requests: a sheet that was up before
    /// 21:00 does not stay up into the night.
    func testAProSheetLeftUpComesDownWhenTheNightBegins() throws {
        let clock = Clock(time(20, 59))
        let model = try makeModel(free: true, clock: clock)
        model.offerPro()
        XCTAssertTrue(model.showPaywall)
        model.closeSaleIfNight()
        XCTAssertTrue(model.showPaywall, "still day: it stays")

        clock.now = time(21)
        model.closeSaleIfNight()
        XCTAssertFalse(model.showPaywall)

        // The night page closes it too, at any hour.
        clock.now = time(12)
        model.offerPro()
        XCTAssertTrue(model.showPaywall)
        model.beginNightSession()
        XCTAssertFalse(model.showPaywall)
    }

    // MARK: A level that did not change

    func testALevelWrittenAsItWasKeepsTheNameOfTheMix() throws {
        let model = try makeModel(free: false, clock: Clock(time(12)))
        for sound in [SoundID.wind, .ocean, .brown, .thunder] {
            XCTAssertEqual(model.setLevel(sound, 0.3), .applied)
        }
        guard case .saved = model.saveCurrent(name: "Six") else { return XCTFail("saved") }
        XCTAssertEqual(model.loadedMixName, "Six")

        // A seventh row dragged and let go: refused, then written back at
        // zero by the end of the drag. Nothing changed, so the name stays.
        XCTAssertEqual(model.setLevel(.campfire, 0.4), .capReached)
        XCTAssertEqual(model.setLevel(.campfire, 0), .applied)
        XCTAssertEqual(model.loadedMixName, "Six")
        // A drag that comes back to where it started.
        XCTAssertEqual(model.setLevel(.ocean, 0.3), .applied)
        XCTAssertEqual(model.loadedMixName, "Six")
        XCTAssertEqual(model.loadedMixBaseName, "Six")

        // The house mix of the first use keeps its identity the same way.
        let fresh = try makeModel(free: false, clock: Clock(time(12)))
        let rain = try XCTUnwrap(fresh.levels[.rain])
        XCTAssertEqual(fresh.setLevel(.rain, rain), .applied)
        XCTAssertEqual(fresh.setLevel(.campfire, 0), .applied)
        XCTAssertEqual(fresh.activeHouseMix, .pinkAndRain)
        XCTAssertEqual(fresh.loadedMixName, HouseMix.pinkAndRain.localizedName)
        // A real change still makes it "Tonight".
        XCTAssertEqual(fresh.setLevel(.rain, rain / 2), .applied)
        XCTAssertNil(fresh.loadedMixName)
        XCTAssertNil(fresh.activeHouseMix)
    }

    // MARK: Six at once, the tide included

    func testTheTideDoesNotAddASeventhLayer() throws {
        let model = try makeModel(free: false, clock: Clock(time(12)))
        // Six layers and the ocean silent.
        for sound in [SoundID.wind, .white, .brown, .thunder] {
            XCTAssertEqual(model.setLevel(sound, 0.3), .applied)
        }
        XCTAssertEqual(model.soundingLayers.count, MixerModel.maxSimultaneousLayers)
        XCTAssertEqual(model.levels[.ocean], 0)

        model.setBreathingEnabled(true)
        XCTAssertTrue(model.breathing.settings.isEnabled, "the tide is armed")
        XCTAssertEqual(model.levels[.ocean], 0, "the ocean is not raised over the cap")
        XCTAssertEqual(model.soundingLayers.count, MixerModel.maxSimultaneousLayers)
        XCTAssertEqual(model.breathingNote, Localized.string("capas.tope"))
        model.setBreathingEnabled(false)
        XCTAssertEqual(model.levels[.ocean], 0)

        // With room for it the ocean comes up to the tide's level, and the
        // note says the number the model used.
        XCTAssertEqual(model.setLevel(.thunder, 0), .applied)
        model.setBreathingEnabled(true)
        XCTAssertEqual(model.levels[.ocean], MixerModel.tideOceanLevel)
        XCTAssertEqual(model.soundingLayers.count, MixerModel.maxSimultaneousLayers)
        let percent = Int64((MixerModel.tideOceanLevel * 100).rounded())
        XCTAssertEqual(model.breathingNote, Localized.format("marea.oceano.subido", percent))
        XCTAssertTrue(model.breathingNote?.contains("\(percent)") == true)
        // Switched off: the tide never lowers the ocean it raised.
        model.setBreathingEnabled(false)
        XCTAssertEqual(model.levels[.ocean], MixerModel.tideOceanLevel)
    }

    // MARK: Levels on disk

    func testLevelsAreWrittenWhenTheFingerLeavesNotOnEverySample() throws {
        let defaults = try makeDefaults()
        let model = try makeModel(free: false, clock: Clock(time(12)), defaults: defaults)
        func storedRain() -> Float? {
            MixerModel(purchases: model.purchases, defaults: defaults).levels[.rain]
        }
        let first = try XCTUnwrap(storedRain())

        model.beginLevelGesture()
        XCTAssertEqual(model.setLevel(.rain, 0.11), .applied)
        XCTAssertEqual(model.setLevel(.rain, 0.12), .applied)
        XCTAssertEqual(model.levels[.rain], 0.12, "the level itself moves at once")
        XCTAssertEqual(storedRain(), first, "nothing on disk while the finger is down")
        model.endLevelGesture()
        XCTAssertEqual(storedRain(), 0.12)

        // Without a gesture (VoiceOver, the fine slider) every write is kept.
        XCTAssertEqual(model.setLevel(.rain, 0.5), .applied)
        XCTAssertEqual(storedRain(), 0.5)
        // An end without a beginning does no harm.
        model.endLevelGesture()
        XCTAssertEqual(model.setLevel(.rain, 0.6), .applied)
        XCTAssertEqual(storedRain(), 0.6)
    }

    func testLeavingNightOnlyCountsAfterEnteringIt() throws {
        let model = try makeModel(free: false, clock: Clock(time(12)))
        model.leaveBedtime()
        XCTAssertFalse(model.isNightSession, "the page did not come from Night")
    }
}
