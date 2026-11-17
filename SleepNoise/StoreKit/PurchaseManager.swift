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
///
/// Only the product has a limit. Restore has none: `AppStore.sync()` asks
/// for the password of the Apple Account, and the time someone takes to type
/// it is not the store failing to answer.
struct StoreTimeouts: Equatable {
    var product: TimeInterval = 8
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
    /// The end of the trial has been found once, wherever it was found: at a
    /// session start, or at a launch that read a record already used up.
    nonisolated static let endEvaluatedKey = "sleepnoise.trial.endEvaluated.v1"
    nonisolated static let lastNightNoteKey = "sleepnoise.trial.lastNightNoteSeen.v1"
    nonisolated static let freeSessionsKey = "sleepnoise.trial.freeSessions.v1"

    private let defaults: UserDefaults
    private let calendar: Calendar
    private let timeouts: StoreTimeouts
    private let store: ProStore
    private let trialStorage: TrialStorage
    /// Goes up every time Pro is granted. A reading of the entitlements
    /// that was asked for before a grant must not undo it.
    private var grantCount = 0
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
        self.trialStorage = trialStorage
        Self.migrateLegacyTrial(from: defaults, to: trialStorage)
        var trial = NightTrial(storage: trialStorage)
        // The clock is sampled at launch; the answer only changes at the
        // next session start.
        trial.observe(now: now)
        self.trial = trial
        // A trial whose time ran out between two launches is read here as
        // over, with no session start in between to say so: its note is due.
        Self.noteEndOnce(of: trial, in: defaults)
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
        !isPro && trialState == .notStarted && LegacyTrial.record(in: defaults) == nil
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

    /// Asks the App Store for the purchases of this Apple Account. There is
    /// no limit of its own: the system may ask for the password, and "the
    /// store does not answer" over that dialog would be false. "Looking…"
    /// stays, with the actions held, until the App Store answers; the one
    /// line that follows is the one that is true then.
    func restore() async {
        guard activity == .idle else { return }
        notice = nil
        activity = .restoring
        let result = await store.sync()
        await refreshEntitlements(allowDowngrade: result == .synced)
        activity = .idle
        if isPro {
            notice = .restored
            return
        }
        switch result {
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
        reloadTrial()
        guard trial.status == .notStarted else {
            trialChanged(now: now, canDowngrade: !isSoundPlaying())
            return .alreadyUsed
        }
        // A trial of the builds before this one that still cannot be moved
        // counts as used: a Keychain that writes again must not hand out
        // seven new nights over it. Nothing is granted.
        guard LegacyTrial.record(in: defaults) == nil else {
            notice = .trialNotStarted
            return .failed
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
        defaults.set(false, forKey: Self.endEvaluatedKey)
        defaults.set(false, forKey: Self.lastNightNoteKey)
        trialChanged(now: now, canDowngrade: true)
        return .started
    }

    /// Samples the clock without changing the answer: at launch and on
    /// every return to the foreground. Without it, winding the clock back
    /// before each Play would stretch the trial without limit.
    func observeClock(now: Date) {
        reloadTrial()
        trial.observe(now: now)
        // A record that could not be read at launch grants what it grants
        // as soon as it can be read. Nothing is taken away here.
        trialChanged(now: now, canDowngrade: false)
    }

    /// The one place the trial is evaluated: a new sound session starts.
    /// Not a resume after a pause or an interruption, and not Small Hours.
    /// A trial that ran out ends here, in silence: what it leaves to say
    /// (`trialNote`) waits for daytime.
    ///
    /// The mixer calls this before the engine starts, on purpose: a mix
    /// whose trial is over must play trimmed from its first sample. Whether
    /// the session counts as one of the free ones is said afterwards
    /// (`sessionDidStart()`), once the sound is there.
    func evaluateTrialAtSessionStart(now: Date) {
        reloadTrial()
        trial.evaluateAtSessionStart(now: now)
        trialChanged(now: now, canDowngrade: !isSoundPlaying())
    }

    /// The session that was just evaluated did start. After the trial, and
    /// without Pro, it is one of the seven that say "always free". A Play
    /// that failed is not a session and does not use one up.
    func sessionDidStart() {
        if trial.status == .ended, !isPro {
            setFreeSessions(freeSessionsAfterTrial + 1)
        }
    }

    /// The person pressed Play: a paragraph that was on the page until
    /// then is gone for good. One that could not be on the page, because it
    /// is night, stays due. The mixer calls this before it starts the
    /// sound, and so before the trial is evaluated.
    func playWasAsked(now: Date) {
        switch trialNote {
        case .lastNight:
            dismissTrialNote()
        case .ended:
            if !NightWindow.contains(now, calendar: calendar) { dismissTrialNote() }
        case nil:
            break
        }
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

    /// Reads the trial again where a launch could not: a legacy trial that
    /// could not be written is moved now, and a record that could not be
    /// read is asked for once more.
    private func reloadTrial() {
        Self.migrateLegacyTrial(from: defaults, to: trialStorage)
        trial.reloadIfMissing()
    }

    /// Moves the trial of the builds before this one. One that had already
    /// run out there ended long ago: its end is not news, so it leaves no
    /// note.
    private static func migrateLegacyTrial(from defaults: UserDefaults, to storage: TrialStorage) {
        guard let legacy = LegacyTrial.record(in: defaults) else { return }
        if legacy.consumed >= NightTrial.length {
            defaults.set(true, forKey: endEvaluatedKey)
        }
        LegacyTrial.migrate(from: defaults, to: storage)
    }

    /// The first time the trial is found over, its note becomes due and the
    /// count of free sessions starts. Returns whether this was that time.
    @discardableResult
    private static func noteEndOnce(of trial: NightTrial, in defaults: UserDefaults) -> Bool {
        guard trial.status == .ended, !defaults.bool(forKey: endEvaluatedKey) else { return false }
        defaults.set(true, forKey: endEvaluatedKey)
        defaults.set(true, forKey: endNoteKey)
        defaults.set(0, forKey: freeSessionsKey)
        return true
    }

    private func trialChanged(now: Date, canDowngrade: Bool) {
        if Self.noteEndOnce(of: trial, in: defaults), freeSessionsAfterTrial != 0 {
            freeSessionsAfterTrial = 0
        }
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
    ///
    /// A reading can be old by the time it is applied: the scene comes back
    /// when the payment sheet closes, and this is asked while the purchase
    /// is still on its way. An answer that does not entitle is dropped when
    /// Pro was granted since it was asked for, or while a purchase is open;
    /// the next refresh reads the truth.
    private func refreshEntitlements(allowDowngrade: Bool) async {
        let grants = grantCount
        let answer = await store.currentEntitlement()
        let mayBeOld = grants != grantCount || activity == .purchasing
        switch answer {
        case .entitled(let receipt):
            setPro(true, receipt: receipt)
        case .notEntitled:
            if !mayBeOld { setPro(false, receipt: nil) }
        case .nothing:
            if allowDowngrade, !mayBeOld { setPro(false, receipt: nil) }
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
            grantCount += 1
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
