import Foundation

enum Spectrum {
    /// Average single-bin power at `steps` frequencies spread across [low, high].
    /// Using the same number of bins in every octave estimates power spectral density,
    /// not integrated band energy.
    static func bandPower(
        samples: [Float],
        sampleRate: Float,
        low: Float,
        high: Float,
        steps: Int
    ) -> Double {
        let count = Double(samples.count)
        guard count > 0, steps > 0 else { return 0 }
        var accumulator = 0.0
        for step in 0..<steps {
            let fraction = (Double(step) + 0.5) / Double(steps)
            let frequency = Double(low) + (Double(high) - Double(low)) * fraction
            let coefficient = 2 * cos(2 * Double.pi * frequency / Double(sampleRate))
            var first = 0.0
            var second = 0.0
            for sample in samples {
                let current = Double(sample) + coefficient * first - second
                second = first
                first = current
            }
            let power = (first * first + second * second - coefficient * first * second) / count
            accumulator += power
        }
        return accumulator / Double(steps)
    }

    /// Mean power ratio of each octave to the next higher one, averaged across windows.
    static func meanOctaveRatios(_ next: () -> Float) -> [Double] {
        for _ in 0..<3_000 {
            _ = next()
        }
        let bands: [(Float, Float)] = [
            (125, 250),
            (250, 500),
            (500, 1_000),
            (1_000, 2_000),
            (2_000, 4_000)
        ]
        var totals = [Double](repeating: 0, count: bands.count - 1)
        for _ in 0..<6 {
            var window: [Float] = []
            window.reserveCapacity(8_192)
            for _ in 0..<8_192 {
                window.append(next())
            }
            let powers = bands.map {
                bandPower(samples: window, sampleRate: 48_000, low: $0.0, high: $0.1, steps: 6)
            }
            for index in 0..<(bands.count - 1) {
                totals[index] += powers[index] / powers[index + 1]
            }
        }
        return totals.map { $0 / 6 }
    }
}

final class GeneratorBox<State> {
    var state: State
    private let step: (inout State) -> Float

    init(_ state: State, step: @escaping (inout State) -> Float) {
        self.state = state
        self.step = step
    }

    func next() -> Float {
        step(&state)
    }
}
