import Foundation

/// Rules of the Night screen that do not need a view.
///
/// The screen is drawn black. System brightness is never changed and no
/// private API is involved; playback continues with the display off because
/// the audio session is `.playback` with the audio background mode.
///
/// Night lets the iPhone sleep (C46): it holds the screen awake only as the
/// "Keep screen on" setting says, by default while it charges. While the
/// screen is on it is drawn dimmed after 60 s without a touch.
///
/// Night never creates, changes or stores a sleep timer. It shows the one that
/// is already running, or none.
enum BedtimeScreenPolicy {
    enum Entry: Equatable {
        /// Cover the interface. `startsPlayback` is true when the mix was paused.
        case enter(startsPlayback: Bool)
        /// Every audible layer is at zero: there is nothing to fall asleep to.
        case nothingToPlay
    }

    /// What asking for Night does, given the mixer state.
    static func entry(isPlaying: Bool, isSilent: Bool) -> Entry {
        if isSilent { return .nothingToPlay }
        return .enter(startsPlayback: !isPlaying)
    }

    /// Seconds without a touch after which the Night screen is drawn dimmed.
    static let dimDelay: TimeInterval = 60

    static func isDimmed(lastTouch: Date, now: Date) -> Bool {
        now.timeIntervalSince(lastTouch) >= dimDelay
    }

    /// Whether Night holds the iPhone awake (`isIdleTimerDisabled`). A
    /// phone left on without a charger wakes up flat, so the default only
    /// keeps it on while it charges.
    static func keepsScreenAwake(_ setting: KeepScreenOn, isCharging: Bool) -> Bool {
        switch setting {
        case .always: return true
        case .never: return false
        case .whileCharging: return isCharging
        }
    }
}

/// Result of `MixerModel.enterBedtime()`.
enum BedtimeEntryOutcome: Equatable {
    case entered
    case nothingToPlay
    case audioFailed
}

/// "Keep screen on" for the Night screen (C46). Night lets the iPhone sleep
/// unless this says otherwise.
enum KeepScreenOn: String, CaseIterable {
    /// The default: awake only while it charges, like a bedside clock.
    case whileCharging
    case always
    case never
}
