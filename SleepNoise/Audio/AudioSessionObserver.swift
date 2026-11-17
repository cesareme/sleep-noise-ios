import AVFoundation
import CallKit
import Foundation

/// What the mixer hears from the audio session: interruptions, the output
/// coming and going, calls. The app has one, `AudioSessionObserver`; the
/// tests of the model put a double here and raise the events by hand.
/// Every handler runs on the main thread.
protocol AudioSessionObserving: AnyObject {
    /// An interruption began. `.routeDisconnected` when the system says the
    /// output went away, `.system` for anything else: it does not say what.
    var onInterruptionBegan: (@MainActor (InterruptionKind) -> Void)? { get set }
    /// The interruption is over. The system's "should resume" hint is not
    /// passed on: `InterruptionPolicy` decides without it.
    var onInterruptionEnded: (@MainActor () -> Void)? { get set }
    /// The output in use went away (earbuds out, cable out).
    var onOutputLost: (@MainActor () -> Void)? { get set }
    /// An output appeared.
    var onOutputAvailable: (@MainActor () -> Void)? { get set }
    /// The route changed for any other reason.
    var onRouteChange: (@MainActor () -> Void)? { get set }
    var onMediaServicesReset: (@MainActor () -> Void)? { get set }
    /// A call began or the last one ended (`CXCallObserver`, C48).
    var onCallChanged: (@MainActor (Bool) -> Void)? { get set }
    /// Where the sound would come out right now.
    var currentRoute: OutputRoute { get }
    /// Another app is playing. Nothing resumes over it unasked.
    var isOtherAudioPlaying: Bool { get }
    func start()
}

/// Forwards interruption, route and call notifications. Callbacks run on the
/// main queue.
final class AudioSessionObserver: NSObject, AudioSessionObserving, @unchecked Sendable {
    var onInterruptionBegan: (@MainActor (InterruptionKind) -> Void)?
    var onInterruptionEnded: (@MainActor () -> Void)?
    var onOutputLost: (@MainActor () -> Void)?
    var onOutputAvailable: (@MainActor () -> Void)?
    var onRouteChange: (@MainActor () -> Void)?
    var onMediaServicesReset: (@MainActor () -> Void)?
    var onCallChanged: (@MainActor (Bool) -> Void)?

    private var tokens: [NSObjectProtocol] = []
    /// Only tells a call from the rest of what interrupts (C48): the system
    /// does not say that an interruption was a call. Nothing about the call
    /// is read or kept.
    private var callObserver: CXCallObserver?
    private var isInCall = false

    var currentRoute: OutputRoute {
        Self.route(of: AVAudioSession.sharedInstance().currentRoute)
    }

    var isOtherAudioPlaying: Bool {
        AVAudioSession.sharedInstance().isOtherAudioPlaying
    }

    /// The route as the rules see it: the iPhone's own speaker, or anything
    /// else told apart by the port's UID. No output at all counts as the
    /// speaker, which is the careful reading: nothing resumes on it unasked.
    static func route(of description: AVAudioSessionRouteDescription) -> OutputRoute {
        guard let port = description.outputs.first else { return .builtInSpeaker }
        switch port.portType {
        case .builtInSpeaker, .builtInReceiver:
            return .builtInSpeaker
        case .airPlay, .carAudio, .HDMI:
            // An output that is certainly not on anybody's ears.
            return .external(id: port.uid, isHeadphones: false)
        default:
            return .external(id: port.uid)
        }
    }

    func start() {
        guard tokens.isEmpty else { return }
        let center = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()

        tokens.append(center.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: session,
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                self?.handleInterruption(notification)
            }
        })

        tokens.append(center.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: session,
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                self?.handleRouteChange(notification)
            }
        })

        tokens.append(center.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification,
            object: session,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.onMediaServicesReset?()
            }
        })

        let calls = CXCallObserver()
        calls.setDelegate(self, queue: .main)
        callObserver = calls
        isInCall = Self.hasLiveCall(calls)
        if isInCall {
            MainActor.assumeIsolated { onCallChanged?(true) }
        }
    }

    func stop() {
        let center = NotificationCenter.default
        tokens.forEach { center.removeObserver($0) }
        tokens.removeAll()
        callObserver?.setDelegate(nil, queue: nil)
        callObserver = nil
    }

    deinit {
        stop()
    }

    private static func hasLiveCall(_ observer: CXCallObserver) -> Bool {
        observer.calls.contains { !$0.hasEnded }
    }

    @MainActor
    private func handleInterruption(_ notification: Notification) {
        guard
            let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: raw)
        else { return }

        switch type {
        case .began:
            let reasonRaw = notification.userInfo?[AVAudioSessionInterruptionReasonKey] as? UInt
            let reason = reasonRaw.flatMap { AVAudioSession.InterruptionReason(rawValue: $0) }
            onInterruptionBegan?(reason == .routeDisconnected ? .routeDisconnected : .system)
        case .ended:
            onInterruptionEnded?()
        @unknown default:
            break
        }
    }

    @MainActor
    private func handleRouteChange(_ notification: Notification) {
        guard
            let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: raw)
        else { return }

        switch reason {
        case .oldDeviceUnavailable:
            onOutputLost?()
        case .newDeviceAvailable:
            onOutputAvailable?()
        case .override, .categoryChange, .routeConfigurationChange:
            onRouteChange?()
        default:
            break
        }
    }
}

extension AudioSessionObserver: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        // Delivered on the main queue (`setDelegate(_:queue:)`).
        let live = Self.hasLiveCall(callObserver)
        guard live != isInCall else { return }
        isInCall = live
        MainActor.assumeIsolated { onCallChanged?(live) }
    }
}
