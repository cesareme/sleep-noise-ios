import Foundation

/// Where the sound comes out, as far as the rules care.
enum OutputRoute: Equatable {
    /// The iPhone's own speaker.
    case builtInSpeaker
    /// Anything else: AirPods, wired or Bluetooth headphones, a Bluetooth or
    /// AirPlay speaker. `id` tells one from another (the port's UID).
    case external(id: String)
}

enum RouteEvent: Equatable, CaseIterable {
    /// The output in use went away: AirPods out of the ear, out of battery or
    /// disconnected, headphones unplugged (route change with
    /// `.oldDeviceUnavailable`, or an interruption with `.routeDisconnected`).
    case outputLost
    /// An output appeared (route change with `.newDeviceAvailable`).
    case outputAvailable
    /// The person asked to play: the Disc, "Keep playing on speaker", the
    /// lock screen, the button on the headphones.
    case resumeRequested
}

/// The night as the route rules see it.
struct RouteState: Equatable {
    var isPlaying: Bool
    /// The output the night is playing on, or was playing on when it paused.
    var sessionRoute: OutputRoute
    /// The output the system would use now.
    var currentRoute: OutputRoute
    /// When the night was paused because its output went away; nil when it
    /// is playing or was paused for any other reason.
    var lostOutputAt: Date?
    /// The app is in front. Only then may it resume unasked.
    var appIsActive: Bool
    /// The session's master level, 0 to 1. Never the system volume.
    var master: Float
}

enum RouteAction: Equatable {
    case none
    /// Fade out and pause. When the iPhone's speaker is what is left,
    /// "Keep playing on speaker" is offered until `speakerOfferUntil`.
    case pause(fadeOut: TimeInterval, speakerOfferUntil: Date?)
    /// Play again on the current output with this master level.
    case resume(fadeIn: TimeInterval, master: Float)
    /// It was paused too long: the night is over.
    case endSession
}

/// What a change of output does to the night.
///
/// - When the output goes away the night pauses with a fade short enough not
///   to be heard on the speaker the system falls back to.
/// - It never plays again by itself on the iPhone's speaker. It resumes
///   unasked only when the same output comes back with the app in front.
/// - "Keep playing on speaker" is the explicit way on, offered for a minute.
///   A touch anywhere does the same at any time.
/// - A resume the person asks for is capped to 0.4 only when the output
///   changed to the iPhone's speaker since the night paused.
enum RoutePolicy {
    /// Catalog key of the explicit action.
    static let speakerOfferKey = "ruta.seguir_altavoz"

    static let lostOutputFadeOut: TimeInterval = 0.04
    static let speakerOfferDuration: TimeInterval = 60
    static let speakerMasterCap: Float = 0.4
    static let resumeFadeIn: TimeInterval = 0.8
    /// A pause command with headphones on (lock screen, the stem, the
    /// earbuds pausing by themselves) fades this long.
    static let headphonesPauseFadeOut: TimeInterval = 3
    static let longestPause = InterruptionPolicy.longestPause

    static func action(for event: RouteEvent, state: RouteState, now: Date) -> RouteAction {
        switch event {
        case .outputLost:
            guard state.isPlaying else { return .none }
            let offer = state.currentRoute == .builtInSpeaker ? now.addingTimeInterval(speakerOfferDuration) : nil
            return .pause(fadeOut: lostOutputFadeOut, speakerOfferUntil: offer)

        case .outputAvailable:
            guard !state.isPlaying, let lostAt = state.lostOutputAt else { return .none }
            if now.timeIntervalSince(lostAt) >= longestPause { return .endSession }
            guard state.appIsActive,
                  state.currentRoute != .builtInSpeaker,
                  mayResumeUnasked(pausedOn: state.sessionRoute, current: state.currentRoute)
            else { return .none }
            return .resume(fadeIn: resumeFadeIn, master: state.master)

        case .resumeRequested:
            guard !state.isPlaying else { return .none }
            return .resume(
                fadeIn: resumeFadeIn,
                master: resumeMaster(pausedOn: state.sessionRoute, current: state.currentRoute, master: state.master)
            )
        }
    }

    /// Gate for every resume nobody asked for, the end of an interruption
    /// included: only on the output the night was playing on. So a night
    /// that was on AirPods never comes back by itself on the speaker, or on
    /// some other speaker that happened to connect.
    static func mayResumeUnasked(pausedOn: OutputRoute, current: OutputRoute) -> Bool {
        pausedOn == current
    }

    /// The master level a requested resume plays at.
    static func resumeMaster(pausedOn: OutputRoute, current: OutputRoute, master: Float) -> Float {
        guard current == .builtInSpeaker, pausedOn != current else { return master }
        return min(master, speakerMasterCap)
    }

    /// "Keep playing on speaker" is on screen: the output was lost less than
    /// a minute ago, the night is still paused and the speaker is what is left.
    static func speakerOfferIsVisible(state: RouteState, now: Date) -> Bool {
        guard !state.isPlaying, state.currentRoute == .builtInSpeaker, let lostAt = state.lostOutputAt else {
            return false
        }
        let elapsed = now.timeIntervalSince(lostAt)
        return elapsed >= 0 && elapsed < speakerOfferDuration
    }
}
