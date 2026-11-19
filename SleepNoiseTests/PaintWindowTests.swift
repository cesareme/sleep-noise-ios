import SwiftUI
import XCTest
@testable import SleepNoise

/// The painted window on the page (exploration 12 §7 fase 2, task 2): the
/// veil the page draws, the pulse the Horizon feeds, the rule of Layers,
/// the conditions a view hands the policy, the night fade that is final,
/// the words of Settings and the staged states.
final class PaintWindowTests: XCTestCase {
    private let geometry = PaintWindowGeometry(width: 402)

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Madrid")!
        return calendar
    }()

    private func day(_ hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 19, hour: hour, minute: minute))!
    }

    // MARK: The veil

    /// 35 % at the Horizon, 75 % at the edges, 80 % over the reserve strip
    /// of 24 pt, 90 % under the text that enters the window.
    func testTheVeilIsTheOneOfTheDesign() {
        let g = geometry
        XCTAssertEqual(PaintVeil.opacity(atY: 0, geometry: g), 0.75, accuracy: 0.001)
        XCTAssertEqual(PaintVeil.opacity(atY: g.height, geometry: g), 0.75, accuracy: 0.001)
        XCTAssertEqual(PaintVeil.opacity(atY: g.horizonY, geometry: g), 0.80, "the reserve strip")
        XCTAssertEqual(PaintVeil.opacity(atY: g.horizonY - 12, geometry: g), 0.80)
        XCTAssertEqual(PaintVeil.opacity(atY: g.horizonY + 12, geometry: g), 0.80)
        let justOutside = PaintVeil.opacity(atY: g.horizonY + 12.5, geometry: g)
        XCTAssertEqual(justOutside, 0.392, accuracy: 0.001, "the centre, right past the strip")
        let halfway = PaintVeil.opacity(atY: g.horizonY + 60, geometry: g)
        XCTAssertEqual(halfway, 0.55, accuracy: 0.001, "straight from the centre to the edge")
        // Monotonic from the strip to the edge: no line of cut.
        var previous = justOutside
        for y in stride(from: g.horizonY + 13, through: g.height, by: 1) {
            let value = PaintVeil.opacity(atY: y, geometry: g)
            XCTAssertGreaterThanOrEqual(value, previous - 1e-9, "y \(y)")
            previous = value
        }
        let reserves = PaintReserves(rowsTop: 148, textBottom: 12)
        XCTAssertEqual(PaintVeil.opacity(atY: 148, geometry: g, reserves: reserves), 0.96)
        XCTAssertEqual(PaintVeil.opacity(atY: 200, geometry: g, reserves: reserves), 0.96)
        XCTAssertEqual(
            PaintVeil.opacity(atY: 147, geometry: g, reserves: reserves),
            PaintVeil.opacity(atY: 147, geometry: g), "above the rows the veil is the eased one"
        )
        XCTAssertEqual(PaintVeil.opacity(atY: 147, geometry: g), 0.44, accuracy: 0.001)
        XCTAssertEqual(PaintVeil.opacity(atY: 5, geometry: g, reserves: reserves), 0.96)
        XCTAssertEqual(PaintVeil.opacity(atY: 12, geometry: g, reserves: reserves), 0.71, accuracy: 0.001)
        // AA for the secondary ink over the brightest tint of the house
        // palettes under the text veil: Y 0.59 of the rain's light tint.
        let textBackground = 0.59 * (1 - PaintVeil.text)
        XCTAssertGreaterThanOrEqual((0.305 + 0.05) / (textBackground + 0.05), 4.5)
    }

    /// The stops of the gradient keep the hard edges of the strip and the
    /// text as double stops, run from 0 to 1 and never go backwards.
    func testTheVeilStopsKeepTheHardEdges() {
        let g = geometry
        let reserves = PaintReserves(rowsTop: 148, textBottom: 12)
        let stops = PaintVeil.stops(geometry: g, reserves: reserves)
        XCTAssertEqual(stops.first?.location, 0)
        XCTAssertEqual(stops.last?.location, 1)
        for (a, b) in zip(stops, stops.dropFirst()) {
            XCTAssertLessThanOrEqual(a.location, b.location)
        }
        func pair(at y: CGFloat) -> [Double] {
            stops.filter { abs($0.location * g.height - y) < 0.001 }.map(\.opacity)
        }
        XCTAssertEqual(pair(at: g.horizonY - 12).count, 2, "a double stop at the top of the strip")
        XCTAssertEqual(pair(at: g.horizonY - 12).last, 0.80)
        XCTAssertEqual(pair(at: g.horizonY + 12).first, 0.80)
        XCTAssertEqual(pair(at: 148).last, 0.96, "the rows")
        XCTAssertEqual(pair(at: 12).first, 0.96, "the state line")
        XCTAssertEqual(PaintVeil.breaks(geometry: g, reserves: reserves), [12, g.horizonY - 12, g.horizonY + 12, 148])
    }

    // MARK: The pulse

    @MainActor
    func testThePulseFollowsTheHorizonAndHoldsWhenFrozen() {
        let pulse = PaintPulse()
        XCTAssertEqual(pulse.liveOpacity, 0)
        var t: TimeInterval = 1000
        for _ in 0..<80 {
            pulse.tick(rms: 0.2, at: t)
            t += 0.05
        }
        let lit = pulse.liveOpacity
        XCTAssertGreaterThan(lit, 0.5, "four seconds of sound: the live layer is up")
        XCTAssertLessThanOrEqual(lit, PaintBreath.liveMax)

        // Frozen: the ticks come, the layer stays.
        pulse.isLive = false
        for _ in 0..<80 {
            pulse.tick(rms: 0, at: t)
            t += 0.05
        }
        XCTAssertEqual(pulse.liveOpacity, lit)

        // Live again, after a long pause of the timeline: no jump.
        pulse.isLive = true
        pulse.tick(rms: 0, at: t + 60)
        XCTAssertGreaterThan(pulse.liveOpacity, lit - PaintBreath.maxChangePerSecond * PaintPulse.longestStep - 0.3)
        pulse.reset()
        XCTAssertEqual(pulse.liveOpacity, 0)
        XCTAssertEqual(pulse.tideOffset, .zero)

        // Frozen from the start: the layer is drawn still, whole, at the
        // middle of its light, and no reading moves it.
        pulse.isLive = false
        pulse.tick(rms: 0.5, at: 0)
        XCTAssertEqual(pulse.liveOpacity, PaintBreath.stillOpacity)
        pulse.tick(rms: 0, at: 1)
        XCTAssertEqual(pulse.liveOpacity, PaintBreath.stillOpacity)
        XCTAssertEqual(PaintBreath.stillOpacity, 0.65, accuracy: 0.001)
    }

    @MainActor
    func testThePulseSlidesWithTheTideOnlyWhileItGuides() {
        let pulse = PaintPulse()
        pulse.direction = 0
        pulse.tick(rms: 0.1, at: 0)
        XCTAssertEqual(pulse.tideOffset, .zero, "no tide, no slide")
        pulse.tide = { _ in 1 }
        pulse.tick(rms: 0.1, at: 0.05)
        XCTAssertEqual(pulse.tideOffset.width, PaintBreath.tideTravel, accuracy: 0.001)
        XCTAssertEqual(pulse.tideOffset.height, 0, accuracy: 0.001)
        pulse.tide = { _ in 0.5 }
        pulse.tick(rms: 0.1, at: 0.1)
        XCTAssertEqual(pulse.tideOffset.width, 0, accuracy: 0.001, "mid breath is home")
        pulse.tide = nil
        pulse.tick(rms: 0.1, at: 0.15)
        XCTAssertEqual(pulse.tideOffset, .zero)
    }

    // MARK: The rule of Layers

    func testTheRuleIsDryAtZeroAndLiveAtFull() {
        XCTAssertEqual(PaintRule.opacity(level: 0), PaintRule.dryOpacity)
        XCTAssertEqual(PaintRule.opacity(level: 1), 1)
        XCTAssertEqual(PaintRule.opacity(level: 0.5), 0.71, accuracy: 0.001)
        XCTAssertEqual(PaintRule.opacity(level: 2), 1)
        XCTAssertEqual(PaintRule.width, 4)
        XCTAssertLessThan(PaintRule.leading + PaintRule.width, Grid.margin, "inside the margin: the name does not move")
    }

    func testTheDabsOfARuleAreFixedByTheSeedAndGrowWithTheRow() {
        let seed = PaintRule.seed(.rain)
        let dabs = PaintRule.dabs(seed: seed, height: 56)
        XCTAssertEqual(dabs.count, 9)
        XCTAssertEqual(dabs, PaintRule.dabs(seed: seed, height: 56), "the same every draw")
        XCTAssertNotEqual(dabs, PaintRule.dabs(seed: PaintRule.seed(.brown), height: 56))
        for dab in dabs {
            XCTAssertTrue((0..<1).contains(dab.y))
            XCTAssertTrue((2...7).contains(dab.height))
        }
        XCTAssertEqual(PaintRule.dabs(seed: seed, height: 112).count, 18)
        XCTAssertEqual(PaintRule.dabs(seed: seed, height: 10).count, 2)
        XCTAssertNotEqual(PaintRule.seed(.rain), PaintScene.seed(identity: "rain", day: day(12), calendar: calendar))
        let paint = LevelRulePaint(sound: .campfire)
        XCTAssertEqual(paint.motif, .campfire)
        XCTAssertEqual(paint.seed, PaintRule.seed(.campfire))
        XCTAssertTrue(paint.shows)
    }

    // MARK: The conditions a view hands over

    @MainActor
    func testTheConditionsReadTheModelAndTheSwitches() throws {
        let harness = try NightHarness(at: NightHarness.time(12))
        let model = harness.model
        func conditions(
            contrast: ColorSchemeContrast = .standard, reduceMotion: Bool = false, sheet: Bool = false,
            scene: ScenePhase = .active, luminance: Bool = false, transparency: Bool = false
        ) -> PaintConditions {
            PaintConditions(
                model: model, isLuminanceReduced: luminance, contrast: contrast, reduceTransparency: transparency,
                reduceMotion: reduceMotion, sheetPresented: sheet, scenePhase: scene
            )
        }
        let base = conditions()
        XCTAssertEqual(base.now, model.currentDate)
        XCTAssertEqual(base.calendar, model.currentCalendar)
        XCTAssertEqual(base.nightPhase, .day)
        XCTAssertEqual(base.setting, .byDay)
        XCTAssertEqual(PaintPolicy.phase(base), .visible)
        XCTAssertEqual(PaintPolicy.phase(conditions(sheet: true)), .dimmed)
        XCTAssertEqual(PaintPolicy.phase(conditions(scene: .inactive)), .dimmed)
        XCTAssertEqual(PaintPolicy.phase(conditions(scene: .background)), .absent, "no raster behind a dark screen")
        XCTAssertEqual(PaintPolicy.phase(conditions(reduceMotion: true)), .frozen)
        XCTAssertEqual(PaintPolicy.phase(conditions(contrast: .increased)), .absent)
        XCTAssertEqual(PaintPolicy.phase(conditions(luminance: true)), .absent)
        XCTAssertEqual(PaintPolicy.phase(conditions(transparency: true)), .absent)
        // Both switches: the setting goes to never on its own.
        XCTAssertEqual(conditions(contrast: .increased, reduceMotion: true).setting, .never)
        model.setPaintSetting(.never)
        XCTAssertEqual(PaintPolicy.phase(conditions()), .absent)
        model.setPaintSetting(.byDay)

        // The phases of the night, from the model.
        model.beginNightSession()
        XCTAssertEqual(conditions().nightPhase, .nightPage)
        XCTAssertEqual(PaintPolicy.phase(conditions()), .absent)
        model.endNightSession()
        model.enterBedtime()
        XCTAssertEqual(conditions().nightPhase, .night)
        XCTAssertEqual(PaintPolicy.phase(conditions()), .absent)
    }

    /// The window of the page is the model's: the layers that sound, the
    /// six highest, seeded by the house mix or the saved mix or the sounds.
    @MainActor
    func testThePageScenesAreWhatSounds() throws {
        let harness = try NightHarness(at: NightHarness.time(12))
        let model = harness.model
        model.playMix(.house(.brownAndFire))
        let scene = try XCTUnwrap(PagePaint.scene(model: model, hasFullAccess: true, width: 402, isAccessibilitySize: false))
        XCTAssertEqual(Set(scene.layers.map(\.sound)), [.brown, .campfire])
        XCTAssertEqual(scene.geometry.height, PaintWindowGeometry.height)
        XCTAssertEqual(scene.seed, PaintScene.seed(identity: HouseMix.brownAndFire.rawValue, day: model.currentDate, calendar: model.currentCalendar))
        let large = try XCTUnwrap(PagePaint.scene(model: model, hasFullAccess: true, width: 402, isAccessibilitySize: true))
        XCTAssertEqual(large.geometry.height, PaintWindowGeometry.accessibilityHeight)

        // Without access the Pro layer is not painted; nothing left, no scene.
        let trimmed = PagePaint.scene(model: model, hasFullAccess: false, width: 402, isAccessibilitySize: false)
        XCTAssertEqual(trimmed?.layers.map(\.sound), [.brown])

        model.clearMix()
        XCTAssertNil(PagePaint.scene(model: model, hasFullAccess: true, width: 402, isAccessibilitySize: false), "silence paints nothing")

        // A mix of eight: the two that wait are not painted.
        for (sound, level) in [SoundID.white: Float(0.15), .pink: 0.3, .brown: 0.1, .rain: 0.45, .wind: 0.25, .ocean: 0.5, .thunder: 0.2, .campfire: 0.35] {
            model.levels[sound] = level
        }
        let eight = try XCTUnwrap(PagePaint.scene(model: model, hasFullAccess: true, width: 402, isAccessibilitySize: false))
        XCTAssertEqual(eight.layers.count, 6)
        XCTAssertFalse(eight.layers.contains { $0.sound == .white || $0.sound == .brown })
    }

    // MARK: The fade that is final

    func testOnlyTheNightMakesAFadeFinal() {
        var c = PaintConditions(now: day(12))
        c.calendar = calendar
        XCTAssertFalse(PaintPolicy.fadeIsFinal(c))
        func final_(_ change: (inout PaintConditions) -> Void) -> Bool {
            var conditions = c
            change(&conditions)
            return PaintPolicy.fadeIsFinal(conditions)
        }
        XCTAssertTrue(final_ { $0.now = self.day(21, minute: 1) })
        XCTAssertFalse(final_ { $0.now = self.day(20, minute: 59) })
        XCTAssertTrue(final_ { $0.nightPhase = .nightPage })
        XCTAssertTrue(final_ { $0.nightPhase = .night })
        XCTAssertTrue(final_ { $0.nightPhase = .smallHours })
        XCTAssertTrue(final_ { $0.isLuminanceReduced = true })
        XCTAssertFalse(final_ { $0.increaseContrast = true }, "a switch lifts with the switch")
        XCTAssertFalse(final_ { $0.setting = .never })
        XCTAssertFalse(final_ { $0.inBackground = true })
        XCTAssertFalse(final_ { $0.sheetPresented = true })
    }

    func testTheOpacityAndTheDurationsOfTheWindow() {
        XCTAssertEqual(PaintMotion.opacity(phase: .visible, isPlaying: true), 1)
        XCTAssertEqual(PaintMotion.opacity(phase: .frozen, isPlaying: true), 1)
        XCTAssertEqual(PaintMotion.opacity(phase: .visible, isPlaying: false), PaintBreath.driedOpacity, "pause dries")
        XCTAssertEqual(PaintMotion.opacity(phase: .dimmed, isPlaying: true), PaintBreath.dimmedOpacity)
        XCTAssertEqual(PaintMotion.opacity(phase: .dimmed, isPlaying: false), 0.18, accuracy: 0.001)
        XCTAssertEqual(PaintMotion.opacity(phase: .absent, isPlaying: true), 0)
        XCTAssertEqual(PaintMotion.birth(reduceMotion: false), 2)
        XCTAssertEqual(PaintMotion.fade(reduceMotion: false), 2)
        XCTAssertEqual(PaintMotion.fade(reduceMotion: true), 0.25)
        XCTAssertEqual(PaintMotion.duration(from: 0, to: 1, born: true, reduceMotion: false), 2)
        XCTAssertEqual(PaintMotion.duration(from: 1, to: 0.3, born: false, reduceMotion: false), 1.5, "dimmed in 1.5 s")
        XCTAssertEqual(PaintMotion.duration(from: 0.3, to: 1, born: false, reduceMotion: false), 0.8, "back in 0.8 s")
        XCTAssertEqual(PaintMotion.duration(from: 1, to: 0.6, born: false, reduceMotion: true), 0.25)
    }

    // MARK: Settings

    func testTheSettingsRowSaysWhatThePaintGoesByAndWhy() {
        XCTAssertEqual(SettingsText.paintValueKey(stored: .byDay, reduceMotion: false, increaseContrast: false), "ajustes.pintura.dia")
        XCTAssertEqual(SettingsText.paintValueKey(stored: .byDay, reduceMotion: true, increaseContrast: true), "ajustes.pintura.nunca")
        XCTAssertEqual(SettingsText.paintNote(stored: .byDay, reduceMotion: false, increaseContrast: true), SettingsText.paintNoteKey)
        XCTAssertEqual(SettingsText.paintNote(stored: .byDay, reduceMotion: true, increaseContrast: true), SettingsText.paintAutoOffKey)
        XCTAssertEqual(SettingsText.paintNote(stored: .never, reduceMotion: true, increaseContrast: true), SettingsText.paintNoteKey, "never is the choice, not the switches")
        for key in [SettingsText.paintSectionKey, SettingsText.paintNoteKey, SettingsText.paintAutoOffKey] {
            for language in ["en", "es"] {
                let words = ProCatalog.lookup(language)(key)
                XCTAssertNotEqual(words, key, "\(key) in \(language)")
                XCTAssertFalse(words.contains(where: \.isNumber), "\(key): no figure in copy")
            }
        }
        XCTAssertEqual(ProCatalog.lookup("en")(SettingsText.paintSectionKey), "day")
        XCTAssertEqual(ProCatalog.lookup("es")(SettingsText.paintSectionKey), "día")
    }

    // MARK: The staged states

    @MainActor
    func testTheStagedWindowStatesSitOnTheRightSideOfTheRule() {
        XCTAssertFalse(NightWindow.contains(PageStage.clock(for: .windowEvening)))
        XCTAssertTrue(NightWindow.contains(PageStage.clock(for: .windowNight)))
        let painted: [PageDebugState] = [
            .windowPinkRainTide, .windowBrownFire, .windowSeaWind, .windowPaused, .windowEvening,
            .windowContrast, .windowReduceMotion, .windowAX3,
        ]
        for state in painted + [.windowNight] {
            XCTAssertFalse(state.isNight, "\(state)")
            XCTAssertFalse(state.isFreeTier, "\(state): the house mixes with Pro layers play whole")
            XCTAssertNil(state.restoreOutcome)
            XCTAssertFalse(state.opensMixes || state.opensSettings || state.opensTimer || state.opensTide)
        }
        for state in painted {
            XCTAssertFalse(NightWindow.contains(PageStage.clock(for: state)), "\(state)")
        }
    }
}
