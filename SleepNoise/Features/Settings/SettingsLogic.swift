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
        localized: SettingsText.Lookup = { Localized.string($0) },
        date: (Date) -> String = { ProSheetText.shortDate($0) },
        spokenDate: (Date) -> String = { ProSheetText.longDate($0) },
        locale: Locale = .current
    ) {
        opensSheet = canSell
        let name = ProSheetText.name(displayName, localized: localized, locale: locale)
        spokenTitle = name
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
/// The row exists without Pro whenever nothing may be sold: inside the
/// night window, on the night page and in Small Hours. Restoring is not
/// selling, so it carries no price and leads to no sheet: it asks the App
/// Store, says "Looking…" in its own place and leaves one line under it
/// with what came back. By day it does not exist: the Pro row opens the
/// sheet, and Restore is there.
///
/// Once pressed it stays for the rest of the visit, whatever the hour and
/// whatever the answer, so that the line is read where the row was.
struct SettingsRestoreRow: Equatable {
    static let titleKey = "pro.restaurar"
    static let lookingKey = "pro.buscando"
    static let restoredKey = "pro.gracias"
    static let nothingKey = "pro.restaurar.no"
    static let failedKey = "pro.fallo"

    /// Every line the row can leave under itself. The view keeps the
    /// height of the longest, so nothing under the row ever moves.
    static let resultKeys = [
        restoredKey, nothingKey, failedKey,
        ProSheetContent.storeAwayKey, ProSheetContent.storeAwayInSilenceKey,
    ]

    var exists: Bool
    /// "Restore purchase", or "Looking…" while the App Store is asked.
    var titleKey: String
    /// Nothing is in flight: the row answers. While it looks it is words.
    var isEnabled: Bool
    /// The catalog key of what the restore brought, or nil before it was
    /// asked for here and while it is looking.
    var resultKey: String?

    init(
        isPro: Bool,
        canSell: Bool,
        activity: StoreActivity,
        notice: PurchaseNotice?,
        isPlaying: Bool,
        askedHere: Bool
    ) {
        exists = askedHere || (!isPro && !canSell)
        titleKey = activity == .restoring ? Self.lookingKey : Self.titleKey
        isEnabled = activity == .idle
        resultKey = askedHere && activity == .idle
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
        case .cancelled, .failed:
            return failedKey
        case .storeUnavailable:
            // The app never says something is playing when nothing is.
            return isPlaying ? ProSheetContent.storeAwayKey : ProSheetContent.storeAwayInSilenceKey
        case .purchased, .pending, .unconfirmed, .trialNotStarted, nil:
            // Lines of a purchase or of the trial: not this row's to say.
            return nil
        }
    }
}
