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
/// Night never creates, changes or stores a sleep timer (C47). It shows the
/// one that is already running, or none.
enum BedtimeScreenPolicy {
    /// Asking for Night with the mix at rest starts it, in the same
    /// gesture. A mix where nothing would sound is Play's business: it
    /// raises the fallback layer, so the word on the bar never does nothing.
    static func startsPlayback(isPlaying: Bool) -> Bool {
        !isPlaying
    }

    /// Whether locking the iPhone leaves Night in front (C47, the default
    /// of "Switch to Night"): the night is playing, nothing is in front of
    /// the page (a sheet rules, and Night never opens over one) and it is
    /// night. By day a lock is just a lock.
    static func entersOnLock(isPlaying: Bool, isCovered: Bool, sheetIsOpen: Bool, isNight: Bool) -> Bool {
        isPlaying && !isCovered && !sheetIsOpen && isNight
    }

    /// Seconds without a touch after which the Night screen is drawn dimmed.
    static let dimDelay: TimeInterval = 60

    static func isDimmed(lastTouch: Date, now: Date) -> Bool {
        now.timeIntervalSince(lastTouch) >= dimDelay
    }

    /// How much of its ink a dimmed Night screen keeps. The app never
    /// touches the brightness of the display: it draws less light. 0.6 is
    /// the floor 03 §3.7 already set for the Horizon: `texto-noche` at 0.6
    /// on black is 3.3:1, and under that the hour, the state and "+15 min"
    /// fall below 3:1 at the one moment they are looked up. With "Increase
    /// Contrast" the screen dims less.
    static let dimmedOpacity = 0.6
    static let dimmedOpacityHighContrast = 0.8

    static func dimmedOpacity(increasedContrast: Bool) -> Double {
        increasedContrast ? dimmedOpacityHighContrast : dimmedOpacity
    }
    /// A touch counts only this long after the iPhone was unlocked or the
    /// app came forward: the thumb that unlocks also lands on the screen.
    static let wakeGuard: TimeInterval = 0.3
    /// How long the two first-time sentences stay (copy guide T25).
    static let introDuration: TimeInterval = 4
    /// How long "Playing · at 40" stays after the vertical drag (C51).
    static let levelNoteDuration: TimeInterval = 3

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
