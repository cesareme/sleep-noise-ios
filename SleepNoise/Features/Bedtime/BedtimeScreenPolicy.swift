import Foundation

/// Rules of the Night screen that do not need a view.
///
/// The screen is drawn black. System brightness is never changed and no
/// private API is involved; playback continues with the display off because
/// the audio session is `.playback` with the audio background mode.
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
}

/// Result of `MixerModel.enterBedtime()`.
enum BedtimeEntryOutcome: Equatable {
    case entered
    case nothingToPlay
    case audioFailed
}
