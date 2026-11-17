import XCTest
@testable import SleepNoise

/// Settings: the words of its rows, the Pro row in each state and the two
/// ways out of the app that stay hidden until the owner gives them.
@MainActor
final class SettingsTests: XCTestCase {
    private let product = ProProduct(displayName: "Store Name", displayPrice: "¤ 12,34", isFamilyShareable: true)
    private let receipt = ProReceipt(
        purchaseDate: Date(timeIntervalSinceReferenceDate: 700_000_000), isFamilyShared: false
    )

    private func row(
        isPro: Bool = false,
        displayName: String? = "Store Name",
        product: ProductState? = nil,
        receipt: ProReceipt? = nil,
        canSell: Bool = true,
        language: String = "es"
    ) -> SettingsProRow {
        SettingsProRow(
            isPro: isPro,
            displayName: displayName,
            product: product ?? .loaded(self.product),
            receipt: receipt,
            canSell: canSell,
            localized: ProCatalog.lookup(language),
            date: { _ in "<date>" },
            spokenDate: { _ in "<long date>" },
            locale: Locale(identifier: language)
        )
    }

    // MARK: The Pro row

    /// Red if the row writes a name or a price of its own.
    func testTheProRowSaysTheStoreNameAndPrice() {
        let spanish = row()
        XCTAssertEqual(spanish.title, "Store Name")
        XCTAssertEqual(spanish.value, "¤ 12,34 · Una vez.")
        XCTAssertTrue(spanish.opensSheet)
        XCTAssertEqual(spanish.spokenTitle, "Store Name")
        XCTAssertEqual(spanish.spokenValue, "¤ 12,34, Una vez.")
        XCTAssertEqual(row(language: "en").value, "¤ 12,34 · Once.")

        // Red if the row shows anything in the place of a price it does
        // not have: a dash alone under "pro" and "Pro" reads as a fault.
        for state in [ProductState.loading, .unavailable] {
            let waiting = row(product: state)
            XCTAssertNil(waiting.value, "\(state): no figure and nothing in its place")
            XCTAssertNil(waiting.spokenValue)
            XCTAssertTrue(waiting.opensSheet, "the sheet says the store is away")
        }
        XCTAssertEqual(row(displayName: nil).title, "Pro", "until the store has answered once")
    }

    func testTheProRowOfAPurchaseIsTheReceiptLine() {
        let bought = row(isPro: true, receipt: receipt)
        XCTAssertEqual(bought.title, "Store Name · gracias · <date>")
        XCTAssertNil(bought.value, "no price once it is paid")
        XCTAssertTrue(bought.opensSheet, "it opens the receipt")

        // Red if the family is left to wrap with its "·" at the end of
        // the line above: it is the subtitle, on its own line.
        let shared = row(isPro: true, receipt: ProReceipt(purchaseDate: receipt.purchaseDate, isFamilyShared: true))
        XCTAssertEqual(shared.title, "Store Name · gracias · <date>")
        XCTAssertEqual(shared.subtitle, "En familia")
        XCTAssertNil(bought.subtitle)
        XCTAssertEqual(
            row(isPro: true, receipt: receipt, language: "en").title, "Store Name · thank you · <date>"
        )
        let sharedInEnglish = row(
            isPro: true,
            receipt: ProReceipt(purchaseDate: receipt.purchaseDate, isFamilyShared: true),
            language: "en"
        )
        XCTAssertEqual(sharedInEnglish.subtitle, "With your family")
    }

    /// Red if VoiceOver reads the row as it is drawn, middle dots and
    /// short month included: the name is the label and the rest the value.
    func testVoiceOverReadsTheNameAndThenTheReceipt() {
        let bought = row(isPro: true, receipt: receipt)
        XCTAssertEqual(bought.spokenTitle, "Store Name")
        XCTAssertEqual(bought.spokenValue, "gracias, <long date>")

        let shared = row(isPro: true, receipt: ProReceipt(purchaseDate: receipt.purchaseDate, isFamilyShared: true))
        XCTAssertEqual(shared.spokenTitle, "Store Name")
        XCTAssertEqual(shared.spokenValue, "gracias, <long date>, en familia")
        XCTAssertEqual(
            row(isPro: true, receipt: receipt, language: "en").spokenValue, "thank you, <long date>"
        )

        // A purchase kept without its date is the name alone.
        let undated = row(isPro: true)
        XCTAssertEqual(undated.spokenTitle, "Store Name")
        XCTAssertNil(undated.spokenValue)

        let utc = try? XCTUnwrap(TimeZone(identifier: "UTC"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc ?? .gmt
        let day = Date(timeIntervalSinceReferenceDate: 0)
        XCTAssertEqual(
            ProSheetText.longDate(day, locale: Locale(identifier: "es_ES"), calendar: calendar),
            "1 de enero de 2001"
        )
        XCTAssertEqual(
            ProSheetText.longDate(day, locale: Locale(identifier: "en_US"), calendar: calendar),
            "January 1, 2001"
        )
    }

    /// Red if anything on the row sells at night: it is words, with no
    /// price and no way into the sheet (C08).
    func testAtNightTheProRowIsWordsWithoutAPrice() {
        let night = row(canSell: false)
        XCTAssertFalse(night.opensSheet)
        XCTAssertEqual(night.title, "Store Name")
        XCTAssertNil(night.value)
        XCTAssertNil(night.spokenValue)

        let bought = row(isPro: true, receipt: receipt, canSell: false)
        XCTAssertFalse(bought.opensSheet)
        XCTAssertEqual(bought.title, "Store Name · gracias · <date>", "what was bought is still said")
    }

    /// The gate of the row is the gate of everything that sells.
    func testTheWayIntoTheSheetFollowsTheSaleGate() throws {
        let night = try NightHarness(at: NightHarness.time(12), access: .free)
        XCTAssertTrue(night.model.canSell)
        night.model.offerPro()
        XCTAssertTrue(night.model.showPaywall)
        night.model.dismissPro()

        for hour in [21, 23, 3, 6] {
            night.jump(to: NightHarness.time(hour))
            XCTAssertFalse(night.model.canSell, "\(hour)")
            night.model.offerPro()
            XCTAssertFalse(night.model.showPaywall, "\(hour): nothing opens and nothing waits for the morning")
        }
        night.jump(to: NightHarness.time(day: 18, 9))
        XCTAssertFalse(night.model.showPaywall, "no sheet was queued")
    }

    // MARK: Restore purchase while nothing sells

    private func restoreRow(
        isPro: Bool = false,
        canSell: Bool = false,
        activity: StoreActivity = .idle,
        notice: PurchaseNotice? = nil,
        isPlaying: Bool = false,
        askedHere: Bool = false
    ) -> SettingsRestoreRow {
        SettingsRestoreRow(
            isPro: isPro,
            canSell: canSell,
            activity: activity,
            notice: notice,
            isPlaying: isPlaying,
            askedHere: askedHere
        )
    }

    /// The row as Settings builds it, from a model and its store.
    private func restoreRow(_ night: NightHarness, askedHere: Bool) -> SettingsRestoreRow {
        restoreRow(
            isPro: night.purchases.isPro,
            canSell: night.model.canSell,
            activity: night.purchases.activity,
            notice: night.purchases.notice,
            isPlaying: night.model.isPlaying,
            askedHere: askedHere
        )
    }

    /// Red if someone who paid has no way to restore at night, or if the
    /// row shows by day, where the Pro sheet already has it.
    func testRestoreIsARowOnlyWithoutProWhileNothingSells() throws {
        XCTAssertTrue(restoreRow().exists)
        XCTAssertFalse(restoreRow(canSell: true).exists, "by day Restore is in the Pro sheet")
        XCTAssertFalse(restoreRow(isPro: true).exists, "nothing to restore")
        XCTAssertFalse(restoreRow(isPro: true, canSell: true).exists)

        // The gate is the model's: the night window, the night page and
        // Small Hours, and nothing else.
        let night = try NightHarness(at: NightHarness.time(12), access: .free)
        XCTAssertFalse(restoreRow(night, askedHere: false).exists)
        for (hour, minute) in [(20, 59), (7, 0), (9, 0)] {
            night.jump(to: NightHarness.time(hour, minute))
            XCTAssertFalse(restoreRow(night, askedHere: false).exists, "\(hour):\(minute)")
        }
        for (hour, minute) in [(21, 0), (23, 30), (3, 42), (6, 59)] {
            night.jump(to: NightHarness.time(hour, minute))
            XCTAssertTrue(restoreRow(night, askedHere: false).exists, "\(hour):\(minute)")
        }
        night.jump(to: NightHarness.time(12))
        night.model.beginNightSession()
        XCTAssertTrue(restoreRow(night, askedHere: false).exists, "the night page, at any hour")
        night.model.endNightSession()
        XCTAssertFalse(restoreRow(night, askedHere: false).exists)
        XCTAssertEqual(night.model.startSmallHours(), .started)
        XCTAssertTrue(restoreRow(night, askedHere: false).exists, "Small Hours, at any hour")

        // With Pro there is no row at any hour.
        let bought = try NightHarness(at: NightHarness.time(23))
        XCTAssertTrue(bought.purchases.isPro)
        XCTAssertFalse(restoreRow(bought, askedHere: false).exists)
    }

    /// Red if the row carries a price, a figure or a way into the sheet:
    /// its words are the action and nothing else.
    func testTheRestoreRowIsWordsWithoutAPrice() {
        XCTAssertEqual(SettingsRestoreRow.titleKey, "pro.restaurar")
        let row = restoreRow()
        XCTAssertEqual(row.titleKey, "pro.restaurar")
        XCTAssertTrue(row.isEnabled)
        XCTAssertNil(row.resultKey, "nothing is said before it is asked for")
        for language in ["es", "en"] {
            let lookup = ProCatalog.lookup(language)
            for key in [SettingsRestoreRow.titleKey, SettingsRestoreRow.lookingKey] {
                let words = lookup(key)
                XCTAssertNotEqual(words, key, "\(language) \(key)")
                XCTAssertNil(words.rangeOfCharacter(from: .decimalDigits), "\(language) \(key): no figure")
                XCTAssertFalse(words.contains("%"), "\(language) \(key): nothing to fill in")
            }
            for key in SettingsRestoreRow.resultKeys {
                XCTAssertNotEqual(lookup(key), key, "\(language) \(key)")
            }
        }
        XCTAssertEqual(ProCatalog.lookup("es")("pro.restaurar"), "Restaurar compra")
        XCTAssertEqual(ProCatalog.lookup("en")("pro.restaurar"), "Restore purchase")
        // The Pro row beside it still has no price and opens nothing.
        let pro = self.row(canSell: false)
        XCTAssertFalse(pro.opensSheet)
        XCTAssertNil(pro.value)
    }

    /// Red if a line left by something else (a purchase by day, a restore
    /// in the Pro sheet) shows under a row nobody pressed, or if the row
    /// goes away with its answer once it was pressed.
    func testTheLineIsOnlyWhatThisVisitAskedFor() {
        for notice in [PurchaseNotice.nothingToRestore, .restored, .storeUnavailable, .cancelled] {
            XCTAssertNil(restoreRow(notice: notice).resultKey, "\(notice)")
        }
        XCTAssertEqual(restoreRow(notice: .nothingToRestore, askedHere: true).resultKey, "pro.restaurar.no")
        XCTAssertEqual(restoreRow(notice: .cancelled, askedHere: true).resultKey, "pro.fallo")
        XCTAssertEqual(restoreRow(notice: .failed, askedHere: true).resultKey, "pro.fallo")
        XCTAssertEqual(
            restoreRow(notice: .storeUnavailable, askedHere: true).resultKey, "pro.sin_tienda.silencio",
            "the app never says something is playing when nothing is"
        )
        XCTAssertEqual(
            restoreRow(notice: .storeUnavailable, isPlaying: true, askedHere: true).resultKey, "pro.sin_tienda"
        )
        // Lines of a purchase are not this row's to say.
        for notice in [PurchaseNotice.purchased, .pending, .unconfirmed, .trialNotStarted] {
            XCTAssertNil(restoreRow(notice: notice, askedHere: true).resultKey, "\(notice)")
        }

        // Restored: Pro is there, the row stays where it was and thanks.
        let restored = restoreRow(isPro: true, notice: .restored, askedHere: true)
        XCTAssertTrue(restored.exists)
        XCTAssertEqual(restored.resultKey, "pro.gracias")
        XCTAssertEqual(restored.titleKey, "pro.restaurar")
        // And it stays if the morning comes with Settings open.
        XCTAssertTrue(restoreRow(canSell: true, notice: .nothingToRestore, askedHere: true).exists)

        // While it looks: "Looking…", nothing answers and nothing is said.
        let looking = restoreRow(activity: .restoring, notice: nil, askedHere: true)
        XCTAssertEqual(looking.titleKey, "pro.buscando")
        XCTAssertFalse(looking.isEnabled)
        XCTAssertNil(looking.resultKey)
        XCTAssertFalse(restoreRow(activity: .purchasing).isEnabled)

        // Every line the row can say has its place kept.
        let said = ["pro.gracias", "pro.restaurar.no", "pro.fallo", "pro.sin_tienda", "pro.sin_tienda.silencio"]
        XCTAssertEqual(Set(SettingsRestoreRow.resultKeys), Set(said))
    }

    /// Red if restoring at night does not reach the store, opens the Pro
    /// sheet, or says something other than what the App Store answered.
    func testRestoringAtNightAsksTheStoreAndNeverRaisesTheProSheet() async throws {
        let bought = ProReceipt(purchaseDate: NightHarness.time(day: 10, 12), isFamilyShared: false)

        // Nothing for this account.
        let empty = try NightHarness(at: NightHarness.time(23), access: .free)
        XCTAssertFalse(empty.model.canSell)
        XCTAssertTrue(restoreRow(empty, askedHere: false).exists)
        await empty.purchases.restore()
        XCTAssertEqual(empty.store.syncCount, 1, "the real restore ran")
        XCTAssertEqual(restoreRow(empty, askedHere: true).resultKey, "pro.restaurar.no")
        XCTAssertFalse(empty.purchases.isPro)
        XCTAssertFalse(empty.model.showPaywall)

        // The dialog of the App Store was closed, and a store out of reach.
        let cancelled = try NightHarness(at: NightHarness.time(3, 42), access: .free)
        cancelled.store.syncResult = .cancelled
        await cancelled.purchases.restore()
        XCTAssertEqual(restoreRow(cancelled, askedHere: true).resultKey, "pro.fallo")
        XCTAssertFalse(cancelled.model.showPaywall)

        let away = try NightHarness(at: NightHarness.time(3, 42), access: .free)
        away.store.syncResult = .unavailable
        await away.purchases.restore()
        XCTAssertEqual(restoreRow(away, askedHere: true).resultKey, "pro.sin_tienda.silencio")
        away.model.play()
        XCTAssertTrue(away.model.isPlaying)
        await away.purchases.restore()
        XCTAssertEqual(restoreRow(away, askedHere: true).resultKey, "pro.sin_tienda")
        XCTAssertFalse(away.model.showPaywall)

        // The purchase comes back: everything opens at once, at night, and
        // the row says so without a sheet.
        let night = try NightHarness(at: NightHarness.time(23), access: .free)
        night.store.hangs = true
        night.store.entitlementAfterSync = .entitled(bought)
        let restoring = Task { await night.purchases.restore() }
        try await waitUntil { night.store.syncCount == 1 }
        let looking = restoreRow(night, askedHere: true)
        XCTAssertEqual(looking.titleKey, "pro.buscando")
        XCTAssertFalse(looking.isEnabled)
        XCTAssertNil(looking.resultKey)
        XCTAssertFalse(night.purchases.hasFullAccess)

        night.store.release()
        await restoring.value
        XCTAssertTrue(night.purchases.isPro)
        XCTAssertTrue(night.purchases.hasFullAccess)
        XCTAssertEqual(night.purchases.receipt, bought)
        let restored = restoreRow(night, askedHere: true)
        XCTAssertTrue(restored.exists)
        XCTAssertTrue(restored.isEnabled)
        XCTAssertEqual(restored.resultKey, "pro.gracias")
        XCTAssertFalse(night.model.showPaywall, "restoring is not selling: no sheet")
        XCTAssertFalse(night.model.canSell, "and the night still sells nothing")
        // The Pro row beside it is the receipt, still words at night.
        let pro = SettingsProRow(
            isPro: night.purchases.isPro,
            displayName: "Store Name",
            product: night.purchases.productState,
            receipt: night.purchases.receipt,
            canSell: night.model.canSell,
            localized: ProCatalog.lookup("es"),
            date: { _ in "<date>" },
            spokenDate: { _ in "<long date>" },
            locale: Locale(identifier: "es")
        )
        XCTAssertEqual(pro.title, "Store Name · gracias · <date>")
        XCTAssertFalse(pro.opensSheet)
        // A Pro layer answers now.
        XCTAssertEqual(night.model.setLevel(.ocean, 0.3), .applied)
    }

    // MARK: Night

    func testKeepScreenOnHasItsThreeOptionsInWords() {
        let expected: [(KeepScreenOn, String, String)] = [
            (.whileCharging, "While charging", "Mientras carga"),
            (.always, "Always", "Siempre"),
            (.never, "Never", "Nunca"),
        ]
        XCTAssertEqual(KeepScreenOn.allCases.count, expected.count)
        for (option, english, spanish) in expected {
            let key = SettingsText.keepScreenOnKey(option)
            XCTAssertEqual(ProCatalog.lookup("en")(key), english)
            XCTAssertEqual(ProCatalog.lookup("es")(key), spanish)
        }
    }

    func testChoosingKeepScreenOnIsKept() throws {
        let night = try NightHarness(at: NightHarness.time(12))
        XCTAssertEqual(night.model.keepScreenOn, .whileCharging, "the default")
        night.model.setKeepScreenOn(.never)
        XCTAssertEqual(night.model.keepScreenOn, .never)
        XCTAssertEqual(night.defaults.string(forKey: MixerModel.keepScreenOnKey), KeepScreenOn.never.rawValue)
    }

    // MARK: About

    func testTheAboutHeaderCarriesTheNameItIsGiven() {
        XCTAssertEqual(
            SettingsText.aboutHeader(
                appName: "AppName", localized: ProCatalog.lookup("es"), locale: Locale(identifier: "es")
            ),
            "sobre appname"
        )
        XCTAssertEqual(
            SettingsText.aboutHeader(
                appName: "AppName", localized: ProCatalog.lookup("en"), locale: Locale(identifier: "en")
            ),
            "about appname"
        )
    }

    /// Red if "What's not here" loses a fact, gains one that is not true
    /// of 1.0 ("no server", "no network": StoreKit uses the network), or
    /// stops ending on the sentence of the footer.
    func testWhatIsNotHereIsOneFactPerLine() {
        let spanish = SettingsText.facts(localized: ProCatalog.lookup("es"))
        XCTAssertEqual(spanish, [
            "Sin suscripción", "Sin cuenta", "Sin rastreo", "Sin anuncios", "Sin puntuación", "Sin racha",
            "Sin tutorial",
        ])
        let english = SettingsText.facts(localized: ProCatalog.lookup("en"))
        XCTAssertEqual(english, [
            "No subscription", "No account", "No tracking", "No ads", "No score", "No streak", "No tutorial",
        ])
        for fact in spanish + english {
            let lower = fact.lowercased()
            for untrue in ["servidor", "server", "red", "network"] {
                XCTAssertFalse(lower.split(separator: " ").contains(Substring(untrue)), fact)
            }
        }
        XCTAssertEqual(ProCatalog.lookup("es")(ProSheetText.footerKey), "Sin suscripción. Sin cuenta. Sin rastreo.")
        XCTAssertEqual(ProCatalog.lookup("es")("lo_que_no_hay.resena"), "No te pediremos que la valores.")
    }

    /// Red if "Write to the author" could show without an address the
    /// owner gave, or if the app wrote one of its own.
    func testWritingToTheAuthorNeedsAnAddressTheOwnerGave() {
        XCTAssertNil(AppLinks.authorURL(address: "", subject: "AppName"))
        XCTAssertNil(AppLinks.authorURL(address: "   ", subject: "AppName"))
        XCTAssertNil(AppLinks.authorURL(address: "not an address", subject: "AppName"))
        XCTAssertEqual(
            AppLinks.authorURL(address: "someone@example.com", subject: "App Name")?.absoluteString,
            "mailto:someone@example.com?subject=App%20Name"
        )
        // The constant and the row agree: an empty address hides the row.
        XCTAssertEqual(AppLinks.authorURL(subject: "AppName") == nil, AppLinks.authorAddress.isEmpty)
    }

    /// The app never asks the system for a review prompt, opens no
    /// connection of its own and keeps no address in its sources.
    func testTheSourcesAskForNoReviewPromptAndCarryNoAddress() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SleepNoise")
        let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
        var read = 0
        while let url = files?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let source = try String(contentsOf: url, encoding: .utf8)
            read += 1
            for banned in ["requestReview", "SKStoreReviewController", "URLSession"] {
                // Comments may name what the app does not do.
                let code = source.split(separator: "\n").filter {
                    !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//")
                }
                XCTAssertFalse(
                    code.contains { $0.contains(banned) }, "\(url.lastPathComponent) uses \(banned)"
                )
            }
            XCTAssertNil(
                source.range(of: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}"#, options: .regularExpression),
                "\(url.lastPathComponent) carries an address"
            )
        }
        XCTAssertGreaterThan(read, 50, "the sources were not found")
    }
}
