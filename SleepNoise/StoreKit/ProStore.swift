import Foundation

/// The product as the app shows it. Both strings come from StoreKit
/// (`displayName`, `displayPrice`): the app never writes a name or a price
/// of its own (C02).
struct ProProduct: Equatable, Sendable {
    let displayName: String
    let displayPrice: String
    let isFamilyShareable: Bool
}

/// What the app keeps of the purchase, for the receipt: when it was bought
/// and whether it arrives through Family Sharing.
struct ProReceipt: Equatable, Sendable {
    let purchaseDate: Date
    let isFamilyShared: Bool
}

/// How a purchase ended.
enum ProPurchaseResult: Equatable, Sendable {
    case purchased(ProReceipt)
    /// Waiting for someone else: Ask to Buy.
    case pending
    case cancelled
    /// The store could not confirm it: a transaction that did not verify, or
    /// the connection lost after the system sheet. Money may have moved.
    case unconfirmed
    /// It failed before any payment.
    case failed
}

/// How asking the App Store to sync ended.
enum ProSyncResult: Equatable, Sendable {
    case synced
    case cancelled
    case unavailable
}

/// What the store holds for the product right now.
enum ProEntitlement: Equatable, Sendable {
    case entitled(ProReceipt)
    /// The store answered with something that does not entitle: revoked, or
    /// not verified.
    case notEntitled
    /// Nothing came back: there is no purchase, or the store could not be
    /// asked. The two cannot be told apart from here.
    case nothing
}

/// A transaction that arrived by itself: bought on another device, approved
/// by a parent, shared by the family, refunded.
enum ProStoreChange: Equatable, Sendable {
    case entitled(ProReceipt)
    case revoked
    /// Something moved and it does not say what: read the entitlements again.
    case other
}

/// The App Store as `PurchaseManager` needs it. The app uses
/// `AppStoreProStore`; tests and staged launches use a double.
@MainActor
protocol ProStore: AnyObject {
    /// The product, or nil when the store has no such product. Throws when
    /// the store cannot be reached.
    func loadProduct() async throws -> ProProduct?
    func purchase() async -> ProPurchaseResult
    func sync() async -> ProSyncResult
    func currentEntitlement() async -> ProEntitlement
    /// Lasts as long as the app; one listener.
    func changes() -> AsyncStream<ProStoreChange>
}
