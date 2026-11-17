#if DEBUG
import Foundation

/// A store that answers what it is told to: the double behind `ProStore`
/// for the tests and for the staged launches of the captures. Debug builds
/// only; the app talks to `AppStoreProStore`.
@MainActor
final class ScriptedProStore: ProStore {
    /// What `loadProduct` answers. Nil is a store without the listing.
    var product: ProProduct?
    /// `loadProduct` throws: the store cannot be reached.
    var failsToLoad = false
    /// `loadProduct` and `sync` do not answer until `release()`.
    var hangs = false
    /// `purchase` does not answer until `release()`: the system sheet is up.
    var holdsPurchase = false
    var purchaseResult: ProPurchaseResult = .cancelled
    var syncResult: ProSyncResult = .synced
    /// What `currentEntitlement` answers. A purchase that goes through
    /// leaves its receipt here, like the real store.
    var entitlement: ProEntitlement = .nothing
    /// What the App Store sync brings, if it differs from what is there.
    var entitlementAfterSync: ProEntitlement?

    /// Runs while a purchase is in flight, before it answers.
    var duringPurchase: (() -> Void)?

    private(set) var loadCount = 0
    private(set) var purchaseCount = 0
    private(set) var syncCount = 0

    private var waiting: [UnsafeContinuation<Void, Never>] = []
    private var listener: AsyncStream<ProStoreChange>.Continuation?

    init(product: ProProduct? = nil, entitlement: ProEntitlement = .nothing) {
        self.product = product
        self.entitlement = entitlement
    }

    func loadProduct() async throws -> ProProduct? {
        loadCount += 1
        await waitIfHanging()
        if failsToLoad { throw ScriptedStoreError.unreachable }
        return product
    }

    func purchase() async -> ProPurchaseResult {
        purchaseCount += 1
        duringPurchase?()
        if holdsPurchase {
            await withUnsafeContinuation { waiting.append($0) }
        }
        if case .purchased(let receipt) = purchaseResult {
            entitlement = .entitled(receipt)
        }
        return purchaseResult
    }

    func sync() async -> ProSyncResult {
        syncCount += 1
        await waitIfHanging()
        if syncResult == .synced, let entitlementAfterSync {
            entitlement = entitlementAfterSync
        }
        return syncResult
    }

    func currentEntitlement() async -> ProEntitlement {
        entitlement
    }

    func changes() -> AsyncStream<ProStoreChange> {
        AsyncStream { continuation in
            listener = continuation
        }
    }

    /// A transaction arrives by itself, as `Transaction.updates` would
    /// deliver it. The entitlement follows it.
    func send(_ change: ProStoreChange) {
        switch change {
        case .entitled(let receipt): entitlement = .entitled(receipt)
        case .revoked: entitlement = .nothing
        case .other: break
        }
        listener?.yield(change)
    }

    /// Lets every call that was hanging answer.
    func release() {
        hangs = false
        holdsPurchase = false
        let held = waiting
        waiting = []
        held.forEach { $0.resume() }
    }

    private func waitIfHanging() async {
        guard hangs else { return }
        await withUnsafeContinuation { waiting.append($0) }
    }
}

private enum ScriptedStoreError: Error {
    case unreachable
}
#endif
