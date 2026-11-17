import Foundation

/// Small Hours is one fixed recipe for everyone (C05, C60): low ocean with the
/// tide at 8 breaths per minute, 20 minutes, a 3 s fade-in. The tide guides
/// until minute 10.5 and dissolves by minute 13; the sea fades over the last
/// 5 minutes; when it ends, nothing happens.
///
/// Plain data: times in seconds from the start of the session. Nothing here
/// reads the last mix, the tide setting of the sheet or the access level.
struct SmallHoursRecipe: Equatable {
    let sound: SoundID
    let level: Float
    let breathsPerMinute: Int
    let duration: TimeInterval
    let fadeIn: TimeInterval
    /// Until here the tide guides at full depth.
    let tideGuideEnd: TimeInterval
    /// From `tideGuideEnd` to here the tide dissolves into the plain sea.
    let tideDissolveEnd: TimeInterval
    /// Length of the closing fade of the sea.
    let finalFade: TimeInterval

    static let standard = SmallHoursRecipe(
        sound: .ocean,
        level: 0.3,
        breathsPerMinute: 8,
        duration: 1_200,
        fadeIn: 3,
        tideGuideEnd: 630,
        tideDissolveEnd: 780,
        finalFade: 300
    )

    /// When the closing fade begins.
    var finalFadeStart: TimeInterval { duration - finalFade }

    enum Phase: Equatable {
        case tideGuiding
        case tideDissolving
        case plainSea
        case windingDown
        case finished
    }

    /// The phase at `elapsed` seconds. Negative time counts as zero. Every
    /// interval is closed on the left and open on the right.
    func phase(at elapsed: TimeInterval) -> Phase {
        let time = max(0, elapsed)
        if time >= duration { return .finished }
        if time >= finalFadeStart { return .windingDown }
        if time >= tideDissolveEnd { return .plainSea }
        if time >= tideGuideEnd { return .tideDissolving }
        return .tideGuiding
    }

    /// Minutes left, rounded up, never below zero.
    func minutesLeft(at elapsed: TimeInterval) -> Int {
        let left = duration - max(0, elapsed)
        guard left > 0 else { return 0 }
        return Int((left / 60).rounded(.up))
    }

    /// The figure of the winding-down status line (C60): `minutesLeft` during
    /// the closing fade and `nil` outside it.
    func windingDownMinutes(at elapsed: TimeInterval) -> Int? {
        phase(at: elapsed) == .windingDown ? minutesLeft(at: elapsed) : nil
    }
}
