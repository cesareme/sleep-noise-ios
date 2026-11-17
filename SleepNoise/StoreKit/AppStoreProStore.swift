import Foundation
import StoreKit

/// StoreKit 2 behind `ProStore`: one non-consumable, bought once, shared
/// with the family.
@MainActor
final class AppStoreProStore: ProStore {
    private let productID: String
    private var product: Product?

    init(productID: String = AccessPolicy.proProductID) {
        self.productID = productID
    }

    func loadProduct() async throws -> ProProduct? {
        let products = try await Product.products(for: [productID])
        guard let found = products.first(where: { $0.id == productID }) else {
            product = nil
            return nil
        }
        product = found
        return ProProduct(
            displayName: found.displayName,
            displayPrice: found.displayPrice,
            isFamilyShareable: found.isFamilyShareable
        )
    }

    func purchase() async -> ProPurchaseResult {
        guard let product else { return .failed }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                return .purchased(Self.receipt(transaction))
            case .success(.unverified):
                return .unconfirmed
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .unconfirmed
            }
        } catch {
            return Self.result(for: error)
        }
    }

    /// What a purchase that threw amounts to. Only an error that can happen
    /// before the payment is reported as "nothing was charged"; anything
    /// that leaves that in doubt is "could not confirm".
    nonisolated static func result(for error: Error) -> ProPurchaseResult {
        if error is Product.PurchaseError { return .failed }
        if let storeError = error as? StoreKitError {
            // `.unsupported` exists from iOS 18.4 and the app runs on 17:
            // it is only named where it exists. It happens before any
            // payment, like the other two that fail.
            if #available(iOS 18.4, *), case .unsupported = storeError { return .failed }
            switch storeError {
            case .userCancelled:
                return .cancelled
            case .notAvailableInStorefront, .notEntitled:
                return .failed
            case .networkError, .systemError, .unknown:
                return .unconfirmed
            default:
                // A case this build does not know: nothing says the
                // payment did not happen.
                return .unconfirmed
            }
        }
        return .unconfirmed
    }

    func sync() async -> ProSyncResult {
        do {
            try await AppStore.sync()
            return .synced
        } catch StoreKitError.userCancelled {
            return .cancelled
        } catch {
            return .unavailable
        }
    }

    func currentEntitlement() async -> ProEntitlement {
        var sawAny = false
        for await result in Transaction.currentEntitlements {
            sawAny = true
            guard case .verified(let transaction) = result,
                  transaction.productID == productID,
                  transaction.revocationDate == nil else { continue }
            return .entitled(Self.receipt(transaction))
        }
        return sawAny ? .notEntitled : .nothing
    }

    func changes() -> AsyncStream<ProStoreChange> {
        let productID = productID
        return AsyncStream { continuation in
            let task = Task {
                for await update in Transaction.updates {
                    guard case .verified(let transaction) = update else {
                        continuation.yield(.other)
                        continue
                    }
                    await transaction.finish()
                    guard transaction.productID == productID else { continue }
                    if transaction.revocationDate == nil {
                        continuation.yield(.entitled(Self.receipt(transaction)))
                    } else {
                        continuation.yield(.revoked)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    nonisolated private static func receipt(_ transaction: Transaction) -> ProReceipt {
        ProReceipt(
            purchaseDate: transaction.originalPurchaseDate,
            isFamilyShared: transaction.ownershipType == .familyShared
        )
    }
}
