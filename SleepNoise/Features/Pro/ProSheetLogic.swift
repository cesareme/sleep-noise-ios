import Foundation

/// What the Pro sheet shows, worked out from the purchase, the trial and
/// the store (03 §5, surfaces 14, 15 and 33; 08 §2.3). No view and no
/// string: the words are `ProSheetText`.
///
/// The sheet is one screen with two faces. Without Pro it sells: the price
/// first, what Pro includes, and at the foot the trial (while it was never
/// used), the purchase and the restore. With Pro it is the receipt: the
/// same lists, the date, and no button that costs money.
struct ProSheetContent: Equatable {
    struct Input: Equatable {
        var isPro = false
        /// Pro was already there when the sheet went up: it opened as the
        /// receipt. A purchase made with the sheet open thanks and closes.
        var wasProWhenOpened = false
        var trial = TrialState.notStarted
        var product = ProductState.loading
        var activity = StoreActivity.idle
        var isPurchasePending = false
        var notice: PurchaseNotice?
        var receipt: ProReceipt?
        /// The name of the product as the store last gave it.
        var displayName: String?
        var isPlaying = false
        /// The App Store page of the app is known (`AppLinks.reviewURL`).
        var hasReviewLink = false
    }

    /// The row that costs money, in each of its states.
    enum Purchase: Equatable {
        /// The price is known: the only accent of the sheet.
        case buy(price: String)
        /// No product yet, or no store: the word alone, disabled.
        case buyWithoutPrice
        /// The App Store is working on it.
        case buying
        /// Ask to Buy: waiting for someone's approval.
        case pending
        /// Just bought or restored: the row says thanks, then the sheet
        /// closes by itself.
        case thanks
    }

    /// The action the sheet leads with.
    enum Primary: Equatable {
        case startTrial
        case buy
        /// Nothing to press: the receipt, or the store is away or busy.
        case none
    }

    /// The receipt, instead of the sheet that sells.
    var isReceipt: Bool
    var displayName: String?
    /// Nil while the store has not answered: the place of the price holds
    /// a dash.
    var price: String?
    var receipt: ProReceipt?
    /// "With your family" closes the list unless the store says the
    /// product is not shared.
    var listsFamily: Bool
    /// "Start the trial · 7 nights": only while the trial was never used.
    var showsStartTrial: Bool
    /// Nil on the receipt.
    var purchase: Purchase?
    /// Nothing is in flight: the actions answer.
    var isIdle: Bool
    var isRestoring: Bool
    var showsNotNow: Bool
    var showsReview: Bool
    /// The catalog key of the line that says what just happened, or nil
    /// when nothing has: then the foot says `footKey`.
    var resultKey: String?
    /// The line of the foot at rest. While the trial is on offer it is
    /// what the trial is (how long, that nothing is charged, what stays
    /// when it ends): it must be read before the button is pressed, at
    /// every text size. Otherwise it is the footer.
    var footKey: String
    /// Bought or restored from the sheet that sells: it says thanks for a
    /// moment and comes down.
    var closesItself: Bool
    /// The store was asked and did not answer.
    var storeIsAway: Bool

    init(_ input: Input) {
        let thanks = input.isPro && (input.notice == .purchased || input.notice == .restored)
        closesItself = thanks && !input.wasProWhenOpened
        isReceipt = input.isPro && !closesItself
        displayName = input.displayName
        receipt = input.isPro ? input.receipt : nil
        isIdle = input.activity == .idle
        isRestoring = input.activity == .restoring
        storeIsAway = input.product == .unavailable

        var product: ProProduct?
        if case .loaded(let loaded) = input.product { product = loaded }
        price = product?.displayPrice
        listsFamily = product?.isFamilyShareable ?? true

        if isReceipt {
            purchase = nil
        } else if closesItself {
            purchase = .thanks
        } else if input.activity == .purchasing {
            purchase = .buying
        } else if input.isPurchasePending {
            purchase = .pending
        } else if let price {
            purchase = .buy(price: price)
        } else {
            purchase = .buyWithoutPrice
        }

        showsStartTrial = !input.isPro && input.trial == .notStarted
        footKey = showsStartTrial ? ProSheetText.trialNoteKey : ProSheetText.footerKey
        showsNotNow = !isReceipt
        showsReview = isReceipt && input.hasReviewLink
        resultKey = Self.resultKey(input, isReceipt: isReceipt)
    }

    /// Every line the foot of this sheet can say while it is up: the one
    /// at rest and each of the results. The view reserves the height of the
    /// longest, so the foot never changes height.
    var footKeys: [String] { [footKey] + Self.resultKeys }

    static let resultKeys = [
        "pro.restaurar.no", "pro.pendiente", "pro.fallo", "pro.fallo.sin_confirmar",
        storeAwayKey, storeAwayInSilenceKey, "pro.gracias",
    ]

    /// The purchase can be pressed: the price is known and nothing is in
    /// flight. Only then are its hairlines the accent.
    var canBuy: Bool {
        if case .buy = purchase { return isIdle }
        return false
    }

    var canStartTrial: Bool { showsStartTrial && isIdle }

    var primary: Primary {
        if canStartTrial { return .startTrial }
        return canBuy ? .buy : .none
    }

    static let storeAwayKey = "pro.sin_tienda"
    static let storeAwayInSilenceKey = "pro.sin_tienda.silencio"

    /// One line at a time, in the place of the footer. It stays until the
    /// next action or until the sheet closes.
    private static func resultKey(_ input: Input, isReceipt: Bool) -> String? {
        // The app never says something is playing when nothing is.
        let storeAway = input.isPlaying ? storeAwayKey : storeAwayInSilenceKey
        switch input.notice {
        case .purchased, .restored:
            // On the sheet that sells the purchase row says it.
            return isReceipt ? "pro.gracias" : nil
        case .nothingToRestore:
            return "pro.restaurar.no"
        case .pending:
            return "pro.pendiente"
        case .cancelled, .failed, .trialNotStarted:
            return "pro.fallo"
        case .unconfirmed:
            return "pro.fallo.sin_confirmar"
        case .storeUnavailable:
            return storeAway
        case nil:
            guard !input.isPro, input.activity == .idle else { return nil }
            if input.isPurchasePending { return "pro.pendiente" }
            return input.product == .unavailable ? storeAway : nil
        }
    }
}

/// The words of the Pro sheet, from the catalog. The name and the price
/// are the App Store's (`displayName`, `displayPrice`): no string here
/// carries either (C02, C12).
enum ProSheetText {
    typealias Lookup = (String) -> String

    static let footerKey = "lo_que_no_hay.pie"
    static let trialNoteKey = "pro.prueba.empezar.nota"
    static let includedKeys = ["pro.incluye.texturas", "pro.incluye.marea", "pro.incluye.mezclas"]
    static let familyKey = "pro.familia"

    /// The name the sheet and Settings use: the store's, or the bare word
    /// of the tier until the store has answered once on this install.
    static func name(
        _ displayName: String?,
        localized: Lookup = { Localized.string($0) },
        locale: Locale = .current
    ) -> String {
        if let displayName, !displayName.isEmpty { return displayName }
        return localized("comun.pro").capitalized(with: locale)
    }

    /// "{displayName} · thank you · {date}", and "· with your family"
    /// after it when `withFamily` asks for the whole sentence. Without a
    /// date (a purchase kept by a build that stored none) it is the name
    /// alone.
    static func receiptLine(
        displayName: String?,
        receipt: ProReceipt?,
        withFamily: Bool = true,
        localized: Lookup = { Localized.string($0) },
        date: (Date) -> String = { shortDate($0) },
        locale: Locale = .current
    ) -> String {
        let name = name(displayName, localized: localized, locale: locale)
        guard let receipt else { return name }
        var line = String(format: localized("pro.ajustes.gracias"), name, date(receipt.purchaseDate))
        if withFamily, receipt.isFamilyShared {
            line += " " + localized("pro.ajustes.familia")
        }
        return line
    }

    /// The small caps over the price: the name, or the receipt line. The
    /// family goes on a line of its own (`familyLine`).
    static func title(
        _ content: ProSheetContent,
        localized: Lookup = { Localized.string($0) },
        date: (Date) -> String = { shortDate($0) },
        locale: Locale = .current
    ) -> String {
        let words = content.isReceipt
            ? receiptLine(
                displayName: content.displayName,
                receipt: content.receipt,
                withFamily: false,
                localized: localized,
                date: date,
                locale: locale
            )
            : name(content.displayName, localized: localized, locale: locale)
        // State words are small caps: written in lower case.
        return words.lowercased(with: locale)
    }

    /// "· with your family", under the receipt line: its own line, so the
    /// "·" is never left hanging at the end of the one above.
    static func familyLine(
        _ content: ProSheetContent,
        localized: Lookup = { Localized.string($0) },
        locale: Locale = .current
    ) -> String? {
        guard content.isReceipt, content.receipt?.isFamilyShared == true else { return nil }
        return localized("pro.ajustes.familia").lowercased(with: locale)
    }

    /// What VoiceOver reads for the small caps: the same words as a
    /// sentence, with the month in full.
    static func spokenTitle(
        _ content: ProSheetContent,
        localized: Lookup = { Localized.string($0) },
        date: (Date) -> String = { longDate($0) },
        locale: Locale = .current
    ) -> String {
        guard content.isReceipt else { return name(content.displayName, localized: localized, locale: locale) }
        return spoken(receiptLine(
            displayName: content.displayName,
            receipt: content.receipt,
            localized: localized,
            date: date,
            locale: locale
        ))
    }

    /// "Start the trial · 7 nights". With larger text the two halves are
    /// two lines, instead of a "·" left at the end of the first.
    static func trialTitle(stacked: Bool, localized: Lookup = { Localized.string($0) }) -> String {
        let title = localized("pro.prueba.empezar")
        return stacked ? title.replacingOccurrences(of: " · ", with: "\n") : title
    }

    /// "16 Nov 2026": day, short month and year, in the order of the place.
    static func shortDate(_ date: Date, locale: Locale = .current, calendar: Calendar = .current) -> String {
        var style = Date.FormatStyle.dateTime.day().month(.abbreviated).year()
        style.locale = locale
        style.calendar = calendar
        style.timeZone = calendar.timeZone
        return date.formatted(style)
    }

    /// "16 November 2026": the date as a voice says it.
    static func longDate(_ date: Date, locale: Locale = .current, calendar: Calendar = .current) -> String {
        var style = Date.FormatStyle.dateTime.day().month(.wide).year()
        style.locale = locale
        style.calendar = calendar
        style.timeZone = calendar.timeZone
        return date.formatted(style)
    }

    static func purchaseTitle(
        _ purchase: ProSheetContent.Purchase,
        localized: Lookup = { Localized.string($0) }
    ) -> String {
        switch purchase {
        case .buy(let price): return String(format: localized("pro.comprar"), price)
        case .buyWithoutPrice: return localized("pro.comprar.sin_precio")
        case .buying: return localized("pro.comprando")
        case .pending: return localized("pro.pendiente.boton")
        case .thanks: return localized("pro.gracias")
        }
    }

    /// What VoiceOver reads on the purchase: with the name and the price
    /// the App Store gave, so the currency is spoken by the system.
    static func spokenPurchase(
        _ purchase: ProSheetContent.Purchase,
        displayName: String?,
        localized: Lookup = { Localized.string($0) },
        locale: Locale = .current
    ) -> String {
        let name = name(displayName, localized: localized, locale: locale)
        switch purchase {
        case .buy(let price):
            return String(format: localized("ax.comprar"), name, price)
        case .buyWithoutPrice:
            return String(format: localized("ax.comprar.sin_precio"), name)
        case .buying, .pending, .thanks:
            return spoken(purchaseTitle(purchase, localized: localized))
        }
    }

    static func purchaseValue(
        _ purchase: ProSheetContent.Purchase,
        localized: Lookup = { Localized.string($0) }
    ) -> String? {
        purchase == .buyWithoutPrice ? localized("ax.comprar.sin_precio.valor") : nil
    }

    /// The hint says the store is away only when it is: while the price is
    /// still being asked for there is nothing to explain.
    static func purchaseHint(
        _ purchase: ProSheetContent.Purchase,
        storeIsAway: Bool,
        localized: Lookup = { Localized.string($0) }
    ) -> String? {
        switch purchase {
        case .buy: return localized("ax.comprar.pista")
        case .buyWithoutPrice: return storeIsAway ? localized("ax.comprar.sin_precio.pista") : nil
        case .buying, .pending, .thanks: return nil
        }
    }

    static func restoreTitle(isRestoring: Bool, localized: Lookup = { Localized.string($0) }) -> String {
        localized(isRestoring ? "pro.buscando" : "pro.restaurar")
    }

    /// The same words without the marks a voice trips on.
    static func spoken(_ text: String) -> String {
        PageStatus.spoken(text).replacingOccurrences(of: "…", with: "")
    }
}

/// Where the app sends the person outside itself. Both are empty until the
/// owner gives them, and an empty one hides what would use it: the app
/// never shows a link that leads nowhere and never writes an address of
/// its own invention.
enum AppLinks {
    /// The numeric id of the app in the App Store ("Write a review").
    /// It exists once the app is created in App Store Connect.
    static let appStoreID = ""
    /// The public address "Write to the author" writes to.
    static let authorAddress = ""

    /// The App Store page of the app, opened on its review form. The app
    /// never asks the system for a review prompt (C55).
    static func reviewURL(appStoreID: String = appStoreID) -> URL? {
        let id = appStoreID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, id.allSatisfy({ ("0"..."9").contains($0) }) else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
    }

    /// A message to the author in the person's own mail, with the name of
    /// the app as its subject and nothing else filled in (C58).
    static func authorURL(address: String = authorAddress, subject: String) -> URL? {
        let address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard address.contains("@"), !address.contains(" ") else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [URLQueryItem(name: "subject", value: subject)]
        return components.url
    }
}
