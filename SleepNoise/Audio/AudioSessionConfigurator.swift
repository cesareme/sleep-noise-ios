import AVFoundation
import Foundation

enum AudioSessionConfigurator {
    /// `.playback` ignores the silent switch and, with UIBackgroundModes `audio`,
    /// keeps rendering while the screen is locked. The app never mixes over other
    /// audio: starting playback is an explicit user action.
    static func activate() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setPreferredSampleRate(44_100)
        try session.setActive(true)
    }
}

enum EngineError: Error {
    case formatUnavailable
    case session(Error)
    case engine(Error)
}
