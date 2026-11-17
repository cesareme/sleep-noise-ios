import SwiftUI

/// The Pro sheet (03 §5, surfaces 14, 15 and 33): "how much, once, and what
/// stays free?".
///
/// A sheet on `hoja`. The price is the first thing read and the purchase
/// the last thing that costs money; between them there is nothing to
/// touch. The name and the price are the App Store's. The foot is fixed:
/// "Start the trial · 7 nights" while the trial was never used (the only
/// way it starts, C07), the purchase between the only two hairlines of
/// accent in the app, the restore, and one line that is the footer or what
/// just happened. No spinner, no red, no badge: a state is a word.
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
    @ScaledMetric(relativeTo: .footnote) private var titleLine: CGFloat = 18
    @ScaledMetric(relativeTo: .footnote) private var headerBox: CGFloat = 28
    /// Three lines of the footer step and their air: the longest result
    /// line fits, so the foot never changes height.
    @ScaledMetric(relativeTo: .footnote) private var footerBox: CGFloat = 60
    @State private var wasProWhenOpened: Bool

    init(purchases: PurchaseManager, model: MixerModel) {
        self.purchases = purchases
        self.model = model
        _wasProWhenOpened = State(initialValue: purchases.isPro)
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
    /// in reach (the trial, the purchase, the restore); "Not now" and the
    /// footer go to the end of the column, which scrolls.
    private var isLargeText: Bool { dynamicType.isAccessibilitySize }

    var body: some View {
        let content = self.content
        ScrollView {
            column(content)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            foot(content)
        }
        .grafitoSheet(surface: .sheet)
        // The sheet only exists by day: it never takes the night ink.
        .environment(\.nightPhase, .day)
        .animation(Motion.contentCurve, value: content)
        .task {
            await purchases.refresh()
        }
        .task(id: content.closesItself) {
            // "Thank you" stays a moment and the sheet comes down.
            guard content.closesItself else { return }
            #if DEBUG
            if ProArguments.holdsThanks { return }
            #endif
            try? await Task.sleep(for: .milliseconds(1500))
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
            purchases.clearNotice()
        }
        .accessibilityAction(.magicTap) { model.togglePlayback() }
    }

    // MARK: The column

    private func column(_ content: ProSheetContent) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            StateWord(text: ProSheetText.title(content))
                .frame(minHeight: titleLine, alignment: .leading)
                .padding(.top, Grid.unit * 6)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("pro.title")
            figure(content)
                .padding(.top, Grid.unit + 2)
            Text("pro.una_vez")
                .step(.note)
                .foregroundStyle(Ink.text2)
                .padding(.top, Grid.unit)
            Text("pro.pie")
                .step(.name)
                .foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Grid.inner + 2)
            Hairline()
                .padding(.top, Grid.unit * 6)
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
                .padding(.vertical, Grid.unit * 3 - 1)
            if content.showsStartTrial, dynamicType >= .accessibility3 {
                // Where the foot no longer has room for it and the hint of
                // VoiceOver is not enough.
                Text("pro.prueba.empezar.nota")
                    .step(.note)
                    .foregroundStyle(Ink.text2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Grid.unit * 2)
            }
            if isLargeText {
                columnEnd(content)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Grid.margin)
        .padding(.bottom, Grid.unit * 6)
    }

    /// The price as the App Store gives it, or a dash until it does. On
    /// the receipt, the words of thanks in the same box: a hidden figure
    /// gives both the height of the price, so nothing under them moves.
    private func figure(_ content: ProSheetContent) -> some View {
        ZStack(alignment: .leading) {
            Text(verbatim: Localized.string("pro.precio.cargando"))
                .step(.figureSmall)
                .lineLimit(1)
                .hidden()
                .accessibilityHidden(true)
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
                Text(verbatim: Localized.string(detail))
                    .step(.secondary)
                    .foregroundStyle(Ink.text2)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, minHeight: Grid.target, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    /// With larger text: what left the foot.
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
            Text(verbatim: Localized.string(ProSheetText.footerKey))
                .step(.note)
                .foregroundStyle(Ink.text2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Grid.unit * 2)
        }
        .padding(.top, Grid.inner)
    }

    // MARK: The foot

    private func foot(_ content: ProSheetContent) -> some View {
        VStack(spacing: 0) {
            if content.showsStartTrial {
                HairlineAction(
                    title: Localized.string("pro.prueba.empezar"),
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
            if isLargeText {
                if let key = content.resultKey {
                    resultLine(key)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Grid.margin)
                        .padding(.bottom, Grid.unit * 2)
                }
            } else {
                footer(content)
            }
        }
        .background(Ink.sheet)
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
                title: ProSheetText.purchaseTitle(purchase),
                rules: .accent,
                isEnabled: content.canBuy,
                spokenTitle: ProSheetText.spokenPurchase(purchase, displayName: content.displayName),
                spokenValue: ProSheetText.purchaseValue(purchase),
                hint: ProSheetText.purchaseHint(purchase, storeIsAway: content.storeIsAway)
            ) {
                Task { await purchases.purchase() }
            }
            .accessibilityIdentifier("pro.purchase")
        }
    }

    /// The review link and the restore on the receipt; the restore and
    /// "Not now" on the sheet that sells. One row; stacked with larger
    /// text, where "Not now" is at the end of the column.
    @ViewBuilder private func secondaryActions(_ content: ProSheetContent) -> some View {
        let restore = TextAction(
            title: ProSheetText.restoreTitle(isRestoring: content.isRestoring),
            alignment: content.isReceipt && content.showsReview && !isLargeText ? .trailing : .leading
        ) {
            Task { await purchases.restore() }
        }
        .disabled(!content.isIdle)
        .accessibilityLabel(Text(verbatim: ProSheetText.spoken(
            ProSheetText.restoreTitle(isRestoring: content.isRestoring)
        )))
        .accessibilityIdentifier("pro.restore")

        let review = TextAction(title: Localized.string("pro.resena"), alignment: .leading) {
            if let url = AppLinks.reviewURL() { openURL(url) }
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(Text("ax.resena.pista"))
        .accessibilityIdentifier("pro.review")

        if isLargeText {
            VStack(spacing: 0) {
                if content.showsReview { review }
                restore
            }
        } else {
            HStack(spacing: 0) {
                if content.showsReview { review }
                restore
                if content.showsNotNow {
                    TextAction(title: Localized.string("comun.ahora_no"), alignment: .trailing) {
                        model.dismissPro()
                    }
                    .disabled(content.purchase == .buying)
                    .accessibilityIdentifier("pro.notNow")
                }
            }
        }
    }

    /// The footer, or the one line that says what happened, in its place.
    private func footer(_ content: ProSheetContent) -> some View {
        ZStack {
            if let key = content.resultKey {
                resultLine(key)
                    .id(key)
                    .transition(.opacity)
            } else {
                Text(verbatim: Localized.string(ProSheetText.footerKey))
                    .step(.note)
                    .foregroundStyle(Ink.text2)
                    .transition(.opacity)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, minHeight: footerBox, alignment: .top)
        .padding(.horizontal, Grid.margin)
    }

    private func resultLine(_ key: String) -> some View {
        Text(verbatim: Localized.string(key))
            .step(.note)
            .foregroundStyle(Ink.text2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("pro.result")
    }

    // MARK: Actions

    private func startTrial() {
        switch model.startTrial() {
        case .started:
            // The sheet is on its way down; the page already says it.
            if let word = PageTrialWord.spoken(trial: purchases.trialState, isPro: false) {
                announce(word)
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
        AccessibilityNotification.Announcement(ProSheetText.spoken(text)).post()
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
