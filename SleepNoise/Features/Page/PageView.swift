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
    /// The alert that saves the live mix or renames the loaded one.
    @State private var naming = MixNaming()
    /// Saves that went through, and the word that says so for three seconds.
    @State private var saves = 0
    @State private var showsSaved = false
    /// Bumped when the app comes forward, so what depends on the hour (what
    /// may be sold) is read again.
    @State private var clock = 0
    /// Height of the name's line: 34 pt at Large.
    @ScaledMetric(relativeTo: .title) private var nameLine: CGFloat = 34
    /// VoiceOver lands on the name when Night or Small Hours gives the
    /// page back: what was focused there is gone.
    @AccessibilityFocusState private var focusesName: Bool

    init(model: MixerModel, purchases: PurchaseManager) {
        self.model = model
        self.purchases = purchases
        _rows = State(initialValue: PageLayers.rows(model.levels, capacity: PageLayers.fullCapacity))
        #if DEBUG
        _sheet = State(initialValue: PageArguments.initialSheet)
        #endif
    }

    private var phase: NightPhase { model.isNightSession ? .nightPage : .day }
    private var presentsSomething: Bool { sheet != nil || model.showPaywall || naming.isPresented }
    /// Night or Small Hours is over the page: it is not seen or touched.
    private var isCovered: Bool { model.isBedtime || model.isSmallHours }
    /// Night and Small Hours draw no status bar and no home indicator.
    private var hidesSystemBars: Bool {
        #if DEBUG
        // Nor does a capture for the store (11 §2.2).
        if PageArguments.isStoreShot { return true }
        #endif
        return isCovered
    }

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
                    PageHorizon(
                        model: model,
                        guide: model.breathing,
                        band: metrics.tideBand,
                        // With larger text the Horizon sits right under
                        // the state line: there is no band above it.
                        showsWater: !isLargeText
                    )
                    layerRows(shown, capacity: fits, canSell: canSell)
                        .padding(.top, metrics.airUnderHorizon)
                    let allLayers = allLayersValue(shown)
                    EditorialRow(
                        title: Localized.string("capas.todas"),
                        value: allLayers.map { LineTies.dotLeads($0) },
                        valueIsDatum: true,
                        rule: .top
                    ) {
                        sheet = .layers
                    }
                    .accessibilityLabel(Text("capas.todas"))
                    .accessibilityValue(Text(verbatim: PageStatus.spoken(allLayers ?? "")))
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
                } onNight: {
                    enterNight()
                }
            }
            // With text large enough to scroll, the page would pass under
            // the status bar and be read through the system's clock.
            .overlay(alignment: .top) {
                Ink.background
                    .frame(height: insets.top)
                    .offset(y: -insets.top)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .onChange(of: fits, initial: true) { _, next in
                capacity = next
                chooseRows()
            }
        }
        // The keyboard of the naming alert does not lift the bar over the
        // rows: nothing changes position (03 §3.7).
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environment(\.nightPhase, phase)
        // Under Night the Horizon of the page freezes, as under a sheet.
        .environment(\.sheetPresented, presentsSomething || isCovered)
        .environment(\.fineSliderDismissal, sliderDismissal)
        .indexArbiter(arbiter)
        .grafitoRoot()
        .animation(.easeInOut(duration: Motion.phase(reduceMotion: reduceMotion)), value: model.isNightSession)
        .accessibilityHidden(isCovered)
        // Night and Small Hours: a layer over the page, not a
        // presentation, so they come and go by opacity and nothing moves.
        .overlay {
            NightCover(model: model)
        }
        .statusBarHidden(hidesSystemBars)
        .persistentSystemOverlays(hidesSystemBars ? .hidden : .automatic)
        .onChange(of: isCovered) { _, covered in
            // Night never shares the screen with a sheet: whatever was up
            // when it arrived by itself (a lock, a Shortcut) comes down.
            if covered {
                sheet = nil
                naming.isPresented = false
            } else {
                focusesName = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.protectedDataWillBecomeUnavailableNotification
        )) { _ in
            // The iPhone was locked while the night plays: Night is what
            // is there at the next unlock (C47). A sheet rules.
            model.enterBedtimeOnLock(sheetIsOpen: presentsSomething)
        }
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
            // An interruption that never closed, a night paused too long,
            // a Pro sheet left up before the night, which does not come
            // back with it, and the clock of the trial.
            model.appDidBecomeActive()
            clock += 1
        }
        .onChange(of: model.mixRevision) { _, _ in chooseRows() }
        .onChange(of: model.isPlayingFallback) { _, raised in
            if raised {
                rows = PageLayers.adding(MixerModel.fallbackSound, to: rows, capacity: capacity)
            }
        }
        .onChange(of: model.tideOceanRaises) { _, _ in
            // The ocean the tide raised takes a row when one is free.
            rows = PageLayers.adding(.ocean, to: rows, capacity: capacity)
        }
        .onChange(of: purchases.trialState) { before, after in
            // The trial started from the Pro sheet over Settings: both
            // come down, because only the page says so ("trial · 7 nights
            // left"). Settings would look as if nothing had happened.
            if let sheet, sheet.closesWhenTrialStarts(from: before, to: after) { self.sheet = nil }
        }
        .onChange(of: sheet) { previous, next in
            if previous == .layers { chooseRows() }
            if next != nil {
                sliderDismissal += 1
                model.dismissCappedLevelNote()
            }
            clock += 1
        }
        .onChange(of: model.showPaywall) { _, asked in
            // The tide and the Mixes sheets do not present the Pro sheet
            // themselves: they step aside for it. Layers and Settings do.
            if asked, let sheet, !sheet.presentsPro { self.sheet = nil }
        }
        .sheet(item: $sheet) { which in
            sheetContent(which)
        }
        .sheet(isPresented: proBinding(when: sheet == nil)) {
            ProSheet(purchases: purchases, model: model)
                #if DEBUG
                .modifier(DebugDynamicType())
                #endif
        }
        .mixNaming($naming, model: model) { _ in
            saves += 1
        }
        .sensoryFeedback(.success, trigger: saves) { _, _ in
            MotionGate.allows(phase)
        }
        .task(id: saves) {
            // "Saved" takes the state line for three seconds (08 §2.2):
            // never a new line, never a question.
            guard saves > 0 else { return }
            AccessibilityNotification.Announcement(Localized.string("mezclas.guardada")).post()
            showsSaved = true
            try? await Task.sleep(for: .seconds(3))
            showsSaved = false
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
            StatusLine(
                model: model,
                timer: model.timer,
                hasFullAccess: purchases.hasFullAccess,
                note: showsSaved ? Localized.string("mezclas.guardada") : nil,
                trialNote: trialNote
            )
            .padding(.top, Grid.unit * 2 + 2)
            if let words = PageTrialNote.footnote(trialNote) {
                TrialEndedNote(words: words) {
                    purchases.dismissTrialNote()
                }
                .padding(.top, Grid.unit * 3)
                .transition(.opacity)
            }
        }
        .animation(Motion.contentCurve, value: trialNote)
        .padding(.horizontal, Grid.margin)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            sliderDismissal += 1
            model.dismissCappedLevelNote()
        }
    }

    /// What the page may say once about the trial right now. Read on every
    /// draw: the hour decides, and `clock` makes the draw happen.
    private var trialNote: TrialNote? { clock >= 0 ? model.visibleTrialNote : nil }

    private var title: String { PageTitle.text(loadedMixName: model.loadedMixName) }

    /// A name the person wrote may shrink a little before it is cut.
    private var isOwnName: Bool {
        model.loadedMixName != nil && model.activeHouseMix == nil && !model.loadedMixWasStripped
    }

    /// A mix that plays trimmed: its title is "<name> · without <layer>",
    /// and the layer is what the title is there to say.
    private var isTrimmedName: Bool {
        model.loadedMixName != nil && model.loadedMixWasStripped
    }

    /// The line of the name at full size: the name keeps it when it is set
    /// smaller, so nothing under it moves.
    private var nameHeight: CGFloat {
        UIFont.systemFont(ofSize: TypeStep.name.scaledSize(for: dynamicType), weight: .medium).lineHeight
    }

    private func nameText(_ text: String) -> some View {
        Text(verbatim: text)
            .step(.name)
            .foregroundStyle(Ink.primary(phase))
            .lineLimit(dynamicType.isAccessibilitySize ? 2 : 1)
            .truncationMode(.tail)
    }

    /// The words of the name. A trimmed title is never cut on the layer it
    /// names: it is set whole, then smaller (down to 0.7), and only when
    /// even that does not fit is the name left alone, uncut.
    @ViewBuilder private var nameWords: some View {
        if isTrimmedName, !dynamicType.isAccessibilitySize {
            ViewThatFits(in: .horizontal) {
                nameText(title).fixedSize()
                ShrinkToFit(least: Self.trimmedNameScale) {
                    nameText(title).minimumScaleFactor(Self.trimmedNameScale)
                }
                nameText(model.loadedMixBaseName ?? title).minimumScaleFactor(0.8)
            }
        } else {
            nameText(title).minimumScaleFactor(isOwnName ? 0.8 : 1)
        }
    }

    private static let trimmedNameScale: CGFloat = 0.7

    /// A fourth mix without access: the menu says so before the touch.
    private var saveNeedsPro: Bool { !model.canSaveMix }

    /// The loaded mix is one the person saved: its name can be changed.
    private var loadedSavedMix: SavedMix? {
        model.loadedSavedMixID.flatMap { model.mixStore.mix($0) }
    }

    private var name: some View {
        // The tap on the name is the one way out of the night page: its
        // touch area is 64 pt there, taken from the air above and below, so
        // nothing moves.
        let reach = model.isNightSession ? max(0, (Grid.largeTarget - nameLine) / 2) : 0
        return nameWords
            .contentTransition(.opacity)
            .animation(Motion.contentCurve, value: title)
            .frame(maxWidth: .infinity, minHeight: nameHeight, alignment: .leading)
            .padding(.vertical, reach)
            .contentShape(Rectangle())
            .padding(.vertical, -reach)
            .onTapGesture {
                // By day a tap on the name does nothing. On the night page
                // it is the deliberate way back to the day page.
                if model.isNightSession { model.endNightSession() }
            }
            .contextMenu {
                // Saving, renaming and clearing are things of the day: on
                // the night page a long press does nothing (08 §2.2).
                if !model.isNightSession {
                    nameMenu
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityFocused($focusesName)
            .accessibilityLabel(Text("mezcla.guardar.campo"))
            .accessibilityValue(Text(verbatim: PageStatus.spoken(title)))
            .accessibilityHint(Text(model.isNightSession ? "ax.nombre.pista.noche" : "ax.nombre.pista"))
            .accessibilityAddTraits(model.isNightSession ? .isButton : .isHeader)
            .accessibilityActions {
                // On the night page the only action is the way back (05 §5b).
                if model.isNightSession {
                    Button {
                        model.endNightSession()
                    } label: {
                        Text("ax.accion.volver.dia")
                    }
                } else {
                    Button {
                        beginSave()
                    } label: {
                        Text(saveNeedsPro ? "ax.guardar.pro" : "ax.accion.guardar")
                    }
                    if let mix = loadedSavedMix {
                        Button {
                            naming.beginRename(mix)
                        } label: {
                            Text("comun.renombrar")
                        }
                    }
                    Button {
                        model.clearMix()
                    } label: {
                        Text("mezcla.menu.vaciar")
                    }
                }
            }
            .accessibilityIdentifier("mixName")
    }

    /// The menu of the name: save, rename the loaded mix if it is one of
    /// the person's, and clear.
    @ViewBuilder private var nameMenu: some View {
        if saveNeedsPro {
            // While nothing may be sold the touch does nothing, so no hint
            // offers Pro.
            // The word "pro" is the second line of the item: inside the
            // title, the system menu broke the line before its dot.
            Button {
                beginSave()
            } label: {
                Text("mezcla.menu.guardar")
                Text("comun.pro")
            }
            // Nothing sells now: an item that would do nothing is not
            // offered as if it did.
            .disabled(!model.canSell)
            .accessibilityLabel(Text("ax.guardar.pro"))
            .accessibilityHint(model.canSell ? Text("ax.guardar.pro.pista") : Text(verbatim: ""))
        } else {
            Button {
                beginSave()
            } label: {
                Text("mezcla.menu.guardar")
            }
        }
        if let mix = loadedSavedMix {
            Button {
                naming.beginRename(mix)
            } label: {
                Text("comun.renombrar")
            }
        }
        Button {
            model.clearMix()
        } label: {
            Text("mezcla.menu.vaciar")
        }
        .accessibilityHint(Text("ax.vaciar.pista"))
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
        PageLayers.moreValue(
            model.levels,
            rows: shown,
            waiting: model.waitingLayers,
            more: { Localized.format("capas.mas", Int64($0)) },
            cap: Localized.string("capas.tope")
        )
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
            } onNight: {
                enterNight()
            }
            .environment(\.nightPhase, phase)
            #if DEBUG
            .modifier(DebugDynamicType())
            #endif
        case .timer:
            TimerSheet(model: model)
                .environment(\.nightPhase, phase)
                #if DEBUG
                .modifier(DebugDynamicType())
                #endif
        case .tide:
            TideSheet(model: model)
                .environment(\.nightPhase, phase)
                #if DEBUG
                .modifier(DebugDynamicType())
                #endif
        case .mixes:
            MixesSheet(model: model, purchases: purchases) {
                sheet = nil
            } onNight: {
                enterNight()
            } onSettings: {
                // Settings takes the place of Mixes: one sheet at a time.
                sheet = .settings
            }
            .environment(\.nightPhase, phase)
            #if DEBUG
            .modifier(DebugDynamicType())
            #endif
        case .settings:
            SettingsSheet(model: model, purchases: purchases)
                .environment(\.nightPhase, phase)
                #if DEBUG
                .modifier(DebugDynamicType())
                #endif
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

    /// "Night" on the bar. It always works: the sheet in front, if any,
    /// closes, the mix starts if it was at rest and Night covers the page.
    private func enterNight() {
        sheet = nil
        model.enterBedtime()
    }

    private func beginSave() {
        guard model.canSaveMix else {
            // Dropped while nothing may be sold: the mix stays as it is.
            model.offerPro()
            return
        }
        naming.beginSave(model)
    }
}

/// What the page can put in front of itself.
enum PageSheet: String, Identifiable {
    case layers
    case timer
    case tide
    case mixes
    case settings

    var id: String { rawValue }

    /// Layers and Settings put the Pro sheet over themselves and are still
    /// there when it closes. The others step aside for it.
    var presentsPro: Bool { self == .layers || self == .settings }

    /// The trial has just started with this sheet under the Pro sheet.
    /// Layers stays: its rows open under the finger. Settings says nothing
    /// of the trial, so it leaves with the Pro sheet and the page is read.
    func closesWhenTrialStarts(from before: TrialState, to after: TrialState) -> Bool {
        guard self == .settings, before == .notStarted, case .active = after else { return false }
        return true
    }
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
    /// The band the water line of the tide moves in, measured up from the
    /// bottom of the Horizon's own band (05 §2.3; 96 on a short screen,
    /// where 120 would reach the state line, 05 §2.13).
    var tideBand: CGFloat { isShort ? 96 : TideLine.band }
    var airOverTide: CGFloat { isShort ? Grid.unit * 6 : Grid.group }
}

// MARK: - Head lines

/// The trial word above the name (05 §2.1): a state word that opens the Pro
/// sheet. It exists only while something may be sold: inside the night
/// window, on the night page and in Small Hours the line is empty, because
/// nothing sells and nothing speaks of the trial at night (C08). Its line is
/// always there, so nothing below it moves.
private struct PageHeaderWord: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager
    let canSell: Bool

    @ScaledMetric(relativeTo: .footnote) private var line: CGFloat = 18

    private var word: String? {
        PageTrialWord.text(
            trial: purchases.trialState,
            isPro: purchases.isPro,
            showsAlwaysFree: purchases.showsAlwaysFree,
            canSell: canSell
        )
    }

    private var spokenWord: String {
        PageTrialWord.spoken(
            trial: purchases.trialState,
            isPro: purchases.isPro,
            showsAlwaysFree: purchases.showsAlwaysFree,
            canSell: canSell
        ) ?? ""
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if let word {
                Button {
                    model.offerPro()
                } label: {
                    StateWord(text: word)
                        .frame(minHeight: Grid.target)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressedFadeStyle())
                .accessibilityLabel(Text(verbatim: spokenWord))
                .accessibilityHint(Text("ax.prueba.pista"))
                .accessibilityIdentifier("openPro")
                .transition(.opacity)
            }
        }
        // The touch area is 44 pt; the line it sits on is 18.
        .frame(height: line)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(Motion.contentCurve, value: word)
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
    /// A word that takes the line for a moment ("Saved"). The error line,
    /// which is a button, is never covered by it.
    var note: String?
    /// What the page may say once about the trial: the last night takes
    /// the place of "Silent" until the Play.
    var trialNote: TrialNote?

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
            timerEndsAtAnHour: timer.choice.mode == .blanket,
            timerIsFading: timer.isFading,
            timerRemaining: timer.remaining,
            omitted: model.unheardLayers,
            isSilent: model.isSilent,
            isPlayingFallback: model.isPlayingFallback,
            isNightSession: model.isNightSession,
            lostOutputWasHeadphones: model.lostOutputWasHeadphones,
            cappedLevelNote: model.cappedLevelNote
        ))
    }

    /// "Keep playing on speaker" (C49): on the second line, for the minute
    /// the offer lasts. The error line is a button of its own and rules.
    private func showsSpeakerOffer(_ status: PageStatus) -> Bool {
        model.speakerOfferUntil != nil && !model.isPlaying && !status.isRetry
    }

    private var offerHeight: CGFloat {
        Grid.textAction(dynamicType: dynamicType, night: phase.isNight)
    }

    var body: some View {
        let status = self.status
        // The last night of the trial takes the place of "Silent".
        let lastNight = note == nil ? PageTrialNote.statusLine(trialNote, status: status) : nil
        let text = status.isRetry ? status.text() : note ?? lastNight ?? status.text()
        let offers = showsSpeakerOffer(status)
        // With larger text the action takes its own room under the words.
        let offerIsInline = dynamicType.isAccessibilitySize
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
                // Two sentences: one per line, like the error line.
                words(lastNight == nil ? text : PageStatus.errorLines(text, bindsTail: false))
                    .lineLimit(lastNight == nil ? (dynamicType >= .accessibility3 ? 3 : 2) : nil)
                    .accessibilityLabel(Text(verbatim: PageStatus.spoken(text)))
                    .accessibilityIdentifier("pageStatus")
            }
        }
        .frame(maxWidth: .infinity, minHeight: twoLines, alignment: .topLeading)
        .padding(.bottom, offers && offerIsInline ? offerHeight : 0)
        .overlay(alignment: offerIsInline ? .bottomLeading : .topLeading) {
            if offers {
                // Centred on the second line; its touch area reaches into
                // the air around it, so nothing moves when it comes or goes.
                TextAction(title: Localized.string(RoutePolicy.speakerOfferKey), alignment: .leading) {
                    model.continueOnSpeaker()
                }
                .padding(.horizontal, -Grid.margin)
                .offset(y: offerIsInline ? 0 : twoLines * 0.75 - offerHeight / 2)
                .accessibilityHint(Text(verbatim: Localized.format(
                    "ax.altavoz.pista", Int64(NightAxis.percent(RoutePolicy.speakerMasterCap))
                )))
                .accessibilityIdentifier("pageSpeaker")
                .transition(.opacity)
            }
        }
        .animation(Motion.contentCurve, value: offers)
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

/// "The trial is over. What you used is still here." and "Got it" under it
/// (08 §2.4): once, by day and in silence. The action is 22 pt of words in
/// a 44 pt touch area that reaches into the air around it, so the note
/// sits above the Horizon and nothing moves when it goes.
private struct TrialEndedNote: View {
    var words: String
    var onDismiss: () -> Void

    @Environment(\.nightPhase) private var phase
    @Environment(\.dynamicTypeSize) private var dynamicType
    @ScaledMetric(relativeTo: .body) private var actionLine: CGFloat = 22

    private var actionHeight: CGFloat {
        Grid.textAction(dynamicType: dynamicType, night: phase.isNight)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Grid.unit) {
            Text(verbatim: words)
                .step(.secondary)
                .foregroundStyle(Ink.secondary(phase))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("trialEndedNote")
            // With larger text the action takes its own room.
            Color.clear
                .frame(height: dynamicType.isAccessibilitySize ? actionHeight : actionLine)
                .frame(maxWidth: .infinity)
                .overlay {
                    TextAction(title: Localized.string(PageTrialNote.dismissKey), alignment: .leading) {
                        onDismiss()
                    }
                    .padding(.horizontal, -Grid.margin)
                    .accessibilityIdentifier("trialEndedDismiss")
                }
        }
    }
}

// MARK: - Tide and timer rows

/// The tide on the page: its name, its state in words and the switch,
/// drawn with tokens in plain ink (never the accent). The words open the tide sheet;
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
                // Centred on the name's line: its box is that line, and
                // its touch area reaches past it.
                .fixedSize()
                .frame(height: nameLine)
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
            set: { model.setBreathingEnabled($0, startsSound: true) }
        )) {
            Text("marea.titulo")
        }
        .toggleStyle(GrafitoToggleStyle(showsLabel: false))
    }

    /// With access the system says on or off. Without it the toggle says
    /// why it stays off, and only offers Pro while something may be sold.
    /// On the night page nothing says "requires Pro" (copy guide §3): the
    /// toggle just says it is off.
    @ViewBuilder private var toggle: some View {
        if isIncluded {
            // Turning it on over silence starts the night: say so.
            plainToggle
                .accessibilityHint(isOn || model.isPlaying ? Text(verbatim: "") : Text("ax.marea.pista"))
        } else if phase.isNight {
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
                "marea.estado.guiando.corto", Int64(guide.guidingRate ?? guide.settings.breathsPerMinute)
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

/// The timer on the page: the setting, never the count ("Until I sleep ·
/// 45 min", "Blanket · until 07:00", "Off"). The whole timer is free, so the
/// word "pro" never appears here. When it ends is said by the state line, as
/// an hour; VoiceOver also gets the minutes left on this row.
private struct TimerRow: View {
    @ObservedObject var timer: SleepTimerController
    var onOpen: () -> Void

    @Environment(\.calendar) private var calendar

    var body: some View {
        // The timer publishes nothing as the minutes go by. What VoiceOver
        // reads here is read again by the minute, only while it counts and
        // only while the page is on screen.
        TimelineView(.everyMinute) { _ in
            let input = TimerSheetText.Input(timer)
            EditorialRow(
                title: Localized.string("temporizador.titulo"),
                value: TimerSheetText.setting(
                    timer.choice,
                    hour: TimerSheetText.blanketHour(timer.choice, on: Date(), calendar: calendar)
                ),
                rule: .top,
                action: onOpen
            )
            .accessibilityValue(Text(verbatim: TimerSheetText.settingSpokenValue(input) ?? ""))
            .accessibilityIdentifier("openTimer")
        }
    }
}

// MARK: - Horizon and water line

/// The Horizon of the page and, while the tide guides, its water line
/// (06 §2.4, 05 §2.3): one line, never two.
///
/// The band of the water line reaches up from the bottom of the Horizon's
/// own band into the air above it, so low water is the Horizon and nothing
/// on the page is laid out differently with or without the tide. While the
/// tide has a course the Horizon steps back and the same place is the water
/// line: the accent by day (colour means sound), plain ink while a finger
/// holds a level, the one ink at night. It reads the curve and the anchor
/// the audio uses, like the line of the tide sheet.
private struct PageHorizon: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var guide: BreathingGuideController
    var band: CGFloat
    var showsWater: Bool

    @Environment(\.indexArbiter) private var arbiter
    @Environment(\.nightPhase) private var phase
    @Environment(\.sheetPresented) private var sheetPresented
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// From the top of the band to high water, and from low water (the
    /// Horizon, in the middle of its own band) to the bottom.
    private static let highWater: CGFloat = 8
    private static var lowWater: CGFloat { Grid.horizonBand / 2 }

    /// The tide is guiding or letting go under a night that plays.
    private var hasCourse: Bool {
        showsWater && model.isPlaying && !model.isSmallHours && model.breathingIsIncluded && guide.isActive
    }

    private var ink: Color {
        if phase.isNight { return Ink.textNight }
        return arbiter.fingerIsDown ? Ink.text : Ink.index
    }

    var body: some View {
        let hasCourse = self.hasCourse
        SoundLine(isSounding: model.isPlaying) { tau in
            model.outputLevel(tau: tau)
        }
        .opacity(hasCourse ? 0 : 1)
        .overlay(alignment: .bottom) {
            if showsWater {
                TideLine(
                    mode: hasCourse ? (sheetPresented ? .paused : .moving) : .off,
                    level: { date in
                        let now = guide.onGuideClock(date)
                        return TideBreath.level(at: now, anchor: guide.anchor, parameters: guide.lastPublished)
                            * (guide.scheduledWeight(now: now) ?? 1)
                    },
                    band: band,
                    highWaterInset: Self.highWater - TideLine.thickness / 2,
                    lowWaterInset: Self.lowWater - TideLine.thickness / 2,
                    ink: ink
                )
                .padding(.horizontal, Grid.margin)
                .opacity(hasCourse ? 1 : 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
        .animation(.easeInOut(duration: reduceMotion ? Motion.content : PlaybackFade.start), value: hasCourse)
    }
}

/// Lets a single line of text be offered to `ViewThatFits` at the width it
/// would have set smaller: its ideal width is `least` times the text's own,
/// and the text inside (with a `minimumScaleFactor`) shrinks only as far
/// as the room it is given asks.
private struct ShrinkToFit: Layout {
    var least: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let text = subviews.first else { return .zero }
        let ideal = text.sizeThatFits(.unspecified)
        guard let width = proposal.width else {
            return CGSize(width: ideal.width * least, height: ideal.height)
        }
        return CGSize(width: min(width, ideal.width), height: ideal.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(
            at: CGPoint(x: bounds.minX, y: bounds.midY),
            anchor: .leading,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
        )
    }
}
