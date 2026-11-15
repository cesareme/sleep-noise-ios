import XCTest
@testable import SleepNoise

final class DSPGeneratorTests: XCTestCase {
    func testWhiteStaysBoundedAndMoves() {
        var noise = WhiteNoise(seed: 0xA341316C)
        var minimum: Float = 1
        var maximum: Float = -1
        var sum: Float = 0
        let count = 20_000
        for _ in 0..<count {
            let sample = noise.next()
            assertUnit(sample)
            minimum = min(minimum, sample)
            maximum = max(maximum, sample)
            sum += sample
        }
        XCTAssertGreaterThan(maximum - minimum, 0.5)
        XCTAssertEqual(sum / Float(count), 0, accuracy: 0.05)
        let rms = rmsOf { noise.next() }
        XCTAssertGreaterThan(rms, 0.05)
        XCTAssertLessThan(rms, 0.45)
    }

    func testPinkAndBrownStayBounded() {
        var pink = PinkNoise(seed: 0xC2B2AE35)
        var brown = BrownNoise(seed: 0x27BB2EE6)
        for _ in 0..<48_000 {
            assertUnit(pink.next())
            assertUnit(brown.next())
        }
        XCTAssertGreaterThan(rmsOf { pink.next() }, 0.05)
        XCTAssertGreaterThan(rmsOf { brown.next() }, 0.04)
    }

    func testSpectralTilt() {
        let white = GeneratorBox(WhiteNoise(seed: 1)) { state in state.next() }
        let pink = GeneratorBox(PinkNoise(seed: 1)) { state in state.next() }
        let brown = GeneratorBox(BrownNoise(seed: 1)) { state in state.next() }

        let whiteRatios = Spectrum.meanOctaveRatios { white.next() }
        let pinkRatios = Spectrum.meanOctaveRatios { pink.next() }
        let brownRatios = Spectrum.meanOctaveRatios { brown.next() }

        XCTAssertGreaterThan(whiteRatios.min() ?? 0, 0.6)
        XCTAssertLessThan(whiteRatios.max() ?? 0, 2.2)
        XCTAssertEqual(mean(whiteRatios), 1.2, accuracy: 0.6)

        XCTAssertGreaterThan(pinkRatios.min() ?? 0, 1.4)
        XCTAssertGreaterThan(mean(pinkRatios), 1.8)

        XCTAssertGreaterThan(brownRatios.min() ?? 0, 2.4)
        XCTAssertGreaterThan(mean(brownRatios), 3.2)
        XCTAssertGreaterThan(mean(brownRatios), mean(pinkRatios))
    }

    func testTexturesStayBoundedAndDiffer() {
        var rain = RainTexture(seed: 0x5A1F3B91, sampleRate: 48_000)
        var fan = FanTexture(seed: 0x91E10DA5, sampleRate: 48_000)
        var ocean = OceanTexture(seed: 0x3C6EF35F, sampleRate: 48_000)
        var rainSamples: [Float] = []
        var fanSamples: [Float] = []
        var oceanSamples: [Float] = []
        rainSamples.reserveCapacity(48_000)
        fanSamples.reserveCapacity(48_000)
        oceanSamples.reserveCapacity(48_000)
        for _ in 0..<48_000 {
            let rainSample = rain.next()
            let fanSample = fan.next()
            let oceanSample = ocean.next()
            assertUnit(rainSample)
            assertUnit(fanSample)
            assertUnit(oceanSample)
            rainSamples.append(rainSample)
            fanSamples.append(fanSample)
            oceanSamples.append(oceanSample)
        }
        // Beds sit near -15 dBFS so a single sound is neither faint nor hot.
        for samples in [rainSamples, fanSamples, oceanSamples] {
            let rms = rootMeanSquare(samples)
            XCTAssertGreaterThan(rms, 0.09)
            XCTAssertLessThan(rms, 0.26)
            XCTAssertLessThan(samples.map { abs($0) }.max() ?? 1, 0.95, "a texture should not touch the hard clip")
        }

        let rainRate = zeroCrossingRate(rainSamples)
        let fanRate = zeroCrossingRate(fanSamples)
        let oceanRate = zeroCrossingRate(oceanSamples)
        // Rain is hiss plus bright droplets; the fan is a low whoosh; the ocean sits
        // between them because its surf band carries foam above the rumble.
        XCTAssertGreaterThan(rainRate, 0.3)
        XCTAssertLessThan(fanRate, 0.1)
        XCTAssertLessThan(oceanRate, 0.3)
        XCTAssertGreaterThan(rainRate, oceanRate)
        XCTAssertGreaterThan(oceanRate, fanRate)
    }

    func testOceanSwellsMoreThanTheFan() {
        let sampleRate: Float = 48_000
        let seconds = 14
        let count = Int(sampleRate) * seconds
        var fan = FanTexture(seed: 0x91E10DA5, sampleRate: sampleRate)
        var ocean = OceanTexture(seed: 0x3C6EF35F, sampleRate: sampleRate)
        var fanSamples: [Float] = []
        var oceanSamples: [Float] = []
        fanSamples.reserveCapacity(count)
        oceanSamples.reserveCapacity(count)
        for _ in 0..<count {
            fanSamples.append(fan.next())
            oceanSamples.append(ocean.next())
        }
        let fanRatio = windowRatio(fanSamples, sampleRate: sampleRate)
        let oceanRatio = windowRatio(oceanSamples, sampleRate: sampleRate)
        XCTAssertLessThan(fanRatio, 1.5)
        XCTAssertGreaterThan(oceanRatio, 2.5)
        XCTAssertGreaterThan(oceanRatio, fanRatio)
    }

    func testSoftClipStaysInRange() {
        XCTAssertEqual(softClip(0), 0, accuracy: 0.000_001)
        XCTAssertEqual(softClip(0.5), 0.5, accuracy: 0.000_001, "linear below the knee")
        XCTAssertLessThan(softClip(3), 1, "a stacked mix must compress, never hard-clip")
        XCTAssertLessThanOrEqual(softClip(50), 1)
        XCTAssertGreaterThan(softClip(3), softClip(1.5))
        XCTAssertEqual(softClip(0.5), -softClip(-0.5), accuracy: 0.000_001)
        var previous: Float = -2
        var input: Float = -2
        while input <= 2 {
            let output = softClip(input)
            assertUnit(output)
            XCTAssertGreaterThanOrEqual(output, previous)
            previous = output
            input += 0.05
        }
    }

    private func rmsOf(_ next: () -> Float) -> Float {
        var energy: Float = 0
        let count = 8_192
        for _ in 0..<count {
            let sample = next()
            energy += sample * sample
        }
        return sqrt(energy / Float(count))
    }
}

final class FadeCurveTests: XCTestCase {
    func testSmoothstepEndpointsMidpointAndFlatEnds() {
        XCTAssertEqual(FadeCurve.unity(0), 0, accuracy: 0.000_001)
        XCTAssertEqual(FadeCurve.unity(1), 1, accuracy: 0.000_001)
        XCTAssertEqual(FadeCurve.unity(0.5), 0.5, accuracy: 0.000_001)
        XCTAssertEqual(FadeCurve.outputGain(progress: 0), 1, accuracy: 0.000_001)
        XCTAssertEqual(FadeCurve.outputGain(progress: 1), 0, accuracy: 0.000_001)

        var previous = Float(-0.000_1)
        var cursor: Float = 0
        while cursor <= 1 {
            let value = FadeCurve.unity(cursor)
            XCTAssertGreaterThanOrEqual(value, previous)
            previous = value
            cursor += 0.01
        }

        let edge = FadeCurve.unity(0.02) - FadeCurve.unity(0)
        let middle = FadeCurve.unity(0.52) - FadeCurve.unity(0.50)
        XCTAssertLessThan(edge, middle)

        var gain = Float(1.1)
        cursor = 0
        while cursor <= 1 {
            let value = FadeCurve.outputGain(progress: cursor)
            XCTAssertLessThanOrEqual(value, gain + 0.000_01)
            gain = value
            cursor += 0.01
        }
    }

    func testRenderEnvelopeFollowsTheCurve() {
        var state = RenderState(sampleRate: 48_000)
        state.envelope = 1
        let command = EngineCommand(
            gains: .zero,
            envelopeTarget: 0,
            rampSamples: 2_000,
            generation: 1,
            envelopeGeneration: 1
        )
        var previous = state.envelope
        for index in 0..<2_004 {
            _ = state.process(command)
            XCTAssertLessThanOrEqual(state.envelope, previous + 0.000_1)
            previous = state.envelope
            if index == 999 {
                XCTAssertEqual(state.envelope, 0.5, accuracy: 0.02)
            }
        }
        XCTAssertEqual(state.envelope, 0, accuracy: 0.000_1)
    }

    func testGainUpdateDoesNotRestartTheEnvelope() {
        var state = RenderState(sampleRate: 48_000)
        state.envelope = 0.4
        state.appliedEnvelopeGeneration = 3
        var gains = SoundGains.zero
        gains.white = 1
        let command = EngineCommand(
            gains: gains,
            envelopeTarget: 0,
            rampSamples: -1,
            generation: 9,
            envelopeGeneration: 9
        )
        _ = state.process(command)
        XCTAssertEqual(state.envelope, 0.4, accuracy: 0.000_1)
        XCTAssertEqual(state.appliedEnvelopeGeneration, 9)
    }

    func testMixedOutputStaysInsideTheUnitInterval() {
        var state = RenderState(sampleRate: 48_000)
        let command = EngineCommand(
            gains: SoundGains(white: 1, pink: 1, brown: 1, rain: 1, fan: 1, ocean: 1),
            envelopeTarget: 1,
            rampSamples: 1,
            generation: 1,
            envelopeGeneration: 1
        )
        var peak: Float = 0
        for _ in 0..<4_000 {
            let sample = state.process(command)
            assertUnit(sample)
            peak = max(peak, abs(sample))
        }
        XCTAssertGreaterThan(peak, 0.05)
    }
}

final class ParameterMailboxTests: XCTestCase {
    func testPublishIsVisibleToTheReader() {
        let mailbox = ParameterMailbox()
        var gains = SoundGains.zero
        gains.pink = 0.5
        mailbox.publish(EngineCommand(gains: gains, envelopeTarget: 1, rampSamples: 12, generation: 0))
        let loaded = mailbox.load(fallback: .silence)
        XCTAssertEqual(loaded.gains.pink, 0.5, accuracy: 0.000_1)
        XCTAssertEqual(loaded.envelopeTarget, 1, accuracy: 0.000_1)
        XCTAssertEqual(loaded.rampSamples, 12)
        XCTAssertEqual(loaded.generation, 1)

        gains.ocean = 0.25
        for _ in 0..<20 {
            mailbox.publish(EngineCommand(gains: gains, envelopeTarget: 0, rampSamples: -1, generation: 0))
        }
        let latest = mailbox.load(fallback: .silence)
        XCTAssertEqual(latest.gains.ocean, 0.25, accuracy: 0.000_1)
        XCTAssertEqual(latest.rampSamples, -1)
        XCTAssertEqual(latest.generation, 21)
    }
}

final class StereoRenderTests: XCTestCase {
    func testChannelsAreDecorrelatedButLevelMatched() {
        var state = RenderState(sampleRate: 48_000)
        let command = EngineCommand(
            gains: SoundGains(white: 0.5, pink: 0.5, brown: 0.5, rain: 0.5, fan: 0.5, ocean: 0.5),
            envelopeTarget: 1,
            rampSamples: 1,
            generation: 1,
            envelopeGeneration: 1
        )
        let count = 48_000
        var sxy = 0.0, sxx = 0.0, syy = 0.0
        for _ in 0..<count {
            let frame = state.processStereo(command)
            assertUnit(frame.left)
            assertUnit(frame.right)
            sxy += Double(frame.left * frame.right)
            sxx += Double(frame.left * frame.left)
            syy += Double(frame.right * frame.right)
        }
        let correlation = sxy / sqrt(sxx * syy)
        XCTAssertLessThan(abs(correlation), 0.1, "left and right should carry independent noise")
        let levelRatio = sqrt(sxx / syy)
        XCTAssertEqual(levelRatio, 1, accuracy: 0.15, "but at the same loudness")
    }

    func testSilentGainsProduceSilence() {
        var state = RenderState(sampleRate: 48_000)
        let command = EngineCommand(gains: .zero, envelopeTarget: 1, rampSamples: 1, generation: 1, envelopeGeneration: 1)
        for _ in 0..<4_000 {
            let frame = state.processStereo(command)
            XCTAssertEqual(frame.left, 0)
            XCTAssertEqual(frame.right, 0)
        }
    }
}

extension ParameterMailboxTests {
    /// A writer thread publishes commands whose every field encodes the same
    /// counter. A reader thread must never observe a mixture of two commands.
    func testConcurrentReadsNeverTear() {
        // The initial command must itself satisfy the consistency predicate below,
        // otherwise reads made before the writer's first publish look torn.
        var initial = EngineCommand(gains: .zero, envelopeTarget: 0, rampSamples: 0, generation: 0)
        initial.breath.inhale = 0
        let mailbox = ParameterMailbox(initial: initial)
        let iterations = 200_000
        let done = expectation(description: "writer finished")
        var torn = 0
        var reads = 0

        let writer = Thread {
            for index in 0..<iterations {
                let value = Float(index % 1_000) / 1_000
                var gains = SoundGains.zero
                gains.white = value
                gains.pink = value
                gains.brown = value
                gains.rain = value
                gains.fan = value
                gains.ocean = value
                var breath = BreathParameters.off
                breath.rate = value
                breath.inhale = value
                breath.weight = value
                breath.epoch = UInt32(index % 1_000)
                mailbox.publish(EngineCommand(
                    gains: gains,
                    envelopeTarget: value,
                    rampSamples: Int32(index % 1_000),
                    generation: 0,
                    envelopeGeneration: UInt32(index % 1_000),
                    breath: breath
                ))
            }
            done.fulfill()
        }
        writer.qualityOfService = .userInteractive
        writer.start()

        var last = EngineCommand.silence
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            let command = mailbox.load(fallback: last)
            last = command
            reads += 1
            let g = command.gains
            let consistent = g.white == g.pink && g.pink == g.brown && g.brown == g.rain
                && g.rain == g.fan && g.fan == g.ocean && g.ocean == command.envelopeTarget
                && Int32((g.white * 1_000).rounded()) == command.rampSamples
                && command.breath.rate == g.white && command.breath.inhale == g.white
                && command.breath.weight == g.white
                && command.breath.epoch == UInt32(command.rampSamples)
                && command.envelopeGeneration == UInt32(command.rampSamples)
            if !consistent { torn += 1 }
        }
        wait(for: [done], timeout: 10)
        XCTAssertEqual(torn, 0, "seqlock let \(torn) of \(reads) reads through torn")
        XCTAssertGreaterThan(reads, 1_000)
    }
}

private func assertUnit(_ sample: Float, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertFalse(sample.isNaN, file: file, line: line)
    XCTAssertFalse(sample.isInfinite, file: file, line: line)
    XCTAssertGreaterThanOrEqual(sample, -1, file: file, line: line)
    XCTAssertLessThanOrEqual(sample, 1, file: file, line: line)
}

private func mean(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
}

private func rootMeanSquare(_ samples: [Float]) -> Float {
    guard !samples.isEmpty else { return 0 }
    let energy = samples.reduce(Float(0)) { $0 + $1 * $1 }
    return sqrt(energy / Float(samples.count))
}

private func zeroCrossingRate(_ samples: [Float]) -> Float {
    guard samples.count > 1 else { return 0 }
    var crossings = 0
    for index in 1..<samples.count {
        if (samples[index - 1] >= 0) != (samples[index] >= 0) {
            crossings += 1
        }
    }
    return Float(crossings) / Float(samples.count)
}

private func windowRatio(_ samples: [Float], sampleRate: Float) -> Float {
    let window = Int(sampleRate) * 2
    var levels: [Float] = []
    var offset = 0
    while offset + window <= samples.count {
        levels.append(rootMeanSquare(Array(samples[offset..<(offset + window)])))
        offset += window
    }
    guard let high = levels.max(), let rawLow = levels.min() else { return 0 }
    let low = max(rawLow, 0.000_01)
    return high / low
}
