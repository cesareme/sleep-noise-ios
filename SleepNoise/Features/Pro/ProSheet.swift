import SwiftUI

/// The Pro sheet (03 §5, surfaces 14, 15 and 33): "how much, once, and what
/// stays free?".
///
/// A sheet on `hoja`. The price is the first thing read and the purchase
/// the last thing that costs money; between them there is nothing to
/// touch. The name and the price are the App Store's. The foot is fixed:
/// "Start the trial · 7 nights" while the trial was never used (the only
/// way it starts, C07), the purchase between the only two hairlines of
/// accent in the app, the restore, and one line: what the trial is while
/// it is on offer, the footer otherwise, or what just happened. No spinner,
/// no red, no badge: a state is a word.
///
/// Bought, the same sheet is the receipt: the date, what was paid for, and
/// a link to the review page instead of a button that costs money.
///
/// It never goes up at night: every request passes `MixerModel.offerPro()`.
struct ProSheet: View {
    @ObservedObject var purchases: PurchaseManager
    @ObservedObject var model: MixerModel

    @Environment(\.dynamicTypeSize) private var dynamicType
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @ScaledMetric(relativeTo: .footnote) private var titleLine: CGFloat = 18
    @ScaledMetric(relativeTo: .footnote) private var headerBox: CGFloat = 28
    /// A line of "with pro" is words, not a target: 36 pt, not 44.
    @ScaledMetric(relativeTo: .body) private var includedLine: CGFloat = 36
    /// The line that names its textures under it: 22 of words and 18 of
    /// names, with no air of its own.
    @ScaledMetric(relativeTo: .body) private var detailedLine: CGFloat = 40
    /// Air under the last line of the foot, over the home indicator.
    @ScaledMetric(relativeTo: .footnote) private var footAir: CGFloat = 6
    /// False on a phone with a home button: nothing keeps the last line of
    /// the foot off the edge of the glass there but the foot itself.
    @State private var hasHomeIndicator = true
    @State private var wasProWhenOpened: Bool
    /// The trial was on offer when the sheet went up: its note keeps its
    /// room at the foot until the sheet closes, so buying from this sheet
    /// does not move what is under the purchase.
    @State private var offeredTrialWhenOpened: Bool

    init(purchases: PurchaseManager, model: MixerModel) {
        self.purchases = purchases
        self.model = model
        _wasProWhenOpened = State(initialValue: purchases.isPro)
        _offeredTrialWhenOpened = State(initialValue: !purchases.isPro && purchases.trialState == .notStarted)
    }

    /// Every line the foot may say while this sheet is up.
    private func reservedFootKeys(_ content: ProSheetContent) -> [String] {
        var keys = content.footKeys
        if offeredTrialWhenOpened, !keys.contains(ProSheetText.trialNoteKey) {
            keys.append(ProSheetText.trialNoteKey)
        }
        return keys
    }

    private var content: ProSheetContent {
        ProSheetContent(ProSheetContent.Input(
            isPro: purchases.isPro,
            wasProWhenOpened: wasProWhenOpened,
            trial: purchases.trialState,
            product: purchases.productState,
            activity: purchases.activity,
            isPurchasePending: purchases.isPurchasePending,
            notice: purchases.notice,
            receipt: purchases.receipt,
            displayName: purchases.displayName,
            isPlaying: model.isPlaying,
            hasReviewLink: hasReviewLink
        ))
    }

    private var hasReviewLink: Bool {
        #if DEBUG
        if ProArguments.stagesReviewLink { return true }
        #endif
        return AppLinks.reviewURL() != nil
    }

    /// From the first accessibility size the foot keeps only what must be
    /// in reach (the trial, the purchase, the restore) and never changes
    /// height; "Not now", the note of the trial and the line that says what
    /// happened go to the end of the column, which scrolls.
    private var isLargeText: Bool { dynamicType.isAccessibilitySize }

    private static let columnEndID = "pro.columnEnd"

    var body: some View {
        let content = self.content
        ScrollViewReader { proxy in
            ScrollView {
                column(content)
            }
            .scrollBounceBehavior(.basedOnSize)
            // Where the column does not fit, the foot cuts it between two
            // lines and nothing says there is more: the system's own
            // indicator shows once as the sheet goes up.
            .scrollIndicatorsFlash(onAppear: true)
            .onChange(of: content.resultKey) { _, key in
                // With larger text the line is at the end of the column:
                // the column goes to it, the foot stays where it is.
                guard key != nil, isLargeText else { return }
                withAnimation(Motion.contentCurve) {
                    proxy.scrollTo(Self.columnEndID, anchor: .bottom)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            foot(content)
                .background {
                    // Read here, under the foot, where the safe area is
                    // still the device's own.
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.safeAreaInsets.bottom, initial: true) { _, inset in
                                hasHomeIndicator = inset > 0
                            }
                    }
                }
        }
        .grafitoSheet(surface: .sheet)
        // The sheet only exists by day: it never takes the night ink.
        .environment(\.nightPhase, .day)
        // The confirmation of the App Store is up: the sheet under it is
        // not dragged away, or the purchase would end with nobody thanked.
        .interactiveDismissDisabled(content.purchase == .buying)
        .animation(Motion.contentCurve, value: content)
        .onAppear {
            // A line left by a restore that ended with the sheet closed
            // says nothing about this visit.
            if purchases.activity == .idle { purchases.clearNotice() }
        }
        .task {
            await purchases.refresh()
        }
        .task(id: content.closesItself) {
            // "Thank you" stays a moment and the sheet comes down. With
            // VoiceOver it stays long enough to be heard.
            guard content.closesItself else { return }
            #if DEBUG
            if ProArguments.holdsThanks { return }
            #endif
            try? await Task.sleep(for: .milliseconds(voiceOver ? 3000 : 1500))
            guard !Task.isCancelled else { return }
            model.dismissPro()
        }
        .onChange(of: content.resultKey) { _, key in
            if let key { announce(Localized.string(key)) }
        }
        .onChange(of: content.closesItself) { _, thanks in
            if thanks { announce(Localized.string("pro.gracias")) }
        }
        .onDisappear {
            if purchases.activity == .idle { purchases.clearNotice() }
        }
        .accessibilityAction(.magicTap) { model.togglePlayback() }
    }

    // MARK: The column

    private func column(_ content: ProSheetContent) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Where it has to wrap, a line begins with the dot and
                // never ends with it.
                StateWord(text: LineTies.dotLeads(ProSheetText.title(content)))
                    .frame(minHeight: titleLine, alignment: .leading)
                if let family = ProSheetText.familyLine(content) {
                    // Its own line, never a "·" left at the end of one.
                    StateWord(text: family)
                        .frame(minHeight: titleLine, alignment: .leading)
                }
            }
            .padding(.top, Grid.unit * 6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: ProSheetText.spokenTitle(content)))
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("pro.title")
            figure(content)
                .padding(.top, Grid.unit + 2)
            Text("pro.una_vez")
                .step(.note)
                .foregroundStyle(Ink.text2)
                .padding(.top, content.isReceipt ? Grid.unit * 2 : Grid.unit)
            Text("pro.pie")
                .step(.name)
                .foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Grid.inner + 2)
            Hairline()
                .padding(.top, Grid.inner)
            header("pro.con")
            ForEach(ProSheetText.includedKeys, id: \.self) { key in
                included(key, detail: key == "pro.incluye.texturas" ? "pro.incluye.texturas.detalle" : nil)
            }
            if content.listsFamily {
                included(ProSheetText.familyKey, detail: nil)
            }
            Hairline()
                .padding(.top, Grid.inner)
            header("pro.gratis")
            Text("pro.gratis.lista")
                .step(.body)
                .foregroundStyle(Ink.text2)
                .fixedSize(horizontal: false, vertical: true)
                // Right under its header, like the lines of "with pro".
                .accessibilityLabel(Text(verbatim: ProSheetText.spoken(Localized.string("pro.gratis.lista"))))
            if isLargeText {
                columnEnd(content)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Grid.margin)
        // No more air than this under the last line: a column that fits
        // must not scroll for the sake of its own margin.
        .padding(.bottom, isLargeText ? Grid.unit * 6 : Grid.unit * 2)
    }

    /// The price as the App Store gives it, or a dash until it does: a
    /// hidden figure gives the box its height, so nothing under it moves
    /// when the price arrives. On the receipt, the words of thanks, as
    /// tall as they are in this language: a line kept empty for another
    /// one reads as something missing.
    private func figure(_ content: ProSheetContent) -> some View {
        ZStack(alignment: .topLeading) {
            if !content.isReceipt {
                Text(verbatim: Localized.string("pro.precio.cargando"))
                    .step(.figureSmall)
                    .lineLimit(1)
                    .hidden()
                    .accessibilityHidden(true)
            }
            if content.isReceipt {
                Text("pro.gracias")
                    .step(.name)
                    .foregroundStyle(Ink.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
                    .accessibilityIdentifier("pro.thanks")
            } else {
                Text(verbatim: content.price ?? Localized.string("pro.precio.cargando"))
                    .step(.figureSmall)
                    .foregroundStyle(content.price == nil ? Ink.text3 : Ink.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.opacity)
                    .transition(.opacity)
                    .accessibilityLabel(Text(verbatim: content.price ?? Localized.string("ax.comprar.sin_precio.valor")))
                    .accessibilityIdentifier("pro.price")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func header(_ key: String) -> some View {
        Text(verbatim: Localized.string(key))
            .step(.stateWord)
            .foregroundStyle(Ink.text2)
            .frame(minHeight: headerBox, alignment: .leading)
            .padding(.top, Grid.unit * 2)
            .accessibilityAddTraits(.isHeader)
    }

    /// A line of what Pro includes: words, with no mark and no icon. The
    /// first one names its textures under it and never counts them (C04).
    private func included(_ key: String, detail: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: Localized.string(key))
                .step(.body)
                .foregroundStyle(Ink.text)
            if let detail {
                // The step of the notes of the foot (10 §2.8): six steps
                // on the sheet, and the names fit on one line.
                Text(verbatim: Localized.string(detail))
                    .step(.note)
                    .foregroundStyle(Ink.text2)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, minHeight: detail == nil ? includedLine : detailedLine, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    /// With larger text: what left the foot. The line that says what
    /// happened takes the place of the footer here, so the foot keeps its
    /// height and the three actions stay where they were.
    private func columnEnd(_ content: ProSheetContent) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if content.showsNotNow {
                TextAction(title: Localized.string("comun.ahora_no"), alignment: .leading) {
                    model.dismissPro()
                }
                .padding(.horizontal, -Grid.margin)
                .disabled(content.purchase == .buying)
                .accessibilityIdentifier("pro.notNow")
            }
            footLine(content)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Grid.unit * 2)
        }
        .padding(.top, Grid.inner)
        .id(Self.columnEndID)
    }

    // MARK: The foot

    private func foot(_ content: ProSheetContent) -> some View {
        VStack(spacing: 0) {
            if content.showsStartTrial {
                HairlineAction(
                    title: ProSheetText.trialTitle(stacked: isLargeText),
                    isEnabled: content.canStartTrial,
                    // The hairline under it is the first of the purchase.
                    showsBottomRule: false,
                    spokenTitle: Localized.string("ax.prueba.empezar"),
                    hint: Localized.string("ax.prueba.empezar.pista")
                ) {
                    startTrial()
                }
                .accessibilityIdentifier("pro.trial.start")
            }
            if let purchase = content.purchase {
                purchaseRow(purchase, content)
            }
            secondaryActions(content)
            if !isLargeText {
                // Every line this place can say is laid out, unseen, under
                // the one it says: the foot is as tall as the longest of
                // them at this width and in this language, and no taller,
                // so it never changes height and takes nothing it does not
                // need from the column.
                ZStack(alignment: .top) {
                    ForEach(reservedFootKeys(content), id: \.self) { key in
                        noteLine(key)
                            .hidden()
                            .accessibilityHidden(true)
                    }
                    footLine(content)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, Grid.margin)
                .padding(.bottom, hasHomeIndicator ? footAir : max(footAir, Grid.inner))
            }
        }
        .overlay(alignment: .top) {
            // The receipt and "Thank you" have no action with rules: the
            // foot draws its own upper edge, or the column would end
            // against nothing where it scrolls. Over the foot, so it adds
            // no height to it.
            if content.footOpensWithRule {
                Hairline()
                    .padding(.horizontal, Grid.margin)
                    .transition(.opacity)
            }
        }
        .background(Ink.sheet)
        // The foot is always on screen and does not scroll: past this size
        // it would leave the column a slit to be read through. Everything
        // above it keeps growing.
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }

    @ViewBuilder private func purchaseRow(
        _ purchase: ProSheetContent.Purchase,
        _ content: ProSheetContent
    ) -> some View {
        if purchase == .thanks {
            // In the place of the purchase, and not a button.
            Text("pro.gracias")
                .step(.row)
                .foregroundStyle(Ink.text)
                .multilineTextAlignment(.center)
                .padding(.vertical, Grid.unit * 3)
                .frame(maxWidth: .infinity, minHeight: Grid.primaryAction(dynamicType: dynamicType))
                .padding(.horizontal, Grid.margin)
                .transition(.opacity)
                .accessibilityIdentifier("pro.thanks")
        } else {
            HairlineAction(
                // The price is never cut from its currency by a line end.
                title: LineTies.dotLeads(ProSheetText.purchaseTitle(purchase)),
                rules: .accent,
                isEnabled: content.canBuy,
                spokenTitle: ProSheetText.spokenPurchase(purchase, displayName: content.displayName),
                spokenValue: ProSheetText.purchaseValue(purchase),
                hint: ProSheetText.purchaseHint(purchase, storeIsAway: content.storeIsAway)
            ) {
                // Through the mixer: the night gate is its.
                Task { await model.purchasePro() }
            }
            .accessibilityIdentifier("pro.purchase")
        }
    }

    /// The review link and the restore on the receipt; the restore and
    /// "Not now" on the sheet that sells. One row while both fit on a line
    /// each; stacked otherwise, and always with larger text, where "Not
    /// now" is at the end of the column.
    @ViewBuilder private func secondaryActions(_ content: ProSheetContent) -> some View {
        if isLargeText {
            VStack(spacing: 0) {
                if content.showsReview { review(.leading) }
                restore(content, alignment: .leading)
            }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) {
                    if content.showsReview {
                        review(.leading)
                        restore(content, alignment: .trailing)
                            .fixedSize(horizontal: true, vertical: false)
                    } else {
                        restore(content, alignment: .leading)
                    }
                    if content.showsNotNow {
                        notNow(content, alignment: .trailing)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                VStack(spacing: 0) {
                    if content.showsReview { review(.leading) }
                    restore(content, alignment: .leading)
                    if content.showsNotNow { notNow(content, alignment: .leading) }
                }
            }
        }
    }

    private func restore(_ content: ProSheetContent, alignment: Alignment) -> some View {
        TextAction(
            title: ProSheetText.restoreTitle(isRestoring: content.isRestoring),
            alignment: alignment,
            // "Looking…" is shorter: the row is measured with the words it
            // has at rest, so it does not change shape while it looks.
            sizingTitle: ProSheetText.restoreTitle(isRestoring: false)
        ) {
            Task { await purchases.restore() }
        }
        .disabled(!content.isIdle)
        .accessibilityLabel(Text(verbatim: ProSheetText.spoken(
            ProSheetText.restoreTitle(isRestoring: content.isRestoring)
        )))
        .accessibilityIdentifier("pro.restore")
    }

    private func review(_ alignment: Alignment) -> some View {
        TextAction(title: Localized.string("pro.resena"), alignment: alignment) {
            if let url = AppLinks.reviewURL() { openURL(url) }
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(Text("ax.resena.pista"))
        .accessibilityIdentifier("pro.review")
    }

    private func notNow(_ content: ProSheetContent, alignment: Alignment) -> some View {
        TextAction(title: Localized.string("comun.ahora_no"), alignment: alignment) {
            model.dismissPro()
        }
        .disabled(content.purchase == .buying)
        .accessibilityIdentifier("pro.notNow")
    }

    /// The one line under the actions: what just happened, or what is true
    /// at rest (`ProSheetContent.footKey`). One at a time, in one place.
    private func footLine(_ content: ProSheetContent) -> some View {
        ZStack {
            if let key = content.resultKey {
                noteLine(key)
                    .id(key)
                    .transition(.opacity)
                    .accessibilityIdentifier("pro.result")
            } else {
                noteLine(content.footKey)
                    .id(content.footKey)
                    .transition(.opacity)
            }
        }
    }

    private func noteLine(_ key: String) -> some View {
        Text(verbatim: Localized.string(key))
            .step(.note)
            .foregroundStyle(Ink.text2)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Actions

    private func startTrial() {
        switch model.startTrial() {
        case .started:
            // The sheet is on its way down and the page already says it.
            // Spoken once the sheet is gone: the change of screen would
            // talk over it.
            if let word = PageTrialWord.spoken(trial: purchases.trialState, isPro: false) {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(700))
                    Self.announce(word)
                }
            }
        case .closedAtNight:
            // The night began with the sheet up: it comes down, in silence.
            model.closeSaleIfNight()
        case .notNeeded, .alreadyUsed, .failed:
            // The sheet shows what is true now: the row is gone, or the
            // line under the purchase says nothing was granted.
            break
        }
    }

    private func announce(_ text: String) {
        Self.announce(text)
    }

    /// Said over whatever VoiceOver is reading: these lines are about
    /// money or about what just changed, and a sheet that moves must not
    /// swallow them.
    private static func announce(_ text: String) {
        var words = AttributedString(ProSheetText.spoken(text))
        words.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(words).post()
    }
}

#if DEBUG
/// What a staged Pro sheet needs to know about its own capture.
enum ProArguments {
    /// "Thank you" stays up: the sheet does not close itself.
    static var holdsThanks: Bool { PageArguments.state == .proThanks }
    /// The review link is drawn although the app has no App Store id yet.
    /// Staged, it opens nothing.
    static var stagesReviewLink: Bool { PageArguments.state == .proReceiptReview }
}
#endif
