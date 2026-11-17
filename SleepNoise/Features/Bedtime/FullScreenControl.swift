import SwiftUI
import UIKit

/// The screen as a button (03 §4.5): Night and Small Hours.
///
/// Black from edge to edge, and the whole of it answers one finger: a touch
/// pauses or resumes, a finger that moves up or down sets the session level
/// (C51) and, on Night, a finger that stays put and lifts goes back to the
/// page. No gesture is sideways and none takes two fingers.
///
/// What the screen shows is laid over the black and takes no touches; only
/// the night actions at the bottom are buttons of their own. Everything is
/// drawn dimmed once 60 s go by without a touch (C46).
///
/// For VoiceOver the screen is one button with its state as its value, and
/// the level is an adjustable element where the rule appears: no gesture is
/// the only way to anything.
struct FullScreenControl<Content: View, Actions: View>: View {
    @ObservedObject var model: MixerModel
    /// A long press goes back: Night. In Small Hours it does nothing.
    var allowsBack: Bool
    var spoken: FullScreenSpoken
    var onTap: () -> Void
    var onBack: () -> Void = {}
    /// The session level moved under a finger, or from VoiceOver.
    var onLevel: () -> Void = {}
    @ViewBuilder var content: (NightLayout) -> Content
    @ViewBuilder var actions: () -> Actions

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var touch = NightTouch()
    /// The touch in course began inside the wake guard: it is not counted.
    @State private var swallowsTouch = false
    @State private var wokeAt: Date?
    @State private var showsRule = false
    @State private var ruleRelease = 0

    /// The rule stays this long after the finger lifts.
    private static var ruleLinger: TimeInterval { Motion.stop }

    var body: some View {
        GeometryReader { geometry in
            let insets = geometry.safeAreaInsets
            let layout = NightLayout(fullHeight: geometry.size.height + insets.top + insets.bottom)
            ZStack(alignment: .top) {
                surface
                Group {
                    content(layout)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    rule(layout)
                    actions()
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, insets.bottom)
                        .accessibilitySortPriority(3)
                    levelElement(layout)
                }
                .opacity(model.isBedtimeDimmed ? BedtimeScreenPolicy.dimmedOpacity : 1)
                .animation(
                    .easeInOut(duration: Motion.phase(reduceMotion: reduceMotion)),
                    value: model.isBedtimeDimmed
                )
            }
            .ignoresSafeArea()
        }
        .environment(\.nightPhase, allowsBack ? .night : .smallHours)
        .accessibilityElement(children: .contain)
        .accessibilityAction(.magicTap) { activate() }
        .onChange(of: scenePhase) { _, next in
            if next == .active {
                wokeAt = Date()
                // Whoever wakes the iPhone is looking at it: full ink, and
                // the minute starts over.
                model.noteBedtimeTouch()
            } else {
                touch.cancel()
                swallowsTouch = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.protectedDataDidBecomeAvailableNotification
        )) { _ in
            wokeAt = Date()
        }
        .task(id: ruleRelease) {
            guard ruleRelease > 0 else { return }
            try? await Task.sleep(for: .seconds(Self.ruleLinger))
            if !Task.isCancelled, !touch.isAdjustingLevel { showsRule = false }
        }
        #if DEBUG
        .onAppear {
            if NightArguments.showsLevelRule { showsRule = true }
        }
        #endif
    }

    // MARK: The button

    private var surface: some View {
        Ink.background
            .contentShape(Rectangle())
            .gesture(finger)
            .accessibilityElement()
            .accessibilityLabel(Text(verbatim: spoken.label))
            .accessibilityValue(Text(verbatim: spoken.value))
            .accessibilityHint(Text(verbatim: spoken.hint ?? ""))
            .accessibilityAddTraits(spoken.isButton ? [.isButton, .startsMediaSession] : .isStaticText)
            .accessibilityAction { activate() }
            .accessibilityActions {
                ForEach(Array(spoken.actions.enumerated()), id: \.offset) { _, item in
                    Button(action: item.run) { Text(verbatim: item.name) }
                }
            }
            .accessibilityAction(.escape) {
                if allowsBack { onBack() }
            }
            .accessibilitySortPriority(4)
            .accessibilityIdentifier(allowsBack ? "nightScreen" : "smallHoursScreen")
    }

    private func activate() {
        model.noteBedtimeTouch()
        onTap()
    }

    private var finger: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !swallowsTouch else { return }
                if !touch.isDown {
                    if NightTouch.isGuarded(wokeAt: wokeAt, touchAt: value.time) {
                        swallowsTouch = true
                        return
                    }
                    model.noteBedtimeTouch()
                    touch.begin(at: value.time, level: model.sessionLevel)
                }
                if let level = touch.move(translation: value.translation) {
                    showsRule = true
                    model.setSessionLevel(level)
                    onLevel()
                }
            }
            .onEnded { value in
                if swallowsTouch {
                    swallowsTouch = false
                    return
                }
                let wasLevel = touch.isAdjustingLevel
                switch touch.end(at: value.time, allowsBack: allowsBack) {
                case .tap: onTap()
                case .back: onBack()
                case .nothing: break
                }
                if wasLevel { ruleRelease += 1 }
            }
    }

    // MARK: The level

    /// The vertical rule of the level: 1 pt, 200 pt tall, centred on the
    /// Horizon near the trailing edge. The part in the ink of the night is
    /// the session level. It is there only while a finger moves it, and a
    /// moment after. Never the accent: it is not a layer.
    private func rule(_ layout: NightLayout) -> some View {
        Rectangle()
            .fill(Ink.textNight)
            .frame(width: 1, height: NightAxis.ruleLength(model.sessionLevel))
            .frame(height: NightAxis.travel, alignment: .bottom)
            // What is left of the rule above the level, in `trazo`.
            .background(Ink.rule.frame(width: 1))
            .padding(.top, layout.ruleTop)
            .padding(.trailing, Grid.margin + NightLayout.ruleInset)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(showsRule ? 1 : 0)
            .animation(showsRule ? Motion.fingerInCurve : Motion.contentCurve, value: showsRule)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    /// The level for VoiceOver and Switch Control: adjustable, where the
    /// rule is drawn.
    private func levelElement(_ layout: NightLayout) -> some View {
        Color.clear
            .frame(width: Grid.target, height: NightAxis.travel)
            .padding(.top, layout.ruleTop)
            .padding(.trailing, Grid.margin)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .allowsHitTesting(false)
            .accessibilityElement()
            .accessibilityLabel(Text("ax.volumen"))
            .accessibilityValue(Text(verbatim: Localized.format(
                "a11y.percentFormat", Int64(NightAxis.percent(model.sessionLevel))
            )))
            .accessibilityAdjustableAction { direction in
                model.noteBedtimeTouch()
                model.setSessionLevel(NightAxis.stepped(model.sessionLevel, up: direction == .increment))
                onLevel()
            }
            .accessibilitySortPriority(2)
            .accessibilityIdentifier("nightLevel")
    }
}

/// What VoiceOver says for a full-screen control as one element.
struct FullScreenSpoken {
    var label: String
    var value: String
    var hint: String?
    /// A screen that does nothing when touched is not read as a button.
    var isButton = true
    var actions: [(name: String, run: () -> Void)] = []
}
