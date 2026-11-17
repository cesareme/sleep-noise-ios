import Combine
import Foundation

/// The seven-night trial as the page, the Pro sheet and Settings read it.
enum TrialState: Equatable {
    /// Never used: the free tier, and "Start the trial" is on offer.
    case notStarted
    /// Running. `nightsLeft` is the figure of "trial · n nights left": 1 is
    /// the last night and 0 the day it runs out, when no figure is shown.
    case active(nightsLeft: Int)
    /// Used up. It does not run twice.
    case ended
}

/// What tapping "Start the trial · 7 nights" did.
enum TrialStartResult: Equatable {
    case started
    /// Pro is bought: there is nothing to try.
    case notNeeded
    /// The trial was used before, on this install or an earlier one.
    case alreadyUsed
    /// Nothing is sold or offered at night (C08): nothing happened.
    case closedAtNight
    /// The record could not be written, so nothing was granted.
    case failed
}

/// The price and the name, as far as the store has answered.
enum ProductState: Equatable {
    /// Asked and not answered yet: the price is a dash.
    case loading
    case loaded(ProProduct)
    /// No network, no listing, or no answer in time. The cause is not
    /// guessed.
    case unavailable
}

/// What the store is busy with.
enum StoreActivity: Equatable {
    case idle
    case purchasing
    case restoring
}

/// The one line the Pro sheet says after an action. It stays until the next
/// action or until the sheet closes (`clearNotice()`).
enum PurchaseNotice: Equatable {
    case purchased
    case restored
    case nothingToRestore
    /// Ask to Buy: waiting for approval.
    case pending
    /// The person closed the system sheet. Not an error.
    case cancelled
    /// Failed before any payment.
    case failed
    /// Could not be confirmed; money may have moved.
    case unconfirmed
    /// The store does not answer.
    case storeUnavailable
    /// "Start the trial" could not write its record: nothing was granted.
    case trialNotStarted
}

/// A paragraph the page says once about the trial, by day and in silence.
enum TrialNote: Equatable {
    /// "Last night with everything."
    case lastNight
    /// "The trial is over."
    case ended
}

/// How long the store is waited for before saying it does not answer.
struct StoreTimeouts: Equatable {
    var product: TimeInterval = 8
    var restore: TimeInterval = 10
}

/// Who has what: the purchase, the seven-night trial and the store.
///
/// - `hasFullAccess` is the one answer every entitlement check reads:
///   bought, or the trial as its last evaluation left it.
/// - The trial starts only with `startTrial` (the button of the Pro sheet),
///   is evaluated only when a sound session starts, and lives in the
///   Keychain. Play never starts it and no Shortcut does.
/// - Access is gained at once. It is lost only while nothing is sounding: a
///   revocation that arrives with the bed playing waits for the session to
///   end (`applyAccess(canDowngrade:)`).
/// - The price and the name come from the store, never from a string.
@MainActor
final class PurchaseManager: ObservableObject {
    /// Bought, or shared by the family.
    @Published private(set) var isPro: Bool
    /// Bought, or inside the trial. Every entitlement check reads this one.
    @Published private(set) var hasFullAccess: Bool
    @Published private(set) var trialState: TrialState
    @Published private(set) var productState: ProductState = .loading
    @Published private(set) var activity: StoreActivity = .idle
    /// A purchase is waiting for someone's approval (Ask to Buy). Until it
    /// arrives, or until the next launch, Buy says "Pending".
    @Published private(set) var isPurchasePending = false
    @Published private(set) var notice: PurchaseNotice?
    /// When Pro was bought and whether it comes from the family. Nil
    /// without Pro, and for a purchase cached by a build that kept no date.
    @Published private(set) var receipt: ProReceipt?
    /// The paragraph that is due, if any. The page decides when it may be
    /// read (`MixerModel.visibleTrialNote`): never at night, only in silence.
    @Published private(set) var trialNote: TrialNote?
    /// Sessions started on the free tier since the trial ended. The header
    /// says "always free" for the first `alwaysFreeSessions` of them.
    @Published private(set) var freeSessionsAfterTrial: Int

    /// The trial itself. Read only: every change goes through this class.
    private(set) var trial: NightTrial

    /// Whether the bed is sounding. The mixer sets it; a loss of access
    /// that comes from the store waits while it answers true.
    var isSoundPlaying: () -> Bool = { false }
    /// Called after `hasFullAccess` has changed, with the new value in
    /// place. The mixer sets it.
    var onAccessChange: (() -> Void)?

    nonisolated static let alwaysFreeSessions = 7
    nonisolated static let cacheKey = "sleepnoise.pro.cached"
    nonisolated static let purchasedAtKey = "sleepnoise.pro.purchasedAt.v1"
    nonisolated static let familySharedKey = "sleepnoise.pro.familyShared.v1"
    nonisolated static let displayNameKey = "sleepnoise.pro.displayName.v1"
    nonisolated static let endNoteKey = "sleepnoise.trial.endNoteDue.v1"
    nonisolated static let lastNightNoteKey = "sleepnoise.trial.lastNightNoteSeen.v1"
    nonisolated static let freeSessionsKey = "sleepnoise.trial.freeSessions.v1"

    private let defaults: UserDefaults
    private let calendar: Calendar
    private let timeouts: StoreTimeouts
    private let store: ProStore
    private var updatesTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    /// Access was lost while the bed was sounding; applied when it stops.
    private var downgradePending = false

    init(
        defaults: UserDefaults = .standard,
        trialStorage: TrialStorage = KeychainTrialStorage(),
        store: ProStore? = nil,
        calendar: Calendar = .autoupdatingCurrent,
        timeouts: StoreTimeouts = StoreTimeouts(),
        now: Date = Date()
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.timeouts = timeouts
        self.store = store ?? AppStoreProStore()
        LegacyTrial.migrate(from: defaults, to: trialStorage)
        var trial = NightTrial(storage: trialStorage)
        // The clock is sampled at launch; the answer only changes at the
        // next session start.
        trial.observe(now: now)
        self.trial = trial
        let purchased = defaults.bool(forKey: Self.cacheKey)
        isPro = purchased
        hasFullAccess = purchased || trial.grantsFullAccess
        trialState = Self.state(of: trial, now: now, calendar: calendar)
        freeSessionsAfterTrial = defaults.integer(forKey: Self.freeSessionsKey)
        receipt = purchased ? Self.cachedReceipt(in: defaults) : nil
        refreshTrialNote()
    }

    // MARK: What the sheet and Settings read

    /// The product once the store has answered.
    var product: ProProduct? {
        if case .loaded(let product) = productState { return product }
        return nil
    }

    /// The name of the product as the store last gave it: the title of the
    /// Pro sheet and of the row in Settings. Nil until the store has
    /// answered once on this install.
    var displayName: String? {
        product?.displayName ?? defaults.string(forKey: Self.displayNameKey)
    }

    /// "Start the trial · 7 nights" exists: not bought and never used. The
    /// night gate is the mixer's (`MixerModel.startTrial()`).
    var canStartTrial: Bool {
        !isPro && trialState == .notStarted
    }

    /// The header says "always free": the trial is over, nothing was bought
    /// and fewer than seven free sessions have started since.
    var showsAlwaysFree: Bool {
        !isPro && trialState == .ended && freeSessionsAfterTrial < Self.alwaysFreeSessions
    }

    var hasPendingDowngrade: Bool { downgradePending }

    // MARK: Launch and refresh

    /// Starts listening to the store and asks it once. Safe to call again.
    func start() {
        guard updatesTask == nil else { return }
        let changes = store.changes()
        updatesTask = Task { [weak self] in
            for await change in changes {
                await self?.storeChanged(change)
            }
        }
        Task { [weak self] in
            await self?.refresh()
        }
    }

    /// Asks for the product and the entitlements: at launch, on the return
    /// to the foreground and when the Pro sheet appears. Calls that overlap
    /// share one request.
    func refresh() async {
        if let refreshTask {
            await refreshTask.value
            return
        }
        let task = Task { [weak self] in
            guard let self else { return }
            let answered = await self.loadProduct()
            // The store answered with the product, so an empty entitlement
            // list is the truth and may remove a cached Pro. With no answer
            // (offline, first launch without network) the cache is kept.
            await self.refreshEntitlements(allowDowngrade: answered)
        }
        refreshTask = task
        await task.value
        refreshTask = nil
    }

    func clearNotice() {
        notice = nil
    }

    // MARK: Buying and restoring

    func purchase() async {
        guard activity == .idle, !isPro else { return }
        notice = nil
        if product == nil {
            await loadProduct()
        }
        guard product != nil else {
            notice = .storeUnavailable
            return
        }
        activity = .purchasing
        let result = await store.purchase()
        activity = .idle
        switch result {
        case .purchased(let receipt):
            setPro(true, receipt: receipt)
            notice = .purchased
        case .pending:
            isPurchasePending = true
            notice = .pending
        case .cancelled:
            notice = .cancelled
        case .unconfirmed:
            notice = .unconfirmed
        case .failed:
            notice = .failed
        }
    }

    /// Asks the App Store for the purchases of this Apple Account. It never
    /// waits longer than `timeouts.restore`: past that the store "does not
    /// answer", and whatever arrives later still applies in silence.
    func restore() async {
        guard activity == .idle else { return }
        notice = nil
        activity = .restoring
        let outcome = await Self.value(within: timeouts.restore) { [weak self] () -> ProSyncResult in
            guard let self else { return .unavailable }
            let result = await self.store.sync()
            await self.refreshEntitlements(allowDowngrade: result == .synced)
            return result
        }
        activity = .idle
        guard let outcome else {
            notice = .storeUnavailable
            return
        }
        if isPro {
            notice = .restored
            return
        }
        switch outcome {
        case .synced: notice = .nothingToRestore
        case .cancelled: notice = .cancelled
        case .unavailable: notice = .storeUnavailable
        }
    }

    // MARK: The trial

    /// "Start the trial · 7 nights". Call it through
    /// `MixerModel.startTrial()`, which also refuses on the night page and
    /// in Small Hours. Never from Play and never from an intent.
    @discardableResult
    func startTrial(now: Date, calendar: Calendar? = nil) -> TrialStartResult {
        guard !isPro else { return .notNeeded }
        guard !NightWindow.contains(now, calendar: calendar ?? self.calendar) else { return .closedAtNight }
        trial.reloadIfMissing()
        guard trial.status == .notStarted else {
            trialChanged(now: now, canDowngrade: !isSoundPlaying())
            return .alreadyUsed
        }
        guard trial.start(now: now) else {
            // An item may be there that could not be read: ask once more.
            trial.reloadIfMissing()
            trialChanged(now: now, canDowngrade: !isSoundPlaying())
            notice = .trialNotStarted
            return .failed
        }
        setFreeSessions(0)
        defaults.set(false, forKey: Self.endNoteKey)
        defaults.set(false, forKey: Self.lastNightNoteKey)
        trialChanged(now: now, canDowngrade: true)
        return .started
    }

    /// Samples the clock without changing the answer: at launch and on
    /// every return to the foreground. Without it, winding the clock back
    /// before each Play would stretch the trial without limit.
    func observeClock(now: Date) {
        trial.reloadIfMissing()
        trial.observe(now: now)
        // A record that could not be read at launch grants what it grants
        // as soon as it can be read. Nothing is taken away here.
        trialChanged(now: now, canDowngrade: false)
    }

    /// The one place the trial is evaluated: a new sound session starts.
    /// Not a resume after a pause or an interruption, and not Small Hours.
    /// A trial that ran out ends here, in silence: what it leaves to say
    /// (`trialNote`) waits for daytime.
    func evaluateTrialAtSessionStart(now: Date) {
        trial.reloadIfMissing()
        let before = trial.status
        let isDay = !NightWindow.contains(now, calendar: calendar)
        // Notes that were on the page until this Play.
        if trialNote == .lastNight {
            defaults.set(true, forKey: Self.lastNightNoteKey)
        }
        if trialNote == .ended, isDay {
            defaults.set(false, forKey: Self.endNoteKey)
        }
        trial.evaluateAtSessionStart(now: now)
        if before == .active, trial.status == .ended {
            defaults.set(true, forKey: Self.endNoteKey)
            setFreeSessions(0)
        }
        if trial.status == .ended, !isPro {
            setFreeSessions(freeSessionsAfterTrial + 1)
        }
        trialChanged(now: now, canDowngrade: !isSoundPlaying())
    }

    /// "Got it" under the paragraph, or the paragraph has been read.
    func dismissTrialNote() {
        switch trialNote {
        case .lastNight: defaults.set(true, forKey: Self.lastNightNoteKey)
        case .ended: defaults.set(false, forKey: Self.endNoteKey)
        case nil: return
        }
        refreshTrialNote()
    }

    // MARK: Access

    /// Works out the access again. Gaining it applies at once. Losing it
    /// applies only when `canDowngrade` is true, which the mixer passes
    /// when nothing is sounding: nothing is cut under someone asleep.
    func applyAccess(canDowngrade: Bool) {
        let access = isPro || trial.grantsFullAccess
        guard access || canDowngrade else {
            if hasFullAccess { downgradePending = true }
            return
        }
        downgradePending = false
        guard access != hasFullAccess else { return }
        hasFullAccess = access
        onAccessChange?()
    }

    // MARK: Private

    private func trialChanged(now: Date, canDowngrade: Bool) {
        let state = Self.state(of: trial, now: now, calendar: calendar)
        if state != trialState { trialState = state }
        refreshTrialNote()
        applyAccess(canDowngrade: canDowngrade)
    }

    private func refreshTrialNote() {
        var note: TrialNote?
        if !isPro {
            if trialState == .ended, defaults.bool(forKey: Self.endNoteKey) {
                note = .ended
            } else if trialState == .active(nightsLeft: 1), !defaults.bool(forKey: Self.lastNightNoteKey) {
                note = .lastNight
            }
        }
        if note != trialNote { trialNote = note }
    }

    private func setFreeSessions(_ count: Int) {
        guard count != freeSessionsAfterTrial else { return }
        freeSessionsAfterTrial = count
        defaults.set(count, forKey: Self.freeSessionsKey)
    }

    private static func state(of trial: NightTrial, now: Date, calendar: Calendar) -> TrialState {
        switch trial.status {
        case .notStarted: return .notStarted
        case .ended: return .ended
        case .active: return .active(nightsLeft: trial.nightsRemaining(now: now, calendar: calendar) ?? 0)
        }
    }

    /// Asks for the product. Returns whether the store answered with it in
    /// time. A product already on screen stays there while it is asked for
    /// again; one that arrives late still shows.
    @discardableResult
    private func loadProduct() async -> Bool {
        if product == nil, productState != .loading {
            productState = .loading
        }
        let answered = await Self.value(within: timeouts.product) { [weak self] () -> Bool in
            guard let self else { return false }
            guard let loaded = try? await self.store.loadProduct() else {
                if self.product == nil { self.productState = .unavailable }
                return false
            }
            self.defaults.set(loaded.displayName, forKey: Self.displayNameKey)
            if self.productState != .loaded(loaded) { self.productState = .loaded(loaded) }
            return true
        }
        if answered == nil, product == nil {
            productState = .unavailable
        }
        return answered ?? false
    }

    /// Reads the entitlements. "Nothing" only removes Pro when
    /// `allowDowngrade` is set (the product just loaded, or the App Store
    /// just synced): a launch with the store out of reach must not take a
    /// paid Pro away.
    private func refreshEntitlements(allowDowngrade: Bool) async {
        switch await store.currentEntitlement() {
        case .entitled(let receipt):
            setPro(true, receipt: receipt)
        case .notEntitled:
            setPro(false, receipt: nil)
        case .nothing:
            if allowDowngrade { setPro(false, receipt: nil) }
        }
    }

    private func storeChanged(_ change: ProStoreChange) async {
        switch change {
        case .entitled(let receipt):
            setPro(true, receipt: receipt)
        case .revoked:
            setPro(false, receipt: nil)
        case .other:
            await refreshEntitlements(allowDowngrade: false)
        }
    }

    private func setPro(_ value: Bool, receipt next: ProReceipt?) {
        if isPro != value { isPro = value }
        defaults.set(value, forKey: Self.cacheKey)
        if value {
            isPurchasePending = false
            if let next {
                defaults.set(next.purchaseDate, forKey: Self.purchasedAtKey)
                defaults.set(next.isFamilyShared, forKey: Self.familySharedKey)
            }
            let known = next ?? Self.cachedReceipt(in: defaults)
            if receipt != known { receipt = known }
        } else {
            defaults.removeObject(forKey: Self.purchasedAtKey)
            defaults.removeObject(forKey: Self.familySharedKey)
            if receipt != nil { receipt = nil }
        }
        refreshTrialNote()
        // Buying is heard at once. A revocation is Apple's decision and
        // applies too, once nothing is sounding.
        applyAccess(canDowngrade: !isSoundPlaying())
    }

    private static func cachedReceipt(in defaults: UserDefaults) -> ProReceipt? {
        guard let date = defaults.object(forKey: purchasedAtKey) as? Date else { return nil }
        return ProReceipt(purchaseDate: date, isFamilyShared: defaults.bool(forKey: familySharedKey))
    }

    /// The value of `work` if it arrives within `seconds`, or nil. Past that
    /// `work` goes on by itself: StoreKit calls have no timeout and cannot
    /// be cancelled, so whatever they bring still applies when it comes.
    private static func value<T>(
        within seconds: TimeInterval,
        _ work: @escaping @MainActor () async -> T
    ) async -> T? {
        let gate = Gate()
        return await withCheckedContinuation { (continuation: CheckedContinuation<T?, Never>) in
            let limit = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
                guard !Task.isCancelled, gate.close() else { return }
                continuation.resume(returning: nil)
            }
            Task { @MainActor in
                let value = await work()
                guard gate.close() else { return }
                limit.cancel()
                continuation.resume(returning: value)
            }
        }
    }
}

/// Lets one of two racers through.
@MainActor
private final class Gate {
    private var isClosed = false

    /// True for the first caller only.
    func close() -> Bool {
        guard !isClosed else { return false }
        isClosed = true
        return true
    }
}
