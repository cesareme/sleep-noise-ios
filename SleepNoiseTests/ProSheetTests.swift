import XCTest
@testable import SleepNoise

/// The catalog of one language, for the tests that check the words.
enum ProCatalog {
    static func lookup(_ language: String) -> (String) -> String {
        let main = Bundle(for: MixStore.self)
        guard let url = main.url(forResource: language, withExtension: "lproj"),
              let bundle = Bundle(url: url)
        else {
            XCTFail("no \(language).lproj in the app bundle")
            return { $0 }
        }
        return { bundle.localizedString(forKey: $0, value: "<missing \($0)>", table: nil) }
    }
}

/// What the Pro sheet shows in each state of the purchase, the trial and
/// the store: which action it leads with, which word the purchase says and
/// which line sits in the place of the footer.
final class ProSheetContentTests: XCTestCase {
    private typealias Input = ProSheetContent.Input

    private let product = ProProduct(displayName: "Store Name", displayPrice: "¤ 12,34", isFamilyShareable: true)
    private let receipt = ProReceipt(
        purchaseDate: Date(timeIntervalSinceReferenceDate: 700_000_000), isFamilyShared: false
    )

    private func selling(_ change: (inout Input) -> Void = { _ in }) -> ProSheetContent {
        var input = Input(product: .loaded(product), displayName: product.displayName)
        change(&input)
        return ProSheetContent(input)
    }

    private func bought(_ change: (inout Input) -> Void = { _ in }) -> ProSheetContent {
        var input = Input(
            isPro: true,
            wasProWhenOpened: true,
            trial: .ended,
            product: .loaded(product),
            receipt: receipt,
            displayName: product.displayName
        )
        change(&input)
        return ProSheetContent(input)
    }

    // MARK: The action it leads with

    /// Red if a new install is not offered the trial first, or if the
    /// price of the purchase is anything but the store's.
    func testANewInstallLeadsWithTheTrialAndThePurchaseSaysTheStorePrice() {
        let sheet = selling()
        XCTAssertFalse(sheet.isReceipt)
        XCTAssertTrue(sheet.showsStartTrial)
        XCTAssertTrue(sheet.canStartTrial)
        XCTAssertEqual(sheet.primary, .startTrial)
        XCTAssertEqual(sheet.purchase, .buy(price: "¤ 12,34"))
        XCTAssertTrue(sheet.canBuy, "the purchase is there too, under the trial")
        XCTAssertEqual(sheet.price, "¤ 12,34")
        XCTAssertTrue(sheet.showsNotNow)
        XCTAssertFalse(sheet.showsReview)
        XCTAssertNil(sheet.resultKey, "nothing happened: the footer is the footer")
        XCTAssertFalse(sheet.closesItself)
    }

    /// Red if the trial can be started without its terms in sight: how
    /// long it lasts, that nothing is charged and what stays when it ends
    /// are the line of the foot for as long as the button is there, and the
    /// footer comes back when it is not.
    func testWhileTheTrialIsOnOfferTheFootSaysWhatItIs() {
        XCTAssertEqual(selling().footKey, "pro.prueba.empezar.nota")
        XCTAssertEqual(selling { $0.product = .loading }.footKey, "pro.prueba.empezar.nota")
        for trial in [TrialState.active(nightsLeft: 3), .ended] {
            XCTAssertEqual(selling { $0.trial = trial }.footKey, "lo_que_no_hay.pie", "\(trial)")
        }
        XCTAssertEqual(bought().footKey, "lo_que_no_hay.pie")
        XCTAssertEqual(bought { $0.trial = .notStarted }.footKey, "lo_que_no_hay.pie")

        // What just happened still takes its place, one line at a time.
        let failed = selling { $0.notice = .trialNotStarted }
        XCTAssertEqual(failed.resultKey, "pro.fallo")

        // Red if a line the foot can say is missing from the ones it
        // reserves room for: the foot would grow when that line appears.
        let notices: [PurchaseNotice?] = [
            nil, .purchased, .restored, .nothingToRestore, .pending, .cancelled, .failed, .unconfirmed,
            .storeUnavailable, .trialNotStarted,
        ]
        for notice in notices {
            for isPlaying in [false, true] {
                for sheet in [
                    selling { $0.notice = notice; $0.isPlaying = isPlaying },
                    selling { $0.notice = notice; $0.isPlaying = isPlaying; $0.product = .unavailable },
                    selling { $0.notice = notice; $0.isPurchasePending = true },
                    bought { $0.notice = notice },
                ] {
                    XCTAssertTrue(sheet.footKeys.contains(sheet.footKey))
                    if let key = sheet.resultKey {
                        XCTAssertTrue(sheet.footKeys.contains(key), "\(String(describing: notice)): \(key)")
                    }
                }
            }
        }
        for language in ["en", "es"] {
            let note = ProCatalog.lookup(language)("pro.prueba.empezar.nota")
            XCTAssertFalse(note.isEmpty, language)
            XCTAssertNotEqual(note, "pro.prueba.empezar.nota", language)
        }
    }

    /// Red if "Start the trial" is offered once the trial was used, in any
    /// of its states, or with Pro bought.
    func testTheTrialIsOfferedOnlyWhileItWasNeverUsed() {
        for trial in [TrialState.active(nightsLeft: 7), .active(nightsLeft: 1), .active(nightsLeft: 0), .ended] {
            let sheet = selling { $0.trial = trial }
            XCTAssertFalse(sheet.showsStartTrial, "\(trial)")
            XCTAssertFalse(sheet.canStartTrial, "\(trial)")
            XCTAssertEqual(sheet.primary, .buy, "\(trial): the purchase is what is left")
        }
        let receipt = bought { $0.trial = .notStarted }
        XCTAssertFalse(receipt.showsStartTrial, "there is nothing to try with Pro bought")
        XCTAssertEqual(receipt.primary, .none)
    }

    /// Red if the purchase can be pressed without a price, or if the trial
    /// waits for a store it does not need.
    func testWithoutAPriceThePurchaseIsAWordThatCannotBePressed() {
        for state in [ProductState.loading, .unavailable] {
            let sheet = selling { $0.product = state }
            XCTAssertNil(sheet.price, "\(state): a dash, never a figure of our own")
            XCTAssertEqual(sheet.purchase, .buyWithoutPrice)
            XCTAssertFalse(sheet.canBuy)
            XCTAssertEqual(sheet.primary, .startTrial, "the trial is local: it needs no store")
            XCTAssertEqual(sheet.storeIsAway, state == .unavailable)
        }
        let used = selling {
            $0.product = .unavailable
            $0.trial = .ended
        }
        XCTAssertEqual(used.primary, .none, "no store and no trial: nothing to press")
        XCTAssertNil(selling { $0.product = .loading }.resultKey, "still asking: nothing to explain")
    }

    /// Red if the store being away is said as if something were playing
    /// when nothing is, or the other way round.
    func testAStoreThatDoesNotAnswerSaysSoWithoutClaimingSound() {
        let silent = selling { $0.product = .unavailable }
        XCTAssertEqual(silent.resultKey, "pro.sin_tienda.silencio")
        let playing = selling {
            $0.product = .unavailable
            $0.isPlaying = true
        }
        XCTAssertEqual(playing.resultKey, "pro.sin_tienda")
        // The same after an action that found no store.
        XCTAssertEqual(selling { $0.notice = .storeUnavailable }.resultKey, "pro.sin_tienda.silencio")
        XCTAssertEqual(
            selling {
                $0.notice = .storeUnavailable
                $0.isPlaying = true
            }.resultKey,
            "pro.sin_tienda"
        )
    }

    // MARK: The store at work

    /// Red if anything can be pressed while the App Store works, or if a
    /// spinner would be needed to know it is working.
    func testWhileTheStoreWorksTheRowsSayItAndNothingAnswers() {
        let buying = selling { $0.activity = .purchasing }
        XCTAssertEqual(buying.purchase, .buying)
        XCTAssertFalse(buying.canBuy)
        XCTAssertFalse(buying.canStartTrial)
        XCTAssertFalse(buying.isIdle)
        XCTAssertEqual(buying.primary, .none)
        XCTAssertNil(buying.resultKey)

        let restoring = selling { $0.activity = .restoring }
        XCTAssertTrue(restoring.isRestoring)
        XCTAssertEqual(restoring.purchase, .buy(price: "¤ 12,34"), "the price stays where it was")
        XCTAssertFalse(restoring.canBuy)
        XCTAssertFalse(restoring.canStartTrial)
        XCTAssertEqual(restoring.primary, .none)
    }

    /// Red if a purchase waiting for approval can be bought again, or if
    /// the sheet forgets it is waiting once the line was cleared.
    func testAPurchaseWaitingForApprovalSaysPending() {
        let fresh = selling {
            $0.isPurchasePending = true
            $0.notice = .pending
        }
        XCTAssertEqual(fresh.purchase, .pending)
        XCTAssertFalse(fresh.canBuy)
        XCTAssertEqual(fresh.resultKey, "pro.pendiente")
        XCTAssertEqual(fresh.primary, .startTrial, "the trial does not wait for anyone's approval")

        let reopened = selling { $0.isPurchasePending = true }
        XCTAssertEqual(reopened.purchase, .pending)
        XCTAssertEqual(reopened.resultKey, "pro.pendiente")
    }

    /// Red if an ending without Pro says another ending's line, or leaves
    /// the purchase in a state that cannot be tried again.
    func testEveryEndingWithoutProHasItsLineAndLeavesThePurchaseIntact() {
        let lines: [(PurchaseNotice, String)] = [
            (.cancelled, "pro.fallo"),
            (.failed, "pro.fallo"),
            (.trialNotStarted, "pro.fallo"),
            (.unconfirmed, "pro.fallo.sin_confirmar"),
            (.nothingToRestore, "pro.restaurar.no"),
        ]
        for (notice, key) in lines {
            let sheet = selling { $0.notice = notice }
            XCTAssertEqual(sheet.resultKey, key, "\(notice)")
            XCTAssertEqual(sheet.purchase, .buy(price: "¤ 12,34"), "\(notice)")
            XCTAssertTrue(sheet.canBuy, "\(notice)")
            XCTAssertFalse(sheet.closesItself, "\(notice)")
        }
    }

    // MARK: Bought

    /// Red if a purchase made from the sheet does not thank and close, or
    /// shows the receipt and a second "thank you" on its way out.
    func testBuyingFromTheSheetThanksAndCloses() {
        for notice in [PurchaseNotice.purchased, .restored] {
            let sheet = selling {
                $0.isPro = true
                $0.receipt = self.receipt
                $0.notice = notice
            }
            XCTAssertTrue(sheet.closesItself, "\(notice)")
            XCTAssertFalse(sheet.isReceipt, "\(notice): the sheet that sold stays as it was while it thanks")
            XCTAssertEqual(sheet.purchase, .thanks)
            XCTAssertFalse(sheet.canBuy)
            XCTAssertFalse(sheet.showsStartTrial)
            XCTAssertEqual(sheet.primary, .none)
            XCTAssertNil(sheet.resultKey, "the purchase row says it: not twice")
        }
    }

    /// Red if the receipt has anything that costs money, closes by itself
    /// after a restore, or offers the trial.
    func testTheReceiptHasNoActionThatCostsMoney() {
        let sheet = bought()
        XCTAssertTrue(sheet.isReceipt)
        XCTAssertNil(sheet.purchase)
        XCTAssertFalse(sheet.canBuy)
        XCTAssertFalse(sheet.showsStartTrial)
        XCTAssertFalse(sheet.showsNotNow)
        XCTAssertEqual(sheet.primary, .none)
        XCTAssertEqual(sheet.receipt, receipt)
        XCTAssertNil(sheet.resultKey)

        let restored = bought { $0.notice = .restored }
        XCTAssertTrue(restored.isReceipt)
        XCTAssertFalse(restored.closesItself, "it opened as the receipt: it stays")
        XCTAssertEqual(restored.resultKey, "pro.gracias")

        // Approved by a parent with the sheet open: no notice, just Pro.
        let arrived = selling {
            $0.isPro = true
            $0.receipt = self.receipt
        }
        XCTAssertTrue(arrived.isReceipt)
        XCTAssertFalse(arrived.closesItself)
        XCTAssertNil(arrived.purchase)
    }

    /// Red if the foot of the receipt or of "Thank you" has no upper edge
    /// (the column would end against nothing where it scrolls), or if the
    /// foot draws a second hairline over an action that has its own.
    func testTheFootDrawsItsOwnEdgeOnlyWhereNoActionDoes() {
        XCTAssertTrue(bought().footOpensWithRule)
        XCTAssertTrue(bought { $0.notice = .restored }.footOpensWithRule)
        let thanked = selling {
            $0.isPro = true
            $0.receipt = self.receipt
            $0.notice = .purchased
        }
        XCTAssertEqual(thanked.purchase, .thanks)
        XCTAssertTrue(thanked.footOpensWithRule)

        XCTAssertFalse(selling().footOpensWithRule, "the trial opens the foot")
        XCTAssertFalse(selling { $0.trial = .ended }.footOpensWithRule, "the purchase opens it")
        XCTAssertFalse(selling { $0.product = .loading }.footOpensWithRule)
        XCTAssertFalse(selling { $0.activity = .purchasing }.footOpensWithRule)
        XCTAssertFalse(selling { $0.isPurchasePending = true }.footOpensWithRule)
    }

    /// Red if the review link shows without an App Store page to open, or
    /// anywhere but on the receipt (C55).
    func testTheReviewLinkExistsOnlyOnTheReceiptAndOnlyWithAnAppStoreID() {
        XCTAssertFalse(bought().showsReview)
        XCTAssertTrue(bought { $0.hasReviewLink = true }.showsReview)
        XCTAssertFalse(selling { $0.hasReviewLink = true }.showsReview, "never on the sheet that sells")

        XCTAssertNil(AppLinks.reviewURL(appStoreID: ""))
        XCTAssertNil(AppLinks.reviewURL(appStoreID: "  "))
        XCTAssertNil(AppLinks.reviewURL(appStoreID: "id123"), "the id is its digits alone")
        XCTAssertEqual(
            AppLinks.reviewURL(appStoreID: "1234567890")?.absoluteString,
            "https://apps.apple.com/app/id1234567890?action=write-review"
        )
        // The constant and the link agree: an empty id hides the link.
        XCTAssertEqual(AppLinks.reviewURL() == nil, AppLinks.appStoreID.isEmpty)
    }

    /// Red if "With your family" is promised for a product the store says
    /// is not shared.
    func testFamilySharingIsListedUnlessTheStoreSaysOtherwise() {
        XCTAssertTrue(selling().listsFamily)
        XCTAssertTrue(selling { $0.product = .loading }.listsFamily, "the plan until the store answers")
        let alone = ProProduct(displayName: "Store Name", displayPrice: "¤ 1", isFamilyShareable: false)
        XCTAssertFalse(selling { $0.product = .loaded(alone) }.listsFamily)
    }
}

/// The words of the Pro sheet: the name and the price are the store's, and
/// every state is a word of the guide in both languages.
final class ProSheetTextTests: XCTestCase {
    private let date = Date(timeIntervalSinceReferenceDate: 700_000_000)

    private func fixedDate(_: Date) -> String { "<date>" }

    /// Red if the title is anything but the name the store gave, or if a
    /// name of our own appears before the store has answered.
    func testTheTitleIsTheStoreNameInSmallCaps() {
        for language in ["en", "es"] {
            let strings = ProCatalog.lookup(language)
            let locale = Locale(identifier: language)
            let named = ProSheetContent(.init(displayName: "Store Name"))
            XCTAssertEqual(ProSheetText.title(named, localized: strings, locale: locale), "store name", language)
            let unnamed = ProSheetContent(.init())
            XCTAssertEqual(ProSheetText.title(unnamed, localized: strings, locale: locale), "pro", language)
            XCTAssertEqual(ProSheetText.name(nil, localized: strings, locale: locale), "Pro", language)
            XCTAssertEqual(ProSheetText.name("", localized: strings, locale: locale), "Pro", language)
        }
    }

    func testTheReceiptLineSaysTheNameTheDateAndTheFamily() {
        let own = ProReceipt(purchaseDate: date, isFamilyShared: false)
        let shared = ProReceipt(purchaseDate: date, isFamilyShared: true)
        for (language, thanks, family) in [
            ("en", "Store Name · thank you · <date>", "Store Name · thank you · <date> · with your family"),
            ("es", "Store Name · gracias · <date>", "Store Name · gracias · <date> · en familia"),
        ] {
            let strings = ProCatalog.lookup(language)
            let locale = Locale(identifier: language)
            func line(_ receipt: ProReceipt?) -> String {
                ProSheetText.receiptLine(
                    displayName: "Store Name", receipt: receipt, localized: strings, date: fixedDate, locale: locale
                )
            }
            XCTAssertEqual(line(own), thanks, language)
            XCTAssertEqual(line(shared), family, language)
            XCTAssertEqual(line(nil), "Store Name", "a purchase kept without a date is the name alone")

            let sheet = ProSheetContent(.init(
                isPro: true, wasProWhenOpened: true, receipt: shared, displayName: "Store Name"
            ))
            // On the sheet the family has a line of its own: a "·" is
            // never left at the end of the line above.
            XCTAssertEqual(
                ProSheetText.title(sheet, localized: strings, date: fixedDate, locale: locale),
                thanks.lowercased(with: locale),
                language
            )
            let familyLine = try? XCTUnwrap(ProSheetText.familyLine(sheet, localized: strings, locale: locale))
            XCTAssertEqual(
                ProSheetText.title(sheet, localized: strings, date: fixedDate, locale: locale)
                    + " " + (familyLine ?? ""),
                family.lowercased(with: locale),
                language
            )
            let alone = ProSheetContent(.init(
                isPro: true, wasProWhenOpened: true, receipt: own, displayName: "Store Name"
            ))
            XCTAssertNil(ProSheetText.familyLine(alone, localized: strings, locale: locale), language)
            XCTAssertNil(
                ProSheetText.familyLine(ProSheetContent(.init(displayName: "Store Name")), localized: strings),
                "the sheet that sells has no receipt"
            )
        }
    }

    /// Red if VoiceOver reads the small caps as they are drawn: middle
    /// dots, and a month cut to three letters.
    func testVoiceOverReadsTheReceiptAsASentence() {
        let shared = ProReceipt(purchaseDate: date, isFamilyShared: true)
        func longDate(_: Date) -> String { "<long date>" }
        for (language, expected) in [
            ("en", "Store Name, thank you, <long date>, with your family"),
            ("es", "Store Name, gracias, <long date>, en familia"),
        ] {
            let strings = ProCatalog.lookup(language)
            let locale = Locale(identifier: language)
            let sheet = ProSheetContent(.init(
                isPro: true, wasProWhenOpened: true, receipt: shared, displayName: "Store Name"
            ))
            let spoken = ProSheetText.spokenTitle(sheet, localized: strings, date: longDate, locale: locale)
            XCTAssertEqual(spoken, expected, language)
            XCTAssertFalse(spoken.contains("·"), language)
            XCTAssertEqual(
                ProSheetText.spokenTitle(
                    ProSheetContent(.init(displayName: "Store Name")), localized: strings, locale: locale
                ),
                "Store Name",
                language
            )
            XCTAssertFalse(ProSheetText.spoken(strings("pro.gratis.lista")).contains("·"), language)
        }
    }

    /// Red if the trial button, set in two lines with larger text, leaves
    /// its "·" at the end of the first.
    func testWithLargerTextTheTrialButtonIsTwoLinesWithoutADot() {
        for (language, whole, stacked) in [
            ("en", "Start the trial · 7 nights", "Start the trial\n7 nights"),
            ("es", "Empezar la prueba · 7 noches", "Empezar la prueba\n7 noches"),
        ] {
            let strings = ProCatalog.lookup(language)
            XCTAssertEqual(ProSheetText.trialTitle(stacked: false, localized: strings), whole, language)
            XCTAssertEqual(ProSheetText.trialTitle(stacked: true, localized: strings), stacked, language)
        }
    }

    func testTheDateOfTheReceiptIsShortAndFollowsThePlace() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 16
        components.hour = 12
        let day = utc.date(from: components) ?? date
        XCTAssertEqual(ProSheetText.shortDate(day, locale: Locale(identifier: "es_ES"), calendar: utc), "16 nov 2026")
        XCTAssertEqual(ProSheetText.shortDate(day, locale: Locale(identifier: "en_US"), calendar: utc), "Nov 16, 2026")
    }

    /// Red if the purchase row says a price that is not the one it was
    /// given, or a state in other words than the guide's.
    func testThePurchaseSaysItsStateInWords() {
        for (language, buy, plain, buying, pending, thanks) in [
            ("en", "Buy · ¤ 12,34", "Buy", "Buying…", "Pending", "Thank you. Everything’s open."),
            ("es", "Comprar · ¤ 12,34", "Comprar", "Comprando…", "Pendiente", "Gracias. Todo abierto."),
        ] {
            let strings = ProCatalog.lookup(language)
            func title(_ purchase: ProSheetContent.Purchase) -> String {
                ProSheetText.purchaseTitle(purchase, localized: strings)
            }
            XCTAssertEqual(title(.buy(price: "¤ 12,34")), buy, language)
            XCTAssertEqual(title(.buyWithoutPrice), plain, language)
            XCTAssertEqual(title(.buying), buying, language)
            XCTAssertEqual(title(.pending), pending, language)
            XCTAssertEqual(title(.thanks), thanks, language)
        }
        let english = ProCatalog.lookup("en")
        XCTAssertEqual(ProSheetText.restoreTitle(isRestoring: false, localized: english), "Restore purchase")
        XCTAssertEqual(ProSheetText.restoreTitle(isRestoring: true, localized: english), "Looking…")
        let spanish = ProCatalog.lookup("es")
        XCTAssertEqual(ProSheetText.restoreTitle(isRestoring: false, localized: spanish), "Restaurar compra")
        XCTAssertEqual(ProSheetText.restoreTitle(isRestoring: true, localized: spanish), "Buscando…")
    }

    /// Red if VoiceOver reads a name or a price that did not come from the
    /// store, or says the store is away while it is only being asked.
    func testVoiceOverReadsThePurchaseWithTheStoreNameAndPrice() {
        for (language, buy, plain, value, away, buying) in [
            ("en", "Buy Store Name, ¤ 12,34", "Buy Store Name", "price unavailable",
             "The store isn’t responding.", "Buying"),
            ("es", "Comprar Store Name, ¤ 12,34", "Comprar Store Name", "precio no disponible",
             "La tienda no responde.", "Comprando"),
        ] {
            let strings = ProCatalog.lookup(language)
            let locale = Locale(identifier: language)
            func spoken(_ purchase: ProSheetContent.Purchase) -> String {
                ProSheetText.spokenPurchase(purchase, displayName: "Store Name", localized: strings, locale: locale)
            }
            XCTAssertEqual(spoken(.buy(price: "¤ 12,34")), buy, language)
            XCTAssertEqual(spoken(.buyWithoutPrice), plain, language)
            XCTAssertEqual(spoken(.buying), buying, "\(language): no ellipsis for the voice")
            XCTAssertEqual(ProSheetText.purchaseValue(.buyWithoutPrice, localized: strings), value, language)
            XCTAssertNil(ProSheetText.purchaseValue(.buy(price: "¤ 12,34"), localized: strings))
            XCTAssertEqual(
                ProSheetText.purchaseHint(.buyWithoutPrice, storeIsAway: true, localized: strings), away, language
            )
            XCTAssertNil(ProSheetText.purchaseHint(.buyWithoutPrice, storeIsAway: false, localized: strings))
            XCTAssertNotNil(ProSheetText.purchaseHint(.buy(price: "¤ 12,34"), storeIsAway: false, localized: strings))
            XCTAssertNil(ProSheetText.purchaseHint(.buying, storeIsAway: false, localized: strings))
        }
    }
}

/// The catalog behind the Pro sheet, the trial on the page and Settings.
final class ProCatalogTests: XCTestCase {
    static let keys = [
        "pro.precio.cargando", "pro.una_vez", "pro.precio", "pro.pie", "pro.con", "pro.incluye.texturas",
        "pro.incluye.texturas.detalle", "pro.incluye.marea", "pro.incluye.mezclas", "pro.familia", "pro.gratis",
        "pro.gratis.lista", "pro.prueba.empezar", "pro.prueba.empezar.nota", "pro.prueba.estado",
        "pro.prueba.estado.ultima", "pro.prueba.estado.gratis", "pro.comprar", "pro.comprar.sin_precio",
        "pro.comprando", "pro.buscando", "pro.pendiente.boton", "pro.restaurar", "pro.resena", "pro.gracias",
        "pro.fallo", "pro.fallo.sin_confirmar", "pro.pendiente", "pro.sin_tienda", "pro.sin_tienda.silencio",
        "pro.restaurar.no", "pro.ajustes.gracias", "pro.ajustes.familia", "comun.ahora_no", "comun.entendido",
        "comun.pro", "prueba.ultima", "prueba.terminada", "ajustes.titulo", "ajustes.seccion.noche",
        "ajustes.pantalla", "ajustes.pantalla.carga", "ajustes.pantalla.siempre", "ajustes.pantalla.nunca",
        "ajustes.seccion.pro", "ajustes.seccion.sobre", "ajustes.autor", "lo_que_no_hay.titulo",
        "lo_que_no_hay.pie", "lo_que_no_hay.lista", "lo_que_no_hay.resena", "ax.prueba.cabecera",
        "ax.prueba.pista", "ax.comprar", "ax.comprar.pista", "ax.comprar.sin_precio",
        "ax.comprar.sin_precio.valor", "ax.comprar.sin_precio.pista", "ax.prueba.empezar",
        "ax.prueba.empezar.pista", "ax.resena.pista", "ax.autor.pista"
    ]

    func testEveryStringExistsInBothLanguages() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in Self.keys {
            for language in ["en", "es"] {
                let found = TimerCatalogTests.values(key, language, in: strings)
                XCTAssertFalse(found.isEmpty, "\(key) [\(language)] is missing")
                XCTAssertFalse(found.contains { $0.isEmpty }, "\(key) [\(language)] is empty")
            }
        }
    }

    /// The old sheet went with its strings, and so did its Close button:
    /// a Grafito sheet is dismissed with the gesture or with "Not now".
    func testTheStringsOfTheOldSheetAreGone() throws {
        let strings = try TimerCatalogTests.catalog()
        for key in strings.keys {
            XCTAssertFalse(key.hasPrefix("paywall."), "\(key) belongs to the sheet that was removed")
            XCTAssertFalse(key.hasPrefix("trial."), "\(key) belongs to the trial that was removed")
        }
        XCTAssertNil(strings["common.close"])
    }

    /// Red if a string carries a price, a count of textures or the length
    /// of the trial as a figure of its own (C02, C04), or a banned word.
    /// The one figure allowed is the 7 of "Start the trial · 7 nights",
    /// which is the name of the action and is tied to `NightTrial.nights`.
    func testNoStringCarriesAPriceACountOrABannedWord() throws {
        let strings = try TimerCatalogTests.catalog()
        let banned = [
            "unlock", "desbloque", "premium", "lifetime", "vitalicio", "oferta", "offer", "discount",
            "descuento", "lanzamiento", "launch", "!", "¡", "€", "$", "29", "once texturas", "eleven",
        ]
        // The figures of these two come from the model, not from a count
        // someone wrote: the length of the trial and the nights left.
        let figures = ["pro.prueba.empezar", "pro.prueba.estado"]
        for key in Self.keys {
            for language in ["en", "es"] {
                for value in TimerCatalogTests.values(key, language, in: strings) {
                    var words = value.lowercased()
                    for placeholder in ["%lld", "%1$@", "%2$@", "%@"] {
                        words = words.replacingOccurrences(of: placeholder, with: "")
                    }
                    for word in banned {
                        XCTAssertFalse(words.contains(word), "\(key) [\(language)]: \(value)")
                    }
                    if !figures.contains(key) {
                        XCTAssertNil(words.rangeOfCharacter(from: .decimalDigits), "\(key) [\(language)]: \(value)")
                    }
                }
            }
        }
        for language in ["en", "es"] {
            let start = TimerCatalogTests.values("pro.prueba.empezar", language, in: strings)
            XCTAssertEqual(start.count, 1)
            XCTAssertTrue(start[0].contains("\(NightTrial.nights)"), "\(language): the trial is \(NightTrial.nights) nights")
        }
    }

    /// The sentence about the subscription is the only place the word is
    /// allowed, and it reads the same in the three places it appears.
    func testSubscriptionIsOnlyNamedToSayThereIsNone() throws {
        let strings = try TimerCatalogTests.catalog()
        XCTAssertEqual(
            TimerCatalogTests.values("lo_que_no_hay.pie", "es", in: strings),
            ["Sin suscripción. Sin cuenta. Sin rastreo."]
        )
        XCTAssertEqual(
            TimerCatalogTests.values("lo_que_no_hay.pie", "en", in: strings),
            ["No subscription. No account. No tracking."]
        )
        for (key, entry) in strings {
            for language in ["en", "es"] {
                let localizations = (entry as? [String: Any])?["localizations"] as? [String: Any]
                for value in TimerCatalogTests.values(in: localizations?[language]) {
                    let lower = value.lowercased()
                    guard lower.contains("suscri") || lower.contains("subscri") else { continue }
                    XCTAssertTrue(key.hasPrefix("lo_que_no_hay."), "\(key) [\(language)]: \(value)")
                    XCTAssertTrue(
                        lower.contains("sin suscripción") || lower.contains("no subscription"),
                        "\(key) [\(language)]: \(value)"
                    )
                }
            }
        }
    }

    /// The free list of the sheet is `AccessPolicy` in words: red when the
    /// policy moves and the sentence does not.
    func testTheFreeListOfTheSheetIsThePolicy() throws {
        XCTAssertEqual(AccessPolicy.freeSavedMixLimit, 3, "pro.gratis.lista says \"three mixes\"")
        for language in ["en", "es"] {
            let strings = ProCatalog.lookup(language)
            let locale = Locale(identifier: language)
            let free = strings("pro.gratis.lista").lowercased(with: locale)
            let pro = strings("pro.incluye.texturas.detalle").lowercased(with: locale)
            for sound in SoundID.allCases {
                let name = strings("sound.\(sound.rawValue)").lowercased(with: locale)
                let isFree = AccessPolicy.soundIsIncluded(sound, hasFullAccess: false)
                XCTAssertEqual(free.contains(name), isFree, "\(language): \(name) in the free list")
                XCTAssertEqual(pro.contains(name), !isFree, "\(language): \(name) in the Pro list")
            }
        }
    }
}

/// The trial on the page: its word, what VoiceOver reads and the two notes
/// it says once, never at night.
@MainActor
final class PageTrialTests: XCTestCase {
    private func time(day: Int = 17, _ hour: Int, _ minute: Int = 0) -> Date {
        NightHarness.time(day: day, hour, minute)
    }

    func testVoiceOverReadsTheNightsAsASentence() {
        for (language, five, last, free) in [
            ("en", "Trial, 5 nights left", "trial, final night", "always free"),
            ("es", "Prueba, quedan 5 noches", "prueba, última noche", "gratis siempre"),
        ] {
            let strings = ProCatalog.lookup(language)
            let locale = Locale(identifier: language)
            func spoken(_ trial: TrialState, isPro: Bool = false, alwaysFree: Bool = false) -> String? {
                PageTrialWord.spoken(
                    trial: trial, isPro: isPro, showsAlwaysFree: alwaysFree, localized: strings, locale: locale
                )
            }
            XCTAssertEqual(spoken(.active(nightsLeft: 5)), five, language)
            XCTAssertEqual(spoken(.active(nightsLeft: 1)), last, language)
            XCTAssertEqual(spoken(.ended, alwaysFree: true), free, language)
            XCTAssertNil(spoken(.active(nightsLeft: 0)), "the last day has no figure and no word")
            XCTAssertNil(spoken(.notStarted))
            XCTAssertNil(spoken(.ended))
            XCTAssertNil(spoken(.active(nightsLeft: 5), isPro: true))
        }
    }

    /// Red if the header speaks of the trial, or of what is free, inside
    /// the night window, on the night page or in Small Hours (C08).
    func testTheHeaderSaysNothingWhileNothingMayBeSold() throws {
        let strings = ProCatalog.lookup("es")
        let locale = Locale(identifier: "es")
        func word(_ night: NightHarness) -> String? {
            PageTrialWord.text(
                trial: night.purchases.trialState,
                isPro: night.purchases.isPro,
                showsAlwaysFree: night.purchases.showsAlwaysFree,
                canSell: night.model.canSell,
                localized: strings,
                locale: locale
            )
        }
        func spoken(_ night: NightHarness) -> String? {
            PageTrialWord.spoken(
                trial: night.purchases.trialState,
                isPro: night.purchases.isPro,
                showsAlwaysFree: night.purchases.showsAlwaysFree,
                canSell: night.model.canSell,
                localized: strings,
                locale: locale
            )
        }

        let night = try NightHarness(at: time(12), access: .trial)
        XCTAssertEqual(word(night), "prueba · quedan 7 noches")
        for hour in [21, 23, 2, 6] {
            night.jump(to: time(day: 18, hour))
            night.model.appDidBecomeActive()
            XCTAssertNil(word(night), "\(hour): nothing speaks of the trial at night")
            XCTAssertNil(spoken(night), "\(hour)")
        }
        night.jump(to: time(day: 19, 9))
        night.model.appDidBecomeActive()
        XCTAssertNotNil(word(night))
        night.model.beginNightSession()
        XCTAssertNil(word(night), "the night page, whatever the hour")
        night.model.endNightSession()
        night.model.startSmallHours()
        XCTAssertNil(word(night), "Small Hours never sells")

        // "always free" is a way into the sheet too.
        let after = try NightHarness(at: time(12), access: .trialEnded)
        after.model.play()
        after.model.pause()
        XCTAssertEqual(word(after), "gratis siempre")
        after.jump(to: time(22))
        XCTAssertNil(word(after))
    }

    /// Red if the sentence of the last night covers a pause, an error or
    /// anything else the state line has to say.
    func testTheLastNightTakesOnlyTheLineOfSilence() {
        let strings = ProCatalog.lookup("es")
        let sentence = "Última noche con todo. Mañana, lo gratis sigue gratis."
        XCTAssertEqual(PageTrialNote.statusLine(.lastNight, status: .silent, localized: strings), sentence)
        for status in [PageStatus.playing, .paused, .pausedCall, .pausedHeadphones, .error(attempt: 1), .silentAllPro] {
            XCTAssertNil(PageTrialNote.statusLine(.lastNight, status: status, localized: strings), "\(status)")
        }
        XCTAssertNil(PageTrialNote.statusLine(.ended, status: .silent, localized: strings))
        XCTAssertNil(PageTrialNote.statusLine(nil, status: .silent, localized: strings))
        XCTAssertEqual(
            PageTrialNote.statusLine(.lastNight, status: .silent, localized: ProCatalog.lookup("en")),
            "Final night with everything. Tomorrow, free stays free."
        )
    }

    func testTheEndOfTheTrialIsANoteWithItsOwnWords() {
        XCTAssertEqual(
            PageTrialNote.footnote(.ended, localized: ProCatalog.lookup("es")),
            "La prueba terminó. Lo que usaste sigue aquí."
        )
        XCTAssertEqual(
            PageTrialNote.footnote(.ended, localized: ProCatalog.lookup("en")),
            "The trial is over. What you used is still here."
        )
        XCTAssertNil(PageTrialNote.footnote(.lastNight))
        XCTAssertNil(PageTrialNote.footnote(nil))
    }

    /// Red if the last night is announced at night, on the night page,
    /// over the sound, or again after the Play that follows it.
    func testTheLastNightIsSaidOnlyByDayInSilenceAndOnce() throws {
        // Started at noon six days ago: one night is left.
        let night = try NightHarness(at: time(day: 11, 12), access: .trial)
        night.jump(to: time(day: 17, 12))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.purchases.trialState, .active(nightsLeft: 1))
        XCTAssertEqual(night.model.visibleTrialNote, .lastNight)

        night.model.beginNightSession()
        XCTAssertNil(night.model.visibleTrialNote, "the night page says nothing of the trial")
        night.model.endNightSession()
        XCTAssertEqual(night.model.visibleTrialNote, .lastNight)

        night.model.play()
        XCTAssertNil(night.model.visibleTrialNote, "it dies with the Play")
        night.model.pause()
        XCTAssertNil(night.model.visibleTrialNote, "and does not come back")

        let late = try NightHarness(at: time(day: 11, 12), access: .trial)
        late.jump(to: time(day: 17, 22))
        late.model.appDidBecomeActive()
        XCTAssertEqual(late.purchases.trialState, .active(nightsLeft: 1))
        XCTAssertNil(late.model.visibleTrialNote, "inside the night window nothing speaks of the trial")
    }

    /// Red if "The trial is over" shows at night, or stays after "Got it".
    func testTheEndIsSaidByDayUntilGotIt() throws {
        let night = try NightHarness(at: time(22), access: .trial)
        night.jump(to: time(day: 25, 23))
        night.model.play()
        XCTAssertEqual(night.purchases.trialState, .ended)
        night.model.pause()
        XCTAssertNil(night.model.visibleTrialNote, "23:00: it waits for the day")

        night.jump(to: time(day: 26, 10))
        night.model.appDidBecomeActive()
        XCTAssertEqual(night.model.visibleTrialNote, .ended)
        XCTAssertEqual(PageTrialNote.footnote(night.model.visibleTrialNote, localized: ProCatalog.lookup("en")),
                       "The trial is over. What you used is still here.")
        night.purchases.dismissTrialNote()
        XCTAssertNil(night.model.visibleTrialNote)
        XCTAssertNil(night.purchases.trialNote)
    }
}
