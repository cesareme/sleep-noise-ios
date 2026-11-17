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
/// on the right, a dash while there is no price. With Pro it is the
/// receipt line. The trial is not said here: it is read on the page.
///
/// At night, on the night page and in Small Hours the row is words, not a
/// button, and it carries no price: nothing sells then (C08).
struct SettingsProRow: Equatable {
    var title: String
    var value: String?
    /// The row opens the Pro sheet.
    var opensSheet: Bool

    init(
        isPro: Bool,
        displayName: String?,
        product: ProductState,
        receipt: ProReceipt?,
        canSell: Bool,
        localized: SettingsText.Lookup = { Localized.string($0) },
        date: (Date) -> String = { ProSheetText.shortDate($0) },
        locale: Locale = .current
    ) {
        opensSheet = canSell
        if isPro {
            title = ProSheetText.receiptLine(
                displayName: displayName,
                receipt: receipt,
                localized: localized,
                date: date,
                locale: locale
            )
            value = nil
            return
        }
        title = ProSheetText.name(displayName, localized: localized, locale: locale)
        guard canSell else {
            value = nil
            return
        }
        if case .loaded(let loaded) = product {
            value = String(format: localized("pro.precio"), loaded.displayPrice)
        } else {
            value = localized("pro.precio.cargando")
        }
    }

    /// What VoiceOver reads as the value: the price with its words, or
    /// that there is none yet.
    func spokenValue(localized: SettingsText.Lookup = { Localized.string($0) }) -> String? {
        guard let value else { return nil }
        if value == localized("pro.precio.cargando") { return localized("ax.comprar.sin_precio.valor") }
        return PageStatus.spoken(value)
    }
}
