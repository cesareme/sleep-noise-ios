import SwiftUI

/// Grafito motion (03 §3.7). Three causes only: sound, a fade, a finger.
/// Nothing ever changes position: only length, thickness, opacity or content.
/// No springs, no bounce, nothing finite longer than two seconds.
enum Motion {
    /// Controls: press, release, content swap.
    static let control: TimeInterval = 0.2
    /// Content that changes in place: a state word, a value.
    static let content: TimeInterval = 0.25
    /// A level row lights up under the finger.
    static let fingerIn: TimeInterval = 0.15
    /// A level row lets go.
    static let fingerOut: TimeInterval = 0.25
    /// Start of playback: the Horizon is born from the hairline.
    static let start: TimeInterval = 0.8
    /// Stop: the accent is gone 1.5 s after the sound.
    static let stop: TimeInterval = 1.5
    /// Change of night phase. 0.25 s with Reduce Motion.
    static let phase: TimeInterval = 2
    static let phaseReduced: TimeInterval = 0.25
    /// Upper bound of any finite animation.
    static let longest: TimeInterval = 2

    /// The Horizon reads the engine 20 times a second with a time constant of
    /// 0.5 s; with Reduce Motion, 4 times a second and 1.5 s.
    static let horizonInterval: TimeInterval = 0.05
    static let horizonTau: TimeInterval = 0.5
    static let horizonIntervalReduced: TimeInterval = 0.25
    static let horizonTauReduced: TimeInterval = 1.5
    /// The spoken level of the Horizon changes at most this often.
    static let spokenLevelHold: TimeInterval = 3

    static func horizonInterval(reduceMotion: Bool) -> TimeInterval {
        reduceMotion ? horizonIntervalReduced : horizonInterval
    }

    static func horizonTau(reduceMotion: Bool) -> TimeInterval {
        reduceMotion ? horizonTauReduced : horizonTau
    }

    static func phase(reduceMotion: Bool) -> TimeInterval {
        reduceMotion ? phaseReduced : phase
    }

    static var controlCurve: Animation { .easeInOut(duration: control) }
    static var contentCurve: Animation { .easeInOut(duration: content) }
    static var fingerInCurve: Animation { .easeInOut(duration: fingerIn) }
    static var fingerOutCurve: Animation { .easeInOut(duration: fingerOut) }
    static var startCurve: Animation { .easeOut(duration: start) }
    static var stopCurve: Animation { .easeInOut(duration: stop) }
}

/// Haptics are gated by phase: never at night (03 §3.8).
enum MotionGate {
    static func allows(_ phase: NightPhase) -> Bool {
        !phase.isNight
    }
}
