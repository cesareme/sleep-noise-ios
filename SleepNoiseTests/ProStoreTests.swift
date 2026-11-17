import StoreKit
import XCTest
@testable import SleepNoise

/// Every state of the store the Pro sheet can show, on a scripted store:
/// loading, no product, buying, pending, bought, restored, nothing to
/// restore, failed, cancelled, Family Sharing and what arrives by itself.
@MainActor
final class ProStoreTests: XCTestCase {
    private let product = ProProduct(displayName: "Scripted Pro", displayPrice: "¤ 12,34", isFamilyShareable: true)
    private let bought = ProReceipt(purchaseDate: NightHarness.time(12), isFamilyShared: false)
    private let shared = ProReceipt(purchaseDate: NightHarness.time(day: 10, 9), isFamilyShared: true)
    private var stores: [ScriptedProStore] = []

    override func tearDown() async throws {
        // Nothing is left waiting on a store that never answered.
        stores.forEach { $0.release() }
        stores = []
        try await super.tearDown()
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "sleepnoise.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func makeStore(withProduct: Bool = true) -> ScriptedProStore {
        let store = ScriptedProStore(product: withProduct ? product : nil)
        stores.append(store)
        return store
    }

    private func manager(
        _ store: ScriptedProStore,
        defaults: UserDefaults? = nil,
        access: TestAccess = .free,
        timeouts: StoreTimeouts = StoreTimeouts(product: 0.05, restore: 0.05)
    ) throws -> PurchaseManager {
        PurchaseManager.onDoubles(
            defaults: try defaults ?? makeDefaults(),
            access: access,
            store: store,
            timeouts: timeouts,
            now: NightHarness.time(12)
        )
    }

    // MARK: The product

    /// Red if the price or the name can come from anywhere but the store,
    /// or if the sheet has no way to tell "asked" from "answered".
    func testThePriceAndTheNameComeFromTheStore() async throws {
        let store = makeStore()
        let defaults = try makeDefaults()
        let purchases = try manager(store, defaults: defaults)
        XCTAssertEqual(purchases.productState, .loading, "a dash until the store answers")
        XCTAssertNil(purchases.product)
        XCTAssertNil(purchases.displayName, "no name of the app's own")

        await purchases.refresh()
        XCTAssertEqual(purchases.productState, .loaded(product))
        XCTAssertEqual(purchases.product?.displayPrice, "¤ 12,34")
        XCTAssertEqual(purchases.displayName, "Scripted Pro")
        XCTAssertEqual(purchases.product?.isFamilyShareable, true)

        // The name is remembered for the receipt, offline. The price is not.
        let offline = makeStore()
        offline.failsToLoad = true
        let next = try manager(offline, defaults: defaults)
        await next.refresh()
        XCTAssertEqual(next.productState, .unavailable)
        XCTAssertNil(next.product)
        XCTAssertEqual(next.displayName, "Scripted Pro")
    }

    /// Red if a store that is out of reach, has no listing or never answers
    /// leaves the sheet waiting for ever, or if a product that arrives late
    /// is thrown away.
    func testAStoreWithoutAProductIsOneState() async throws {
        let unreachable = makeStore()
        unreachable.failsToLoad = true
        let offline = try manager(unreachable)
        await offline.refresh()
        XCTAssertEqual(offline.productState, .unavailable)

        let unlisted = try manager(makeStore(withProduct: false))
        await unlisted.refresh()
        XCTAssertEqual(unlisted.productState, .unavailable)

        let silent = makeStore()
        silent.hangs = true
        let waiting = try manager(silent)
        await waiting.refresh()
        XCTAssertEqual(waiting.productState, .unavailable, "past its time limit")
        silent.release()
        try await waitUntil { waiting.product != nil }
        XCTAssertEqual(waiting.productState, .loaded(product), "late, and still shown")

        // Asked again later: the store is back.
        unreachable.failsToLoad = false
        await offline.refresh()
        XCTAssertEqual(offline.productState, .loaded(product))
        // And a product on screen stays there while the store is away.
        unreachable.failsToLoad = true
        await offline.refresh()
        XCTAssertEqual(offline.productState, .loaded(product))
    }

    // MARK: Buying

    /// Red if a purchase does not open everything at once, says nothing,
    /// keeps no receipt, or does not survive a launch without network.
    func testBuyingOpensEverythingAndKeepsTheReceipt() async throws {
        let store = makeStore()
        store.purchaseResult = .purchased(bought)
        let defaults = try makeDefaults()
        let purchases = try manager(store, defaults: defaults)
        await purchases.refresh()
        var changes = 0
        purchases.onAccessChange = { changes += 1 }
        var during: StoreActivity?
        store.duringPurchase = { during = purchases.activity }

        await purchases.purchase()
        XCTAssertEqual(during, .purchasing, "Buy says \"Buying\" while the store works")
        XCTAssertEqual(purchases.activity, .idle)
        XCTAssertTrue(purchases.isPro)
        XCTAssertTrue(purchases.hasFullAccess)
        XCTAssertEqual(changes, 1)
        XCTAssertEqual(purchases.notice, .purchased)
        XCTAssertEqual(purchases.receipt, bought)
        XCTAssertFalse(purchases.canStartTrial)

        purchases.clearNotice()
        XCTAssertNil(purchases.notice)
        await purchases.purchase()
        XCTAssertEqual(store.purchaseCount, 1, "nothing to buy twice")

        // The next launch, with the store out of reach: still Pro, with
        // its date.
        let offline = makeStore()
        offline.failsToLoad = true
        let next = try manager(offline, defaults: defaults)
        XCTAssertTrue(next.isPro)
        XCTAssertEqual(next.receipt, bought)
        await next.refresh()
        XCTAssertTrue(next.isPro, "no answer is not \"no purchase\"")
        XCTAssertTrue(next.hasFullAccess)
    }

    /// Red if any way a purchase can end without Pro opens something, says
    /// the wrong line, or leaves the button busy.
    func testEveryEndingWithoutProSaysItsOwnLine() async throws {
        let endings: [(ProPurchaseResult, PurchaseNotice)] = [
            (.cancelled, .cancelled),
            (.failed, .failed),
            (.unconfirmed, .unconfirmed),
            (.pending, .pending),
        ]
        for (result, notice) in endings {
            let store = makeStore()
            store.purchaseResult = result
            let purchases = try manager(store)
            await purchases.refresh()
            await purchases.purchase()
            XCTAssertEqual(purchases.notice, notice, "\(result)")
            XCTAssertFalse(purchases.isPro, "\(result)")
            XCTAssertFalse(purchases.hasFullAccess, "\(result)")
            XCTAssertNil(purchases.receipt, "\(result)")
            XCTAssertEqual(purchases.activity, .idle, "\(result)")
            XCTAssertEqual(purchases.isPurchasePending, result == .pending, "\(result)")
        }
    }

    /// Red if Buy does anything without a product, or blames the purchase
    /// for a store that is away.
    func testBuyingWithoutAProductOnlySaysTheStoreIsAway() async throws {
        let store = makeStore()
        store.failsToLoad = true
        store.purchaseResult = .purchased(bought)
        let purchases = try manager(store)
        await purchases.purchase()
        XCTAssertEqual(store.purchaseCount, 0)
        XCTAssertEqual(purchases.notice, .storeUnavailable)
        XCTAssertFalse(purchases.isPro)

        // The store comes back: the same button loads the product and buys.
        store.failsToLoad = false
        await purchases.purchase()
        XCTAssertEqual(store.purchaseCount, 1)
        XCTAssertTrue(purchases.isPro)
    }

    /// Ask to Buy. Red if the approval that arrives later does not open
    /// Pro by itself, or if it does so with a line nobody asked for.
    func testAPurchaseWaitingForApprovalOpensWhenItArrives() async throws {
        let store = makeStore()
        store.purchaseResult = .pending
        let purchases = try manager(store)
        purchases.start()
        try await waitUntil { purchases.product != nil }
        await purchases.purchase()
        XCTAssertEqual(purchases.notice, .pending)
        XCTAssertTrue(purchases.isPurchasePending)
        purchases.clearNotice()
        XCTAssertTrue(purchases.isPurchasePending, "the sheet closed; it is still waiting")

        store.send(.entitled(bought))
        try await waitUntil { purchases.isPro }
        XCTAssertTrue(purchases.hasFullAccess)
        XCTAssertFalse(purchases.isPurchasePending)
        XCTAssertEqual(purchases.receipt, bought)
        XCTAssertNil(purchases.notice, "in silence")
    }

    // MARK: Restoring

    /// Red if any ending of Restore says the wrong line.
    func testRestoreSaysWhatItFound() async throws {
        // Found.
        let found = makeStore()
        found.entitlementAfterSync = .entitled(bought)
        let restored = try manager(found)
        await restored.restore()
        XCTAssertEqual(restored.activity, .idle)
        XCTAssertEqual(found.syncCount, 1)
        XCTAssertTrue(restored.isPro)
        XCTAssertEqual(restored.notice, .restored)
        XCTAssertEqual(restored.receipt, bought)

        // Nothing bought with this account.
        let none = try manager(makeStore())
        await none.restore()
        XCTAssertFalse(none.isPro)
        XCTAssertEqual(none.notice, .nothingToRestore)

        // The person closed the sign-in sheet.
        let closing = makeStore()
        closing.syncResult = .cancelled
        let cancelled = try manager(closing)
        await cancelled.restore()
        XCTAssertEqual(cancelled.notice, .cancelled)

        // The store is away: a cached Pro is not taken for that.
        let away = makeStore()
        away.syncResult = .unavailable
        let offline = try manager(away, access: .pro)
        away.entitlement = .nothing
        await offline.restore()
        XCTAssertEqual(offline.notice, .restored, "Pro was there and still is")
        XCTAssertTrue(offline.isPro)
        let offlineFree = try manager(away)
        await offlineFree.restore()
        XCTAssertEqual(offlineFree.notice, .storeUnavailable)
    }

    /// Red if Restore can wait for ever (`AppStore.sync()` has no timeout),
    /// or if what arrives after the limit is lost.
    func testRestoreGivesUpAfterItsLimitAndStillTakesWhatArrivesLate() async throws {
        let store = makeStore()
        store.hangs = true
        store.entitlementAfterSync = .entitled(bought)
        let purchases = try manager(store)
        await purchases.restore()
        XCTAssertEqual(purchases.notice, .storeUnavailable)
        XCTAssertEqual(purchases.activity, .idle, "the button is free again")
        XCTAssertFalse(purchases.isPro)

        store.release()
        try await waitUntil { purchases.isPro }
        XCTAssertEqual(purchases.receipt, bought)
        XCTAssertEqual(purchases.notice, .storeUnavailable, "the line is not rewritten behind the person")
    }

    /// Red if a sync that finds nothing leaves a cached Pro in place: after
    /// the App Store has answered, its answer is the truth.
    func testASyncThatFindsNothingRemovesACachedPro() async throws {
        let store = makeStore()
        let purchases = try manager(store, access: .pro)
        store.entitlement = .nothing
        XCTAssertTrue(purchases.isPro)
        await purchases.restore()
        XCTAssertFalse(purchases.isPro)
        XCTAssertFalse(purchases.hasFullAccess)
        XCTAssertNil(purchases.receipt)
        XCTAssertEqual(purchases.notice, .nothingToRestore)
    }

    // MARK: Family Sharing and what arrives by itself

    /// Red if a purchase shared by the family does not open Pro at launch
    /// without a tap, or loses "with your family" on the receipt.
    func testAFamilyPurchaseArrivesAtLaunch() async throws {
        let store = makeStore()
        store.entitlement = .entitled(shared)
        let defaults = try makeDefaults()
        let purchases = try manager(store, defaults: defaults)
        XCTAssertFalse(purchases.isPro)
        await purchases.refresh()
        XCTAssertTrue(purchases.isPro)
        XCTAssertTrue(purchases.hasFullAccess)
        XCTAssertEqual(purchases.receipt, shared)
        XCTAssertEqual(purchases.receipt?.isFamilyShared, true)
        XCTAssertNil(purchases.notice)

        let next = try manager(makeStore(), defaults: defaults)
        XCTAssertEqual(next.receipt, shared, "remembered until the store answers")
    }

    /// Red if a launch that reaches the store and finds no purchase keeps a
    /// stale Pro, or if one that does not reach it drops a real one.
    func testTheCacheFollowsTheStoreOnlyWhenTheStoreAnswers() async throws {
        let store = makeStore()
        let purchases = try manager(store, access: .pro)
        store.entitlement = .nothing
        await purchases.refresh()
        XCTAssertFalse(purchases.isPro, "the product loaded: an empty list is the truth")

        let dark = makeStore()
        dark.failsToLoad = true
        let kept = try manager(dark, access: .pro)
        dark.entitlement = .nothing
        await kept.refresh()
        XCTAssertTrue(kept.isPro)

        // Something that does not entitle (revoked, unverified) is an
        // answer too, product or not.
        dark.entitlement = .notEntitled
        await kept.refresh()
        XCTAssertFalse(kept.isPro)
    }

    /// `Transaction.updates`. Red if a refund, a family that stops sharing
    /// or a transaction that only says "something moved" is ignored.
    func testWhatArrivesByItselfIsApplied() async throws {
        let store = makeStore()
        let purchases = try manager(store)
        purchases.start()
        purchases.start()
        try await waitUntil { purchases.product != nil }

        store.send(.entitled(shared))
        try await waitUntil { purchases.isPro }
        XCTAssertEqual(purchases.receipt, shared)

        store.send(.revoked)
        try await waitUntil { !purchases.isPro }
        XCTAssertFalse(purchases.hasFullAccess, "nothing was sounding")
        XCTAssertNil(purchases.receipt)

        store.entitlement = .entitled(bought)
        store.send(.other)
        try await waitUntil { purchases.isPro }
        XCTAssertEqual(purchases.receipt, bought)
        XCTAssertNil(purchases.notice)
    }

    // MARK: The local store

    /// `SleepNoise.storekit` is the store of a Run from Xcode. Red if it
    /// stops being one non-consumable shared with the family, drifts from
    /// the product the app asks for, or its descriptions carry a figure or
    /// a claim of the old split (timers, a count of sounds).
    func testTheLocalStoreSellsOneFamilySharedProductAndClaimsNothingOld() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SleepNoise/Resources/SleepNoise.storekit")
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let products = try XCTUnwrap(root["products"] as? [[String: Any]])
        XCTAssertEqual(products.count, 1)
        XCTAssertEqual((root["subscriptionGroups"] as? [Any])?.count, 0, "no subscription, ever")
        let pro = try XCTUnwrap(products.first)
        XCTAssertEqual(pro["productID"] as? String, AccessPolicy.proProductID)
        XCTAssertEqual(pro["type"] as? String, "NonConsumable")
        XCTAssertEqual(pro["familyShareable"] as? Bool, true)

        let localizations = try XCTUnwrap(pro["localizations"] as? [[String: String]])
        XCTAssertEqual(Set(localizations.compactMap { $0["locale"] }), ["en_US", "es_ES"])
        for localization in localizations {
            let locale = localization["locale"] ?? "?"
            let name = try XCTUnwrap(localization["displayName"])
            let description = try XCTUnwrap(localization["description"])
            XCTAssertFalse(name.isEmpty, locale)
            XCTAssertFalse(description.isEmpty, locale)
            XCTAssertNil(description.rangeOfCharacter(from: .decimalDigits), "\(locale): no figure")
            for old in ["timer", "temporizador", "60", "custom", "medida", "respiratoria", "breathing"] {
                XCTAssertFalse(description.lowercased().contains(old), "\(locale): \(old)")
            }
        }
    }

    // MARK: The adapter

    /// Red if an error that can follow the payment is reported as "nothing
    /// was charged".
    func testOnlyErrorsBeforeThePaymentSayNothingWasCharged() {
        XCTAssertEqual(AppStoreProStore.result(for: StoreKitError.userCancelled), .cancelled)
        XCTAssertEqual(AppStoreProStore.result(for: StoreKitError.notAvailableInStorefront), .failed)
        XCTAssertEqual(AppStoreProStore.result(for: Product.PurchaseError.purchaseNotAllowed), .failed)
        XCTAssertEqual(AppStoreProStore.result(for: Product.PurchaseError.productUnavailable), .failed)
        XCTAssertEqual(AppStoreProStore.result(for: StoreKitError.networkError(URLError(.timedOut))), .unconfirmed)
        XCTAssertEqual(AppStoreProStore.result(for: StoreKitError.unknown), .unconfirmed)
        XCTAssertEqual(AppStoreProStore.result(for: URLError(.badServerResponse)), .unconfirmed)
    }
}
