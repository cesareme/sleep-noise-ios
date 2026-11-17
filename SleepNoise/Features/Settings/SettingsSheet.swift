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
/// words: nothing sells at night.
struct SettingsSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager

    @Environment(\.nightPhase) private var phase
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .footnote) private var headerLine: CGFloat = 18
    @State private var path: [SettingsPage]

    init(model: MixerModel, purchases: PurchaseManager) {
        self.model = model
        self.purchases = purchases
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
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                SheetHeader(title: Localized.string("ajustes.titulo"))
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header(Localized.string("ajustes.seccion.noche"))
                            .padding(.top, Grid.inner)
                        keepScreenOnRow
                        header(Localized.string("ajustes.seccion.pro"))
                            .padding(.top, Grid.group)
                        proRow(canSell: canSell)
                        header(SettingsText.aboutHeader(appName: Self.appName))
                            .padding(.top, Grid.group)
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
            value: Localized.string(SettingsText.keepScreenOnKey(model.keepScreenOn))
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

    private func proRow(canSell: Bool) -> some View {
        let row = SettingsProRow(
            isPro: purchases.isPro,
            displayName: purchases.displayName,
            product: purchases.productState,
            receipt: purchases.receipt,
            canSell: canSell
        )
        return EditorialRow(title: row.title, value: row.value, isInert: !row.opensSheet) {
            model.offerPro()
        }
        .accessibilityLabel(Text(verbatim: PageStatus.spoken(row.title)))
        .accessibilityValue(Text(verbatim: row.spokenValue() ?? ""))
        .accessibilityIdentifier("settings.pro")
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
                    words(Localized.string("lo_que_no_hay.resena"))
                    Text(verbatim: Localized.string(ProSheetText.footerKey))
                        .step(.note)
                        .foregroundStyle(Ink.secondary(phase))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Grid.group)
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
}
#endif
