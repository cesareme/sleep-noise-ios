import SwiftUI
import UIKit
import XCTest
@testable import SleepNoise

/// The logic behind the Grafito components: the mapping from RMS to the
/// Horizon, the single accent, level arithmetic and what VoiceOver says.
final class DesignSystemTests: XCTestCase {
    // MARK: Horizon

    func testRMSMapsToThicknessBetweenOneAndAHalfAndThreePoints() {
        // Silence: no level, no presence, and the thinnest sounding line is
        // still 1.5 pt, the least the accent may be.
        XCTAssertEqual(SoundLevelScale.level(rms: 0), 0)
        XCTAssertEqual(SoundLevelScale.presence(rms: 0), 0)
        XCTAssertEqual(SoundLevelScale.thickness(level: 0), 1.5)
        XCTAssertEqual(SoundLevelScale.thickness(level: 1), 3)
        XCTAssertEqual(SoundLevelScale.opacity(level: 0), 0.6)
        XCTAssertEqual(SoundLevelScale.opacity(level: 1), 1)
        XCTAssertEqual(SoundLevelScale.thickness(level: 0.5), 2.25)
        XCTAssertEqual(SoundLevelScale.thickness(level: 7), 3)
        XCTAssertEqual(SoundLevelScale.thickness(level: -1), 1.5)

        // The anchors, in dBFS.
        func rms(_ decibels: Float) -> Float { powf(10, decibels / 20) }
        XCTAssertEqual(SoundLevelScale.level(rms: rms(-48)), 0, accuracy: 0.001)
        XCTAssertEqual(SoundLevelScale.level(rms: rms(-9)), 1, accuracy: 0.001)
        XCTAssertEqual(SoundLevelScale.level(rms: rms(-28.5)), 0.5, accuracy: 0.001)
        XCTAssertEqual(SoundLevelScale.level(rms: 1), 1)
        XCTAssertEqual(SoundLevelScale.presence(rms: rms(-72)), 0, accuracy: 0.001)
        XCTAssertEqual(SoundLevelScale.presence(rms: rms(-66)), 1, accuracy: 0.001)
        XCTAssertEqual(SoundLevelScale.presence(rms: rms(-69)), 0.5, accuracy: 0.001)

        // Louder is never thinner.
        var previous = SoundLevelScale.thickness(level: SoundLevelScale.level(rms: 0))
        for step in 1...200 {
            let thickness = SoundLevelScale.thickness(level: SoundLevelScale.level(rms: Float(step) / 200))
            XCTAssertGreaterThanOrEqual(thickness, previous)
            previous = thickness
        }
        // Bad input is silence.
        XCTAssertEqual(SoundLevelScale.level(rms: .nan), 0)
        XCTAssertEqual(SoundLevelScale.presence(rms: -1), 0)
    }

    func testTheScaleFitsWhatTheEngineProduces() {
        // What a real mix measures (see OutputLevelTests) lands inside the
        // scale: the default mix reads thick, one layer at one percent still
        // shows as sounding.
        func settledRMS(_ gains: SoundGains) -> Float {
            var state = RenderState(sampleRate: 48_000)
            let command = EngineCommand(
                gains: gains, envelopeTarget: 1, rampSamples: 1, generation: 1, envelopeGeneration: 1
            )
            for _ in 0..<96_000 { _ = state.processStereo(command) }
            return state.outputMeter.rms
        }
        var defaultMix = SoundGains.zero
        defaultMix.pink = 0.65

        let loud = SoundLevelScale.level(rms: settledRMS(defaultMix))
        XCTAssertGreaterThan(loud, 0.5)
        XCTAssertLessThan(loud, 1)
        XCTAssertEqual(SoundLevelScale.level(rms: settledRMS(.uniform(1))), 1)
        XCTAssertEqual(SoundLevelScale.presence(rms: settledRMS(.zero)), 0)

        // The quietest thing a person can play, one free layer at one
        // percent, is drawn whole: the 0.6 floor of the opacity holds for
        // any steady mix, and VoiceOver never calls it silence.
        for sound in [SoundID.white, .pink, .brown, .rain, .wind] {
            var whisper = SoundGains.zero
            whisper.set(sound, 0.01)
            let rms = settledRMS(whisper)
            XCTAssertEqual(SoundLevelScale.presence(rms: rms), 1, "\(sound)")
            XCTAssertEqual(SoundLevelScale.spoken(rms: rms), .low, "\(sound)")
            XCTAssertEqual(
                SoundLevelScale.opacity(level: SoundLevelScale.level(rms: rms))
                    * Double(SoundLevelScale.presence(rms: rms)),
                SoundLevelScale.minOpacity,
                "\(sound)"
            )
        }
    }

    func testSpokenLevelSaysItInWords() {
        func rms(_ decibels: Float) -> Float { powf(10, decibels / 20) }
        XCTAssertEqual(SoundLevelScale.spoken(rms: 0), .silent)
        XCTAssertEqual(SoundLevelScale.spoken(rms: rms(-75)), .silent)
        XCTAssertEqual(SoundLevelScale.spoken(rms: rms(-40)), .low)
        XCTAssertEqual(SoundLevelScale.spoken(rms: rms(-28)), .medium)
        XCTAssertEqual(SoundLevelScale.spoken(rms: rms(-15)), .high)

        let keys: [SoundLevelScale.Spoken] = [.silent, .low, .medium, .high]
        XCTAssertEqual(
            keys.map { localized($0.key, "en") },
            ["Silent", "Playing, low level", "Playing, medium level", "Playing, high level"]
        )
        XCTAssertEqual(
            keys.map { localized($0.key, "es") },
            ["En silencio", "Sonando, nivel bajo", "Sonando, nivel medio", "Sonando, nivel alto"]
        )
    }

    func testSpokenLevelDoesNotChatter() {
        var gate = SpokenLevelGate()
        XCTAssertEqual(gate.spoken, .silent)
        XCTAssertEqual(gate.update(.medium, at: 10), .medium)
        // Inside three seconds the spoken value holds, whatever the sound does.
        XCTAssertEqual(gate.update(.high, at: 11), .medium)
        XCTAssertEqual(gate.update(.low, at: 12.9), .medium)
        XCTAssertEqual(gate.update(.high, at: 13), .high)
        XCTAssertEqual(gate.update(.high, at: 20), .high)
        XCTAssertEqual(gate.update(.silent, at: 21), .silent)
    }

    func testSilenceIsNeverHeldBack() {
        // Pause one second after the level changed: the hold must not keep
        // "playing" on show, because the line stops ticking right there.
        var gate = SpokenLevelGate()
        XCTAssertEqual(gate.update(.medium, at: 10), .medium)
        XCTAssertEqual(gate.update(.silent, at: 11), .silent)
        XCTAssertEqual(gate.spoken, .silent)

        // The fall of a pause from "high": medium is taken, low is held
        // back, silence is not.
        var falling = SpokenLevelGate()
        XCTAssertEqual(falling.update(.high, at: 0), .high)
        XCTAssertEqual(falling.update(.medium, at: 5.2), .medium)
        XCTAssertEqual(falling.update(.low, at: 5.6), .medium)
        XCTAssertEqual(falling.update(.silent, at: 6), .silent)
        // Coming back within the hold is held, as any other change.
        XCTAssertEqual(falling.update(.high, at: 7), .silent)
        XCTAssertEqual(falling.update(.high, at: 9), .high)
    }

    func testTheAccentIsGoneWithinTheStopTimeOnceTheEngineStops() {
        // Colour means sound (03 §3.7): 1.5 s after the engine stops there
        // is no line and no accent, from any level, at either refresh rate
        // and whatever time constant the line was following with.
        func rms(_ decibels: Float) -> Float { powf(10, decibels / 20) }
        for reduceMotion in [false, true] {
            let interval = Motion.horizonInterval(reduceMotion: reduceMotion)
            let requested = Motion.horizonTau(reduceMotion: reduceMotion)
            let tau = OutputLevelFollower.tau(requested: requested, isRendering: false)
            // Full scale, the top of the scale, the default mix.
            for start in [Float(1), rms(-9), rms(-18)] {
                // The engine may stop at any moment between two reads.
                for phase in [0.001, interval / 2, interval] {
                    var follower = OutputLevelFollower()
                    _ = follower.follow(start, at: 0, tau: requested)
                    var time = phase
                    var value = follower.follow(0, at: time, tau: tau)
                    var gone: TimeInterval?
                    while time <= Motion.longest, gone == nil {
                        if SoundLevelScale.presence(rms: value) == 0 {
                            gone = time
                        } else {
                            time += interval
                            value = follower.follow(0, at: time, tau: tau)
                        }
                    }
                    let label = "reduce \(reduceMotion) start \(start) phase \(phase)"
                    XCTAssertNotNil(gone, label)
                    XCTAssertLessThanOrEqual(gone ?? .infinity, Motion.stop, label)
                }
            }
            // The default mix is a hairline again in under a second.
            var follower = OutputLevelFollower()
            _ = follower.follow(rms(-18), at: 0, tau: requested)
            XCTAssertEqual(SoundLevelScale.presence(rms: follower.follow(0, at: 1, tau: tau)), 0)
        }
    }

    // MARK: One accent per screen

    func testOnlyOneOwnerHoldsTheAccent() {
        let arbiter = IndexArbiter()
        XCTAssertNil(arbiter.owner)
        XCTAssertFalse(arbiter.fingerIsDown)

        arbiter.claim(.horizon)
        XCTAssertTrue(arbiter.owns(.horizon))

        // A finger outranks the Horizon, which steps back to plain ink.
        arbiter.claim(.finger("rain"))
        XCTAssertTrue(arbiter.owns(.finger("rain")))
        XCTAssertFalse(arbiter.owns(.horizon))
        XCTAssertTrue(arbiter.fingerIsDown)

        // A second finger takes nothing while the first one holds.
        arbiter.claim(.finger("pink"))
        XCTAssertTrue(arbiter.owns(.finger("rain")))
        XCTAssertFalse(arbiter.owns(.finger("pink")))

        arbiter.release(.finger("rain"))
        XCTAssertTrue(arbiter.owns(.finger("pink")))
        arbiter.release(.finger("pink"))
        XCTAssertTrue(arbiter.owns(.horizon))

        // The tide sits between the two.
        arbiter.claim(.tide)
        XCTAssertTrue(arbiter.owns(.tide))
        arbiter.release(.tide)
        arbiter.release(.horizon)
        XCTAssertNil(arbiter.owner)
    }

    // MARK: Level row

    func testLevelIsKeptAsAWholePercent() {
        XCTAssertEqual(LevelMath.percent(0), 0)
        XCTAssertEqual(LevelMath.percent(1), 100)
        XCTAssertEqual(LevelMath.percent(0.654), 65)
        XCTAssertEqual(LevelMath.percent(0.655_1), 66)
        XCTAssertEqual(LevelMath.percent(1.7), 100)
        XCTAssertEqual(LevelMath.percent(-0.2), 0)
        XCTAssertEqual(LevelMath.percent(.nan), 0)
        XCTAssertEqual(LevelMath.quantized(0.3349), 0.33, accuracy: 0.0001)
        XCTAssertEqual(LevelMath.quantized(0.004), 0)
        XCTAssertEqual(LevelMath.quantized(0.996), 1)
        for percent in 0...100 {
            let level = Float(percent) / 100
            XCTAssertEqual(LevelMath.percent(LevelMath.quantized(level)), percent)
        }
    }

    func testAccessibilityStepsAreFivePercent() {
        XCTAssertEqual(LevelMath.percent(LevelMath.stepped(0.30, up: true)), 35)
        XCTAssertEqual(LevelMath.percent(LevelMath.stepped(0.30, up: false)), 25)
        XCTAssertEqual(LevelMath.percent(LevelMath.stepped(0.98, up: true)), 100)
        XCTAssertEqual(LevelMath.percent(LevelMath.stepped(0.03, up: false)), 0)
        // Twenty steps cover the whole range, both ways.
        var level: Float = 0
        for _ in 0..<20 { level = LevelMath.stepped(level, up: true) }
        XCTAssertEqual(level, 1)
        for _ in 0..<20 { level = LevelMath.stepped(level, up: false) }
        XCTAssertEqual(level, 0)
    }

    func testDragAxisIsDecidedByAThirtyDegreeCone() {
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 10, height: 0)), .level)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: -10, height: 5)), .level)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 10, height: -5.7)), .level)
        // Past 30°, and at exactly 30°, the scroll wins.
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 10, height: 5.8)), .scroll)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 10, height: 10 * LevelDrag.coneTangent)), .scroll)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 0, height: 12)), .scroll)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 3, height: -40)), .scroll)
        XCTAssertEqual(LevelDrag.axis(for: .zero), .scroll)
    }

    func testNightPageNarrowsTheConeToTwentyDegrees() {
        XCTAssertEqual(LevelDrag.coneTangent(night: false), LevelDrag.coneTangent)
        XCTAssertEqual(LevelDrag.coneTangent(night: true), LevelDrag.nightConeTangent)
        XCTAssertEqual(LevelDrag.nightConeTangent, CGFloat(tan(20.0 * Double.pi / 180)), accuracy: 0.0001)
        XCTAssertEqual(LevelDrag.coneTangent, CGFloat(tan(30.0 * Double.pi / 180)), accuracy: 0.0001)

        let night = LevelDrag.nightConeTangent
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 10, height: 0), coneTangent: night), .level)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: -10, height: 3.6), coneTangent: night), .level)
        // Between 20° and 30°: the level by day, the scroll at night.
        let slanted = CGSize(width: 10, height: 4.5)
        XCTAssertEqual(LevelDrag.axis(for: slanted), .level)
        XCTAssertEqual(LevelDrag.axis(for: slanted, coneTangent: night), .scroll)
        XCTAssertEqual(LevelDrag.axis(for: CGSize(width: 10, height: 10 * night), coneTangent: night), .scroll)
    }

    @MainActor
    func testLevelRowKeepsItsHeightWhateverTheLevelOrTheGesture() {
        // Nothing may move under a finger: the row measures the same at 0,
        // above 0, while dragged and with the slider out, at every width a
        // phone has and at every text size. The Spanish free layer whose
        // label used to reflow when its value appeared is the sample.
        func height(_ level: Float, _ mode: LevelRuleFace.Mode, _ size: DynamicTypeSize, _ width: CGFloat) -> CGFloat {
            let face = LevelRuleFace(
                name: "Lluvia", subtitle: "Gotas sobre un fondo constante", level: level, mode: mode
            )
            .dynamicTypeSize(size)
            let host = UIHostingController(rootView: face)
            return host.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude)).height
        }
        let sizes: [DynamicTypeSize] = [.large, .xLarge, .xxxLarge, .accessibility1, .accessibility3]
        for size in sizes {
            for width in stride(from: CGFloat(320), through: 440, by: 4) {
                let rest = height(0, .rest, size, width)
                XCTAssertGreaterThanOrEqual(rest, Grid.layerTouch)
                let others: [(Float, LevelRuleFace.Mode)] = [
                    (0.65, .rest), (1, .rest), (0, .underFinger(accent: true)),
                    (1, .underFinger(accent: true)), (0, .fineSlider), (0.65, .fineSlider),
                ]
                for (level, mode) in others {
                    XCTAssertEqual(
                        height(level, mode, size, width), rest, accuracy: 0.01,
                        "\(size) width \(width) level \(level) \(mode)"
                    )
                }
            }
        }
        // At Large the pair fits on one line on a 393 pt screen: 56 pt.
        XCTAssertEqual(height(0.3, .rest, .large, 393), Grid.layerTouch, accuracy: 0.01)
    }

    func testDragIsRelativeAndBanksNothingPastTheEnds() {
        let travel = LevelMath.travel(columnWidth: 353)
        XCTAssertEqual(travel, 333)
        XCTAssertEqual(LevelMath.travel(columnWidth: 335), 315)
        XCTAssertEqual(LevelMath.travel(columnWidth: 4), 1)

        // Relative: a third of the travel is a third of the range, from
        // wherever the level was.
        var drag = LevelDrag()
        var level: Float = 0.30
        level = drag.update(translationX: 111, level: level, travel: travel)
        XCTAssertEqual(level, 0.30 + 111.0 / 333, accuracy: 0.0005)

        // Far past the end: full, and no more.
        level = drag.update(translationX: 900, level: level, travel: travel)
        XCTAssertEqual(level, 1)
        // Coming back, the level moves from the first point.
        level = drag.update(translationX: 890, level: level, travel: travel)
        XCTAssertEqual(level, 1 - 10.0 / 333, accuracy: 0.0005)

        // The same at the bottom.
        var down = LevelDrag()
        var low: Float = 0.10
        low = down.update(translationX: -400, level: low, travel: travel)
        XCTAssertEqual(low, 0)
        low = down.update(translationX: -390, level: low, travel: travel)
        XCTAssertEqual(low, 10.0 / 333, accuracy: 0.0005)
    }

    // MARK: What VoiceOver says

    private func bundle(_ language: String) -> Bundle {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            XCTFail("missing \(language).lproj")
            return .main
        }
        return bundle
    }

    private func localized(_ key: String, _ language: String) -> String {
        Localized.string(key, bundle: bundle(language))
    }

    func testLevelRowSpeechInEnglishAndSpanish() {
        let english = LevelRuleSpeech(
            name: "Rain", subtitle: "drops on a steady bed", level: 0.65, bundle: bundle("en")
        )
        XCTAssertEqual(english.label, "Rain, drops on a steady bed")
        XCTAssertEqual(english.value, "65 percent")

        let spanish = LevelRuleSpeech(
            name: "Lluvia", subtitle: "gotas sobre un fondo constante", level: 0.654, bundle: bundle("es")
        )
        XCTAssertEqual(spanish.label, "Lluvia, gotas sobre un fondo constante")
        XCTAssertEqual(spanish.value, "65 por ciento")

        var silent = spanish
        silent.level = 0
        XCTAssertEqual(silent.value, "0 por ciento")
    }

    func testLockedRowSpeechKeepsTheSavedLevel() {
        var english = LevelRuleSpeech(
            name: "Ocean", subtitle: "swells that come and go", level: 0.3, isLocked: true, bundle: bundle("en")
        )
        XCTAssertEqual(english.label, "Ocean, swells that come and go, requires Pro")
        XCTAssertEqual(english.value, "silent, saved level 30")
        XCTAssertEqual(english.lockedWord, "pro · 30")
        english.level = 0
        XCTAssertEqual(english.value, "Silent")
        XCTAssertEqual(english.lockedWord, "pro")

        var spanish = LevelRuleSpeech(
            name: "Océano", subtitle: "oleaje que va y viene", level: 0.3, isLocked: true, bundle: bundle("es")
        )
        XCTAssertEqual(spanish.label, "Océano, oleaje que va y viene, requiere Pro")
        XCTAssertEqual(spanish.value, "en silencio, nivel guardado 30")
        XCTAssertEqual(spanish.lockedWord, "pro · 30")
        spanish.level = 0
        XCTAssertEqual(spanish.value, "En silencio")
    }

    func testEveryComponentStringExistsInBothLanguages() {
        let keys = [
            "ax.horizonte", "pagina.estado.silencio", "ax.horizonte.valor.bajo", "ax.horizonte.valor.medio",
            "ax.horizonte.valor.alto", "control.play", "ax.accion.pausar", "ax.capa", "ax.capa.pista",
            "ax.capa.pro", "ax.capa.pro.valor", "ax.capa.pro.pista", "ax.accion.silenciar", "ax.accion.maximo",
            "ax.accion.subir", "ax.accion.bajar", "ax.accion.deslizador", "ax.accion.ver_pro",
            "capas.deslizador", "comun.pro", "comun.pro.nivel", "a11y.percentFormat",
        ]
        for language in ["en", "es"] {
            for key in keys {
                let value = localized(key, language)
                XCTAssertNotEqual(value, key, "\(key) is missing in \(language)")
                XCTAssertFalse(value.isEmpty)
            }
        }
        XCTAssertEqual(localized("control.play", "es"), "Reproducir")
        XCTAssertEqual(localized("ax.accion.pausar", "es"), "Pausar")
        XCTAssertEqual(Localized.format("capas.deslizador", bundle: bundle("es"), "Lluvia"), "Nivel de Lluvia")
        XCTAssertEqual(Localized.format("capas.deslizador", bundle: bundle("en"), "Rain"), "Rain level")
    }
}
