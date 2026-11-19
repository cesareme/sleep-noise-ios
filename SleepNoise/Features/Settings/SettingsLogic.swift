import Foundation

/// The words of Settings (03 §5, surface 18; inventory of C58 as
/// PLAN-SIMPLE §4.3 trims it for 1.0): Night, Pro, "What's not here" and
/// "Write to the author".
enum SettingsText {
    typealias Lookup = (String) -> String

    static func keepScreenOnKey(_ setting: KeepScreenOn) -> String {
        switch setting {
        case .whileCharging: return "ajustes.pantalla.carga"
        case .always: return "ajustes.pantalla.siempre"
        case .never: return "ajustes.pantalla.nunca"
        }
    }

    /// The row "Paint" of Settings (exploration 12 §7 fase 2), under its
    /// own header, "day".
    static let paintSectionKey = "ajustes.seccion.dia"
    static let paintTitleKey = "ajustes.pintura"
    /// The note under the row: what the paint is and when it goes.
    static let paintNoteKey = "ajustes.pintura.nota"
    /// The note while both accessibility switches keep it off.
    static let paintAutoOffKey = "ajustes.pintura.nota.apagada"

    static func paintKey(_ setting: PaintSetting) -> String {
        switch setting {
        case .byDay: return "ajustes.pintura.dia"
        case .never: return "ajustes.pintura.nunca"
        }
    }

    /// The value the row shows: what the paint goes by, in words. With
    /// Reduce Motion and Increase Contrast both on it says "Never" whatever
    /// is stored, and the note under it says why.
    static func paintValueKey(stored: PaintSetting, reduceMotion: Bool, increaseContrast: Bool) -> String {
        paintKey(PaintSetting.effective(stored, reduceMotion: reduceMotion, increaseContrast: increaseContrast))
    }

    static func paintNote(stored: PaintSetting, reduceMotion: Bool, increaseContrast: Bool) -> String {
        let effective = PaintSetting.effective(stored, reduceMotion: reduceMotion, increaseContrast: increaseContrast)
        return effective == stored ? paintNoteKey : paintAutoOffKey
    }

    /// "about sleepnoise": the name is the bundle's, never a string here.
    static func aboutHeader(
        appName: String,
        localized: Lookup = { Localized.string($0) },
        locale: Locale = .current
    ) -> String {
        String(format: localized("ajustes.seccion.sobre"), appName).lowercased(with: locale)
    }

    /// The facts of "What's not here", one per line.
    static func facts(localized: Lookup = { Localized.string($0) }) -> [String] {
        localized("lo_que_no_hay.lista")
            .components(separatedBy: " · ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

/// The Pro row of Settings: the state of the purchase, and the way into
/// the Pro sheet while something may be sold.
///
/// Without Pro it is the name the App Store gives with "{price} · Once."
/// on the right, and nothing there until the store has given a price. With
/// Pro it is the receipt line, and "With your family" under it when the
/// purchase is shared. The trial is not said here: it is read on the page.
///
/// At night, on the night page and in Small Hours the row is words, not a
/// button, and it carries no price: nothing sells then (C08).
///
/// In the visit in which "Restore purchase" was pressed the row keeps the
/// name alone, also when the purchase comes back (`holdsName`): the receipt
/// line is taller than the name at the larger text sizes, and with a family
/// purchase at every size, and the row that was just pressed is right under
/// it. The line under that row already says "Thank you"; the receipt is
/// here the next time Settings opens.
struct SettingsProRow: Equatable {
    var title: String
    /// "With your family", on its own line.
    var subtitle: String?
    var value: String?
    /// The row opens the Pro sheet.
    var opensSheet: Bool
    /// What VoiceOver reads: the name as the label, and the rest (the
    /// thanks and the date in full, the family, or the price) as the value.
    var spokenTitle: String
    var spokenValue: String?

    init(
        isPro: Bool,
        displayName: String?,
        product: ProductState,
        receipt: ProReceipt?,
        canSell: Bool,
        holdsName: Bool = false,
        localized: SettingsText.Lookup = { Localized.string($0) },
        date: (Date) -> String = { ProSheetText.shortDate($0) },
        spokenDate: (Date) -> String = { ProSheetText.longDate($0) },
        locale: Locale = .current
    ) {
        opensSheet = canSell
        let name = ProSheetText.name(displayName, localized: localized, locale: locale)
        spokenTitle = name
        if isPro, holdsName {
            // Restored in this visit: nothing above the pressed row grows.
            title = name
            subtitle = nil
            value = nil
            spokenValue = nil
            return
        }
        if isPro {
            title = ProSheetText.receiptLine(
                displayName: displayName,
                receipt: receipt,
                withFamily: false,
                localized: localized,
                date: date,
                locale: locale
            )
            let isShared = receipt?.isFamilyShared == true
            subtitle = isShared ? localized("pro.familia") : nil
            value = nil
            let spoken = ProSheetText.spoken(ProSheetText.receiptLine(
                displayName: displayName,
                receipt: receipt,
                localized: localized,
                date: spokenDate,
                locale: locale
            ))
            // "Name, thank you, date": the name is the label, the rest the
            // value. A sentence built another way is read whole.
            let lead = name + ", "
            if spoken.hasPrefix(lead) {
                spokenValue = String(spoken.dropFirst(lead.count))
            } else {
                spokenTitle = spoken
                spokenValue = nil
            }
            return
        }
        title = name
        subtitle = nil
        // No price yet, or nothing to sell right now: the row is the name
        // alone. A dash on its own here would read as a fault.
        if canSell, case .loaded(let loaded) = product {
            let price = String(format: localized("pro.precio"), loaded.displayPrice)
            value = price
            spokenValue = PageStatus.spoken(price)
        } else {
            value = nil
            spokenValue = nil
        }
    }
}

/// "Restore purchase" in Settings: the way back to a purchase while the
/// Pro sheet cannot go up.
///
/// The row is there without Pro whenever nothing may be sold: inside the
/// night window, on the night page and in Small Hours. Restoring is not
/// selling, so it carries no price and leads to no sheet: it asks the App
/// Store, says "Looking…" in its own place and leaves one line under it
/// with what came back. By day it is not there: the Pro row opens the
/// sheet, and Restore is there.
///
/// Whether it is there is decided once, when Settings opens
/// (`existsOnOpen`), and holds until the sheet closes: the row does not
/// come or go under the eyes when the hour reaches 21:00 or 07:00, and it
/// stays with its answer whatever the answer is.
///
/// What it says after the answer: "Thank you" when the purchase is back,
/// the long line when the account has none, and that the store does not
/// answer. Closing the dialog of the Apple Account says nothing: whoever
/// closed it knows, and the row is "Restore purchase" again. It never says
/// the lines of a purchase: nothing was bought and nothing was charged.
struct SettingsRestoreRow: Equatable {
    static let titleKey = "pro.restaurar"
    static let lookingKey = "pro.buscando"
    static let restoredKey = "pro.gracias"
    static let nothingKey = "pro.restaurar.no"

    /// Every line the row can leave under itself. Up to the largest
    /// regular text size the view keeps the height of the longest, so
    /// nothing under the row moves.
    static let resultKeys = [
        restoredKey, nothingKey,
        ProSheetContent.storeAwayKey, ProSheetContent.storeAwayInSilenceKey,
    ]

    /// Whether the row is there for a visit to Settings. Asked once, when
    /// the sheet opens. A restore that is already with the App Store (the
    /// sheet was closed while it looked) keeps its row.
    static func existsOnOpen(isPro: Bool, canSell: Bool, activity: StoreActivity) -> Bool {
        activity == .restoring || (!isPro && !canSell)
    }

    /// A restore still looking when Settings opens was asked for before:
    /// the visit that sees it end is the one that says what came back.
    static func askedOnOpen(activity: StoreActivity) -> Bool {
        activity == .restoring
    }

    var exists: Bool
    /// "Restore purchase", or "Looking…" while the App Store is asked.
    var titleKey: String
    /// The row answers a touch: nothing is in flight and there is
    /// something to restore. With Pro it stays where it was and does
    /// nothing: asking the store again could only take away what it just
    /// gave back.
    var isEnabled: Bool
    /// The catalog key of what the restore brought, or nil before it was
    /// asked for here, while it is looking and when there is nothing to
    /// say.
    var resultKey: String?

    init(
        exists: Bool,
        isPro: Bool,
        activity: StoreActivity,
        notice: PurchaseNotice?,
        isPlaying: Bool,
        askedHere: Bool
    ) {
        self.exists = exists
        titleKey = activity == .restoring ? Self.lookingKey : Self.titleKey
        isEnabled = exists && activity == .idle && !isPro
        resultKey = exists && askedHere && activity == .idle
            ? Self.resultKey(isPro: isPro, notice: notice, isPlaying: isPlaying)
            : nil
    }

    private static func resultKey(isPro: Bool, notice: PurchaseNotice?, isPlaying: Bool) -> String? {
        // Pro is there: whatever the App Store said on the way, it is open.
        if isPro { return restoredKey }
        switch notice {
        case .restored:
            return restoredKey
        case .nothingToRestore:
            return nothingKey
        case .storeUnavailable:
            // The app never says something is playing when nothing is.
            return isPlaying ? ProSheetContent.storeAwayKey : ProSheetContent.storeAwayInSilenceKey
        case .cancelled:
            // The person closed the dialog of the account: not an error
            // and nothing to tell them.
            return nil
        case .purchased, .pending, .failed, .unconfirmed, .trialNotStarted, nil:
            // Lines of a purchase or of the trial: not this row's to say.
            // A restore leaves none of them.
            return nil
        }
    }

    /// The touch on the row: the one restore there is, unless the row does
    /// not answer. It does not go through the sale gate, because it sells
    /// nothing, and it never raises the Pro sheet. Returns whether the App
    /// Store was asked.
    @MainActor
    @discardableResult
    func restore(with purchases: PurchaseManager) async -> Bool {
        guard isEnabled else { return false }
        await purchases.restore()
        return true
    }
}
