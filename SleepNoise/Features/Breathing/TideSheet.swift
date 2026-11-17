import SwiftUI

/// The tide (03 §5, surface 6): "how do I breathe?".
///
/// A sheet on `hoja`. The water line is the hero and, while it guides, the
/// control: dragging it sideways changes the pace. Under it, the state in
/// a word, when it recedes as an hour, the one sentence there is to know,
/// and four rows: the switch, the pace with a human name, the ritual
/// "Descent" and how long before it recedes.
///
/// The tide is Pro. Without access the sheet says so with the word "pro"
/// beside its title and nothing is disabled: the switch asks for the Pro
/// sheet, which only goes up while something may be sold, and goes back to
/// off. At night nothing happens.
struct TideSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var guide: BreathingGuideController
    /// Watched for the hour the night ends, which the line of the tide
    /// never outlasts.
    @ObservedObject private var timer: SleepTimerController

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.scenePhase) private var scenePhase
    /// "breathe in" / "breathe out" are on show: the first three breaths
    /// of a guide. Their timeline exists only then.
    @State private var showsBreathWord = false
    /// The box of the state word and the box of the recede line: 20 pt at
    /// Large. They are there when empty, so nothing below moves.
    @ScaledMetric(relativeTo: .subheadline) private var box: CGFloat = 20

    /// The pace when the finger came down on the line. Kept by reference:
    /// the touch layer reads it in the same event that set it.
    @State private var drag = PaceDrag()
    @State private var isDragging = false
    @State private var paceSteps = 0
    /// "It has receded. The sea goes on.", for ten seconds.
    @State private var showsReceded = false
    @State private var recededTask: Task<Void, Never>?

    init(model: MixerModel) {
        self.model = model
        guide = model.breathing
        timer = model.timer
    }

    /// When the line says the tide recedes: never after the timer's end.
    private var recedesAt: Date? {
        TideSheetText.recedesAt(guideEnd: guide.guideEndsAt, timerEnd: timer.endsAt)
    }

    private var isIncluded: Bool { model.breathingIsIncluded }
    private var settings: BreathingSettings { guide.settings }

    private var status: TideStatus {
        TideStatus.resolve(TideStatus.Input(
            isEnabled: settings.isEnabled,
            isIncluded: isIncluded,
            phase: guide.phase,
            guidingRate: guide.guidingRate,
            chosenRate: settings.breathsPerMinute,
            isPausedInsideWindow: !model.isPlaying && model.pauseCause != nil && guide.hasOpenWindow()
        ))
    }

    var body: some View {
        let status = self.status
        // Read once per draw; the model checks again on the touch.
        let canSell = model.canSell
        VStack(spacing: 0) {
            SheetHeader(
                title: Localized.string("marea.titulo"),
                stateWord: isIncluded ? nil : Localized.string("comun.pro"),
                // On the night page nothing says "requires Pro".
                spokenTitle: isIncluded || phase.isNight
                    ? nil
                    : Localized.string("marea.titulo") + ", " + Localized.string("ax.marea.off.pro")
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    band(status)
                        .padding(.top, Grid.inner)
                    words(status)
                        .padding(.top, Grid.group)
                    Text("marea.instruccion")
                        .step(.secondary)
                        .foregroundStyle(Ink.secondary(phase))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Grid.margin)
                        .padding(.top, Grid.inner)
                    rows(canSell: canSell)
                        .padding(.top, Grid.group)
                }
                .padding(.bottom, Grid.group)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .grafitoSheet(surface: .sheet)
        .sensoryFeedback(.selection, trigger: paceSteps) { _, _ in
            MotionGate.allows(phase)
        }
        .onChange(of: guide.phase) { previous, next in
            noteReceded(from: previous, to: next)
        }
        .onChange(of: model.breathingNote) { _, note in
            // The sheet does not say what the tide did to the ocean (the
            // page does); VoiceOver cannot see the page behind.
            if let note {
                AccessibilityNotification.Announcement(note).post()
            }
        }
        .onDisappear { recededTask?.cancel() }
        .accessibilityAction(.magicTap) { model.togglePlayback() }
    }

    // MARK: Band

    private func band(_ status: TideStatus) -> some View {
        let isGuiding: Bool = {
            if case .guiding = status { return true }
            return false
        }()
        let mode: TideLine.Mode = {
            switch status {
            case .off, .armed: return .off
            case .guiding, .dissolving: return .moving
            case .paused: return .paused
            }
        }()
        return TideLine(
            mode: mode,
            level: { date in
                let now = guide.onGuideClock(date)
                return TideBreath.level(at: now, anchor: guide.anchor, parameters: guide.lastPublished)
                    * (guide.scheduledWeight(now: now) ?? 1)
            },
            isUnderFinger: isDragging
        )
        .overlay {
            // Sideways is the pace; anything else is the sheet's own scroll
            // and dismissal. Only water answers a finger.
            LevelTouchSurface(
                adjusts: isGuiding,
                taps: false,
                onPanBegan: {
                    drag.startRate = guide.settings.breathsPerMinute
                    isDragging = true
                },
                onPanChanged: { translation in
                    guard let start = drag.startRate else { return }
                    setPace(TideSheetText.draggedRate(from: start, translation: Double(translation)))
                },
                onPanEnded: {
                    drag.startRate = nil
                    isDragging = false
                },
                onHold: {},
                onTap: {}
            )
        }
        .padding(.horizontal, Grid.margin)
        .accessibilityHidden(true)
        .overlay {
            // The line for VoiceOver, as an element of its own over the
            // drawing: what it offers changes with the state, and the
            // drawing under it must not be rebuilt for that.
            Color.clear
                .allowsHitTesting(false)
                .accessibilityElement()
                .accessibilityLabel(Text("marea.toggle"))
                .accessibilityValue(Text(verbatim: spokenLine(status)))
                .accessibilityHint(isGuiding ? Text("ax.agua.pista") : Text(verbatim: ""))
                // Adjustable only while it can be adjusted: off, paused or
                // letting go, VoiceOver must not offer a gesture that does
                // nothing.
                .modifier(AdjustablePace(isOn: isGuiding) { step in
                    setPace(settings.breathsPerMinute + step)
                })
                .accessibilityIdentifier("tideLine")
        }
    }

    private func spokenLine(_ status: TideStatus) -> String {
        TideSheetText.spokenLine(
            status: status,
            chosenRate: settings.breathsPerMinute,
            recedesAt: recedesAt
        )
    }

    private func setPace(_ rate: Int) {
        let next = min(BreathingSettings.rateRange.upperBound, max(BreathingSettings.rateRange.lowerBound, rate))
        // Read from the controller, not from this draw of the view: several
        // steps may come inside one gesture.
        let current = guide.settings
        guard next != current.breathsPerMinute else { return }
        var changed = current
        changed.breathsPerMinute = next
        model.updateBreathing(changed)
        paceSteps += 1
    }

    // MARK: Words

    /// The state word with "breathe in" / "breathe out" on its right for
    /// the first three breaths, and under it when the tide recedes.
    private func words(_ status: TideStatus) -> some View {
        VStack(alignment: .leading, spacing: Grid.unit) {
            // Larger text: the two words do not fit one line, so the breath
            // goes under the state.
            let layout = dynamicType.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: Grid.unit))
                : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Grid.inner))
            layout {
                if let word = status.word() {
                    StateWord(text: word, announcesChanges: true)
                }
                if !dynamicType.isAccessibilitySize {
                    Spacer(minLength: 0)
                }
                // Always in the layout: the row is measured by it whether
                // or not it shows, so the state word never shifts when the
                // tide goes from guiding to letting go.
                breathWord(isGuiding: status.isGuiding)
            }
            .frame(maxWidth: .infinity, minHeight: box, alignment: .leading)
            .task(id: BreathWordKey(isGuiding: status.isGuiding, anchor: guide.anchor, rate: guide.lastPublished.rate)) {
                await countBreathWord(isGuiding: status.isGuiding)
            }
            Group {
                if showsReceded {
                    Text("marea.retirada")
                } else {
                    Text(verbatim: TideSheetText.recedes(status: status, at: recedesAt) ?? " ")
                        .accessibilityHidden(!status.showsWater || recedesAt == nil)
                }
            }
            .step(.secondary)
            .monospacedDigit()
            .foregroundStyle(Ink.secondary(phase))
            .frame(maxWidth: .infinity, minHeight: box, alignment: .leading)
            .contentTransition(.opacity)
            .accessibilityIdentifier("tideRecedes")
        }
        .padding(.horizontal, Grid.margin)
    }

    /// Shown for three breaths and gone: there is no need to watch. Not
    /// read by VoiceOver. Its place is always kept; its timeline exists
    /// only for those three breaths and only while the scene is active, so
    /// nothing ticks behind a locked screen (03 §3.7).
    private func breathWord(isGuiding: Bool) -> some View {
        // On the right of the state word; under it, at its edge, when the
        // text is large.
        ZStack(alignment: dynamicType.isAccessibilitySize ? .leading : .trailing) {
            Group {
                Text("marea.fase.inhala")
                Text("marea.fase.exhala")
            }
            .step(.secondary)
            .hidden()
            if isGuiding, showsBreathWord, scenePhase == .active {
                TimelineView(.periodic(from: .now, by: 0.25)) { context in
                    let now = guide.onGuideClock(context.date)
                    let parameters = guide.lastPublished
                    let done = TideBreath.breathsDone(at: now, anchor: guide.anchor, parameters: parameters)
                    let rising = TideBreath.isBreathingIn(at: now, anchor: guide.anchor, parameters: parameters)
                    Text(rising ? "marea.fase.inhala" : "marea.fase.exhala")
                        .step(.secondary)
                        .foregroundStyle(Ink.secondary(phase))
                        .contentTransition(.opacity)
                        .opacity(done < TideBreath.guidedBreaths ? 1 : 0)
                        .animation(Motion.contentCurve, value: rising)
                        .animation(.easeInOut(duration: 0.5), value: done < TideBreath.guidedBreaths)
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// Keeps the words up for the first three breaths of this guide, and
    /// half a second more for them to fade.
    private func countBreathWord(isGuiding: Bool) async {
        let rate = Double(guide.lastPublished.rate)
        guard isGuiding, let anchor = guide.anchor, rate > 0 else {
            showsBreathWord = false
            return
        }
        let end = anchor.addingTimeInterval(Double(TideBreath.guidedBreaths) / rate + 0.5)
        let wait = end.timeIntervalSince(guide.onGuideClock(Date()))
        guard wait > 0 else {
            showsBreathWord = false
            return
        }
        showsBreathWord = true
        #if DEBUG
        // A capture that holds the breath holds its word too.
        if guide.debugHeldBreath != nil { return }
        #endif
        try? await Task.sleep(for: .seconds(wait))
        if !Task.isCancelled { showsBreathWord = false }
    }

    /// Only after the guide ran its course and let go by itself, with the
    /// sea still sounding. Never after the timer's fade, a pause or the
    /// switch: then the sea does not go on, or the person turned it off.
    private func noteReceded(from previous: BreathingPhase, to next: BreathingPhase) {
        guard previous == .dissolving, next == .idle else { return }
        guard model.isPlaying, settings.isEnabled, !guide.hasOpenWindow() else { return }
        showsReceded = true
        recededTask?.cancel()
        recededTask = Task {
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            showsReceded = false
        }
    }

    // MARK: Rows

    private func rows(canSell: Bool) -> some View {
        VStack(spacing: 0) {
            Hairline().padding(.horizontal, Grid.margin)
            switchRow(canSell: canSell)
            menuRow(
                title: "marea.ritmo.fila",
                value: TideSheetText.paceValue(settings.breathsPerMinute),
                spokenValue: TideSheetText.paceOption(settings.breathsPerMinute),
                identifier: "tidePace"
            ) {
                Picker(selection: change(\.breathsPerMinute)) {
                    ForEach(TideSheetText.paceOptions(current: settings.breathsPerMinute), id: \.self) { rate in
                        // The short name: with its tick, the long one
                        // breaks in two lines in the system menu.
                        Text(verbatim: TideSheetText.paceValue(rate))
                            .accessibilityLabel(Text(verbatim: TideSheetText.paceOption(rate)))
                            .tag(rate)
                    }
                } label: {
                    Text("marea.ritmo.fila")
                }
            }
            toggleRow(
                title: "marea.descenso",
                subtitle: TideSheetText.descentDetail(),
                isOn: change(\.descends),
                identifier: "tideDescent"
            )
            menuRow(
                title: "marea.retira",
                value: TideSheetText.recedesAfterValue(settings.guideMinutes),
                spokenValue: TideSheetText.recedesAfterValue(settings.guideMinutes),
                identifier: "tideRecedesAfter"
            ) {
                Picker(selection: change(\.guideMinutes)) {
                    ForEach(BreathingSettings.durationChoices, id: \.self) { minutes in
                        Text(verbatim: TideSheetText.recedesAfterValue(minutes)).tag(minutes)
                    }
                } label: {
                    Text("marea.retira")
                }
            }
        }
    }

    /// One setting of the tide, written through the model so a running
    /// guide follows it.
    private func change<Value: Equatable>(_ keyPath: WritableKeyPath<BreathingSettings, Value>) -> Binding<Value> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { value in
                guard settings[keyPath: keyPath] != value else { return }
                var changed = settings
                changed[keyPath: keyPath] = value
                model.updateBreathing(changed)
            }
        )
    }

    /// The switch of the tide. With access the system says on or off.
    /// Without it the switch says why it stays off, and offers Pro only
    /// while something may be sold; on the night page it just says off.
    @ViewBuilder private func switchRow(canSell: Bool) -> some View {
        let row = toggleRow(
            title: "marea.toggle",
            subtitle: nil,
            isOn: Binding(
                get: { settings.isEnabled && isIncluded },
                set: { model.setBreathingEnabled($0, startsSound: true) }
            ),
            identifier: "tideSwitch"
        )
        if isIncluded {
            // Turning it on over silence starts the night: say so.
            row.accessibilityHint(
                settings.isEnabled || model.isPlaying ? Text(verbatim: "") : Text("ax.marea.pista")
            )
        } else if phase.isNight {
            row
        } else if canSell {
            row
                .accessibilityValue(Text("ax.marea.off.pro"))
                .accessibilityHint(Text("ax.marea.pista.pro"))
        } else {
            row.accessibilityValue(Text("ax.marea.off.pro"))
        }
    }

    private func toggleRow(title: String, subtitle: String?, isOn: Binding<Bool>, identifier: String) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: Grid.unit / 2) {
                Text(verbatim: Localized.string(title))
                    .step(.row)
                    .foregroundStyle(Ink.primary(phase))
                if let subtitle {
                    Text(verbatim: subtitle)
                        .step(.secondary)
                        .foregroundStyle(Ink.secondary(phase))
                }
            }
            .multilineTextAlignment(.leading)
        }
        .toggleStyle(GrafitoToggleStyle())
        .padding(.vertical, Grid.unit * 3)
        .padding(.horizontal, Grid.margin)
        .frame(minHeight: Grid.row(subtitle: subtitle != nil, dynamicType: dynamicType))
        .overlay(alignment: .bottom) {
            Hairline().padding(.horizontal, Grid.margin)
        }
        .accessibilityIdentifier(identifier)
    }

    /// A setting of the tide with a few options, in the system's menu.
    private func menuRow<Options: View>(
        title: String,
        value: String,
        spokenValue: String,
        identifier: String,
        @ViewBuilder options: () -> Options
    ) -> some View {
        MenuRow(
            title: Localized.string(title),
            value: value,
            spokenValue: PageStatus.spoken(spokenValue),
            options: options
        )
        .accessibilityIdentifier(identifier)
    }
}

/// Where a drag of the water line began.
private final class PaceDrag {
    var startRate: Int?
}

/// What restarts the count of the three first breaths.
private struct BreathWordKey: Equatable {
    var isGuiding: Bool
    var anchor: Date?
    var rate: Float
}

/// The adjustable action of the water line, only while it can be adjusted.
private struct AdjustablePace: ViewModifier {
    var isOn: Bool
    var step: (Int) -> Void

    func body(content: Content) -> some View {
        if isOn {
            content.accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: step(1)
                case .decrement: step(-1)
                @unknown default: break
                }
            }
        } else {
            content
        }
    }
}
