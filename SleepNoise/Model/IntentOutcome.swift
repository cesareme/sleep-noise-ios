import Foundation

/// What a Shortcut entry point of the mixer did, for the intent to put in words.
enum IntentOutcome: Equatable {
    case started
    case stopped
    /// Stop was asked for while nothing was playing.
    case nothingPlaying
    case needsPro
    /// Playback was asked for with every audible layer at zero.
    case nothingToPlay
    /// A timer length outside 1...`AccessPolicy.maxTimerMinutes`.
    case outOfRange
    case failed
}
