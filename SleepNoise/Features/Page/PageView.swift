import SwiftUI

/// The page (03 §5, surfaces 1 to 4; anatomy in spec 05 §2.0): the root of
/// the app.
///
/// A black page that answers one question, "what is going to sound?": the
/// name of the live mix, the Horizon at a third of the screen, up to three
/// of the layers that sound as level rows, "All layers", the tide, the
/// timer, and a bar with the Disc. No app title and no logo.
///
/// Every element has its line. When a line has nothing to say it stays
/// empty: between states only content, length and opacity change, never a
/// position. The only colour is the Horizon while the engine sounds, or the
/// level under a finger.
struct PageView: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var arbiter = IndexArbiter()
    /// The layers that have a row. Chosen when a mix loads and when the
    /// Layers sheet closes, never while a finger is on a row.
    @State private var rows: [SoundID]
    @State private var capacity = PageLayers.fullCapacity
    @State private var sheet: PageSheet?
    @State private var sliderDismissal = 0
    @State private var showsSave = false
    @State private var draftName = ""
    /// Bumped when the app comes forward, so what depends on the hour (what
    /// may be sold) is read again.
    @State private var clock = 0
    /// Height of the name's line: 34 pt at Large.
    @ScaledMetric(relativeTo: .title) private var nameLine: CGFloat = 34

    init(model: MixerModel, purchases: PurchaseManager) {
        self.model = model
        self.purchases = purchases
        _rows = State(initialValue: PageLayers.rows(model.levels, capacity: PageLayers.fullCapacity))
        #if DEBUG
        _sheet = State(initialValue: PageArguments.opensLayers ? .layers : nil)
        #endif
    }

    private var phase: NightPhase { model.isNightSession ? .nightPage : .day }
    private var presentsSomething: Bool { sheet != nil || model.showPaywall || showsSave }

    var body: some View {
        GeometryReader { geometry in
            let insets = geometry.safeAreaInsets
            let fullHeight = geometry.size.height + insets.top + insets.bottom
            let metrics = PageMetrics(fullHeight: fullHeight, topInset: insets.top)
            let fits = PageLayers.capacity(
                fullHeight: fullHeight,
                isAccessibilitySize: dynamicType.isAccessibilitySize,
                isLargestSizes: dynamicType >= .accessibility3
            )
            let shown = Array(rows.prefix(fits))
            // From the first accessibility size the Horizon is no longer at
            // a third of the screen: it sits 24 pt under the state line, so
            // the rows below it stay on screen (05 §5d).
            let isLargeText = dynamicType.isAccessibilitySize
            // Read on every draw; `clock` only makes the draw happen.
            let canSell = clock >= 0 && model.canSell

            ScrollView {
                VStack(spacing: 0) {
                    head(metrics: metrics, canSell: canSell)
                        .frame(minHeight: isLargeText ? nil : metrics.headHeight, alignment: .top)
                        .padding(.bottom, isLargeText ? Grid.unit * 6 : 0)
                    SoundLine(isSounding: model.isPlaying) { tau in
                        model.outputLevel(tau: tau)
                    }
                    layerRows(shown, capacity: fits, canSell: canSell)
                        .padding(.top, metrics.airUnderHorizon)
                    EditorialRow(
                        title: Localized.string("capas.todas"),
                        value: allLayersValue(shown),
                        valueIsDatum: true,
                        rule: .top
                    ) {
                        sheet = .layers
                    }
                    .accessibilityHint(Text("ax.mas.pista"))
                    .accessibilityIdentifier("openLayers")
                    Color.clear.frame(height: metrics.airOverTide)
                    TideRow(model: model, guide: model.breathing, canSell: canSell) {
                        sheet = .tide
                    }
                    TimerRow(timer: model.timer) {
                        sheet = .timer
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                PageBar(model: model, timer: model.timer) {
                    sheet = .mixes
                }
            }
            .onChange(of: fits, initial: true) { _, next in
                capacity = next
                chooseRows()
            }
        }
        .environment(\.nightPhase, phase)
        .environment(\.sheetPresented, presentsSomething)
        .environment(\.fineSliderDismissal, sliderDismissal)
        .indexArbiter(arbiter)
        .grafitoRoot()
        .animation(.easeInOut(duration: Motion.phase(reduceMotion: reduceMotion)), value: model.isNightSession)
        // Magic Tap from any focus: the Disc is last in the reading order.
        .accessibilityAction(.magicTap) { model.togglePlayback() }
        .onAppear {
            model.startIfNeeded()
            #if DEBUG
            PageStage.didAppear(model)
            #endif
        }
        .onChange(of: scenePhase) { _, next in
            guard next == .active else {
                model.appDidResignActive()
                return
            }
            // A trial that ran out is only applied while nothing is playing.
            purchases.refreshAccess(canDowngrade: !model.isPlaying)
            // An interruption that never closed, a night paused too long,
            // and a Pro sheet left up before the night, which does not come
            // back with it.
            model.appDidBecomeActive()
            clock += 1
        }
        .onChange(of: purchases.hasFullAccess) { _, _ in
            model.clampTimerToEntitlement()
            model.refreshEntitledAudio()
        }
        .onChange(of: model.mixRevision) { _, _ in chooseRows() }
        .onChange(of: model.isPlayingFallback) { _, raised in
            if raised {
                rows = PageLayers.adding(MixerModel.fallbackSound, to: rows, capacity: capacity)
            }
        }
        .onChange(of: sheet) { previous, next in
            if previous == .layers { chooseRows() }
            if next != nil { sliderDismissal += 1 }
            clock += 1
        }
        .onChange(of: model.showPaywall) { _, asked in
            // The old sheets cannot present the Pro sheet themselves: they
            // step aside for it.
            if asked, let sheet, sheet != .layers { self.sheet = nil }
        }
        .sheet(item: $sheet) { which in
            sheetContent(which)
        }
        .sheet(isPresented: proBinding(when: sheet == nil)) {
            PaywallView(purchases: purchases)
                .tint(Palette.amber)
                .onDisappear { purchases.clearNotice() }
        }
        .alert("mixes.save.title", isPresented: $showsSave) {
            TextField("mezcla.guardar.campo", text: $draftName)
            Button("common.save") {
                _ = model.saveCurrent(name: draftName)
            }
            Button("common.cancel", role: .cancel) {}
        }
    }

    // MARK: Head

    /// Everything above the Horizon: the trial word, the name, the state
    /// line and its second line. Fixed lines, empty when they have nothing
    /// to say.
    private func head(metrics: PageMetrics, canSell: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeaderWord(model: model, purchases: purchases, canSell: canSell)
                .padding(.top, metrics.headerTop)
            name
                .padding(.top, metrics.airUnderHeader)
            StatusLine(model: model, timer: model.timer, hasFullAccess: purchases.hasFullAccess)
                .padding(.top, Grid.unit * 2 + 2)
        }
        .padding(.horizontal, Grid.margin)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { sliderDismissal += 1 }
    }

    private var title: String { PageTitle.text(loadedMixName: model.loadedMixName) }

    /// A name the person wrote may shrink a little before it is cut; the
    /// names the app writes never scale.
    private var isOwnName: Bool {
        model.loadedMixName != nil && model.activeHouseMix == nil && !model.loadedMixWasStripped
    }

    /// A fourth mix without access: the menu says so before the touch.
    private var saveNeedsPro: Bool {
        !AccessPolicy.canSave(
            existingCount: model.mixStore.mixes.count,
            hasFullAccess: purchases.hasFullAccess
        )
    }

    private var name: some View {
        // The tap on the name is the one way out of the night page: its
        // touch area is 64 pt there, taken from the air above and below, so
        // nothing moves.
        let reach = model.isNightSession ? max(0, (Grid.largeTarget - nameLine) / 2) : 0
        return Text(verbatim: title)
            .step(.name)
            .foregroundStyle(Ink.primary(phase))
            .lineLimit(dynamicType.isAccessibilitySize ? 2 : 1)
            .truncationMode(.tail)
            .minimumScaleFactor(isOwnName ? 0.8 : 1)
            .contentTransition(.opacity)
            .animation(Motion.contentCurve, value: title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, reach)
            .contentShape(Rectangle())
            .padding(.vertical, -reach)
            .onTapGesture {
                // By day a tap on the name does nothing. On the night page
                // it is the deliberate way back to the day page.
                if model.isNightSession { model.endNightSession() }
            }
            .contextMenu {
                if saveNeedsPro {
                    // At night the touch does nothing, so no hint offers Pro.
                    Button {
                        beginSave()
                    } label: {
                        Text("mezcla.menu.guardar.pro")
                    }
                    .accessibilityLabel(Text("ax.guardar.pro"))
                    .accessibilityHint(model.canSell ? Text("ax.guardar.pro.pista") : Text(verbatim: ""))
                } else {
                    Button {
                        beginSave()
                    } label: {
                        Text("mezcla.menu.guardar")
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("mezcla.guardar.campo"))
            .accessibilityValue(Text(verbatim: PageStatus.spoken(title)))
            .accessibilityHint(Text(model.isNightSession ? "ax.nombre.pista.noche" : "ax.nombre.pista"))
            .accessibilityAddTraits(model.isNightSession ? .isButton : .isHeader)
            .accessibilityActions {
                Button {
                    beginSave()
                } label: {
                    Text(saveNeedsPro ? "ax.guardar.pro" : "ax.accion.guardar")
                }
                // The way back exists only on the night page (05 §5b).
                if model.isNightSession {
                    Button {
                        model.endNightSession()
                    } label: {
                        Text("ax.accion.volver.dia")
                    }
                }
            }
            .accessibilityIdentifier("mixName")
    }

    // MARK: Rows

    /// The rows keep their room whether or not there is a layer in them.
    private func layerRows(_ shown: [SoundID], capacity: Int, canSell: Bool) -> some View {
        VStack(spacing: 0) {
            ForEach(shown) { sound in
                LayerRow(
                    model: model,
                    sound: sound,
                    hasFullAccess: purchases.hasFullAccess,
                    canSell: canSell
                )
            }
        }
        .frame(minHeight: Grid.layerRow * CGFloat(capacity), alignment: .top)
    }

    private func allLayersValue(_ shown: [SoundID]) -> String? {
        let more = PageLayers.more(model.levels, rows: shown)
        guard more > 0 else { return nil }
        return Localized.format("capas.mas", Int64(more))
    }

    private func chooseRows() {
        rows = PageLayers.rows(model.levels, capacity: capacity)
    }

    // MARK: Sheets

    @ViewBuilder
    private func sheetContent(_ which: PageSheet) -> some View {
        switch which {
        case .layers:
            LayersSheet(model: model, purchases: purchases) {
                sheet = .mixes
            }
            .environment(\.nightPhase, phase)
            #if DEBUG
            .modifier(DebugDynamicType())
            #endif
        case .timer:
            // The whole timer is free (C03): the old sheet is asked to show
            // every length open, so it has nothing to sell.
            SleepTimerView(
                timer: model.timer,
                hasFullAccess: true,
                onSelect: { model.selectTimer(minutes: $0) },
                onLocked: {}
            )
            .tint(Palette.amber)
        case .tide:
            BreathingSettingsView(guide: model.breathing) { settings in
                model.updateBreathing(settings)
            }
            .tint(Palette.amber)
            .presentationDetents([.medium, .large])
        case .mixes:
            SavedMixesView(store: model.mixStore) { mix in
                model.apply(mix)
            }
            .tint(Palette.amber)
        }
    }

    /// The Pro sheet goes up from whatever is in front. The model only ever
    /// raises the request while something may be sold.
    private func proBinding(when isFront: Bool) -> Binding<Bool> {
        Binding(
            get: { model.showPaywall && isFront },
            set: { if !$0 { model.dismissPro() } }
        )
    }

    private func beginSave() {
        guard AccessPolicy.canSave(
            existingCount: model.mixStore.mixes.count,
            hasFullAccess: purchases.hasFullAccess
        ) else {
            model.offerPro()
            return
        }
        // The field starts from the name the mix already has.
        draftName = model.loadedMixBaseName ?? title
        showsSave = true
    }
}

/// What the page can put in front of itself.
enum PageSheet: String, Identifiable {
    case layers
    case timer
    case tide
    case mixes

    var id: String { rawValue }
}

/// Where things sit (05 §2.0 and §2.13). The Horizon is at a third of the
/// whole screen; the head fills the room above it, and grows past it only
/// when the text is too large to fit, pushing the Horizon down.
struct PageMetrics: Equatable {
    var fullHeight: CGFloat
    var topInset: CGFloat

    /// A short screen (375 × 667) keeps the same page with less air.
    var isShort: Bool { fullHeight < 800 }

    var horizonY: CGFloat { Grid.horizonY(fullHeight: fullHeight) }

    /// From the top of the content to the top of the Horizon band.
    var headHeight: CGFloat {
        max(0, horizonY - Grid.horizonBand / 2 - topInset)
    }

    /// The trial word sits at y 64 of the screen (28 on a short one).
    var headerTop: CGFloat {
        max(Grid.unit, (isShort ? 28 : 64) - topInset)
    }

    var airUnderHeader: CGFloat { isShort ? Grid.unit * 2 + 2 : Grid.inner + 2 }
    var airUnderHorizon: CGFloat { isShort ? Grid.unit * 3 : Grid.inner }
    var airOverTide: CGFloat { isShort ? Grid.unit * 6 : Grid.group }
}

// MARK: - Head lines

/// The trial word above the name (05 §2.1): a state word that opens the Pro
/// sheet. Plain text while nothing may be sold, and gone on the night page.
/// Its line is always there, so nothing below it moves.
private struct PageHeaderWord: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager
    let canSell: Bool

    @ScaledMetric(relativeTo: .footnote) private var line: CGFloat = 18

    private var word: String? {
        guard !model.isNightSession else { return nil }
        return PageTrialWord.text(trial: purchases.trialState, isPro: purchases.isPro)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if let word {
                if canSell {
                    Button {
                        model.offerPro()
                    } label: {
                        StateWord(text: word)
                            .frame(minHeight: Grid.target)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressedFadeStyle())
                    .accessibilityHint(Text("ax.prueba.pista"))
                    .accessibilityIdentifier("openPaywall")
                } else {
                    StateWord(text: word)
                }
            }
        }
        // The touch area is 44 pt; the line it sits on is 18.
        .frame(height: line)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The state line (05 §2.1): what is happening, in words. When the engine
/// did not start, the line is the button that tries again. It keeps the room
/// of two lines, the second one being where a short action goes.
///
/// It watches the timer itself: the model does not republish it.
private struct StatusLine: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var timer: SleepTimerController
    let hasFullAccess: Bool

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityShowButtonShapes) private var buttonShapes
    @ScaledMetric(relativeTo: .subheadline) private var twoLines: CGFloat = 40

    private var status: PageStatus {
        PageStatus.resolve(PageStatus.Input(
            isPlaying: model.isPlaying,
            pauseCause: model.pauseCause,
            startFailures: model.startFailures,
            timerEndsAt: timer.endsAt,
            timerIsFading: timer.isFading,
            timerRemaining: timer.remaining,
            omitted: MixLoad(levels: model.levels, hasFullAccess: hasFullAccess).omitted,
            isSilent: model.isSilent,
            isPlayingFallback: model.isPlayingFallback,
            isNightSession: model.isNightSession
        ))
    }

    var body: some View {
        let status = self.status
        let text = status.text()
        Group {
            if case .error(let attempt) = status {
                Button {
                    model.togglePlayback()
                } label: {
                    // One sentence per line; the largest sizes take the
                    // lines they need, the button grows with them.
                    words(PageStatus.errorLines(text, bindsTail: !dynamicType.isAccessibilitySize))
                        .underline(buttonShapes, color: Ink.secondary(phase))
                        .lineLimit(dynamicType >= .accessibility3 ? nil : 3)
                        .frame(maxWidth: .infinity, minHeight: Grid.target, alignment: .topLeading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressedFadeStyle())
                // The first failure has its own label. From the second on
                // the words on screen say what to do, so they are the label
                // and "try again" is the hint.
                .accessibilityLabel(
                    attempt >= 2 ? Text(verbatim: PageStatus.spoken(text)) : Text("ax.reintentar")
                )
                .accessibilityHint(attempt >= 2 ? Text("ax.reintentar") : Text(verbatim: ""))
                .accessibilityIdentifier("retryAudio")
            } else {
                words(text)
                    .lineLimit(dynamicType >= .accessibility3 ? 3 : 2)
                    .accessibilityLabel(Text(verbatim: PageStatus.spoken(text)))
                    .accessibilityIdentifier("pageStatus")
            }
        }
        .frame(maxWidth: .infinity, minHeight: twoLines, alignment: .topLeading)
        .onChange(of: model.startFailures) { _, failures in
            // A start that failed was caused by a touch: it may be spoken.
            // High priority, so it is not lost under VoiceOver reading the
            // Disc that was just activated.
            if failures > 0 {
                var announcement = AttributedString(PageStatus.spoken(self.status.text()))
                announcement.accessibilitySpeechAnnouncementPriority = .high
                AccessibilityNotification.Announcement(announcement).post()
            }
        }
    }

    private func words(_ text: String) -> some View {
        Text(verbatim: text)
            .step(.secondary)
            .monospacedDigit()
            .foregroundStyle(Ink.secondary(phase))
            .multilineTextAlignment(.leading)
            .contentTransition(.opacity)
            .animation(Motion.contentCurve, value: text)
    }
}

// MARK: - Tide and timer rows

/// The tide on the page: its name, its state in words and the system
/// toggle in plain ink (never the accent). The words open the tide sheet;
/// the toggle switches it. Without access the toggle goes back to off and
/// the row says "Off · pro"; the Pro sheet only goes up while something may
/// be sold.
private struct TideRow: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var guide: BreathingGuideController
    let canSell: Bool
    var onOpen: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType
    /// Height of the name's line: 22 pt at Large.
    @ScaledMetric(relativeTo: .headline) private var nameLine: CGFloat = 22

    private var isIncluded: Bool { model.breathingIsIncluded }
    private var isOn: Bool { guide.settings.isEnabled && isIncluded }

    /// How far the system toggle draws past its own frame on the trailing
    /// side: 2 pt on iOS 26 (measured: 63 pt drawn, ending 2 pt beyond the
    /// frame), nothing before. Taken back so its edge is the column's.
    private static var toggleOverhang: CGFloat {
        if #available(iOS 26, *) { return 2 }
        return 0
    }

    var body: some View {
        HStack(alignment: .top, spacing: Grid.inner) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: Grid.unit / 2) {
                    Text("marea.titulo")
                        .step(.row)
                        .foregroundStyle(Ink.primary(phase))
                    subtitle
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressedFadeStyle())
            .accessibilityIdentifier("openTide")
            toggle
                .accessibilityIdentifier("tideToggle")
                // Centred on the name's line whatever the system's toggle
                // measures (31 pt on iOS 17, 28 pt on iOS 26): its box is
                // that line.
                .fixedSize()
                .frame(height: nameLine)
                .padding(.trailing, Self.toggleOverhang)
        }
        .padding(.top, Grid.unit * 3)
        .padding(.bottom, Grid.unit * 2)
        .padding(.horizontal, Grid.margin)
        .frame(minHeight: Grid.row(subtitle: true, dynamicType: dynamicType), alignment: .top)
        .overlay(alignment: .top) {
            Hairline().padding(.horizontal, Grid.margin)
        }
    }

    private var plainToggle: some View {
        Toggle(isOn: Binding(
            get: { isOn },
            set: { model.setBreathingEnabled($0) }
        )) {
            Text("marea.titulo")
        }
        .labelsHidden()
        .tint(Ink.primary(phase))
    }

    /// With access the system says on or off. Without it the toggle says
    /// why it stays off, and only offers Pro while something may be sold.
    /// On the night page nothing says "requires Pro" (copy guide §3): the
    /// toggle just says it is off.
    @ViewBuilder private var toggle: some View {
        if isIncluded || phase.isNight {
            plainToggle
        } else if canSell {
            plainToggle
                .accessibilityValue(Text("ax.marea.off.pro"))
                .accessibilityHint(Text("ax.marea.pista.pro"))
        } else {
            plainToggle
                .accessibilityValue(Text("ax.marea.off.pro"))
        }
    }

    /// Empty while the tide is off with access: the toggle already says so.
    @ViewBuilder private var subtitle: some View {
        if let note = model.breathingNote {
            line(note)
        } else if !isIncluded {
            line(Localized.string("marea.estado.apagada.pro"))
        } else if isOn, guide.phase == .dissolving {
            StateWord(text: Localized.string("marea.estado.disolviendo"))
        } else if isOn, guide.isActive {
            StateWord(text: Localized.format(
                "marea.estado.guiando.corto", Int64(guide.settings.breathsPerMinute)
            ))
        } else {
            line(" ").accessibilityHidden(true)
        }
    }

    private func line(_ text: String) -> some View {
        Text(verbatim: text)
            .step(.secondary)
            .foregroundStyle(Ink.secondary(phase))
    }
}

/// The timer on the page: the setting, never the count. The whole timer is
/// free, so the word "pro" never appears here. When it ends is said by the
/// state line, as an hour.
private struct TimerRow: View {
    @ObservedObject var timer: SleepTimerController
    var onOpen: () -> Void

    private var setting: String {
        guard let minutes = timer.selectedMinutes else {
            return Localized.string("temporizador.apagado")
        }
        return Localized.format("temporizador.estado.dormirme", Int64(minutes))
    }

    var body: some View {
        EditorialRow(
            title: Localized.string("temporizador.titulo"),
            value: setting,
            rule: .top,
            action: onOpen
        )
        .accessibilityIdentifier("openTimer")
    }
}
