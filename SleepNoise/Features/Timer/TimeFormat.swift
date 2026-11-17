import Foundation

enum TimeFormat {
    /// "45 min": minutes, abbreviated.
    static func minutes(_ minutes: Int) -> String {
        String(format: String(localized: "comun.min"), Int64(minutes))
    }
}
