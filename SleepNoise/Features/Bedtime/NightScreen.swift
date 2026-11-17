import SwiftUI

/// Night (03 §5, surface 10): "is everything still all right?".
///
/// True black, one ink, four things: the Horizon at a third of the screen
/// (continuous while it sounds, absent while it does not), the hour, the
/// state in words and "+15 min". The whole screen is the button. Nothing
/// moves: content changes in place and the only finite animation is the
/// way in and out.
///
/// Night never creates a timer (C47): without one the place of "+15 min"
/// is empty. Once the night has ended that place offers Small Hours (C27).
/// Nothing here sells, at any hour, and the word "Pro" does not exist.
struct NightScreen: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var timer: SleepTimerController

    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    /// The session level to say, for a moment after the vertical drag.
    @State private var levelNote: Int?
    @State private var levelNoteToken = 0
    /// "+15 min" was just pressed: the figures of the hour roll, once.
    @State private var rollsFigures = false
    @State private var rollToken = 0

    private var status: NightStatus {
        NightStatus.resolve(NightStatus.Input(model, levelNote: levelNote))
    }

    /// The largest sizes leave the two first-time sentences out: they are
    /// in the hint VoiceOver reads, and there is no room for them.
    private var hasRoomForIntro: Bool { dynamicType < .accessibility3 }

    var body: some View {
        let status = self.status
        let clock = Self.clock(model.clockNow)
        FullScreenControl(
            model: model,
            allowsBack: true,
            spoken: spoken(status, clock: clock),
            onTap: { touched(status) },
            onBack: goBack,
            onLevel: noteLevel
        ) { layout in
            VStack(spacing: 0) {
                SoundLineMark(rms: 0, isSounding: status.isSounding, ownsAccent: false)
                    .frame(height: Grid.horizonBand)
                    .padding(.horizontal, Grid.margin)
                    .padding(.top, layout.horizonY - Grid.horizonBand / 2)
                clockFace
                    .padding(.top, NightLayout.clockDrop - Grid.horizonBand / 2)
                word(status)
                    .padding(.top, NightLayout.lineGap)
                if hasRoomForIntro {
                    intro
                        .padding(.top, NightLayout.lineGap)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } actions: {
            VStack(spacing: 0) {
                if model.speakerOfferUntil != nil, !status.isOver {
                    NightAction(title: Localized.string("ruta.seguir_altavoz")) {
                        model.noteBedtimeTouch()
                        model.continueOnSpeaker()
                    }
                    .accessibilityHint(Text(verbatim: Localized.format(
                        "ax.altavoz.pista", Int64(NightAxis.percent(RoutePolicy.speakerMasterCap))
                    )))
                    .accessibilityIdentifier("nightSpeaker")
                    .padding(.bottom, NightLayout.channel)
                    .transition(.opacity)
                }
                slot(status)
            }
            .animation(Motion.contentCurve, value: model.speakerOfferUntil != nil)
        }
        .overlay(alignment: .top) { backElement }
        .task(id: levelNoteToken) {
            guard levelNoteToken > 0 else { return }
            try? await Task.sleep(for: .seconds(BedtimeScreenPolicy.levelNoteDuration))
            if !Task.isCancelled { levelNote = nil }
        }
        .task(id: rollToken) {
            guard rollToken > 0 else { return }
            try? await Task.sleep(for: .seconds(Motion.content * 2))
            if !Task.isCancelled { rollsFigures = false }
        }
        .task(id: model.showsNightIntro && scenePhase == .active) {
            // The sentences count their seconds only while someone can
            // read them: a Night entered by locking shows them at the
            // unlock.
            guard model.showsNightIntro, scenePhase == .active else { return }
            #if DEBUG
            if NightArguments.holdsIntro { return }
            #endif
            try? await Task.sleep(for: .seconds(BedtimeScreenPolicy.introDuration))
            if !Task.isCancelled { model.nightIntroDidShow() }
        }
        #if DEBUG
        .onAppear {
            if NightArguments.showsLevelRule { levelNote = NightAxis.percent(model.sessionLevel) }
        }
        #endif
    }

    // MARK: What it shows

    /// The hour of the system, as the person set it. It changes by the
    /// minute, in place.
    private var clockFace: some View {
        TimelineView(.everyMinute) { _ in
            Text(verbatim: Self.clock(model.clockNow))
                .step(.figure)
                .foregroundStyle(Ink.textNight)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, Grid.margin)
                .frame(maxWidth: .infinity, minHeight: TypeStep.figure.scaledLineHeight(for: dynamicType))
        }
    }

    private func word(_ status: NightStatus) -> some View {
        let text = status.text()
        return Text(verbatim: text)
            .step(.nightState)
            .monospacedDigit()
            .foregroundStyle(Ink.textNight)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .contentTransition(rollsFigures && !reduceMotion ? .numericText() : .opacity)
            .animation(Motion.contentCurve, value: text)
            .padding(.horizontal, Grid.margin)
            .frame(maxWidth: .infinity, minHeight: TypeStep.nightState.scaledLineHeight(for: dynamicType), alignment: .top)
    }

    /// The only two sentences of the night, the first time Night is seen:
    /// fixed text, not a tip (C65). They keep their room, so nothing moves
    /// when they go.
    private var intro: some View {
        VStack(spacing: Grid.unit / 2) {
            Text("noche.primera")
            Text("noche.volver")
        }
        .step(.body)
        .foregroundStyle(Ink.textNight)
        .multilineTextAlignment(.center)
        .padding(.horizontal, Grid.margin)
        .frame(maxWidth: .infinity)
        .opacity(model.showsNightIntro ? 1 : 0)
        .animation(.easeInOut(duration: model.showsNightIntro ? Motion.content : Motion.content * 2), value: model.showsNightIntro)
    }

    /// The place of "+15 min": always the same row, with the action that
    /// means something now, or nothing.
    private func slot(_ status: NightStatus) -> some View {
        ZStack {
            if status.isOver {
                NightAction(title: Localized.format("madrugada.estado", Int64(smallHoursMinutes))) {
                    model.startSmallHours()
                }
                .accessibilityLabel(Text(verbatim: Localized.format("ax.la.madrugada", Int64(smallHoursMinutes))))
                .accessibilityIdentifier("nightSmallHours")
                .transition(.opacity)
            } else if model.canExtendTimer {
                NightAction(title: Localized.string("comun.mas15"), action: extend)
                    .accessibilityLabel(Text("ax.mas15"))
                    .accessibilityIdentifier("nightExtend")
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, minHeight: NightAction.height(dynamicType: dynamicType))
        .animation(Motion.contentCurve, value: status.isOver)
        .animation(Motion.contentCurve, value: model.canExtendTimer)
    }

    private var smallHoursMinutes: Int {
        Int((model.smallHours.recipe.duration / 60).rounded())
    }

    /// "Back to the page" as a button of its own, last in the reading
    /// order: it exists for VoiceOver and Switch Control, where a long
    /// press is not a gesture anyone can count on.
    private var backElement: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: Grid.largeTarget)
            .allowsHitTesting(false)
            .accessibilityElement()
            .accessibilityLabel(Text("ax.accion.volver"))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { goBack() }
            .accessibilitySortPriority(1)
            .accessibilityIdentifier("nightBack")
    }

    // MARK: What it does

    private func touched(_ status: NightStatus) {
        switch status.touch {
        case .pause: model.pause()
        case .resume, .retry: model.play()
        case .nothing: return
        }
        // No haptic: the sound confirms it. VoiceOver says the new state.
        if let key = self.status.announcementKey {
            AccessibilityNotification.Announcement(Localized.string(key)).post()
        }
    }

    private func extend() {
        model.noteBedtimeTouch()
        rollsFigures = true
        rollToken += 1
        guard model.extendTimer() else { return }
        if let words = TimerSheetText.extensionAnnouncement(TimerSheetText.Input(timer)) {
            AccessibilityNotification.Announcement(words).post()
        }
    }

    private func goBack() {
        model.leaveBedtime()
        AccessibilityNotification.Announcement(Localized.string("ax.anuncio.pagina")).post()
    }

    private func noteLevel() {
        levelNote = NightAxis.percent(model.sessionLevel)
        levelNoteToken += 1
    }

    private func spoken(_ status: NightStatus, clock: String) -> FullScreenSpoken {
        var actions: [(name: String, run: () -> Void)] = []
        switch status.touch {
        case .pause:
            actions.append((Localized.string("ax.accion.pausar"), { touched(status) }))
        case .resume, .retry:
            actions.append((Localized.string("ax.accion.reanudar"), { touched(status) }))
        case .nothing:
            break
        }
        actions.append((Localized.string("ax.accion.volver"), goBack))
        if model.speakerOfferUntil != nil, !status.isOver {
            actions.append((Localized.string("ruta.seguir_altavoz"), { model.continueOnSpeaker() }))
        }
        return FullScreenSpoken(
            label: Localized.string("ax.noche.pantalla"),
            value: status.spoken(clock: clock),
            hint: status.hintKey.map { Localized.string($0) },
            isButton: status.touch != .nothing,
            actions: actions
        )
    }

    static func clock(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
