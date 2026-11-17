import XCTest
@testable import SleepNoise

/// What the tide sheet says (surface 6), without a view.
final class TideSheetTextTests: XCTestCase {
    private let spanish: [String: String] = [
        "marea.estado.guiando.corto": "guiando · %lld por minuto",
        "marea.estado.disolviendo": "disolviendo",
        "marea.estado.pausa": "en pausa",
        "marea.estado.apagada": "apagada",
        "marea.retira.hora": "Se retira a las %@",
        "marea.ritmo": "Empezar a %lld por minuto",
        "marea.ritmo.tranquilo": "Tranquilo · %lld por minuto",
        "marea.ritmo.suave": "Suave · %lld por minuto",
        "marea.ritmo.tranquilo.corto": "Tranquilo · %lld",
        "marea.ritmo.suave.corto": "Suave · %lld",
        "marea.ritmo.exacto": "%lld por minuto",
        "marea.retira.valor": "%lld min",
        "marea.fase.inhala": "inhala",
        "marea.fase.exhala": "exhala",
        "ax.agua.valor": "%1$@, %2$lld por minuto, se retira en %3$lld minutos"
    ]

    private var lookup: (String) -> String {
        { [spanish] key in spanish[key] ?? "?\(key)?" }
    }

    private let locale = Locale(identifier: "es_ES")
    private let end = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func word(_ status: TideStatus) -> String? {
        status.word(localized: lookup, locale: locale)
    }

    // MARK: State

    func testOffAndArmedSayNothing() {
        XCTAssertEqual(TideStatus.resolve(.init()), .off)
        XCTAssertEqual(TideStatus.resolve(.init(isEnabled: true)), .armed)
        XCTAssertNil(word(.off), "the still hairline and the switch already say it")
        XCTAssertNil(word(.armed))
        XCTAssertFalse(TideStatus.off.showsWater)
        XCTAssertFalse(TideStatus.armed.showsWater)
    }

    func testWithoutAccessTheTideIsOffWhateverTheSwitchKept() {
        // The trial ran out with the tide on: the setting is kept, nothing guides.
        let status = TideStatus.resolve(.init(
            isEnabled: true, isIncluded: false, phase: .guiding, guidingRate: 6
        ))
        XCTAssertEqual(status, .off)
        XCTAssertNil(word(status))
    }

    func testGuidingSaysThePaceItHoldsNow() {
        let chosen = TideStatus.resolve(.init(isEnabled: true, phase: .guiding, guidingRate: 6, chosenRate: 6))
        XCTAssertEqual(chosen, .guiding(rate: 6))
        XCTAssertEqual(word(chosen), "guiando · 6 por minuto")

        // Inside a descent the word follows the step, not the pace chosen.
        let descending = TideStatus.resolve(.init(isEnabled: true, phase: .guiding, guidingRate: 11, chosenRate: 6))
        XCTAssertEqual(word(descending), "guiando · 11 por minuto")
        XCTAssertTrue(descending.showsWater)

        let unknown = TideStatus.resolve(.init(isEnabled: true, phase: .guiding, guidingRate: nil, chosenRate: 8))
        XCTAssertEqual(unknown, .guiding(rate: 8))
    }

    func testDissolvingAndPausedAreWords() {
        let dissolving = TideStatus.resolve(.init(isEnabled: true, phase: .dissolving, guidingRate: 6))
        XCTAssertEqual(word(dissolving), "disolviendo")
        XCTAssertTrue(dissolving.showsWater)

        let paused = TideStatus.resolve(.init(isEnabled: true, phase: .idle, isPausedInsideWindow: true))
        XCTAssertEqual(paused, .paused)
        XCTAssertEqual(word(paused), "en pausa")
        XCTAssertTrue(paused.showsWater)
    }

    func testTheHourItRecedesIsOnlyThereWhileThereIsWater() {
        let clock: (Date) -> String = { _ in "23:27" }
        func recedes(_ status: TideStatus, _ date: Date?) -> String? {
            TideSheetText.recedes(status: status, at: date, localized: lookup, time: clock)
        }
        XCTAssertEqual(recedes(.guiding(rate: 6), end), "Se retira a las 23:27")
        XCTAssertEqual(recedes(.dissolving, end), "Se retira a las 23:27")
        XCTAssertEqual(recedes(.paused, end), "Se retira a las 23:27")
        XCTAssertNil(recedes(.off, end), "a window kept from before says nothing while the tide is off")
        XCTAssertNil(recedes(.armed, end))
        XCTAssertNil(recedes(.guiding(rate: 6), nil))
    }

    // MARK: Pace

    func testThePaceHasAHumanNameAtSixAndEight() {
        XCTAssertEqual(TideSheetText.paceValue(6, localized: lookup, locale: locale), "Tranquilo · 6")
        XCTAssertEqual(TideSheetText.paceValue(8, localized: lookup, locale: locale), "Suave · 8")
        XCTAssertEqual(TideSheetText.paceValue(5, localized: lookup, locale: locale), "5 por minuto")
        XCTAssertEqual(TideSheetText.paceOption(6, localized: lookup, locale: locale), "Tranquilo · 6 por minuto")
        XCTAssertEqual(TideSheetText.paceOption(8, localized: lookup, locale: locale), "Suave · 8 por minuto")
        XCTAssertEqual(TideSheetText.paceOption(7, localized: lookup, locale: locale), "7 por minuto")
    }

    /// AGENTS §5.2: the figures of the names come from the model.
    func testTheFiguresOfThePaceComeFromTheModel() {
        let bare: (String) -> String = { _ in "%lld" }
        XCTAssertEqual(
            TideSheetText.paceValue(BreathingSettings.calmRate, localized: bare, locale: locale),
            "\(BreathingSettings.calmRate)"
        )
        XCTAssertEqual(
            TideSheetText.paceOption(BreathingSettings.gentleRate, localized: bare, locale: locale),
            "\(BreathingSettings.gentleRate)"
        )
        XCTAssertEqual(
            TideSheetText.descentDetail(localized: bare, locale: locale),
            "\(BreathingSettings.descentStartRate)"
        )
        XCTAssertEqual(TideSheetText.descentDetail(localized: lookup, locale: locale), "Empezar a 12 por minuto")
    }

    func testTheMenuOffersTheTwoNamesAndTheCurrentPace() {
        XCTAssertEqual(TideSheetText.paceOptions(current: 6), [6, 8])
        XCTAssertEqual(TideSheetText.paceOptions(current: 8), [6, 8])
        XCTAssertEqual(TideSheetText.paceOptions(current: 5), [5, 6, 8])
        XCTAssertEqual(TideSheetText.paceOptions(current: 7), [6, 7, 8])
        XCTAssertEqual(TideSheetText.paceOptions(current: 12), [6, 8], "outside the range is not a choice")
    }

    func testDraggingTheLineIsOneBreathEveryFiftySixPoints() {
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: 0), 6)
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: 55), 6)
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: 56), 7, "to the right is faster")
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: -56), 5)
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: -55), 6)
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: 1_000), 8, "it stops at the range")
        XCTAssertEqual(TideSheetText.draggedRate(from: 6, translation: -1_000), 4)
    }

    func testTheLengthsOfTheGuideAreFiveToThirty() {
        XCTAssertEqual(BreathingSettings.durationChoices, [5, 10, 15, 20, 30])
        XCTAssertEqual(TideSheetText.recedesAfterValue(15, localized: lookup, locale: locale), "15 min")
    }

    // MARK: VoiceOver

    func testTheWaterLineSpeaksItsStateItsPaceAndWhenItRecedes() {
        func spoken(_ status: TideStatus, rising: Bool = true, minutes: Int? = 12) -> String {
            TideSheetText.spokenLine(
                status: status, isBreathingIn: rising, chosenRate: 6, minutesToRecede: minutes,
                localized: lookup, locale: locale
            )
        }
        XCTAssertEqual(spoken(.guiding(rate: 6)), "inhala, 6 por minuto, se retira en 12 minutos")
        XCTAssertEqual(spoken(.guiding(rate: 6), rising: false), "exhala, 6 por minuto, se retira en 12 minutos")
        XCTAssertEqual(spoken(.guiding(rate: 6), minutes: 0), "inhala, 6 por minuto, se retira en 1 minutos")
        XCTAssertEqual(spoken(.guiding(rate: 6), minutes: nil), "inhala, 6 por minuto")
        XCTAssertEqual(spoken(.off), "apagada, 6 por minuto")
        XCTAssertEqual(spoken(.armed), "apagada, 6 por minuto")
        XCTAssertEqual(spoken(.dissolving), "disolviendo")
        XCTAssertEqual(spoken(.paused), "en pausa, 6 por minuto")
    }

    // MARK: The breath on screen

    func testTheLineReadsTheBreathTheEngineRenders() {
        let anchor = Date(timeIntervalSinceReferenceDate: 1_000)
        let parameters = BreathParameters.guided(breathsPerMinute: 6)
        func level(_ seconds: TimeInterval) -> Float {
            TideBreath.level(at: anchor.addingTimeInterval(seconds), anchor: anchor, parameters: parameters)
        }
        // Six a minute: four seconds up, four and a half down, one and a half at rest.
        XCTAssertEqual(level(0), 0, accuracy: 0.001)
        XCTAssertEqual(level(2), 0.5, accuracy: 0.001)
        XCTAssertEqual(level(4), 1, accuracy: 0.001)
        XCTAssertEqual(level(9), 0, accuracy: 0.001)
        XCTAssertEqual(level(12), 0.5, accuracy: 0.001, "the second breath")
        XCTAssertEqual(
            level(3),
            BreathCurve.value(secondsSinceStart: 3, parameters: parameters),
            "never a curve of its own"
        )
        XCTAssertEqual(TideBreath.level(at: anchor, anchor: nil, parameters: parameters), 0)
        XCTAssertEqual(level(-5), 0, "before the anchor it waits at low tide")
    }

    func testBreatheInWhileItRisesAndThreeBreathsAreCounted() {
        let anchor = Date(timeIntervalSinceReferenceDate: 1_000)
        let parameters = BreathParameters.guided(breathsPerMinute: 6)
        func rising(_ seconds: TimeInterval) -> Bool {
            TideBreath.isBreathingIn(at: anchor.addingTimeInterval(seconds), anchor: anchor, parameters: parameters)
        }
        func done(_ seconds: TimeInterval) -> Int {
            TideBreath.breathsDone(at: anchor.addingTimeInterval(seconds), anchor: anchor, parameters: parameters)
        }
        XCTAssertTrue(rising(1))
        XCTAssertFalse(rising(5))
        XCTAssertFalse(rising(9.5), "the rest at low tide is still breathing out")
        XCTAssertTrue(rising(11))
        XCTAssertEqual(done(9), 0)
        XCTAssertEqual(done(10.5), 1)
        XCTAssertEqual(done(29), 2)
        XCTAssertGreaterThanOrEqual(done(30.5), TideBreath.guidedBreaths, "the words go after the third")
        XCTAssertFalse(TideBreath.isBreathingIn(at: anchor, anchor: nil, parameters: parameters))
        XCTAssertFalse(TideBreath.isBreathingIn(at: anchor, anchor: anchor, parameters: .off))
        XCTAssertEqual(TideBreath.breathsDone(at: anchor, anchor: anchor, parameters: .off), 0)
    }

    func testTheLineTravelsTheWholeBandAndNoFurther() {
        XCTAssertEqual(TideLine.offset(level: 0), TideLine.band - TideLine.thickness, "low tide: the foot of the band")
        XCTAssertEqual(TideLine.offset(level: 1), 0, "high tide: its top")
        XCTAssertEqual(TideLine.offset(level: 0.5), (TideLine.band - TideLine.thickness) / 2)
        XCTAssertEqual(TideLine.offset(level: 2), 0)
        XCTAssertEqual(TideLine.offset(level: -1), TideLine.band - TideLine.thickness)
        XCTAssertEqual(TideLine.band, 120)
        // Reduce Motion: no travel, the breath is light.
        XCTAssertEqual(TideLine.reducedOpacity(level: 0), 0.6, accuracy: 0.001)
        XCTAssertEqual(TideLine.reducedOpacity(level: 1), 1, accuracy: 0.001)
    }

    // MARK: Catalog

    func testEveryTideStringExistsInBothLanguages() throws {
        let strings = try TimerCatalogTests.catalog()
        let keys = [
            "marea.titulo", "marea.instruccion", "marea.fase.inhala", "marea.fase.exhala",
            "marea.estado.guiando.corto", "marea.estado.disolviendo", "marea.estado.pausa",
            "marea.estado.apagada", "marea.estado.apagada.pro", "marea.retira.hora", "marea.retirada",
            "marea.oceano.subido", "marea.toggle", "marea.descenso", "marea.ritmo", "marea.ritmo.fila",
            "marea.ritmo.tranquilo", "marea.ritmo.suave", "marea.ritmo.tranquilo.corto",
            "marea.ritmo.suave.corto", "marea.ritmo.exacto", "marea.retira", "marea.retira.valor",
            "ax.agua.valor", "ax.agua.pista", "ax.marea.pista", "ax.marea.off.pro", "ax.marea.pista.pro",
            "comun.pro"
        ]
        for key in keys {
            for language in ["en", "es"] {
                XCTAssertFalse(
                    TimerCatalogTests.values(key, language, in: strings).isEmpty,
                    "\(key) [\(language)] is missing"
                )
            }
        }
        // The names the tide had before the reconciliation are not written.
        for language in ["en", "es"] {
            for key in keys {
                for value in TimerCatalogTests.values(key, language, in: strings) {
                    let text = value.lowercased()
                    XCTAssertFalse(text.contains("respiratoria"), "\(key): \(value)")
                    XCTAssertFalse(text.contains("breathing tide"), "\(key): \(value)")
                }
            }
        }
    }
}

/// The ritual of the tide and what the sheet asks of the controller.
@MainActor
final class TideDescentTests: XCTestCase {
    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    func testThePaceOfADescentComesDownOneEveryFortySeconds() {
        var settings = BreathingSettings()
        XCTAssertEqual(settings.rate(descentElapsed: 0), 6, "without the ritual, the pace chosen")
        XCTAssertNil(settings.nextDescentStep(after: 0))
        settings.descends = true
        XCTAssertEqual(settings.rate(descentElapsed: nil), 6)
        XCTAssertEqual(settings.rate(descentElapsed: 0), 12)
        XCTAssertEqual(settings.rate(descentElapsed: 39.9), 12)
        XCTAssertEqual(settings.rate(descentElapsed: 40), 11)
        XCTAssertEqual(settings.rate(descentElapsed: 200), 7)
        XCTAssertEqual(settings.rate(descentElapsed: 240), 6, "twelve to six takes four minutes")
        XCTAssertEqual(settings.rate(descentElapsed: 3_600), 6, "then the plateau")
        XCTAssertEqual(settings.nextDescentStep(after: 0), 40)
        XCTAssertEqual(settings.nextDescentStep(after: 45), 80)
        XCTAssertEqual(settings.nextDescentStep(after: 239), 240)
        XCTAssertNil(settings.nextDescentStep(after: 240))
        settings.breathsPerMinute = 8
        XCTAssertEqual(settings.rate(descentElapsed: 160), 8)
        XCTAssertNil(settings.nextDescentStep(after: 160))
    }

    func testTheGuideDescendsHoldsAndStillRecedesOnTime() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        guide.settings.descends = true
        let start = Date(timeIntervalSinceReferenceDate: 10_000)
        guide.begin(now: start)
        XCTAssertEqual(guide.guidingRate, 12)
        XCTAssertEqual(published.last?.rate ?? 0, 12.0 / 60, accuracy: 0.000_01)
        XCTAssertEqual(published.last?.bedDepth, 0.4, "the same depth: only the pace moves")
        XCTAssertEqual(guide.guideEndsAt, start.addingTimeInterval(15 * 60))

        // Not due yet: nothing is published.
        let before = published.count
        guide.advance(now: start.addingTimeInterval(39))
        XCTAssertEqual(published.count, before)

        // 42 s in: 8.4 breaths at twelve a minute, so 0.4 of a cycle. The
        // new pace keeps that fraction and the epoch: the sound is continuous.
        let step = start.addingTimeInterval(42)
        guide.advance(now: step)
        XCTAssertEqual(guide.guidingRate, 11)
        XCTAssertEqual(published.last?.rate ?? 0, 11.0 / 60, accuracy: 0.000_01)
        XCTAssertEqual(published.last?.epoch, 1)
        XCTAssertEqual(published.last?.weight, 1)
        let anchor = try XCTUnwrap(guide.anchor)
        XCTAssertEqual(step.timeIntervalSince(anchor) * (11.0 / 60), 0.4, accuracy: 0.001)

        // A late tick lands on the right step, and the plateau holds.
        guide.advance(now: start.addingTimeInterval(4 * 60 + 5))
        XCTAssertEqual(guide.guidingRate, 6)
        XCTAssertEqual(published.last?.rate ?? 0, 0.1, accuracy: 0.000_01)
        let plateau = published.count
        guide.advance(now: start.addingTimeInterval(10 * 60))
        XCTAssertEqual(published.count, plateau)
        XCTAssertEqual(guide.phase, .guiding)

        // The window is the one chosen: the descent does not lengthen it.
        guide.advance(now: start.addingTimeInterval(15 * 60))
        XCTAssertEqual(guide.phase, .dissolving)
        XCTAssertEqual(published.last?.weight, 0)
        XCTAssertEqual(published.last?.dissolveSeconds, BreathingGuideController.dissolveSeconds)
        guide.end()
        XCTAssertNil(guide.guidingRate)
    }

    func testDescentSwitchedWhileGuidingStartsAndStopsAtOnce() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        let start = Date(timeIntervalSinceReferenceDate: 0)
        guide.begin(now: start)
        XCTAssertEqual(guide.guidingRate, 6)

        // On, five minutes in: the way down begins now, not at the start.
        guide.settings.descends = true
        let on = start.addingTimeInterval(5 * 60)
        guide.settingsDidChange(now: on)
        XCTAssertEqual(guide.guidingRate, 12)
        XCTAssertEqual(published.last?.epoch, 1)
        guide.advance(now: on.addingTimeInterval(81))
        XCTAssertEqual(guide.guidingRate, 10)

        // Dragging the line during a descent sets where it lands; the step
        // it is on does not change.
        guide.settings.breathsPerMinute = 8
        guide.settingsDidChange(now: on.addingTimeInterval(82))
        XCTAssertEqual(guide.guidingRate, 10)

        // Off: straight to the pace chosen.
        guide.settings.descends = false
        guide.settingsDidChange(now: on.addingTimeInterval(83))
        XCTAssertEqual(guide.guidingRate, 8)
        XCTAssertEqual(published.last?.rate ?? 0, 8.0 / 60, accuracy: 0.000_01)
        XCTAssertEqual(published.last?.epoch, 1)

        // On again: from twelve once more, down to the pace and no lower.
        guide.settings.descends = true
        let again = on.addingTimeInterval(90)
        guide.settingsDidChange(now: again)
        XCTAssertEqual(guide.guidingRate, 12)
        guide.advance(now: again.addingTimeInterval(4 * 60))
        XCTAssertEqual(guide.guidingRate, 8)
        XCTAssertEqual(guide.phase, .guiding)
        XCTAssertEqual(guide.guideEndsAt, start.addingTimeInterval(15 * 60), "the window keeps its start")
        guide.end()
    }

    func testAPauseKeepsTheWindowOpenUntilTheGuideWouldHaveEnded() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        let start = Date(timeIntervalSinceReferenceDate: 0)
        XCTAssertFalse(guide.hasOpenWindow(now: start))
        guide.begin(now: start)
        guide.end()
        XCTAssertTrue(guide.hasOpenWindow(now: start.addingTimeInterval(5 * 60)))
        XCTAssertFalse(guide.hasOpenWindow(now: start.addingTimeInterval(15 * 60)))
        XCTAssertNil(guide.guidingRate)
    }

    func testSettingsFromBeforeTheRitualKeepEverythingElse() throws {
        let defaults = try makeDefaults()
        let old = #"{"isEnabled":true,"breathsPerMinute":5,"guideMinutes":20}"#
        defaults.set(Data(old.utf8), forKey: BreathingGuideController.storageKey)
        let guide = BreathingGuideController(defaults: defaults)
        XCTAssertEqual(
            guide.settings,
            BreathingSettings(isEnabled: true, breathsPerMinute: 5, guideMinutes: 20, descends: false)
        )

        // The ritual is stored with the rest.
        guide.settings.descends = true
        XCTAssertTrue(BreathingGuideController(defaults: defaults).settings.descends)
    }

    /// "All night" is not offered in 1.0 (06 §8): a stored one is read as
    /// the longest length there is.
    func testAStoredAllNightIsReadAsTheLongestGuide() throws {
        let defaults = try makeDefaults()
        let old = #"{"isEnabled":true,"breathsPerMinute":6,"guideMinutes":0}"#
        defaults.set(Data(old.utf8), forKey: BreathingGuideController.storageKey)
        let guide = BreathingGuideController(defaults: defaults)
        XCTAssertEqual(guide.settings.guideMinutes, 30)
        XCTAssertFalse(guide.settings.guidesAllNight)
        XCTAssertTrue(guide.settings.isEnabled)
        XCTAssertEqual(guide.settings.bedDepth, 0.4)
    }
}

/// The switch of the tide over the real model, on doubles.
@MainActor
final class TideSwitchTests: XCTestCase {
    func testTheSwitchStartsTheNightAndTheGuideWithIt() throws {
        let night = try NightHarness(at: NightHarness.time(12))
        XCTAssertFalse(night.model.isPlaying)
        night.model.setBreathingEnabled(true, startsSound: true)
        XCTAssertTrue(night.model.isPlaying, "the switch never says on over silence")
        XCTAssertEqual(night.model.breathing.phase, .guiding)
        XCTAssertEqual(night.model.breathing.guidingRate, 6)
        XCTAssertNotNil(night.model.breathing.guideEndsAt)

        // Off: the guide stops, the night goes on.
        night.model.setBreathingEnabled(false, startsSound: true)
        XCTAssertTrue(night.model.isPlaying)
        XCTAssertEqual(night.model.breathing.phase, .idle)
    }

    func testArmingWithoutTheSwitchDoesNotStartAnything() throws {
        let night = try NightHarness(at: NightHarness.time(12))
        night.model.setBreathingEnabled(true)
        XCTAssertFalse(night.model.isPlaying)
        XCTAssertEqual(night.model.breathing.phase, .idle)
        XCTAssertEqual(
            TideStatus.resolve(.init(isEnabled: true, phase: night.model.breathing.phase)),
            .armed
        )
    }

    func testTheOceanTheTideRaisedStaysUp() throws {
        let night = try NightHarness(at: NightHarness.time(12))
        XCTAssertEqual(night.model.levels[.ocean], 0)
        night.model.setBreathingEnabled(true, startsSound: true)
        XCTAssertEqual(night.model.levels[.ocean], MixerModel.tideOceanLevel)
        XCTAssertEqual(MixerModel.tideOceanLevel, 0.4)
        night.model.setBreathingEnabled(false, startsSound: true)
        XCTAssertEqual(night.model.levels[.ocean], MixerModel.tideOceanLevel, "the tide never lowers it again")
    }

    func testWithoutAccessTheSwitchAsksForProByDayAndStaysOff() throws {
        let night = try NightHarness(at: NightHarness.time(12), free: true)
        XCTAssertFalse(night.model.breathingIsIncluded)
        XCTAssertTrue(night.model.canSell)
        night.model.setBreathingEnabled(true, startsSound: true)
        XCTAssertTrue(night.model.showPaywall)
        XCTAssertFalse(night.model.breathing.settings.isEnabled, "the switch goes back to off")
        XCTAssertFalse(night.model.isPlaying, "nothing sounds differently")
        XCTAssertEqual(night.model.levels[.ocean], 0)
    }

    func testWithoutAccessAtNightTheSwitchDoesNothing() throws {
        // Inside NightWindow, and on the night page at any hour.
        let night = try NightHarness(at: NightHarness.time(23), free: true)
        XCTAssertFalse(night.model.canSell)
        night.model.setBreathingEnabled(true, startsSound: true)
        XCTAssertFalse(night.model.showPaywall)
        XCTAssertFalse(night.model.breathing.settings.isEnabled)
        XCTAssertFalse(night.model.isPlaying)

        let day = try NightHarness(at: NightHarness.time(12), free: true)
        day.model.beginNightSession()
        day.model.setBreathingEnabled(true, startsSound: true)
        XCTAssertFalse(day.model.showPaywall, "the night page sells nothing, whatever the hour")
        XCTAssertFalse(day.model.isPlaying)
    }

    /// The settings of the sheet go through the model, and a running guide
    /// follows them without the switch moving.
    func testTheRowsOfTheSheetReachARunningGuide() throws {
        let night = try NightHarness(at: NightHarness.time(12))
        night.model.setBreathingEnabled(true, startsSound: true)
        var settings = night.model.breathing.settings
        settings.breathsPerMinute = 8
        settings.guideMinutes = 30
        settings.isEnabled = false
        night.model.updateBreathing(settings)
        XCTAssertTrue(night.model.breathing.settings.isEnabled, "only the switch is the switch")
        XCTAssertEqual(night.model.breathing.guidingRate, 8)
        XCTAssertEqual(night.model.breathing.phase, .guiding)

        settings = night.model.breathing.settings
        settings.descends = true
        night.model.updateBreathing(settings)
        XCTAssertEqual(night.model.breathing.guidingRate, BreathingSettings.descentStartRate)
    }
}
