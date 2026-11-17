import SwiftUI

/// The timer (03 §5, surface 8): "when does it go quiet?".
///
/// A sheet on `hoja` with the two ways a night ends by itself, and none:
/// "Until I sleep" (a length, with a fade at the end), "Blanket" (an hour of
/// the clock) and "Off". The whole timer is free (C03): no row here knows
/// about access and the word "pro" does not appear.
///
/// There is no "Done": what the sheet shows is what holds. While a night is
/// being counted, a block above the list says what is left as a figure, when
/// it ends as an hour, and offers "+15 min". The control of the chosen mode
/// (the wheel of lengths, or the system's time picker) opens under its own
/// row, so no row of the list ever moves.
struct TimerSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var timer: SleepTimerController

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.calendar) private var calendar

    @State private var detent = PresentationDetent.medium
    /// The wheel or the time picker is open under its row.
    @State private var showsControl: Bool
    /// The block above the list. Decided once, when the sheet opens: a
    /// night was being counted then. It never comes or goes while the sheet
    /// is open, so no row moves under a finger (AGENTS §5.9); only its
    /// content changes. A count begun from this sheet is read on the page
    /// behind it, as an hour, and here the next time it opens.
    @State private var showsHead: Bool
    @State private var modeChanges = 0
    @State private var extensions = 0

    /// Height of the system's wheels.
    private static let wheelHeight: CGFloat = 216
    /// Width of the system's time wheels, which do not stretch: the wheel
    /// of lengths takes the same.
    private static let wheelWidth: CGFloat = 320

    init(model: MixerModel) {
        self.model = model
        timer = model.timer
        let showsHead = model.canExtendTimer
        _showsHead = State(initialValue: showsHead)
        // With the block above the list the half sheet cuts the last row
        // and hides the note, which is there to be read.
        var opensLarge = showsHead
        #if DEBUG
        _showsControl = State(initialValue: PageArguments.opensTimerControl)
        opensLarge = opensLarge || PageArguments.opensTimerControl
        #else
        _showsControl = State(initialValue: false)
        #endif
        _detent = State(initialValue: opensLarge ? .large : .medium)
    }

    /// The minutes of the block change when a whole minute is left: the
    /// timer publishes nothing meanwhile, so the block reads it again then,
    /// only while the sheet is on screen.
    private var minuteSchedule: PeriodicTimelineSchedule {
        let anchor = timer.endsAt.map { end -> Date in
            let minutes = (max(0, end.timeIntervalSinceNow) / 60).rounded(.up) + 1
            return end.addingTimeInterval(-minutes * 60)
        }
        return .periodic(from: anchor ?? Date(timeIntervalSinceReferenceDate: 0), by: 60)
    }

    private var input: TimerSheetText.Input { TimerSheetText.Input(timer) }
    private var choice: TimerChoice { timer.choice }
    private var hour: Date {
        TimerSheetText.blanketHour(choice, on: Date(), calendar: calendar)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: Localized.string("temporizador.titulo"))
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if showsHead { head }
                    modeRow(
                        .untilAsleep,
                        title: "temporizador.dormirme",
                        detail: TimerSheetText.asleepDetail(choice)
                    )
                    modeRow(
                        .blanket,
                        title: "temporizador.manto",
                        detail: TimerSheetText.blanketDetail(hour: hour)
                    )
                    EditorialRow(
                        title: Localized.string("temporizador.apagado"),
                        isSelected: choice.mode == .off,
                        isQuiet: choice.mode != .off
                    ) {
                        choose(.off)
                    }
                    .accessibilityIdentifier("timerOff")
                    controlRow
                    if showsControl, choice.mode != .off {
                        control.transition(.opacity)
                    }
                    Text("temporizador.nota")
                        .step(.note)
                        .foregroundStyle(Ink.secondary(phase))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Grid.margin)
                        .padding(.top, Grid.unit * 3)
                        .padding(.bottom, Grid.inner)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .grafitoSheet(surface: .sheet, detents: [.medium, .large], selection: $detent)
        .sensoryFeedback(.selection, trigger: modeChanges) { _, _ in
            MotionGate.allows(phase)
        }
        .sensoryFeedback(.selection, trigger: extensions) { _, _ in
            MotionGate.allows(phase)
        }
        .onAppear {
            // Read once more as the sheet comes up (a night may have begun
            // between its being built and its being shown) and never again.
            showsHead = model.canExtendTimer
            // Larger text does not fit the half sheet, nor does the block.
            if showsHead || dynamicType >= .xLarge { detent = .large }
        }
        .accessibilityAction(.magicTap) { model.togglePlayback() }
    }

    // MARK: Head

    /// What is left, when it ends, and fifteen minutes more. The lines keep
    /// their room when the night is over, so the list does not jump.
    private var head: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimelineView(minuteSchedule) { _ in
                let input = self.input
                let head = model.isSmallHours ? nil : TimerSheetText.head(input)
                let dipIsAhead = input.blanketDipIsAhead
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: head.map { TimerSheetText.figure($0) } ?? " ")
                        .step(.figureSmall)
                        .foregroundStyle(Ink.primary(phase))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(verbatim: head.map { TimerSheetText.line($0, dipIsAhead: dipIsAhead) } ?? " ")
                        .step(.secondary)
                        .monospacedDigit()
                        .foregroundStyle(Ink.secondary(phase))
                        .contentTransition(.opacity)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Grid.margin)
                .padding(.top, Grid.inner)
                .padding(.bottom, Grid.unit * 3)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(
                    verbatim: head.map { TimerSheetText.spoken($0, dipIsAhead: dipIsAhead) } ?? ""
                ))
                .accessibilityHidden(head == nil)
                .accessibilityIdentifier("timerCount")
            }

            HairlineAction(title: Localized.string("comun.mas15"), isEnabled: model.canExtendTimer) {
                guard model.extendTimer() else { return }
                extensions += 1
                if let words = TimerSheetText.extensionAnnouncement(TimerSheetText.Input(timer)) {
                    AccessibilityNotification.Announcement(words).post()
                }
            }
            .accessibilityLabel(Text("ax.mas15"))
            // Voice Control: the words on screen first.
            .accessibilityInputLabels([Text("comun.mas15"), Text("ax.mas15")])
            .accessibilityIdentifier("timerExtend")
        }
    }

    // MARK: Modes

    private func modeRow(_ mode: TimerMode, title: String, detail: String) -> some View {
        EditorialRow(
            title: Localized.string(title),
            subtitle: detail,
            isSelected: choice.mode == mode
        ) {
            choose(mode)
        }
        .accessibilityIdentifier("timerMode.\(mode.rawValue)")
    }

    /// The row is the choice: there is nothing to confirm. Choosing the mode
    /// that is already chosen changes nothing, so a night that is counting
    /// is not started over by a second tap.
    private func choose(_ mode: TimerMode) {
        guard choice.mode != mode else { return }
        model.chooseTimer(choice.with(mode: mode))
        modeChanges += 1
        if mode == .off {
            withAnimation(Motion.contentCurve) { showsControl = false }
        }
    }

    // MARK: Control

    /// Always there, under the three modes: "Length · 45 min" or
    /// "Time · 07:00". With the timer off it is an empty row of the same
    /// height.
    @ViewBuilder private var controlRow: some View {
        let control = TimerSheetText.control(choice, hour: hour)
        EditorialRow(
            title: control?.title ?? " ",
            value: control?.value,
            valueIsDatum: true
        ) {
            if detent != .large { detent = .large }
            withAnimation(Motion.contentCurve) { showsControl.toggle() }
        }
        .opacity(control == nil ? 0 : 1)
        .allowsHitTesting(control != nil)
        .accessibilityHidden(control == nil)
        .accessibilityIdentifier("timerControl")
    }

    /// The system's wheels in Grafito ink: their white text is multiplied
    /// by the ink of the phase, so nothing in the sheet is brighter than
    /// its words.
    @ViewBuilder private var control: some View {
        Group {
            if choice.mode == .blanket {
                DatePicker(selection: hourBinding, displayedComponents: .hourAndMinute) {
                    Text("temporizador.hora")
                }
                .datePickerStyle(.wheel)
                .accessibilityIdentifier("timerHour")
            } else {
                Picker(selection: lengthBinding) {
                    ForEach(TimerSheetText.lengths(including: choice.minutes), id: \.self) { minutes in
                        Text(verbatim: TimeFormat.minutes(minutes)).tag(minutes)
                    }
                } label: {
                    Text("temporizador.duracion")
                }
                .pickerStyle(.wheel)
                .accessibilityHint(Text("ax.duracion.pista"))
                .accessibilityIdentifier("timerLength")
            }
        }
        .labelsHidden()
        // Both wheels in the column, at one width: the band of the
        // selection does not change size from one mode to the other.
        .frame(maxWidth: Self.wheelWidth)
        .frame(height: Self.wheelHeight)
        .clipped()
        .colorMultiply(Ink.primary(phase))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Grid.margin)
        .overlay(alignment: .bottom) {
            Hairline().padding(.horizontal, Grid.margin)
        }
    }

    private var lengthBinding: Binding<Int> {
        Binding(
            get: { choice.minutes },
            set: { minutes in
                guard minutes != choice.minutes || choice.mode != .untilAsleep else { return }
                var next = choice.with(mode: .untilAsleep)
                next.minutes = minutes
                model.chooseTimer(next)
            }
        )
    }

    private var hourBinding: Binding<Date> {
        Binding(
            get: { hour },
            set: { date in
                let parts = calendar.dateComponents([.hour, .minute], from: date)
                let next = TimerChoice(
                    mode: .blanket,
                    minutes: choice.minutes,
                    endHour: parts.hour ?? choice.endHour,
                    endMinute: parts.minute ?? choice.endMinute
                )
                guard next != choice else { return }
                model.chooseTimer(next)
            }
        )
    }
}
