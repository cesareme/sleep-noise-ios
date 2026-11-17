import SwiftUI

/// The Pro sheet as it was before Grafito, kept working on the new model
/// until it is rebuilt: the price and the store states come from
/// `PurchaseManager`, and the trial starts here and nowhere else (C07).
/// Purchase and Restore are keyed on `isPro`, never on trial access.
struct PaywallView: View {
    @ObservedObject var purchases: PurchaseManager
    @ObservedObject var model: MixerModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("paywall.title")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(Palette.text)
                        Text("paywall.subtitle")
                            .font(.body)
                            .foregroundStyle(Palette.muted)
                    }

                    VStack(spacing: 12) {
                        benefit(
                            symbol: "wind",
                            title: "paywall.benefit.breath",
                            detail: "paywall.benefit.breath.detail"
                        )
                        benefit(
                            symbol: "fan.fill",
                            title: "paywall.benefit.textures",
                            detail: "paywall.benefit.textures.detail"
                        )
                        benefit(
                            symbol: "square.stack.fill",
                            title: "paywall.benefit.mixes",
                            detail: "paywall.benefit.mixes.detail"
                        )
                    }

                    if purchases.isPro {
                        Label("paywall.active", systemImage: "checkmark.seal.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Palette.amber)
                    } else {
                        if purchases.canStartTrial {
                            Button {
                                model.startTrial()
                            } label: {
                                Text("pro.prueba.empezar")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 52)
                            }
                            .foregroundStyle(Palette.text)
                            .disabled(purchases.activity != .idle)
                            .accessibilityIdentifier("paywall.trial.start")
                        }
                        purchaseButton
                        Button {
                            Task { await purchases.restore() }
                        } label: {
                            Text("pro.restaurar")
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .disabled(purchases.activity != .idle)
                        .foregroundStyle(Palette.mist)
                    }

                    if let notice = purchases.notice {
                        Text(noticeText(notice))
                            .font(.footnote)
                            .foregroundStyle(Palette.amber)
                    }

                    Text("paywall.once")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                }
                .padding(24)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
                }
            }
        }
        .tint(Palette.amber)
        .preferredColorScheme(.dark)
        .task {
            await purchases.refresh()
        }
    }

    private var purchaseButton: some View {
        Button {
            Task { await purchases.purchase() }
        } label: {
            Group {
                if purchases.activity == .purchasing {
                    ProgressView()
                        .tint(Palette.background)
                } else if let price = purchases.product?.displayPrice {
                    Text(String(format: String(localized: "pro.comprar"), price))
                } else {
                    Text("pro.comprar.sin_precio")
                }
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(Palette.amber)
        .foregroundStyle(Palette.background)
        .disabled(purchases.activity != .idle || purchases.product == nil || purchases.isPurchasePending)
        .accessibilityIdentifier("paywall.purchase")
    }

    private func benefit(symbol: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(Palette.amber)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Palette.text)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.card)
        )
    }

    private func noticeText(_ notice: PurchaseNotice) -> LocalizedStringKey {
        switch notice {
        case .purchased, .restored: return "pro.gracias"
        case .nothingToRestore: return "pro.restaurar.no"
        case .pending: return "pro.pendiente"
        case .cancelled, .failed, .trialNotStarted: return "pro.fallo"
        case .unconfirmed: return "pro.fallo.sin_confirmar"
        case .storeUnavailable: return model.isPlaying ? "pro.sin_tienda" : "pro.sin_tienda.silencio"
        }
    }
}

/// Colours of this sheet, the last one not rebuilt in Grafito. They go with
/// it when the Pro sheet is redone; everything else uses `Ink`.
private enum Palette {
    static let background = Color(red: 0.055, green: 0.067, blue: 0.078)
    static let card = Color(red: 0.122, green: 0.137, blue: 0.153)
    static let amber = Color(red: 0.922, green: 0.722, blue: 0.451)
    static let mist = Color(red: 0.655, green: 0.745, blue: 0.753)
    static let text = Color(red: 0.933, green: 0.914, blue: 0.863)
    static let muted = Color(red: 0.58, green: 0.60, blue: 0.62)
}
