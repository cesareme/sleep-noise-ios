import Combine
import Foundation
import StoreKit

enum PurchaseNotice: Equatable {
    case restored
    case nothingToRestore
    case pending
    case failed
}

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var isPro: Bool
    @Published private(set) var product: Product?
    @Published private(set) var isPurchasing = false
    @Published private(set) var notice: PurchaseNotice?

    private let defaults: UserDefaults
    private let cacheKey = "sleepnoise.pro.cached"
    private var updatesTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isPro = defaults.bool(forKey: cacheKey)
    }

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            await self?.observeTransactions()
        }
        Task { [weak self] in
            await self?.refresh()
        }
    }

    func refresh() async {
        await loadProduct()
        await refreshEntitlements()
    }

    func clearNotice() {
        notice = nil
    }

    func purchase() async {
        notice = nil
        if product == nil {
            await loadProduct()
        }
        guard let product else {
            notice = .failed
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled:
                break
            case .pending:
                notice = .pending
            @unknown default:
                notice = .failed
            }
        } catch {
            notice = .failed
        }
    }

    func restore() async {
        notice = nil
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            notice = isPro ? .restored : .nothingToRestore
        } catch {
            notice = .failed
        }
    }

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [AccessPolicy.proProductID])
            product = products.first { $0.id == AccessPolicy.proProductID }
        } catch {
            product = nil
        }
    }

    private func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result) else { continue }
            guard transaction.productID == AccessPolicy.proProductID else { continue }
            guard transaction.revocationDate == nil else { continue }
            entitled = true
        }
        setPro(entitled)
    }

    private func observeTransactions() async {
        for await update in Transaction.updates {
            guard let transaction = try? verified(update) else { continue }
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func setPro(_ value: Bool) {
        isPro = value
        defaults.set(value, forKey: cacheKey)
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.unverified
        case .verified(let value):
            return value
        }
    }
}

private enum PurchaseError: Error {
    case unverified
}
