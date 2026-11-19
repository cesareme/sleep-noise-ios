import Foundation
import MetricKit

/// One day of MetricKit, as the owner needs it to judge the paint
/// (exploration 12 §7 fase 3): the average luminance of the pixels on
/// screen and the CPU the app used. Nothing else is kept.
struct PaintMetricsSample: Codable, Equatable {
    var receivedAt: Date
    var begin: Date
    var end: Date
    /// `MXDisplayMetric.averagePixelLuminance`, in the unit MetricKit
    /// reports (average pixel luminance, 0 to 100). Nil when the payload
    /// has none.
    var averagePixelLuminance: Double?
    /// `MXCPUMetric.cumulativeCPUTime`, in seconds.
    var cpuSeconds: Double?
    /// `MXCPUMetric.cumulativeCPUInstructions`, as a count.
    var cpuInstructions: Double?
    var appVersion: String?
}

/// Where the samples live: the defaults, the last `keep` days, and a
/// readable JSON file in Documents that the owner can take from the
/// container of a build installed by Xcode. No network, nowhere else.
final class PaintMetricsLog {
    static let key = "sleepnoise.paint.metrics.v1"
    static let fileName = "paint-metrics.json"
    static let keep = 30

    static let standard = PaintMetricsLog(
        defaults: .standard,
        fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    )

    private let defaults: UserDefaults
    private let fileURL: URL?

    init(defaults: UserDefaults, fileURL: URL?) {
        self.defaults = defaults
        self.fileURL = fileURL
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    /// Oldest first.
    var samples: [PaintMetricsSample] {
        guard let data = defaults.data(forKey: Self.key) else { return [] }
        return (try? Self.decoder.decode([PaintMetricsSample].self, from: data)) ?? []
    }

    /// Keeps a sample, drops the oldest beyond `keep`, and rewrites the file.
    func record(_ sample: PaintMetricsSample) {
        var all = samples
        all.append(sample)
        if all.count > Self.keep { all.removeFirst(all.count - Self.keep) }
        if let data = try? Self.encoder.encode(all) {
            defaults.set(data, forKey: Self.key)
        }
        writeFile()
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
    }

    /// Everything kept, as JSON a person can read.
    func dump() -> String {
        let all = samples
        guard !all.isEmpty, let data = try? Self.encoder.encode(all), let text = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return text
    }

    private func writeFile() {
        guard let fileURL else { return }
        try? dump().write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

/// Listens to MetricKit and keeps what the paint needs in the log. iOS
/// hands a payload about once a day, for the previous day, and only on a
/// device: the simulator never delivers one. Started once, at launch.
final class PaintMetricsSubscriber: NSObject, MXMetricManagerSubscriber {
    static let shared = PaintMetricsSubscriber(log: .standard)

    let log: PaintMetricsLog
    private var started = false

    init(log: PaintMetricsLog) {
        self.log = log
    }

    func start() {
        guard !started else { return }
        started = true
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        let now = Date()
        for payload in payloads {
            log.record(Self.sample(from: payload, receivedAt: now))
        }
    }

    static func sample(from payload: MXMetricPayload, receivedAt: Date) -> PaintMetricsSample {
        PaintMetricsSample(
            receivedAt: receivedAt,
            begin: payload.timeStampBegin,
            end: payload.timeStampEnd,
            averagePixelLuminance: payload.displayMetrics?.averagePixelLuminance?.averageMeasurement.value,
            cpuSeconds: payload.cpuMetrics?.cumulativeCPUTime.converted(to: .seconds).value,
            cpuInstructions: payload.cpuMetrics?.cumulativeCPUInstructions.value,
            appVersion: payload.latestApplicationVersion
        )
    }
}
