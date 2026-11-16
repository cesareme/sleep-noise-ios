import SwiftUI

/// Three states: purchased (badge), trial not started or running (disclosure
/// plus "keep everything"), trial over (plain unlock). Purchase and Restore
/// are keyed on `isPro`, never on trial access, so App Review, which always
/// lands inside the trial, can buy Pro.
struct PaywallView: View {
    @ObservedObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("paywall.title")
                            .font(DesignTokens.Typography.display(.medium))
                            .foregroundStyle(Palette.text)
                        Text("paywall.subtitle")
                            .tokenFont(.body)
                            .foregroundStyle(Palette.muted)
                    }

                    if !purchases.isPro {
                        trialStatus
                    }

                    VStack(spacing: 12) {
                        benefit(
                            symbol: "wind",
                            title: "paywall.benefit.breath",
                            detail: "paywall.benefit.breath.detail"
                        )
                        benefit(
                            symbol: "square.grid.2x2.fill",
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
                            .tokenFont(.body, weight: .semibold)
                            .foregroundStyle(Palette.amber)
                    } else {
                        purchaseButton
                        Button {
                            Task { await purchases.restore() }
                        } label: {
                            Text("paywall.restore")
                                .tokenFont(.body, weight: .medium)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .disabled(purchases.isPurchasing)
                        .foregroundStyle(Palette.mist)
                    }

                    if let notice = purchases.notice {
                        Text(noticeText(notice))
                            .tokenFont(.footnote)
                            .foregroundStyle(Palette.amber)
                    }

                    Text("paywall.once")
                        .tokenFont(.footnote)
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
        .task {
            await purchases.refresh()
        }
    }

    /// Trial disclosure: duration, what stays free afterwards, and that the
    /// mixes already saved are kept.
    private var trialStatus: some View {
        let (symbol, title, detail): (String, String, String) = {
            switch purchases.trialState {
            case .notStarted:
                return ("gift",
                        String(format: String(localized: "paywall.trial.titleFormat"), Int64(AccessPolicy.trialDays)),
                        String(format: String(localized: "paywall.trial.notStartedFormat"), Int64(AccessPolicy.trialDays)))
            case .active(let days):
                return ("hourglass",
                        String(format: String(localized: "paywall.trial.titleFormat"), Int64(AccessPolicy.trialDays)),
                        String.localizedStringWithFormat(String(localized: "paywall.trial.activeFormat"), days))
            case .ended:
                return ("hourglass.bottomhalf.filled",
                        String(localized: "paywall.trial.endedTitle"),
                        String(localized: "paywall.trial.endedDetail"))
            }
        }()
        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .tokenFont(.body, weight: .semibold)
                .foregroundStyle(Palette.amber)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .tokenFont(.body, weight: .semibold)
                    .foregroundStyle(Palette.text)
                Text(detail)
                    .tokenFont(.subheadline)
                    .foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.amber.opacity(0.10))
        )
        .accessibilityIdentifier("paywall.trial")
    }

    private var purchaseButton: some View {
        Button {
            Task { await purchases.purchase() }
        } label: {
            Group {
                if purchases.isPurchasing {
                    ProgressView()
                        .tint(Palette.onAccent)
                } else if let price = purchases.product?.displayPrice {
                    Text(String(format: String(localized: purchaseKey), price))
                } else {
                    Text("paywall.purchaseUnavailable")
                }
            }
            .tokenFont(.body, weight: .semibold)
            .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(Palette.amber)
        .foregroundStyle(Palette.onAccent)
        .disabled(purchases.isPurchasing || purchases.product == nil)
        .accessibilityIdentifier("paywall.purchase")
    }

    private var purchaseKey: String.LocalizationValue {
        switch purchases.trialState {
        case .notStarted, .active:
            return "paywall.keepFormat"
        case .ended:
            return "paywall.purchaseFormat"
        }
    }

    private func benefit(symbol: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .tokenFont(.body, weight: .semibold)
                .foregroundStyle(Palette.amber)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .tokenFont(.body, weight: .semibold)
                    .foregroundStyle(Palette.text)
                Text(detail)
                    .tokenFont(.subheadline)
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
