import SwiftUI
import UIKit

/// What covers the page at night: Night, Small Hours, or nothing.
///
/// A layer over the page, not a presentation of the system: it comes and
/// goes by opacity alone (2 s; 0.25 s with Reduce Motion) and the sheets of
/// the page still go over it. Small Hours wins when both are asked for: it
/// may have been started from an ended Night, and when it ends what is
/// behind it is the night page.
struct NightCover: View {
    enum Surface: Equatable {
        case night
        case smallHours

        static func resolve(isBedtime: Bool, isSmallHours: Bool) -> Surface? {
            if isSmallHours { return .smallHours }
            return isBedtime ? .night : nil
        }
    }

    @ObservedObject var model: MixerModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown: Surface?

    private var asked: Surface? {
        Surface.resolve(isBedtime: model.isBedtime, isSmallHours: model.isSmallHours)
    }

    var body: some View {
        ZStack {
            if shown == .night {
                NightScreen(model: model, timer: model.timer)
                    .transition(.opacity)
            }
            if shown == .smallHours {
                SmallHoursScreen(model: model, session: model.smallHours)
                    .transition(.opacity)
            }
        }
        .onChange(of: asked, initial: true) { previous, next in
            guard shown != next else { return }
            guard previous != next else {
                // Already there when the view appears: nothing to fade.
                shown = next
                return
            }
            withAnimation(.easeInOut(duration: Self.fade(from: shown, to: next, reduceMotion: reduceMotion))) {
                shown = next
            }
        }
        .modifier(NightScreenAwake(model: model, isCovered: asked != nil))
    }

    /// Page to night and back is a change of phase. From Night to Small
    /// Hours the screen stays black and only its content changes.
    static func fade(from: Surface?, to: Surface?, reduceMotion: Bool) -> TimeInterval {
        if from != nil, to != nil { return Motion.content }
        return Motion.phase(reduceMotion: reduceMotion)
    }
}

/// Applies "Keep screen on" (C46) while a night surface is in front.
///
/// Night lets the iPhone sleep. It holds the screen awake only as the
/// setting says, by default while it charges, and gives the idle timer
/// back the moment the page returns. The app never touches the brightness.
private struct NightScreenAwake: ViewModifier {
    @ObservedObject var model: MixerModel
    var isCovered: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: isCovered, initial: true) { _, covered in
                // The battery is only watched while it matters.
                UIDevice.current.isBatteryMonitoringEnabled = covered
                apply()
            }
            .onChange(of: model.keepScreenOn) { _, _ in apply() }
            // Only a night that is open holds the screen: when it ends by
            // itself the iPhone sleeps as the system says.
            .onChange(of: model.isPlaying) { _, _ in apply() }
            .onChange(of: model.pauseCause) { _, _ in apply() }
            .onChange(of: model.sessionEndedAt) { _, _ in apply() }
            .onReceive(NotificationCenter.default.publisher(
                for: UIDevice.batteryStateDidChangeNotification
            )) { _ in
                apply()
            }
    }

    private func apply() {
        let state = UIDevice.current.batteryState
        let isCharging = state == .charging || state == .full
        let awake = model.bedtimeKeepsScreenAwake(isCharging: isCharging)
        if UIApplication.shared.isIdleTimerDisabled != awake {
            UIApplication.shared.isIdleTimerDisabled = awake
        }
        #if DEBUG
        NightArguments.note(screenAwake: awake)
        #endif
    }
}
