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

/// A-weighted level meter for the bed-loudness tests.
///
/// The analog A-weighting prototype has four zeros at DC, double poles at
/// 20.6 Hz and 12 194 Hz and single poles at 107.7 Hz and 737.9 Hz. Each pole
/// becomes a first-order section through the bilinear transform with its
/// corner pre-warped, and the cascade is normalised to 0 dB at 1 kHz.
enum AWeighting {
    private struct Section {
        let isHighpass: Bool
        let gain: Double
        let feedback: Double
        var lastInput = 0.0
        var lastOutput = 0.0

        init(corner: Double, sampleRate: Double, isHighpass: Bool) {
            let k = tan(Double.pi * min(corner, sampleRate * 0.49) / sampleRate)
            self.isHighpass = isHighpass
            gain = (isHighpass ? 1 : k) / (1 + k)
            feedback = (1 - k) / (1 + k)
        }

        mutating func process(_ input: Double) -> Double {
            let output = gain * (isHighpass ? input - lastInput : input + lastInput) + feedback * lastOutput
            lastInput = input
            lastOutput = output
            return output
        }

        func magnitude(at hertz: Double, sampleRate: Double) -> Double {
            let cosine = cos(2 * Double.pi * hertz / sampleRate)
            let numerator = isHighpass ? 2 - 2 * cosine : 2 + 2 * cosine
            let denominator = 1 - 2 * feedback * cosine + feedback * feedback
            return gain * sqrt(numerator / denominator)
        }
    }

    /// Root mean square of the A-weighted signal, in dB relative to full scale.
    static func decibels(_ samples: [Float], sampleRate: Double) -> Double {
        guard !samples.isEmpty else { return -.infinity }
        var sections = [
            Section(corner: 20.6, sampleRate: sampleRate, isHighpass: true),
            Section(corner: 20.6, sampleRate: sampleRate, isHighpass: true),
            Section(corner: 107.7, sampleRate: sampleRate, isHighpass: true),
            Section(corner: 737.9, sampleRate: sampleRate, isHighpass: true),
            Section(corner: 12_194, sampleRate: sampleRate, isHighpass: false),
            Section(corner: 12_194, sampleRate: sampleRate, isHighpass: false)
        ]
        let reference = sections.reduce(1.0) { $0 * $1.magnitude(at: 1_000, sampleRate: sampleRate) }
        var energy = 0.0
        for sample in samples {
            var value = Double(sample)
            for index in sections.indices {
                value = sections[index].process(value)
            }
            energy += value * value
        }
        let rms = sqrt(energy / Double(samples.count)) / reference
        return 20 * log10(max(rms, 1e-12))
    }
}
