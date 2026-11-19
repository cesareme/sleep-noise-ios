import SwiftUI

/// Settings (03 §5, surface 18): the short list of 1.0.
///
/// A sheet on `hoja`, opened from the last row of Mixes. Night ("Keep
/// screen on"), Pro (its state, and the way into the Pro sheet by day),
/// "What's not here" and, once the owner gives an address, "Write to the
/// author". Every row is a real setting or a page of text: nothing here
/// sells, rates or asks.
///
/// Opened from the night page it takes its one ink, and the Pro row is
/// words: nothing sells at night. Without Pro, "Restore purchase" is then a
/// row of its own under it (`SettingsRestoreRow`): what was paid for is
/// never out of reach until the morning. Whether that row is there is
/// decided when the sheet opens and does not change while it is open.
struct SettingsSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager

    @Environment(\.nightPhase) private var phase
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @ScaledMetric(relativeTo: .footnote) private var headerLine: CGFloat = 18
    @State private var path: [SettingsPage]
    /// "Restore purchase" is part of this visit, from the moment the sheet
    /// opens until it closes.
    @State private var hasRestoreRow: Bool
    /// "Restore purchase" was pressed in this visit, or was still looking
    /// when the sheet opened: its line is said here.
    @State private var askedRestore: Bool

    init(model: MixerModel, purchases: PurchaseManager) {
        self.model = model
        self.purchases = purchases
        // Read when the sheet is built, kept by the first draw: SwiftUI
        // ignores these values on every later one.
        _hasRestoreRow = State(initialValue: SettingsRestoreRow.existsOnOpen(
            isPro: purchases.isPro, canSell: model.canSell, activity: purchases.activity
        ))
        _askedRestore = State(initialValue: SettingsRestoreRow.askedOnOpen(activity: purchases.activity))
        #if DEBUG
        _path = State(initialValue: SettingsArguments.initialPath)
        #else
        _path = State(initialValue: [])
        #endif
    }

    /// The name on the Home Screen, read from the bundle.
    static var appName: String {
        let bundle = Bundle.main
        return bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ""
    }

    private var authorURL: URL? {
        guard let url = AppLinks.authorURL(subject: Self.appName), UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        return url
    }

    var body: some View {
        // Read once per draw; the model checks again on the tap.
        let canSell = model.canSell
        let restore = restoreRow
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                SheetHeader(title: Localized.string("ajustes.titulo"))
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header(Localized.string("ajustes.seccion.noche"))
                            .padding(.top, Grid.inner)
                        keepScreenOnRow
                        header(Localized.string(SettingsText.paintSectionKey))
                            .padding(.top, Grid.group)
                        paintRow
                        paintNote
                        header(Localized.string("ajustes.seccion.pro"))
                            .padding(.top, Grid.group)
                        proRow(canSell: canSell)
                        if restore.exists {
                            restoreAction(restore)
                            restoreResult(restore)
                        }
                        header(SettingsText.aboutHeader(appName: Self.appName))
                            // The place of the restore line is air already.
                            // At the accessibility sizes no place is kept,
                            // so the air is the group's again.
                            .padding(.top, restore.exists && !isLargeText ? Grid.inner : Grid.group)
                        EditorialRow(title: Localized.string("lo_que_no_hay.titulo")) {
                            path.append(.whatIsNotHere)
                        }
                        .accessibilityIdentifier("settings.whatIsNotHere")
                        if let authorURL {
                            EditorialRow(title: Localized.string("ajustes.autor")) {
                                openURL(authorURL)
                            }
                            .accessibilityHint(Text("ax.autor.pista"))
                            .accessibilityIdentifier("settings.author")
                        }
                        Text(verbatim: Localized.string(ProSheetText.footerKey))
                            .step(.note)
                            .foregroundStyle(Ink.secondary(phase))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, Grid.margin)
                            .padding(.top, Grid.group)
                    }
                    .padding(.bottom, Grid.group)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .background(Ink.sheet)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SettingsPage.self) { page in
                switch page {
                case .whatIsNotHere: WhatIsNotHerePage()
                }
            }
        }
        .tint(Ink.secondary(phase))
        .grafitoSheet(surface: .sheet)
        .accessibilityAction(.magicTap) { model.togglePlayback() }
        .sheet(isPresented: Binding(
            get: { model.showPaywall },
            set: { if !$0 { model.dismissPro() } }
        )) {
            ProSheet(purchases: purchases, model: model)
                #if DEBUG
                .modifier(DebugDynamicType())
                #endif
        }
        .onChange(of: restore.resultKey) { _, key in
            // About what was paid for: said over whatever is being read.
            guard let key else { return }
            var words = AttributedString(ProSheetText.spoken(Localized.string(key)))
            words.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(words).post()
        }
        .onDisappear {
            // The line of this visit says nothing about the next one, in
            // Settings or in the Pro sheet.
            if askedRestore, purchases.activity == .idle { purchases.clearNotice() }
        }
        #if DEBUG
        .task {
            // A capture of the row after its answer: pressed once the
            // sheet is up and the store has given the name.
            guard SettingsArguments.restoresOnAppear else { return }
            try? await Task.sleep(for: .milliseconds(1200))
            PageStage.stageRestore()
            restorePurchase()
        }
        #endif
    }

    private func header(_ text: String) -> some View {
        Text(verbatim: text)
            .step(.stateWord)
            .foregroundStyle(Ink.secondary(phase))
            .frame(minHeight: headerLine)
            .padding(.horizontal, Grid.margin)
            .padding(.bottom, Grid.unit + 2)
            .accessibilityAddTraits(.isHeader)
    }

    /// "Keep screen on" (C46): what the Night screen asks of the iPhone.
    private var keepScreenOnRow: some View {
        MenuRow(
            title: Localized.string("ajustes.pantalla"),
            value: Localized.string(SettingsText.keepScreenOnKey(model.keepScreenOn)),
            // The value of every row of Settings is in the same step.
            valueStep: .secondary
        ) {
            Picker(selection: Binding(
                get: { model.keepScreenOn },
                set: { model.setKeepScreenOn($0) }
            )) {
                ForEach(KeepScreenOn.allCases, id: \.self) { option in
                    Text(verbatim: Localized.string(SettingsText.keepScreenOnKey(option))).tag(option)
                }
            } label: {
                Text("ajustes.pantalla")
            }
        }
        .accessibilityIdentifier("settings.keepScreenOn")
    }

    /// Increase Contrast as the paint reads it: the system's, or the one a
    /// staged capture forces.
    private var paintContrast: Bool {
        #if DEBUG
        return contrast == .increased || PaintArguments.forcesIncreasedContrast
        #else
        return contrast == .increased
        #endif
    }

    private var paintMotion: Bool {
        #if DEBUG
        return reduceMotion || PaintArguments.forcesReduceMotion
        #else
        return reduceMotion
        #endif
    }

    /// "Paint" (exploration 12 §7 fase 2): by day, or never. The value is
    /// what the paint goes by; the choice stays the person's.
    private var paintRow: some View {
        MenuRow(
            title: Localized.string(SettingsText.paintTitleKey),
            value: Localized.string(SettingsText.paintValueKey(
                stored: model.paintSetting, reduceMotion: paintMotion, increaseContrast: paintContrast
            )),
            valueStep: .secondary
        ) {
            Picker(selection: Binding(
                get: { model.paintSetting },
                set: { model.setPaintSetting($0) }
            )) {
                ForEach(PaintSetting.allCases, id: \.self) { option in
                    Text(verbatim: Localized.string(SettingsText.paintKey(option))).tag(option)
                }
            } label: {
                Text("ajustes.pintura")
            }
        }
        .accessibilityIdentifier("settings.paint")
    }

    /// What the paint is, or why it is off on its own.
    private var paintNote: some View {
        Text(verbatim: Localized.string(SettingsText.paintNote(
            stored: model.paintSetting, reduceMotion: paintMotion, increaseContrast: paintContrast
        )))
        .step(.note)
        .foregroundStyle(Ink.secondary(phase))
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, Grid.margin)
        .padding(.top, Grid.unit * 2)
        .accessibilityIdentifier("settings.paint.note")
    }

    private func proRow(canSell: Bool) -> some View {
        let row = SettingsProRow(
            isPro: purchases.isPro,
            displayName: purchases.displayName,
            product: purchases.productState,
            receipt: purchases.receipt,
            canSell: canSell,
            // The row under this one was pressed: nothing here grows.
            holdsName: askedRestore
        )
        return EditorialRow(
            // Where it wraps, a line begins with the dot, never ends with it.
            title: LineTies.dotLeads(row.title),
            subtitle: row.subtitle,
            value: row.value.map { LineTies.dotLeads($0) },
            isInert: !row.opensSheet
        ) {
            model.offerPro()
        }
        .accessibilityLabel(Text(verbatim: row.spokenTitle))
        .accessibilityValue(Text(verbatim: row.spokenValue ?? ""))
        .accessibilityIdentifier("settings.pro")
    }
}

extension SettingsSheet {
    private var isLargeText: Bool { dynamicType.isAccessibilitySize }

    private var restoreRow: SettingsRestoreRow {
        SettingsRestoreRow(
            exists: hasRestoreRow,
            isPro: purchases.isPro,
            activity: purchases.activity,
            notice: purchases.notice,
            isPlaying: model.isPlaying,
            askedHere: askedRestore
        )
    }

    /// "Restore purchase": it asks the App Store and nothing else
    /// (`SettingsRestoreRow.restore(with:)`).
    private func restorePurchase() {
        let row = restoreRow
        guard row.isEnabled else { return }
        askedRestore = true
        // Caused by a touch, so it may be spoken: the answer can take as
        // long as typing the password of the account.
        AccessibilityNotification.Announcement(
            ProSheetText.spoken(Localized.string(SettingsRestoreRow.lookingKey))
        ).post()
        Task { await row.restore(with: purchases) }
    }

    /// One button from the touch to the answer: while it looks, and once
    /// Pro is there, it is disabled, not replaced, so VoiceOver keeps its
    /// place on it and says it is dimmed. With Pro it is words: the button
    /// trait goes too.
    private func restoreAction(_ row: SettingsRestoreRow) -> some View {
        let title = Localized.string(row.titleKey)
        return EditorialRow(title: title) {
            restorePurchase()
        }
        .disabled(!row.isEnabled)
        .accessibilityLabel(Text(verbatim: ProSheetText.spoken(title)))
        .accessibilityRemoveTraits(purchases.isPro ? .isButton : [])
        .accessibilityIdentifier("settings.restore")
    }

    /// What the restore brought, under its row. Up to the largest regular
    /// text size the place is always there, as tall as its longest line:
    /// the rows below never move. At the accessibility sizes that place
    /// would be most of a screen of nothing, and what is under it is
    /// already off the screen: only the line that is said is drawn.
    private func restoreResult(_ row: SettingsRestoreRow) -> some View {
        ZStack(alignment: .topLeading) {
            if !isLargeText {
                ForEach(SettingsRestoreRow.resultKeys, id: \.self) { key in
                    restoreLine(key)
                        .hidden()
                        .accessibilityHidden(true)
                }
            }
            if let key = row.resultKey {
                restoreLine(key)
                    .id(key)
                    .transition(.opacity)
                    .accessibilityIdentifier("settings.restore.result")
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, Grid.margin)
        .padding(.top, row.resultKey != nil || !isLargeText ? Grid.unit * 2 : 0)
        .animation(Motion.contentCurve, value: row.resultKey)
    }

    private func restoreLine(_ key: String) -> some View {
        Text(verbatim: Localized.string(key))
            .step(.note)
            .foregroundStyle(Ink.secondary(phase))
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// What Settings pushes inside its own sheet.
enum SettingsPage: Hashable {
    case whatIsNotHere
}

/// "What's not here" (03 §5, surface 32): what does not exist, as facts of
/// today, one per line. No icons and no ticks: the words are the facts.
struct WhatIsNotHerePage: View {
    @Environment(\.nightPhase) private var phase

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: Localized.string("lo_que_no_hay.titulo"))
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(SettingsText.facts(), id: \.self) { fact in
                        words(fact)
                    }
                    Hairline()
                        .padding(.vertical, Grid.unit * 6)
                    // No footer here: it would repeat the first three
                    // facts of this very page.
                    words(Localized.string("lo_que_no_hay.resena"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Grid.margin)
                .padding(.top, Grid.unit * 6)
                .padding(.bottom, Grid.group)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Ink.sheet)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Ink.sheet, for: .navigationBar)
    }

    private func words(_ text: String) -> some View {
        Text(verbatim: text)
            .step(.reading)
            .foregroundStyle(Ink.primary(phase))
            .fixedSize(horizontal: false, vertical: true)
            // Whole lines of the reading step, so the facts keep their
            // 26 pt from one to the next.
            .lineBox(.reading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
/// What a staged Settings sheet opens on.
enum SettingsArguments {
    static var initialPath: [SettingsPage] {
        PageArguments.state == .settingsNotHere ? [.whatIsNotHere] : []
    }

    /// The capture is of "Restore purchase" after it was pressed.
    static var restoresOnAppear: Bool {
        PageArguments.state?.restoreOutcome != nil
    }
}
#endif
