import Foundation

/// How the bedtime screen treats the display.
///
/// The screen is drawn black and the clock is dim. The system idle timer stays
/// enabled, so iOS may dim and lock the display on its own; playback continues
/// because the audio session is `.playback` with the audio background mode.
/// System brightness is never changed. Both choices are public API and avoid
/// the private brightness and idle-timer tricks review rejects.
enum BedtimeScreenPolicy {
    static let systemIdleTimerStaysEnabled = true
    static let changesSystemBrightness = false
    /// Free 60-minute timer used when bedtime starts with no timer chosen.
    static let defaultMinutes = 60
    /// How long the clock stays readable after a tap before it dims again.
    static let dimAfter: TimeInterval = 8
}
