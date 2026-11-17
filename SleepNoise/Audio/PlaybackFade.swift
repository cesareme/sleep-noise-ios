import Foundation

/// How long the bed takes to come and go, in one place (03 §3.7).
///
/// Nothing in the app starts or stops as a step. The Horizon draws the real
/// level, so these are also the times its accent takes to appear and to
/// leave: colour means sound.
enum PlaybackFade {
    /// Play: the bed rises, easing out.
    static let start: TimeInterval = SleepAudioEngine.defaultFadeIn
    /// Pause by the person: the bed leaves the room, it is not cut.
    static let pause: TimeInterval = 1.5
    /// The system took the output (a call, an alarm, another app). It is
    /// already silent for the person; the fade only has to be clean.
    static let interruption: TimeInterval = 0.3
    /// The output went away (earbuds out): short enough that nothing is
    /// heard from the speaker.
    static let lostOutput: TimeInterval = RoutePolicy.lostOutputFadeOut

    /// A fade length in whole samples, never under one.
    static func samples(_ seconds: TimeInterval, sampleRate: Double) -> Int32 {
        Int32(max(1, (seconds * sampleRate).rounded()))
    }
}
