import Foundation

/// What a Shortcut entry point of the mixer did, for the intent to put in
/// words, or to say nothing about. There is no outcome that asks for Pro: a
/// Shortcut never sells (C43).
enum IntentOutcome: Equatable {
    case started
    case stopped
    /// Pause was asked for while nothing was playing.
    case nothingPlaying
    /// A setting was changed and nothing had to start: the timer set to "Off".
    case applied
    /// The mix that was asked for is no longer in the list.
    case notFound
    /// The sound did not start.
    case failed
}
