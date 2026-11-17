import SwiftUI
import UIKit

/// The level row (03 §4.2, anatomy in 05 §2.0): the row is the control.
///
/// Name and subtitle on one line, the value on the right, and the level line
/// from margin to margin: 2 pt of ink up to the level, 1 pt of track beyond.
/// At the accessibility text sizes name, subtitle and value stack on the left.
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
///
/// A waiting row (an included layer above zero while six others sound) is
/// drawn in secondary ink with its value and no level ink: it keeps its
/// level and does not sound. It still moves under a finger like any other.
struct LevelRule: View {
    /// Stable identifier of the layer, for the accent arbiter.
    let id: String
    let name: String
    let subtitle: String
    @Binding var level: Float
    var isLocked = false
    /// The layer keeps its level and does not sound: six others do.
    var isWaiting = false
    /// A few words in the dead channel under the row ("Six at once"). They
    /// fade in and out in place; the channel never answers a touch.
    var channelNote: String?
    /// Tap on a locked row. Nil means the tap does nothing (night).
    var onLockedTap: (() -> Void)?
    /// A drag began (true) or ended (false). The end comes after the last
    /// level is written.
    var onDragActive: ((Bool) -> Void)?

    @Environment(\.indexArbiter) private var arbiter
    @Environment(\.nightPhase) private var phase
    @Environment(\.fineSliderDismissal) private var dismissal
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @Environment(\.accessibilitySwitchControlEnabled) private var switchControl

    @State private var drag = LevelDrag()
    @State private var isDragging = false
    @State private var columnWidth: CGFloat = 353
    @State private var showsSlider = false
    @State private var sliderTouch = 0
    @State private var sliderIsHeld = false
    @State private var zeroCrossings = 0
    @State private var maxArrivals = 0

    /// On the night page nothing says "requires Pro" (copy guide §3): a
    /// locked row is named like any other and its value says it is silent.
    private var speech: LevelRuleSpeech {
        LevelRuleSpeech(
            name: name, subtitle: subtitle, level: level, isLocked: isLocked, isWaiting: isWaiting,
            namesPro: !phase.isNight
        )
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
                .onChange(of: dismissal) { _, _ in showsSlider = false }
                .onChange(of: showsSlider) { _, shown in
                    if !shown { sliderIsHeld = false }
                }
                // A row taken away with a finger on it still ends its drag.
                .onDisappear { endDrag() }
                #if DEBUG
                .onAppear {
                    // A capture draws this row as it is under a finger.
                    if PageArguments.heldLayer?.rawValue == id { beginDrag() }
                }
                #endif
            // Dead channel: no gesture starts here, so a scroll always has
            // somewhere to begin between two rows.
            channel
        }
        .sensoryFeedback(.selection, trigger: zeroCrossings) { _, _ in
            MotionGate.allows(phase)
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: maxArrivals) { _, _ in
            MotionGate.allows(phase)
        }
    }

    /// The channel keeps its height whatever it says, so the row below
    /// never moves.
    private var channel: some View {
        Text(verbatim: channelNote ?? " ")
            .step(.secondary)
            .foregroundStyle(Ink.secondary(phase))
            .lineLimit(1)
            .opacity(channelNote == nil ? 0 : 1)
            .animation(Motion.contentCurve, value: channelNote)
            .frame(maxWidth: .infinity, minHeight: Grid.layerChannel, alignment: .leading)
            .padding(.horizontal, Grid.margin)
            .accessibilityHidden(channelNote == nil)
            .allowsHitTesting(false)
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
            // An included row has no tap at all: a tap does nothing, except
            // put the slider away when it is out.
            LevelTouchSurface(
                adjusts: !isLocked,
                taps: showsSlider || (isLocked && onLockedTap != nil),
                coneTangent: LevelDrag.coneTangent(night: phase.isNight),
                onPanBegan: beginDrag,
                onPanChanged: moveDrag,
                onPanEnded: endDrag,
                onHold: { if !isDragging { showsSlider = true } },
                onTap: {
                    if showsSlider {
                        showsSlider = false
                    } else {
                        onLockedTap?()
                    }
                }
            )
            .accessibilityHidden(true)
        }
        .animation(isDragging ? Motion.fingerInCurve : Motion.fingerOutCurve, value: isDragging)
    }

    private var faceMode: LevelRuleFace.Mode {
        if isLocked { return .locked }
        if showsSlider { return .fineSlider }
        if isDragging { return .underFinger(accent: arbiter.owns(.finger(id))) }
        return isWaiting ? .waiting : .rest
    }

    // MARK: Gestures

    /// Sideways drag, already inside the cone (`LevelTouchSurface`).
    /// Holding still and then dragging without lifting lands here too: the
    /// slider steps aside and the drag carries on from the current level.
    private func beginDrag() {
        // One beginning per drag, so every one has its end.
        let wasDragging = isDragging
        drag = LevelDrag()
        isDragging = true
        showsSlider = false
        arbiter.claim(.finger(id))
        if !wasDragging { onDragActive?(true) }
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
        onDragActive?(false)
    }

    // MARK: Fine slider

    /// The system slider takes the place of the level line, centred on it.
    /// Plain ink, never the accent: it is not "the live thing".
    ///
    /// It leaves five seconds after the finger does, at once with a tap on
    /// the row, and when the container says so (`fineSliderDismissal`). With
    /// VoiceOver or Switch Control running nothing times out: it stays until
    /// the escape gesture on it, or the row's slider action again.
    private var fineSlider: some View {
        InkSlider(
            level: Binding(
                get: { LevelMath.clamped(level) },
                set: { next in
                    level = LevelMath.quantized(next)
                    sliderTouch += 1
                }
            ),
            isNight: phase.isNight,
            label: Localized.format("capas.deslizador", name),
            onHeld: { sliderIsHeld = $0 },
            onEscape: { showsSlider = false }
        )
        .frame(height: Grid.target)
        .padding(.horizontal, Grid.margin)
        .padding(.bottom, -(Grid.target / 2 - Grid.unit * 3))
        .transition(.opacity)
        .task(id: SliderWatch(touch: sliderTouch, isHeld: sliderIsHeld, isAssisted: voiceOver || switchControl)) {
            guard !sliderIsHeld, !voiceOver, !switchControl else { return }
            try? await Task.sleep(for: .seconds(LevelRule.sliderDismiss))
            if !Task.isCancelled { showsSlider = false }
        }
    }

    /// Seconds the fine slider stays without a finger on it.
    static let sliderDismiss: TimeInterval = 5
}

/// Everything that restarts the five seconds of the fine slider.
private struct SliderWatch: Hashable {
    var touch: Int
    var isHeld: Bool
    var isAssisted: Bool
}

/// The system slider in Grafito inks: thumb and filled track in the text ink
/// of the phase, the rest of the track in `texto3`. UIKit's, because SwiftUI's
/// `Slider` only lets the filled part be tinted.
private struct InkSlider: UIViewRepresentable {
    @Binding var level: Float
    var isNight: Bool
    var label: String
    /// A finger went down on the slider, or left it.
    var onHeld: (Bool) -> Void
    var onEscape: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> EscapableSlider {
        let slider = EscapableSlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        let coordinator = context.coordinator
        slider.addTarget(coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        slider.addTarget(coordinator, action: #selector(Coordinator.down), for: .touchDown)
        slider.addTarget(
            coordinator,
            action: #selector(Coordinator.up),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
        )
        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        slider.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return slider
    }

    func updateUIView(_ slider: EscapableSlider, context: Context) {
        context.coordinator.slider = self
        slider.onEscape = onEscape
        if !slider.isTracking, slider.value != level {
            slider.value = level
        }
        let ink = (isNight ? InkTokens.textNight : InkTokens.text).uiColor
        slider.thumbTintColor = ink
        slider.minimumTrackTintColor = ink
        slider.maximumTrackTintColor = InkTokens.text3.uiColor
        slider.accessibilityLabel = label
    }

    final class Coordinator: NSObject {
        var slider: InkSlider

        init(_ slider: InkSlider) {
            self.slider = slider
        }

        @objc func changed(_ sender: UISlider) {
            slider.level = sender.value
        }

        @objc func down() {
            slider.onHeld(true)
        }

        @objc func up() {
            slider.onHeld(false)
        }
    }
}

/// A slider VoiceOver can put away with the escape gesture.
private final class EscapableSlider: UISlider {
    var onEscape: (() -> Void)?

    override func accessibilityPerformEscape() -> Bool {
        guard let onEscape else { return false }
        onEscape()
        return true
    }
}

private struct FineSliderDismissalKey: EnvironmentKey {
    static let defaultValue = 0
}

extension EnvironmentValues {
    /// A counter the container of level rows bumps on a touch outside them
    /// (the page, the Layers sheet): any row showing its slider puts it away.
    var fineSliderDismissal: Int {
        get { self[FineSliderDismissalKey.self] }
        set { self[FineSliderDismissalKey.self] = newValue }
    }
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
        /// The system slider is standing in for the line. Name, subtitle and
        /// value stay as they were.
        case fineSlider
        /// A Pro layer without access: secondary ink, "pro", track only.
        case locked
        /// Six other layers sound: secondary ink, the value it keeps,
        /// track only. Same anatomy as `rest`.
        case waiting
    }

    var name: String
    var subtitle: String
    var level: Float
    var mode = Mode.rest
    /// Reports the width of the level line, which the drag needs.
    var onColumnWidth: (CGFloat) -> Void = { _ in }

    @Environment(\.nightPhase) private var phase
    @Environment(\.inkSurface) private var surface
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes
    /// Height of the label line: 22 pt at Large, growing with the text.
    @ScaledMetric(relativeTo: .headline) private var labelLine: CGFloat = 22
    /// Room for three digits of the value at its largest, under the finger.
    /// Always kept, so the labels never reflow when the value appears.
    @ScaledMetric(relativeTo: .headline) private var valueSlot: CGFloat = 36

    private var percent: Int { LevelMath.percent(level) }
    private var isLocked: Bool { mode == .locked }
    /// Nothing of this row sounds: no ink on its line.
    private var isMuted: Bool { mode == .locked || mode == .waiting }
    private var showsSlider: Bool { mode == .fineSlider }
    private var isUnderFinger: Bool {
        if case .underFinger = mode { return true }
        return false
    }
    private var ownsAccent: Bool { mode == .underFinger(accent: true) }

    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit * 2) {
            // The anatomy depends on the text size alone, never on the level
            // or on the gesture: nothing may move under a finger.
            if dynamicType.isAccessibilitySize {
                stackedLabels
            } else {
                inlineLabels
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
                .fill(Ink.relief(on: surface))
                .padding(.vertical, 6)
                .padding(.horizontal, Grid.margin)
                .opacity(isUnderFinger ? 1 : 0)
        }
    }

    private var nameColor: Color {
        isMuted ? Ink.secondary(phase) : Ink.primary(phase)
    }

    private var subtitleColor: Color { Ink.secondary(phase) }

    /// Name and subtitle as one paragraph in two steps, so a long pair wraps
    /// to a second line instead of changing the anatomy of the row.
    private var label: AttributedString {
        var name = AttributedString(self.name)
        name.font = TypeStep.row.font(phase, dynamicType: dynamicType)
        name.foregroundColor = nameColor
        var rest = AttributedString(" · " + subtitle)
        rest.font = TypeStep.secondary.font(phase, dynamicType: dynamicType)
        rest.foregroundColor = subtitleColor
        return name + rest
    }

    /// Up to xxxLarge: name and subtitle on the left, the value at the margin.
    private var inlineLabels: some View {
        HStack(alignment: .firstTextBaseline, spacing: Grid.inner) {
            Text(label)
                .step(.row)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing(alignment: .trailing)
        }
        .frame(minHeight: labelLine)
    }

    /// Accessibility sizes: name, subtitle and value in a column on the left,
    /// the line underneath (03 §4.2).
    private var stackedLabels: some View {
        VStack(alignment: .leading, spacing: Grid.unit) {
            Text(verbatim: name)
                .step(.row)
                .foregroundStyle(nameColor)
            Text(verbatim: subtitle)
                .step(.secondary)
                .foregroundStyle(subtitleColor)
            trailing(alignment: .leading)
                .frame(minHeight: labelLine)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The value, or "pro". An included row always keeps the room of its
    /// value, shown or not; it grows in place, at the margin, never floating
    /// over the finger.
    @ViewBuilder
    private func trailing(alignment: Alignment) -> some View {
        if isLocked {
            Text(verbatim: LevelRuleSpeech(name: name, subtitle: subtitle, level: level, isLocked: true).lockedWord)
                .step(.stateWord)
                .foregroundStyle(Ink.secondary(phase))
        } else {
            // From AX3 the value at rest is already the size it has under
            // the finger (04 §5d).
            let isLarge = isUnderFinger || dynamicType >= .accessibility3
            Text(verbatim: "\(percent)")
                .step(isLarge ? .value : .data)
                .foregroundStyle(isUnderFinger ? Ink.primary(phase) : Ink.secondary(phase))
                .underline(buttonShapes && !isUnderFinger, color: Ink.secondary(phase))
                .lineLimit(1)
                .frame(minWidth: valueSlot, alignment: alignment)
                .opacity(percent > 0 || isUnderFinger ? 1 : 0)
        }
    }

    private var levelLine: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Ink.text3)
                    .frame(height: 1)
                if !isMuted {
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
                .accessibilityAction(named: Text("ax.nivel.subir")) { level = LevelMath.stepped(level, up: true) }
                .accessibilityAction(named: Text("ax.nivel.bajar")) { level = LevelMath.stepped(level, up: false) }
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
