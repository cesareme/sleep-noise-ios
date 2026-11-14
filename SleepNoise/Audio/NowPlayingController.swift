import Foundation
import MediaPlayer

/// Lock-screen title plus play/pause. No skip or scrub: this is a bed of noise, not a track.
final class NowPlayingController {
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

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: String(localized: "nowplaying.artist"),
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
        if !isPlaying {
            info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func resetElapsed() {
        accumulated = 0
        startedAt = nil
    }

    private var elapsed: TimeInterval {
        accumulated + (startedAt.map { Date().timeIntervalSince($0) } ?? 0)
    }
}
