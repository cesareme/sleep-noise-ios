import XCTest
@testable import SleepNoise

final class BreathCurveTests: XCTestCase {
    func testShape() {
        let inhale: Float = 0.4
        let exhale: Float = 0.45
        XCTAssertEqual(BreathCurve.value(phase: 0, inhale: inhale, exhale: exhale), 0, accuracy: 0.000_1)
        XCTAssertEqual(BreathCurve.value(phase: inhale, inhale: inhale, exhale: exhale), 1, accuracy: 0.000_1)
        XCTAssertEqual(BreathCurve.value(phase: inhale + exhale, inhale: inhale, exhale: exhale), 0, accuracy: 0.000_1)
        XCTAssertEqual(BreathCurve.value(phase: 0.95, inhale: inhale, exhale: exhale), 0, accuracy: 0.000_1)
        XCTAssertEqual(BreathCurve.value(phase: 1.2, inhale: inhale, exhale: exhale),
                       BreathCurve.value(phase: 0.2, inhale: inhale, exhale: exhale), accuracy: 0.000_1)

        var previous: Float = 0
        var phase: Float = 0
        while phase < inhale {
            let value = BreathCurve.value(phase: phase, inhale: inhale, exhale: exhale)
            XCTAssertGreaterThanOrEqual(value, previous - 0.000_01)
            previous = value
            phase += 0.005
        }
        previous = 1
        while phase < inhale + exhale {
            let value = BreathCurve.value(phase: phase, inhale: inhale, exhale: exhale)
            XCTAssertLessThanOrEqual(value, previous + 0.000_01)
            previous = value
            phase += 0.005
        }
    }

    func testWallClockValueMatchesPhase() {
        let parameters = BreathParameters.guided(breathsPerMinute: 6)
        XCTAssertEqual(parameters.rate, 0.1, accuracy: 0.000_01)
        XCTAssertEqual(BreathCurve.value(secondsSinceStart: 4, parameters: parameters), 1, accuracy: 0.000_1)
        XCTAssertEqual(BreathCurve.value(secondsSinceStart: 10, parameters: parameters), 0, accuracy: 0.000_1)
        XCTAssertEqual(BreathCurve.value(secondsSinceStart: 5, parameters: .off), 0)
    }
}

final class BreathingRenderTests: XCTestCase {
    private let rate: Float = 48_000

    private func guided(weight: Float = 1, epoch: UInt32 = 1) -> BreathParameters {
        BreathParameters.guided(breathsPerMinute: 6, weight: weight, epoch: epoch)
    }

    private func command(_ gains: SoundGains, breath: BreathParameters) -> EngineCommand {
        EngineCommand(gains: gains, envelopeTarget: 1, rampSamples: 1, generation: 1, envelopeGeneration: 1, breath: breath)
    }

    /// Window RMS of the left channel; one value per `window` seconds.
    private func envelope(_ state: inout RenderState, command: EngineCommand, seconds: Int, window: Float = 0.5) -> [Float] {
        let windowSamples = Int(rate * window)
        var result: [Float] = []
        for _ in 0..<Int(Float(seconds) / window) {
            var sum: Float = 0
            for _ in 0..<windowSamples {
                let frame = state.processStereo(command)
                sum += frame.left * frame.left
            }
            result.append((sum / Float(windowSamples)).squareRoot())
        }
        return result
    }

    func testOceanFollowsTheBreath() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.ocean = 1
        let command = command(gains, breath: guided())
        _ = envelope(&state, command: command, seconds: 10)
        let env = envelope(&state, command: command, seconds: 30)

        // Top of the inhale is 4 s into each 10 s cycle; the rest is 9–10 s.
        var peaks: [Float] = []
        var troughs: [Float] = []
        for cycle in 0..<3 {
            let base = cycle * 20
            peaks.append(env[base + 8])
            troughs.append(env[base + 19])
        }
        let ratio = peaks.reduce(0, +) / troughs.reduce(0, +)
        XCTAssertGreaterThan(ratio, 1.8, "ocean should breathe: peak/trough \(ratio)")
        XCTAssertLessThan(ratio, 6, "the rest between breaths must not be a hole: \(ratio)")
    }

    func testPeaksStayOnTheWallClock() {
        // Ten minutes at 6 breaths/min: every top of the inhale must land at
        // 4 s + k·10 s, which is what the on-screen disc assumes.
        var state = RenderState(sampleRate: rate)
        let command = command(.zero, breath: guided())
        let samples = Int(rate) * 600
        var maxDrift: Float = 0
        var lastValue: Float = 0
        var rising = true
        for index in 0..<samples {
            _ = state.processStereo(command)
            let value = state.breathValue
            if rising, value < lastValue {
                let seconds = Float(index) / rate
                let cycle = (seconds / 10).rounded(.down)
                maxDrift = max(maxDrift, abs(seconds - (cycle * 10 + 4)))
                rising = false
            } else if !rising, value > lastValue {
                rising = true
            }
            lastValue = value
        }
        XCTAssertLessThan(maxDrift, 0.02, "breath peaks drifted \(maxDrift) s from the wall clock")
    }

    func testBedsBreatheGentlyWithoutOcean() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.pink = 0.7
        gains.rain = 0.5
        let command = command(gains, breath: guided())
        _ = envelope(&state, command: command, seconds: 10)
        let env = envelope(&state, command: command, seconds: 20)
        let peak = (env[8] + env[28]) / 2
        let trough = (env[19] + env[39]) / 2
        let decibels = 20 * log10(peak / trough)
        XCTAssertGreaterThan(decibels, 2.5, "beds should swell a little: \(decibels) dB")
        XCTAssertLessThan(decibels, 7, "beds must not pump: \(decibels) dB")
    }

    func testSubtleDepthIsHalfTheSwell() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.pink = 0.7
        var breath = guided()
        breath.bedDepth = 0.2
        let command = command(gains, breath: breath)
        _ = envelope(&state, command: command, seconds: 10)
        let env = envelope(&state, command: command, seconds: 20)
        let decibels = 20 * log10(((env[8] + env[28]) / 2) / ((env[19] + env[39]) / 2))
        XCTAssertGreaterThan(decibels, 1.0)
        XCTAssertLessThan(decibels, 3.0)
    }

    func testNoBreathLeavesTheStateUntouched() {
        var plain = RenderState(sampleRate: rate)
        var withField = RenderState(sampleRate: rate)
        let gains = SoundGains(white: 0.3, pink: 0.4, brown: 0.2, rain: 0.5, fan: 0.4, ocean: 0.6)
        let reference = EngineCommand(gains: gains, envelopeTarget: 1, rampSamples: 1, generation: 1, envelopeGeneration: 1)
        var explicit = reference
        explicit.breath = .off
        for _ in 0..<24_000 {
            let a = plain.processStereo(reference)
            let b = withField.processStereo(explicit)
            XCTAssertEqual(a.left, b.left)
            XCTAssertEqual(a.right, b.right)
        }
        XCTAssertEqual(plain.breathSample, 0)
        XCTAssertEqual(plain.breathWeight, 0)
        XCTAssertEqual(plain.breathValueSmoothed, 0)
    }

    func testSwitchingOffHoldsTheValueAndSmoothsTheWeight() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.ocean = 1
        let running = command(gains, breath: guided())
        for _ in 0..<Int(rate * 12) { _ = state.processStereo(running) }
        XCTAssertGreaterThan(state.breathWeight, 0.99)
        let held = state.breathValue

        var off = running
        off.breath = .off
        off.breath.epoch = 1
        for _ in 0..<Int(rate * 1) { _ = state.processStereo(off) }
        XCTAssertEqual(state.breathValue, held, "the breath value is held while the weight carries the beds back")
        XCTAssertLessThan(state.breathWeight, 0.6)
        for _ in 0..<Int(rate * 9) { _ = state.processStereo(off) }
        XCTAssertLessThan(state.breathWeight, 0.01)
        XCTAssertEqual(state.breathPeriod, 0)
    }

    func testSwitchingOffNeverSteps() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.ocean = 1
        gains.pink = 0.6
        let running = command(gains, breath: guided())
        // Reach the middle of an inhale (2 s into the cycle) with full weight.
        for _ in 0..<Int(rate * 12) { _ = state.processStereo(running) }
        var naturalMax: Float = 0
        var previous = state.processStereo(running).left
        for _ in 0..<Int(rate * 1) {
            let sample = state.processStereo(running).left
            naturalMax = max(naturalMax, abs(sample - previous))
            previous = sample
        }
        var off = running
        off.breath = .off
        off.breath.epoch = 1
        var afterMax: Float = 0
        for _ in 0..<Int(rate * 0.05) {
            let sample = state.processStereo(off).left
            afterMax = max(afterMax, abs(sample - previous))
            previous = sample
        }
        XCTAssertLessThan(afterMax, naturalMax * 1.5, "switching the tide off produced a step: \(afterMax) vs natural \(naturalMax)")
    }

    func testDissolveRampsOnTheAudioClock() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.ocean = 1
        let running = command(gains, breath: guided())
        for _ in 0..<Int(rate * 10) { _ = state.processStereo(running) }
        XCTAssertGreaterThan(state.breathWeight, 0.99)

        var dissolving = running
        dissolving.breath.weight = 0
        dissolving.breath.dissolveSeconds = 10
        for _ in 0..<Int(rate * 5) { _ = state.processStereo(dissolving) }
        XCTAssertEqual(state.breathWeightTarget, 0.5, accuracy: 0.01)
        // The applied weight trails the linear target by its 1.5 s smoothing.
        XCTAssertGreaterThan(state.breathWeight, 0.5)
        XCTAssertLessThan(state.breathWeight, 0.72)
        for _ in 0..<Int(rate * 12) { _ = state.processStereo(dissolving) }
        XCTAssertLessThan(state.breathWeight, 0.01)
        for _ in 0..<Int(rate * 12) { _ = state.processStereo(dissolving) }
        XCTAssertEqual(state.breathWeight, 0, "the weight snaps to exactly zero once it is inaudible")
        // The phase keeps running while the rate is set, so a later restart is cheap.
        XCTAssertGreaterThan(state.breathPeriod, 0)
    }

    func testNewEpochRestartsAtTheTopOfAnInhale() {
        var state = RenderState(sampleRate: rate)
        let first = command(.zero, breath: guided(epoch: 1))
        for _ in 0..<Int(rate * 7) { _ = state.processStereo(first) }
        XCTAssertGreaterThan(state.breathSample, 1_000)

        let second = command(.zero, breath: guided(epoch: 2))
        _ = state.processStereo(second)
        XCTAssertEqual(state.breathSample, 1)
        for _ in 0..<Int(rate * 4) { _ = state.processStereo(second) }
        XCTAssertGreaterThan(state.breathValue, 0.99)
    }

    func testEpochBeforeAudibleSeedsTheWeight() {
        // Fresh Play: envelope still at zero, so the weight is seeded at once
        // and the sea rises with the first inhale instead of dipping.
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.ocean = 1
        var breath = guided()
        let fadeIn = EngineCommand(gains: gains, envelopeTarget: 1, rampSamples: Int32(rate * 1.5), generation: 1, envelopeGeneration: 1, breath: breath)
        _ = state.processStereo(fadeIn)
        XCTAssertEqual(state.breathWeight, 1)

        // Toggled on mid-session: smoothed in instead.
        var late = RenderState(sampleRate: rate)
        late.envelope = 1
        breath.epoch = 5
        let toggled = EngineCommand(gains: gains, envelopeTarget: 1, rampSamples: -1, generation: 2, envelopeGeneration: 1, breath: breath)
        _ = late.processStereo(toggled)
        XCTAssertLessThan(late.breathWeight, 0.01)
        for _ in 0..<Int(rate * 8) { _ = late.processStereo(toggled) }
        XCTAssertGreaterThan(late.breathWeight, 0.99)
    }

    func testSampleRateChangeKeepsTheCycleFraction() {
        var state = RenderState(sampleRate: rate)
        let six = command(.zero, breath: guided())
        for _ in 0..<Int(rate * 5) { _ = state.processStereo(six) }
        let fractionBefore = Float(state.breathSample) / Float(state.breathPeriod)
        state.prepare(sampleRate: 44_100)
        _ = state.processStereo(six)
        XCTAssertEqual(state.breathPeriod, 441_000)
        let fractionAfter = Float(state.breathSample) / Float(state.breathPeriod)
        XCTAssertEqual(fractionAfter, fractionBefore, accuracy: 0.001)
    }

    func testDepthChangeIsSmoothed() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.pink = 0.7
        let full = command(gains, breath: guided())
        for _ in 0..<Int(rate * 6) { _ = state.processStereo(full) }
        XCTAssertEqual(state.breathDepth, 0.4, accuracy: 0.001)
        var subtle = full
        subtle.breath.bedDepth = 0.2
        _ = state.processStereo(subtle)
        XCTAssertEqual(state.breathDepth, 0.4, accuracy: 0.001, "one sample later the depth has barely moved")
        for _ in 0..<Int(rate * 8) { _ = state.processStereo(subtle) }
        XCTAssertEqual(state.breathDepth, 0.2, accuracy: 0.002)
    }

    func testFreshStartResetClearsEnvelopeAndBreath() {
        var state = RenderState(sampleRate: rate)
        var gains = SoundGains.zero
        gains.ocean = 1
        let running = command(gains, breath: guided())
        for _ in 0..<Int(rate * 6) { _ = state.processStereo(running) }
        XCTAssertEqual(state.envelope, 1)
        XCTAssertGreaterThan(state.breathWeight, 0.9)
        state.resetForFreshStart()
        XCTAssertEqual(state.envelope, 0)
        XCTAssertEqual(state.breathWeight, 0)
        // The next fade-in really starts from silence and seeds the breath.
        var next = running
        next.rampSamples = Int32(rate * 1.5)
        next.envelopeGeneration = 2
        next.breath.epoch = 2
        _ = state.processStereo(next)
        XCTAssertLessThan(state.envelope, 0.001)
        XCTAssertEqual(state.breathWeight, 1)
    }

    func testRateChangeKeepsTheCycleFraction() {
        var state = RenderState(sampleRate: rate)
        let six = command(.zero, breath: guided())
        for _ in 0..<Int(rate * 5) { _ = state.processStereo(six) }
        let fractionBefore = Float(state.breathSample) / Float(state.breathPeriod)
        var faster = six
        faster.breath.rate = 8.0 / 60
        _ = state.processStereo(faster)
        let fractionAfter = Float(state.breathSample) / Float(state.breathPeriod)
        XCTAssertEqual(fractionAfter, fractionBefore, accuracy: 0.001)
        XCTAssertEqual(state.breathPeriod, UInt32(rate * 60 / 8))
    }
}

final class EngineCommandEnvelopeTests: XCTestCase {
    func testLaterPublishDoesNotCancelAPendingFade() {
        // What SleepAudioEngine does: start() publishes a fade-in, then the
        // breathing guide publishes right after, before the render thread ran.
        var state = RenderState(sampleRate: 48_000)
        var gains = SoundGains.zero
        gains.white = 1
        let overwritten = EngineCommand(gains: gains, envelopeTarget: 1, rampSamples: 1_000, generation: 2, envelopeGeneration: 1, breath: .guided(breathsPerMinute: 6, epoch: 1))
        for _ in 0..<1_002 { _ = state.process(overwritten) }
        XCTAssertEqual(state.envelope, 1, accuracy: 0.000_1)

        // A gain change carrying the same envelope generation leaves the fade alone.
        var midFade = RenderState(sampleRate: 48_000)
        let fadeOut = EngineCommand(gains: gains, envelopeTarget: 0, rampSamples: 2_000, generation: 3, envelopeGeneration: 2)
        midFade.envelope = 1
        for _ in 0..<500 { _ = midFade.process(fadeOut) }
        let partway = midFade.envelope
        var gainsChange = fadeOut
        gainsChange.gains.pink = 0.5
        gainsChange.generation = 4
        _ = midFade.process(gainsChange)
        XCTAssertLessThan(midFade.envelope, partway)
        // The same fade, one sample further: it was not started again.
        XCTAssertEqual(midFade.envelopeRamp.total, 2_000)
        XCTAssertEqual(midFade.envelopeRamp.done, 501)
    }
}

@MainActor
final class BreathingGuideControllerTests: XCTestCase {
    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    func testBeginPublishesAFreshEpochAndEndStops() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        guide.settings.guideMinutes = 15
        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        guide.begin(now: start)

        XCTAssertEqual(guide.phase, .guiding)
        XCTAssertEqual(guide.anchor, start)
        let first = try XCTUnwrap(published.last)
        XCTAssertEqual(first.weight, 1)
        XCTAssertEqual(first.dissolveSeconds, 0)
        XCTAssertEqual(first.bedDepth, 0.4)
        XCTAssertEqual(first.rate, 0.1, accuracy: 0.000_01)
        XCTAssertEqual(first.epoch, 1)
        XCTAssertEqual(guide.scheduledWeight(now: start.addingTimeInterval(14 * 60)), 1)
        XCTAssertEqual(try XCTUnwrap(guide.scheduledWeight(now: start.addingTimeInterval(15 * 60 + 60))), 0.5, accuracy: 0.01)
        XCTAssertEqual(guide.scheduledWeight(now: start.addingTimeInterval(15 * 60 + 121)), 0)
        XCTAssertTrue(guide.isVisuallyActive(now: start.addingTimeInterval(60)))
        XCTAssertFalse(guide.isVisuallyActive(now: start.addingTimeInterval(21 * 60)))

        guide.end()
        XCTAssertEqual(guide.phase, .idle)
        XCTAssertNil(guide.anchor)
        XCTAssertEqual(published.last, .off)

        guide.begin(now: start.addingTimeInterval(100))
        XCTAssertEqual(published.last?.epoch, 2)
        guide.end()
    }

    func testResumeContinuesTheWindowInsteadOfGuidingAgain() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        let start = Date(timeIntervalSinceReferenceDate: 5_000)
        guide.begin(now: start)
        guide.end()

        // A phone call five minutes in: back at full weight, re-anchored.
        let fiveMinutes = start.addingTimeInterval(5 * 60)
        guide.resume(now: fiveMinutes)
        XCTAssertEqual(guide.phase, .guiding)
        XCTAssertEqual(guide.anchor, fiveMinutes)
        XCTAssertEqual(published.last?.weight, 1)
        XCTAssertEqual(published.last?.epoch, 2)
        XCTAssertEqual(guide.guideEndsAt, start.addingTimeInterval(15 * 60))
        guide.end()

        // After the guide is over nothing comes back.
        guide.resume(now: start.addingTimeInterval(16 * 60))
        XCTAssertEqual(guide.phase, .idle)
        XCTAssertEqual(published.last, .off)
        XCTAssertNil(guide.guideEndsAt)
    }

    func testRateChangeRestartsTheEpochAndDissolveSurvivesSettings() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        let start = Date(timeIntervalSinceReferenceDate: 0)
        guide.begin(now: start)
        XCTAssertEqual(published.last?.epoch, 1)

        // New rate mid-guide: same epoch (audio stays continuous), anchor rebased
        // so the disc keeps the same fraction of the cycle as the audio.
        guide.settings.breathsPerMinute = 5
        let later = start.addingTimeInterval(25) // 2.5 cycles at 6/min: fraction 0.5
        guide.settingsDidChange(now: later)
        XCTAssertEqual(guide.phase, .guiding)
        XCTAssertEqual(published.last?.epoch, 1)
        XCTAssertEqual(published.last?.rate ?? 0, 5.0 / 60, accuracy: 0.000_01)
        let anchor = try XCTUnwrap(guide.anchor)
        let fractionAfter = later.timeIntervalSince(anchor) * (5.0 / 60)
        XCTAssertEqual(fractionAfter, 0.5, accuracy: 0.001)
        XCTAssertEqual(guide.guideEndsAt, start.addingTimeInterval(15 * 60), "the window keeps its start")

        // Shorter duration already in the past: dissolve now, and stay dissolving
        // through further settings changes.
        guide.settings.guideMinutes = 5
        guide.settingsDidChange(now: start.addingTimeInterval(6 * 60))
        XCTAssertEqual(guide.phase, .dissolving)
        XCTAssertEqual(published.last?.weight, 0)
        XCTAssertEqual(published.last?.dissolveSeconds, BreathingGuideController.dissolveSeconds)
        guide.settings.breathsPerMinute = 7
        guide.settingsDidChange(now: start.addingTimeInterval(6 * 60 + 30))
        XCTAssertEqual(guide.phase, .dissolving)
        XCTAssertEqual(published.last?.weight, 0)
        XCTAssertEqual(published.last?.rate ?? 0, 7.0 / 60, accuracy: 0.000_01)
        guide.end()
    }

    func testReleaseFollowsTheSleepTimerFade() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        guide.begin(now: Date(timeIntervalSinceReferenceDate: 0))
        guide.release(over: 20)
        XCTAssertEqual(guide.phase, .dissolving)
        XCTAssertEqual(published.last?.weight, 0)
        XCTAssertEqual(published.last?.dissolveSeconds, 20)
        XCTAssertEqual(published.last?.rate ?? 0, 0.1, accuracy: 0.000_01)
        guide.end()
    }

    func testAllNightIsSubtleAndNeverDissolves() throws {
        let guide = BreathingGuideController(defaults: try makeDefaults())
        var published: [BreathParameters] = []
        guide.onChange = { published.append($0) }
        guide.settings.guideMinutes = 0
        let start = Date(timeIntervalSinceReferenceDate: 0)
        guide.begin(now: start)
        XCTAssertEqual(published.last?.bedDepth, 0.2)
        XCTAssertNil(guide.guideEndsAt)
        XCTAssertEqual(guide.scheduledWeight(now: start.addingTimeInterval(9 * 3_600)), 1)
        guide.end()
    }

    func testSettingsPersist() throws {
        let defaults = try makeDefaults()
        let guide = BreathingGuideController(defaults: defaults)
        guide.settings.isEnabled = true
        guide.settings.breathsPerMinute = 5
        guide.settings.guideMinutes = 20
        let reloaded = BreathingGuideController(defaults: defaults)
        XCTAssertEqual(reloaded.settings, BreathingSettings(isEnabled: true, breathsPerMinute: 5, guideMinutes: 20))
    }
}

/// Copy that reads as a medical or efficacy claim, and the vocabulary the
/// copy guide vetoes for mixes, are kept out of both catalogs: the interface
/// strings and the phrases Siri is trained with.
final class CopyLintTests: XCTestCase {
    private static let catalogs = ["Localizable.xcstrings", "AppShortcuts.xcstrings"]

    // The catalogs are compiled away at build time; read the source files.
    private func catalogURL(_ name: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SleepNoise/Resources/\(name)")
    }

    func testNoMedicalClaimsInEitherLanguage() throws {
        for name in Self.catalogs {
            let text = try String(contentsOf: catalogURL(name), encoding: .utf8).lowercased()
            for banned in ["insomn", "ansiedad", "anxiety", "terap", "treat", "cure", "cura ", "coherencia cardíaca", "stay under"] {
                XCTAssertFalse(text.contains(banned), "\(name) contains \"\(banned)\"")
            }
        }
    }

    /// A mix is never a "preset", and no mix is named after a promise (deep
    /// sleep, focus) or after babies. Checked on what people read, language
    /// by language: keys and comments may keep the word.
    func testNoVetoedMixVocabularyInEitherLanguage() throws {
        let vetoed = [
            "en": ["preset", "deep sleep", "focus", "baby"],
            "es": ["preset", "preajuste", "profund", "concentraci", "bebé"]
        ]
        for name in Self.catalogs {
            let data = try Data(contentsOf: catalogURL(name))
            let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
            let strings = try XCTUnwrap(root["strings"] as? [String: Any])
            var checked = 0
            for (key, entry) in strings {
                let localizations = (entry as? [String: Any])?["localizations"] as? [String: Any] ?? [:]
                for (language, words) in vetoed {
                    for value in Self.values(in: localizations[language]) {
                        checked += 1
                        let text = value.lowercased()
                        for word in words {
                            XCTAssertFalse(text.contains(word), "\(name) \(key) [\(language)] contains \"\(word)\"")
                        }
                    }
                }
            }
            XCTAssertGreaterThan(checked, 5, "\(name) should have been read")
        }
    }

    /// Every string under a "value" or "values" key, at any depth.
    private static func values(in node: Any?) -> [String] {
        guard let dictionary = node as? [String: Any] else { return [] }
        var found: [String] = []
        for (key, child) in dictionary {
            if key == "value", let text = child as? String {
                found.append(text)
            } else if key == "values", let list = child as? [String] {
                found.append(contentsOf: list)
            } else {
                found.append(contentsOf: values(in: child))
            }
        }
        return found
    }
}
