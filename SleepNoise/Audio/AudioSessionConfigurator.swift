import AVFoundation
import Foundation

enum AudioSessionConfigurator {
    /// `.playback` ignores the silent switch and, with UIBackgroundModes `audio`,
    /// keeps rendering while the screen is locked. The app never mixes over other
    /// audio: starting playback is an explicit user action. The hardware sample
    /// rate is left alone; the engine adopts whatever the route reports, so there
    /// is no system resampler between the mixer and the speaker.
    static func activate() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
    }

    /// Releases the session once playback has stopped, so the app is not holding
    /// the audio hardware all night after a timer finishes. Other apps are not
    /// told to resume: nobody wants a podcast to restart at 3 a.m.
    static func deactivate() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [])
    }
}

enum EngineError: Error {
    case formatUnavailable
    case session(Error)
    case engine(Error)
}
