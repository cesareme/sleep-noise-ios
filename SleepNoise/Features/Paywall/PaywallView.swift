import SwiftUI

struct PaywallView: View {
    @ObservedObject var purchases: PurchaseManager
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
                            symbol: "fan.fill",
                            title: "paywall.benefit.textures",
                            detail: "paywall.benefit.textures.detail"
                        )
                        benefit(
                            symbol: "square.stack.fill",
                            title: "paywall.benefit.mixes",
                            detail: "paywall.benefit.mixes.detail"
                        )
                        benefit(
                            symbol: "timer",
                            title: "paywall.benefit.timer",
                            detail: "paywall.benefit.timer.detail"
                        )
                    }

                    if purchases.isPro {
                        Label("paywall.active", systemImage: "checkmark.seal.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Palette.amber)
                    } else {
                        purchaseButton
                        Button {
                            Task { await purchases.restore() }
                        } label: {
                            Text("paywall.restore")
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .disabled(purchases.isPurchasing)
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
                if purchases.isPurchasing {
                    ProgressView()
                        .tint(Palette.background)
                } else if let price = purchases.product?.displayPrice {
                    Text(String(format: String(localized: "paywall.purchaseFormat"), price))
                } else {
                    Text("paywall.purchaseUnavailable")
                }
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(Palette.amber)
        .foregroundStyle(Palette.background)
        .disabled(purchases.isPurchasing || purchases.product == nil)
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
        case .restored: return "paywall.restored"
        case .nothingToRestore: return "paywall.nothingToRestore"
        case .pending: return "paywall.pending"
        case .failed: return "paywall.failed"
        }
    }
}
