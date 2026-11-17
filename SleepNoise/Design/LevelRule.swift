import SwiftUI
import UIKit

/// The level row (03 §4.2, anatomy in 05 §2.0): the row is the control.
///
/// Name and subtitle on one line, the value on the right, and the level line
/// from margin to margin: 2 pt of ink up to the level, 1 pt of track beyond.
/// Dragging sideways anywhere on the row sets the level, relative to where it
/// was. A tap does nothing: silencing a layer by accident at three in the
/// morning is the one thing this row must never do.
///
/// Under the finger the line is 3 pt in the accent, a `grafito` track shows
/// behind the row and the value grows in place. The accent is there only
/// while the finger is; the Horizon gives it up meanwhile.
///
/// A locked row (a Pro layer without access) keeps its saved level, shows
/// "pro" where the value would be and does not move. Whether a tap may open
/// the Pro sheet is the caller's decision: at night it passes no action.
struct LevelRule: View {
    /// Stable identifier of the layer, for the accent arbiter.
    let id: String
    let name: String
    let subtitle: String
    @Binding var level: Float
    var isLocked = false
    /// Tap on a locked row. Nil means the tap does nothing (night).
    var onLockedTap: (() -> Void)?

    @Environment(\.indexArbiter) private var arbiter
    @Environment(\.nightPhase) private var phase

    @State private var drag = LevelDrag()
    @State private var isDragging = false
    @State private var columnWidth: CGFloat = 353
    @State private var showsSlider = false
    @State private var sliderTouch = 0
    @State private var zeroCrossings = 0
    @State private var maxArrivals = 0

    private var speech: LevelRuleSpeech {
        LevelRuleSpeech(name: name, subtitle: subtitle, level: level, isLocked: isLocked)
    }

    var body: some View {
        VStack(spacing: 0) {
            touchArea
                .modifier(LevelRuleAccessibility(
                    speech: speech,
                    level: $level,
                    isLocked: isLocked,
                    onLockedTap: onLockedTap,
                    onSlider: { showsSlider.toggle() }
                ))
                .overlay(alignment: .bottom) {
                    // Above the touch layer, so the slider gets its own
                    // touches, and outside the row's accessibility element,
                    // so assistive technologies can reach it.
                    if showsSlider {
                        fineSlider
                    }
                }
                .animation(Motion.contentCurve, value: showsSlider)
            // Dead channel: no gesture starts here, so a scroll always has
            // somewhere to begin between two rows.
            Color.clear.frame(height: Grid.layerChannel)
        }
        .sensoryFeedback(.selection, trigger: zeroCrossings) { _, _ in
            MotionGate.allows(phase)
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: maxArrivals) { _, _ in
            MotionGate.allows(phase)
        }
    }

    // MARK: Touch area

    private var touchArea: some View {
        LevelRuleFace(
            name: name,
            subtitle: subtitle,
            level: level,
            mode: faceMode,
            onColumnWidth: { columnWidth = $0 }
        )
        .overlay {
            // An included row has no tap at all: a tap does nothing.
            LevelTouchSurface(
                adjusts: !isLocked,
                taps: isLocked && onLockedTap != nil,
                onPanBegan: beginDrag,
                onPanChanged: moveDrag,
                onPanEnded: endDrag,
                onHold: { if !isDragging { showsSlider = true } },
                onTap: { onLockedTap?() }
            )
            .accessibilityHidden(true)
        }
        .animation(isDragging ? Motion.fingerInCurve : Motion.fingerOutCurve, value: isDragging)
    }

    private var faceMode: LevelRuleFace.Mode {
        if isLocked { return .locked }
        if showsSlider { return .fineSlider }
        if isDragging { return .underFinger(accent: arbiter.owns(.finger(id))) }
        return .rest
    }

    // MARK: Gestures

    /// Sideways drag, already past the 30° cone (`LevelTouchSurface`).
    /// Holding still and then dragging without lifting lands here too: the
    /// slider steps aside and the drag carries on from the current level.
    private func beginDrag() {
        drag = LevelDrag()
        isDragging = true
        showsSlider = false
        arbiter.claim(.finger(id))
    }

    private func moveDrag(_ translationX: CGFloat) {
        guard isDragging else { return }
        let travel = LevelMath.travel(columnWidth: columnWidth)
        let next = drag.update(translationX: translationX, level: level, travel: travel)
        if (level <= 0) != (next <= 0) { zeroCrossings += 1 }
        if next >= 1, level < 1 { maxArrivals += 1 }
        level = next
    }

    /// Also reached when the system cancels the gesture.
    private func endDrag() {
        guard isDragging else { return }
        isDragging = false
        arbiter.release(.finger(id))
        // Whole percents are what is kept.
        level = LevelMath.quantized(level)
    }

    // MARK: Fine slider

    /// The system slider takes the place of the level line, centred on it.
    /// Plain ink, never the accent: it is not "the live thing". It leaves on
    /// its own five seconds after the last change. With VoiceOver or Switch
    /// Control running it stays until the row's slider action is used again.
    private var fineSlider: some View {
        Slider(
            value: Binding(
                get: { LevelMath.clamped(level) },
                set: { next in
                    level = LevelMath.quantized(next)
                    sliderTouch += 1
                }
            ),
            in: 0...1
        )
        .tint(Ink.primary(phase))
        .frame(height: Grid.target)
        .padding(.horizontal, Grid.margin)
        .padding(.bottom, -(Grid.target / 2 - Grid.unit * 3))
        .accessibilityLabel(Text(verbatim: Localized.format("capas.deslizador", name)))
        .transition(.opacity)
        .task(id: sliderTouch) {
            guard !UIAccessibility.isVoiceOverRunning, !UIAccessibility.isSwitchControlRunning else { return }
            try? await Task.sleep(for: .seconds(LevelRule.sliderDismiss))
            if !Task.isCancelled { showsSlider = false }
        }
    }

    /// Seconds the fine slider stays without a finger on it.
    static let sliderDismiss: TimeInterval = 5
}

/// The drawing of a level row for one state. No gestures and no state of its
/// own: the same inputs always give the same row.
struct LevelRuleFace: View {
    enum Mode: Equatable {
        /// 2 pt of ink up to the level, the value in small figures.
        case rest
        /// A finger is dragging: 3 pt line, `grafito` track, value grown in
        /// place. The line is the accent only if this row owns it.
        case underFinger(accent: Bool)
        /// The system slider is standing in for the line.
        case fineSlider
        /// A Pro layer without access: secondary ink, "pro", track only.
        case locked
    }

    var name: String
    var subtitle: String
    var level: Float
    var mode = Mode.rest
    /// Reports the width of the level line, which the drag needs.
    var onColumnWidth: (CGFloat) -> Void = { _ in }

    @Environment(\.nightPhase) private var phase
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes
    /// Height of the label line: 22 pt at Large, growing with the text.
    @ScaledMetric(relativeTo: .headline) private var labelLine: CGFloat = 22

    private var percent: Int { LevelMath.percent(level) }
    private var isLocked: Bool { mode == .locked }
    private var showsSlider: Bool { mode == .fineSlider }
    private var isUnderFinger: Bool {
        if case .underFinger = mode { return true }
        return false
    }
    private var ownsAccent: Bool { mode == .underFinger(accent: true) }

    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit * 2) {
            ViewThatFits(in: .horizontal) {
                inlineLabels
                stackedLabels
            }
            levelLine
                .opacity(showsSlider ? 0 : 1)
        }
        .padding(.top, Grid.unit * 3)
        .padding(.bottom, Grid.unit * 2 + 2)
        .padding(.horizontal, Grid.margin)
        .frame(minHeight: Grid.layerTouch, alignment: .top)
        .background {
            // The only transient fill of the system: it lasts as long as the
            // gesture and has square corners.
            Rectangle()
                .fill(Ink.relief)
                .padding(.vertical, 6)
                .padding(.horizontal, Grid.margin)
                .opacity(isUnderFinger ? 1 : 0)
        }
    }

    private var nameColor: Color {
        if showsSlider { return Ink.text3 }
        return isLocked ? Ink.secondary(phase) : Ink.primary(phase)
    }

    private var subtitleColor: Color {
        showsSlider ? Ink.text3 : Ink.secondary(phase)
    }

    private var inlineLabels: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: name)
                .step(.row)
                .foregroundStyle(nameColor)
            Text(verbatim: " · " + subtitle)
                .step(.secondary)
                .foregroundStyle(subtitleColor)
            Spacer(minLength: Grid.inner)
            trailing
        }
        .lineLimit(1)
        .frame(minHeight: labelLine)
    }

    /// Larger text: the subtitle drops to a line of its own.
    private var stackedLabels: some View {
        VStack(alignment: .leading, spacing: Grid.unit) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(verbatim: name)
                    .step(.row)
                    .foregroundStyle(nameColor)
                Spacer(minLength: Grid.inner)
                trailing
            }
            .frame(minHeight: labelLine)
            Text(verbatim: subtitle)
                .step(.secondary)
                .foregroundStyle(subtitleColor)
        }
    }

    @ViewBuilder private var trailing: some View {
        if isLocked {
            Text(verbatim: LevelRuleSpeech(name: name, subtitle: subtitle, level: level, isLocked: true).lockedWord)
                .step(.stateWord)
                .foregroundStyle(Ink.secondary(phase))
        } else if (percent > 0 || isUnderFinger) && !showsSlider {
            // It grows in place, at the margin, never floating over the
            // finger; room for three digits so 9 to 10 moves nothing.
            Text(verbatim: "\(percent)")
                .step(isUnderFinger ? .value : .data)
                .foregroundStyle(isUnderFinger ? Ink.primary(phase) : Ink.secondary(phase))
                .underline(buttonShapes && !isUnderFinger, color: Ink.secondary(phase))
                .frame(minWidth: Grid.unit * 9, alignment: .trailing)
        }
    }

    private var levelLine: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Ink.text3)
                    .frame(height: 1)
                if !isLocked {
                    Rectangle()
                        .fill(ownsAccent ? Ink.accent(phase) : Ink.primary(phase))
                        .frame(width: width * CGFloat(LevelMath.clamped(level)), height: isUnderFinger ? 3 : 2)
                }
            }
            .frame(height: Grid.unit, alignment: .center)
            .onAppear { onColumnWidth(width) }
            .onChange(of: width) { _, next in onColumnWidth(next) }
        }
        .frame(height: Grid.unit)
    }
}

/// VoiceOver sees the row as one adjustable control: name and subtitle, the
/// level as a spoken percentage, steps of 5 %. A locked row is not
/// adjustable; by day it is a button that shows Pro, at night it is just text.
private struct LevelRuleAccessibility: ViewModifier {
    let speech: LevelRuleSpeech
    @Binding var level: Float
    let isLocked: Bool
    let onLockedTap: (() -> Void)?
    let onSlider: () -> Void

    func body(content: Content) -> some View {
        if isLocked {
            if let onLockedTap {
                base(content)
                    .accessibilityHint(Text("ax.capa.pro.pista"))
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { onLockedTap() }
                    .accessibilityAction(named: Text("ax.accion.ver_pro")) { onLockedTap() }
            } else {
                base(content)
            }
        } else {
            base(content)
                .accessibilityHint(Text("ax.capa.pista"))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: level = LevelMath.stepped(level, up: true)
                    case .decrement: level = LevelMath.stepped(level, up: false)
                    @unknown default: break
                    }
                }
                .accessibilityAction(named: Text("ax.accion.silenciar")) { level = 0 }
                .accessibilityAction(named: Text("ax.accion.maximo")) { level = 1 }
                .accessibilityAction(named: Text("ax.accion.subir")) { level = LevelMath.stepped(level, up: true) }
                .accessibilityAction(named: Text("ax.accion.bajar")) { level = LevelMath.stepped(level, up: false) }
                .accessibilityAction(named: Text("ax.accion.deslizador")) { onSlider() }
        }
    }

    private func base(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: speech.label))
            .accessibilityValue(Text(verbatim: speech.value))
    }
}

#if DEBUG
private struct LevelRulePreviewHost: View {
    @State private var rain: Float = 0.3
    @State private var pink: Float = 0
    @State private var ocean: Float = 0.5

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LevelRule(id: "rain", name: "Rain", subtitle: "drops on a steady bed", level: $rain)
                LevelRule(id: "pink", name: "Pink", subtitle: "soft and balanced", level: $pink)
                LevelRule(
                    id: "ocean",
                    name: "Ocean",
                    subtitle: "swells that come and go",
                    level: $ocean,
                    isLocked: true,
                    onLockedTap: {}
                )
            }
        }
        .grafitoRoot()
    }
}

#Preview("Level row") {
    LevelRulePreviewHost()
}
#endif
