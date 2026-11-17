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
