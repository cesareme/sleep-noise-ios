import Foundation
import MediaPlayer

/// What the mixer asks of the lock screen. The app has one,
/// `NowPlayingController`; the tests of the model put a double here.
protocol NowPlayingControlling: AnyObject {
    func install(
        onPlay: @escaping @MainActor () -> Void,
        onPause: @escaping @MainActor () -> Void,
        onToggle: @escaping @MainActor () -> Void
    )
    func update(isPlaying: Bool, title: String)
    /// A new night: the elapsed time starts again.
    func resetElapsed()
}

/// Lock-screen title plus play/pause (03 §5, surface 34). No skip or scrub:
/// this is a bed of noise, not a track. It is declared a live stream, so
/// the system shows "Live" where a track would have its progress bar: the
/// sound has no length.
final class NowPlayingController: NowPlayingControlling {
    private var installed = false
    private var accumulated: TimeInterval = 0
    private var startedAt: Date?

    func install(
        onPlay: @escaping @MainActor () -> Void,
        onPause: @escaping @MainActor () -> Void,
        onToggle: @escaping @MainActor () -> Void
    ) {
        let center = MPRemoteCommandCenter.shared()
        guard !installed else { return }
        installed = true

        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
        center.togglePlayPauseCommand.isEnabled = true
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
        center.seekForwardCommand.isEnabled = false
        center.seekBackwardCommand.isEnabled = false
        center.changePlaybackPositionCommand.isEnabled = false
        center.skipForwardCommand.isEnabled = false
        center.skipBackwardCommand.isEnabled = false

        center.playCommand.addTarget { _ in
            DispatchQueue.main.async {
                MainActor.assumeIsolated { onPlay() }
            }
            return .success
        }
        center.pauseCommand.addTarget { _ in
            DispatchQueue.main.async {
                MainActor.assumeIsolated { onPause() }
            }
            return .success
        }
        center.togglePlayPauseCommand.addTarget { _ in
            DispatchQueue.main.async {
                MainActor.assumeIsolated { onToggle() }
            }
            return .success
        }
    }

    func update(isPlaying: Bool, title: String) {
        if isPlaying {
            if startedAt == nil { startedAt = Date() }
        } else if let startedAt {
            accumulated += Date().timeIntervalSince(startedAt)
            self.startedAt = nil
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = Self.info(
            title: title,
            artist: String(localized: "nowplaying.artist"),
            isPlaying: isPlaying,
            elapsed: elapsed
        )
    }

    /// What the lock screen is told: the name of the mix, the app as the
    /// artist, and that it is live. No artwork of its own and no duration.
    static func info(title: String, artist: String, isPlaying: Bool, elapsed: TimeInterval) -> [String: Any] {
        [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
    }

    func resetElapsed() {
        accumulated = 0
        startedAt = nil
    }

    private var elapsed: TimeInterval {
        accumulated + (startedAt.map { Date().timeIntervalSince($0) } ?? 0)
    }
}
