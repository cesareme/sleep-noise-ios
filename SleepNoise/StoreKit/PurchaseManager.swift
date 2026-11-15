import Combine
import Foundation
import StoreKit

enum PurchaseNotice: Equatable {
    case restored
    case nothingToRestore
    case pending
    case failed
}

/// What the header chip and the paywall say about the trial.
enum TrialState: Equatable {
    /// Everything open; the seven days start at the first Play.
    case notStarted
    case active(daysRemaining: Int)
    case ended
}

@MainActor
final class PurchaseManager: ObservableObject {
    /// Purchased the lifetime unlock.
    @Published private(set) var isPro: Bool
    /// Purchased, or inside the local trial. Every entitlement check in the
    /// app reads this one.
    @Published private(set) var hasFullAccess: Bool
    @Published private(set) var trialState: TrialState
    @Published private(set) var product: Product?
    @Published private(set) var isPurchasing = false
    @Published private(set) var notice: PurchaseNotice?

    private(set) var trial: TrialClock

    private let defaults: UserDefaults
    private let cacheKey = "sleepnoise.pro.cached"
    private var updatesTask: Task<Void, Never>?
    /// The trial ran out while audio was playing; applied at the next stop.
    private var downgradePending = false

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        self.defaults = defaults
        let purchased = defaults.bool(forKey: cacheKey)
        var trial = TrialClock(defaults: defaults)
        trial.observe(now: now)
        self.trial = trial
        isPro = purchased
        hasFullAccess = purchased || trial.isActive(now: now)
        trialState = Self.trialState(trial: trial, isPro: purchased, now: now)
    }

    func start() {
        guard updatesTask == nil else { return }
        refreshAccess(canDowngrade: true)
        updatesTask = Task { [weak self] in
            await self?.observeTransactions()
        }
        Task { [weak self] in
            await self?.refresh()
        }
    }

    func refresh() async {
        await loadProduct()
        // Products loaded means StoreKit is reachable, so an empty entitlement
        // stream is the truth and may remove a cached Pro; with no product
        // (offline, first launch without network) the cache is kept.
        await refreshEntitlements(allowDowngrade: product != nil)
    }

    /// Starts the trial clock. Called on the first Play.
    func startTrialIfNeeded(now: Date = Date()) {
        guard !trial.hasStarted else { return }
        trial.start(now: now)
        refreshAccess(now: now, canDowngrade: false)
    }

    /// Re-evaluates the trial against the clock.
    ///
    /// Losing access is only applied when `canDowngrade` is true, which the
    /// mixer passes when nothing is playing: a trial that ends at 3 a.m. must
    /// not cut the ocean under someone who is asleep. Gaining access always
    /// applies at once.
    func refreshAccess(now: Date = Date(), canDowngrade: Bool) {
        trial.observe(now: now)
        let access = isPro || trial.isActive(now: now)
        let state = Self.trialState(trial: trial, isPro: isPro, now: now)
        if access || canDowngrade || !hasFullAccess {
            downgradePending = false
            if access != hasFullAccess { hasFullAccess = access }
            if state != trialState { trialState = state }
        } else {
            downgradePending = true
        }
    }

    var hasPendingDowngrade: Bool { downgradePending }

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
                await refreshEntitlements(allowDowngrade: false)
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
            await refreshEntitlements(allowDowngrade: true)
            notice = isPro ? .restored : .nothingToRestore
        } catch {
            notice = .failed
        }
    }

    private static func trialState(trial: TrialClock, isPro: Bool, now: Date) -> TrialState {
        if isPro { return .ended }
        guard trial.hasStarted else { return .notStarted }
        if let days = trial.daysRemaining(now: now) { return .active(daysRemaining: days) }
        return .ended
    }

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [AccessPolicy.proProductID])
            product = products.first { $0.id == AccessPolicy.proProductID }
        } catch {
            product = nil
        }
    }

    /// Reads the current entitlements. An empty stream only removes Pro when
    /// `allowDowngrade` is set (products loaded, or after `AppStore.sync`): a
    /// launch with StoreKit unreachable must not take a paid unlock away.
    private func refreshEntitlements(allowDowngrade: Bool) async {
        var entitled = false
        var sawAny = false
        for await result in Transaction.currentEntitlements {
            sawAny = true
            guard let transaction = try? verified(result) else { continue }
            guard transaction.productID == AccessPolicy.proProductID else { continue }
            guard transaction.revocationDate == nil else { continue }
            entitled = true
        }
        if entitled {
            setPro(true)
        } else if allowDowngrade || sawAny {
            setPro(false)
        }
    }

    private func observeTransactions() async {
        for await update in Transaction.updates {
            guard let transaction = try? verified(update) else { continue }
            await transaction.finish()
            if transaction.productID == AccessPolicy.proProductID, transaction.revocationDate != nil {
                setPro(false)
            } else {
                await refreshEntitlements(allowDowngrade: false)
            }
        }
    }

    private func setPro(_ value: Bool) {
        if isPro != value {
            isPro = value
        }
        defaults.set(value, forKey: cacheKey)
        // A purchase applies at once; a revocation is Apple's decision and applies too.
        refreshAccess(canDowngrade: true)
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
