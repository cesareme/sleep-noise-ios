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

    /// Whether Settings opens with the row, as the sheet asks it.
    private func opensWithRestore(
        isPro: Bool = false,
        canSell: Bool = false,
        activity: StoreActivity = .idle
    ) -> Bool {
        SettingsRestoreRow.existsOnOpen(isPro: isPro, canSell: canSell, activity: activity)
    }

    private func opensWithRestore(_ night: NightHarness) -> Bool {
        opensWithRestore(
            isPro: night.purchases.isPro, canSell: night.model.canSell, activity: night.purchases.activity
        )
    }

    /// The row of a visit that opened with it.
    private func restoreRow(
        exists: Bool = true,
        isPro: Bool = false,
        activity: StoreActivity = .idle,
        notice: PurchaseNotice? = nil,
        isPlaying: Bool = false,
        askedHere: Bool = false
    ) -> SettingsRestoreRow {
        SettingsRestoreRow(
            exists: exists,
            isPro: isPro,
            activity: activity,
            notice: notice,
            isPlaying: isPlaying,
            askedHere: askedHere
        )
    }

    /// The row as Settings builds it, from a model and its store.
    private func restoreRow(_ night: NightHarness, exists: Bool = true, askedHere: Bool) -> SettingsRestoreRow {
        restoreRow(
            exists: exists,
            isPro: night.purchases.isPro,
            activity: night.purchases.activity,
            notice: night.purchases.notice,
            isPlaying: night.model.isPlaying,
            askedHere: askedHere
        )
    }

    /// Red if someone who paid has no way to restore at night, or if the
    /// row shows by day, where the Pro sheet already has it.
    func testRestoreIsARowOnlyWithoutProWhileNothingSells() throws {
        XCTAssertTrue(opensWithRestore())
        XCTAssertFalse(opensWithRestore(canSell: true), "by day Restore is in the Pro sheet")
        XCTAssertFalse(opensWithRestore(isPro: true), "nothing to restore")
        XCTAssertFalse(opensWithRestore(isPro: true, canSell: true))

        // The gate is the model's: the night window, the night page and
        // Small Hours, and nothing else.
        let night = try NightHarness(at: NightHarness.time(12), access: .free)
        XCTAssertFalse(opensWithRestore(night))
        for (hour, minute) in [(20, 59), (7, 0), (9, 0)] {
            night.jump(to: NightHarness.time(hour, minute))
            XCTAssertFalse(opensWithRestore(night), "\(hour):\(minute)")
        }
        for (hour, minute) in [(21, 0), (23, 30), (3, 42), (6, 59)] {
            night.jump(to: NightHarness.time(hour, minute))
            XCTAssertTrue(opensWithRestore(night), "\(hour):\(minute)")
        }
        night.jump(to: NightHarness.time(12))
        night.model.beginNightSession()
        XCTAssertTrue(opensWithRestore(night), "the night page, at any hour")
        night.model.endNightSession()
        XCTAssertFalse(opensWithRestore(night))
        XCTAssertEqual(night.model.startSmallHours(), .started)
        XCTAssertTrue(opensWithRestore(night), "Small Hours, at any hour")

        // With Pro there is no row at any hour.
        let bought = try NightHarness(at: NightHarness.time(23))
        XCTAssertTrue(bought.purchases.isPro)
        XCTAssertFalse(opensWithRestore(bought))
        // A visit that opened without the row has none, whatever comes.
        let absent = restoreRow(exists: false, notice: .nothingToRestore, askedHere: true)
        XCTAssertFalse(absent.exists)
        XCTAssertFalse(absent.isEnabled)
        XCTAssertNil(absent.resultKey)
    }

    /// Red if the row comes or goes while Settings is open: at 07:00 it
    /// would take its place and the rows under it would jump, and at 21:00
    /// it would push them down. It is asked once, when the sheet opens.
    func testTheRowIsDecidedWhenSettingsOpensAndHoldsForTheVisit() throws {
        // Opened at 06:59 without Pro: the row is there.
        let morning = try NightHarness(at: NightHarness.time(day: 18, 6, 59), access: .free)
        let opened = opensWithRestore(morning)
        XCTAssertTrue(opened)
        // 07:00 with the sheet open: selling is back, and the row stays.
        morning.jump(to: NightHarness.time(day: 18, 7))
        morning.model.nightWindowChanged()
        XCTAssertTrue(morning.model.canSell)
        let kept = restoreRow(morning, exists: opened, askedHere: false)
        XCTAssertTrue(kept.exists, "nothing leaves under the eyes")
        XCTAssertTrue(kept.isEnabled, "and it still restores")
        XCTAssertNil(kept.resultKey)
        XCTAssertFalse(opensWithRestore(morning), "the next visit, by day, has none")

        // Opened at 20:59: no row, and none appears at 21:00.
        let evening = try NightHarness(at: NightHarness.time(20, 59), access: .free)
        let absent = opensWithRestore(evening)
        XCTAssertFalse(absent)
        evening.jump(to: NightHarness.time(21))
        evening.model.nightWindowChanged()
        XCTAssertFalse(evening.model.canSell)
        XCTAssertFalse(restoreRow(evening, exists: absent, askedHere: false).exists)
        XCTAssertTrue(opensWithRestore(evening), "it is there the next time Settings opens")
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
                let words = lookup(key)
                XCTAssertNotEqual(words, key, "\(language) \(key)")
                // Nothing was bought here: no line of the row speaks of a
                // charge, at the hours when nothing is sold.
                for sale in ["charged", "cobrado", "didn’t go through", "completar"] {
                    XCTAssertFalse(words.contains(sale), "\(language) \(key): \(sale)")
                }
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
    /// says the line of a purchase.
    func testTheLineIsOnlyWhatThisVisitAskedFor() {
        for notice in [PurchaseNotice.nothingToRestore, .restored, .storeUnavailable, .cancelled] {
            XCTAssertNil(restoreRow(notice: notice).resultKey, "\(notice)")
        }
        XCTAssertEqual(restoreRow(notice: .nothingToRestore, askedHere: true).resultKey, "pro.restaurar.no")
        XCTAssertEqual(
            restoreRow(notice: .storeUnavailable, askedHere: true).resultKey, "pro.sin_tienda.silencio",
            "the app never says something is playing when nothing is"
        )
        XCTAssertEqual(
            restoreRow(notice: .storeUnavailable, isPlaying: true, askedHere: true).resultKey, "pro.sin_tienda"
        )
        // Closing the dialog of the account says nothing: the row is
        // "Restore purchase" again, and it answers.
        let cancelled = restoreRow(notice: .cancelled, askedHere: true)
        XCTAssertNil(cancelled.resultKey, "nobody tried to buy: no line about a purchase or a charge")
        XCTAssertEqual(cancelled.titleKey, "pro.restaurar")
        XCTAssertTrue(cancelled.isEnabled)
        // Lines of a purchase are not this row's to say.
        for notice in [PurchaseNotice.purchased, .pending, .failed, .unconfirmed, .trialNotStarted] {
            XCTAssertNil(restoreRow(notice: notice, askedHere: true).resultKey, "\(notice)")
        }

        // Restored: Pro is there, the row stays where it was, thanks and
        // answers no more touches.
        let restored = restoreRow(isPro: true, notice: .restored, askedHere: true)
        XCTAssertTrue(restored.exists)
        XCTAssertEqual(restored.resultKey, "pro.gracias")
        XCTAssertEqual(restored.titleKey, "pro.restaurar")
        XCTAssertFalse(restored.isEnabled, "nothing is left to restore")

        // While it looks: "Looking…", nothing answers and nothing is said.
        let looking = restoreRow(activity: .restoring, notice: nil, askedHere: true)
        XCTAssertEqual(looking.titleKey, "pro.buscando")
        XCTAssertFalse(looking.isEnabled)
        XCTAssertNil(looking.resultKey)
        XCTAssertFalse(restoreRow(activity: .purchasing).isEnabled)

        // Every line the row can say has its place kept, and the line of
        // a purchase that failed is not one of them.
        let said = ["pro.gracias", "pro.restaurar.no", "pro.sin_tienda", "pro.sin_tienda.silencio"]
        XCTAssertEqual(Set(SettingsRestoreRow.resultKeys), Set(said))
        XCTAssertFalse(SettingsRestoreRow.resultKeys.contains("pro.fallo"))
    }

    /// Red if the answer of a slow restore is lost: Settings closed while
    /// the App Store was asking for the password, opened again, and the
    /// row went back to "Restore purchase" without a word.
    func testARestoreStillLookingWhenSettingsOpensIsSaidByThatVisit() async throws {
        XCTAssertFalse(SettingsRestoreRow.askedOnOpen(activity: .idle))
        XCTAssertFalse(SettingsRestoreRow.askedOnOpen(activity: .purchasing))
        XCTAssertTrue(SettingsRestoreRow.askedOnOpen(activity: .restoring))
        // The row of a restore in flight is there whatever the hour: it
        // may have begun in the Pro sheet a minute before 21:00, or the
        // morning may have come meanwhile.
        XCTAssertTrue(opensWithRestore(canSell: true, activity: .restoring))

        let night = try NightHarness(at: NightHarness.time(23), access: .free)
        night.store.hangs = true
        let first = restoreRow(night, exists: opensWithRestore(night), askedHere: false)
        let restoring = Task { await first.restore(with: night.purchases) }
        try await waitUntil { night.store.syncCount == 1 }

        // Settings is closed and opened again while it looks.
        let exists = opensWithRestore(night)
        let asked = SettingsRestoreRow.askedOnOpen(activity: night.purchases.activity)
        XCTAssertTrue(exists)
        XCTAssertTrue(asked)
        let looking = restoreRow(night, exists: exists, askedHere: asked)
        XCTAssertEqual(looking.titleKey, "pro.buscando")
        XCTAssertNil(looking.resultKey)

        night.store.release()
        let didAsk = await restoring.value
        XCTAssertTrue(didAsk)
        XCTAssertEqual(
            restoreRow(night, exists: exists, askedHere: asked).resultKey, "pro.restaurar.no",
            "the visit that sees it end says what came back"
        )
    }

    /// Red if restoring at night does not reach the store, opens the Pro
    /// sheet, or says something other than what the App Store answered.
    /// Every restore here goes through the touch of the row.
    func testRestoringAtNightAsksTheStoreAndNeverRaisesTheProSheet() async throws {
        let bought = ProReceipt(purchaseDate: NightHarness.time(day: 10, 12), isFamilyShared: false)

        // Nothing for this account.
        let empty = try NightHarness(at: NightHarness.time(23), access: .free)
        XCTAssertFalse(empty.model.canSell)
        XCTAssertTrue(opensWithRestore(empty))
        let asked = await restoreRow(empty, askedHere: false).restore(with: empty.purchases)
        XCTAssertTrue(asked)
        XCTAssertEqual(empty.store.syncCount, 1, "the real restore ran")
        XCTAssertEqual(restoreRow(empty, askedHere: true).resultKey, "pro.restaurar.no")
        XCTAssertFalse(empty.purchases.isPro)
        XCTAssertFalse(empty.model.showPaywall)

        // The dialog of the App Store was closed: nothing is said, and
        // nothing about a purchase.
        let cancelled = try NightHarness(at: NightHarness.time(3, 42), access: .free)
        cancelled.store.syncResult = .cancelled
        await restoreRow(cancelled, askedHere: false).restore(with: cancelled.purchases)
        XCTAssertEqual(cancelled.purchases.notice, .cancelled)
        let closed = restoreRow(cancelled, askedHere: true)
        XCTAssertNil(closed.resultKey)
        XCTAssertTrue(closed.isEnabled, "it can be asked again")
        XCTAssertFalse(cancelled.model.showPaywall)

        // A store out of reach.
        let away = try NightHarness(at: NightHarness.time(3, 42), access: .free)
        away.store.syncResult = .unavailable
        await restoreRow(away, askedHere: false).restore(with: away.purchases)
        XCTAssertEqual(restoreRow(away, askedHere: true).resultKey, "pro.sin_tienda.silencio")
        away.model.play()
        XCTAssertTrue(away.model.isPlaying)
        await restoreRow(away, askedHere: true).restore(with: away.purchases)
        XCTAssertEqual(restoreRow(away, askedHere: true).resultKey, "pro.sin_tienda")
        XCTAssertFalse(away.model.showPaywall)

        // The purchase comes back: everything opens at once, at night, and
        // the row says so without a sheet.
        let night = try NightHarness(at: NightHarness.time(23), access: .free)
        night.store.hangs = true
        night.store.entitlementAfterSync = .entitled(bought)
        let pressed = restoreRow(night, askedHere: false)
        let restoring = Task { await pressed.restore(with: night.purchases) }
        try await waitUntil { night.store.syncCount == 1 }
        let looking = restoreRow(night, askedHere: true)
        XCTAssertEqual(looking.titleKey, "pro.buscando")
        XCTAssertFalse(looking.isEnabled)
        XCTAssertNil(looking.resultKey)
        XCTAssertFalse(night.purchases.hasFullAccess)
        // A touch while it looks asks nothing twice.
        let again = await looking.restore(with: night.purchases)
        XCTAssertFalse(again)
        XCTAssertEqual(night.store.syncCount, 1)

        night.store.release()
        _ = await restoring.value
        XCTAssertTrue(night.purchases.isPro)
        XCTAssertTrue(night.purchases.hasFullAccess)
        XCTAssertEqual(night.purchases.receipt, bought)
        let restored = restoreRow(night, askedHere: true)
        XCTAssertTrue(restored.exists)
        XCTAssertEqual(restored.resultKey, "pro.gracias")
        XCTAssertFalse(night.model.showPaywall, "restoring is not selling: no sheet")
        XCTAssertFalse(night.model.canSell, "and the night still sells nothing")

        // With Pro back the row answers no touch: a second one never
        // reaches the App Store, which could ask for the password again
        // and, with an empty answer, take back what it just gave.
        XCTAssertFalse(restored.isEnabled)
        night.store.entitlementAfterSync = .nothing
        let second = await restored.restore(with: night.purchases)
        XCTAssertFalse(second)
        XCTAssertEqual(night.store.syncCount, 1, "the store was asked once")
        XCTAssertTrue(night.purchases.isPro)

        // The Pro row over it keeps the name alone in this visit, so the
        // row that was pressed does not move; it is words at night.
        func pro(holdsName: Bool) -> SettingsProRow {
            SettingsProRow(
                isPro: night.purchases.isPro,
                displayName: "Store Name",
                product: night.purchases.productState,
                receipt: night.purchases.receipt,
                canSell: night.model.canSell,
                holdsName: holdsName,
                localized: ProCatalog.lookup("es"),
                date: { _ in "<date>" },
                spokenDate: { _ in "<long date>" },
                locale: Locale(identifier: "es")
            )
        }
        XCTAssertEqual(pro(holdsName: true).title, "Store Name")
        XCTAssertFalse(pro(holdsName: true).opensSheet)
        // The next time Settings opens it is the receipt.
        XCTAssertFalse(opensWithRestore(night), "and Restore is gone: there is Pro")
        XCTAssertEqual(pro(holdsName: false).title, "Store Name · gracias · <date>")
        // A Pro layer answers now.
        XCTAssertEqual(night.model.setLevel(.ocean, 0.3), .applied)
    }

    /// Red if the Pro row grows when a restore brings the purchase back:
    /// the receipt line wraps at the larger text sizes and a family
    /// purchase adds a line at every size, right over the pressed row.
    func testTheProRowKeepsTheNameAloneInTheVisitThatRestored() {
        let family = ProReceipt(purchaseDate: receipt.purchaseDate, isFamilyShared: true)
        for bought in [receipt, family] {
            let before = SettingsProRow(
                isPro: false, displayName: "Store Name", product: .loaded(product), receipt: nil,
                canSell: false, holdsName: true, localized: ProCatalog.lookup("es"),
                locale: Locale(identifier: "es")
            )
            let after = SettingsProRow(
                isPro: true, displayName: "Store Name", product: .loaded(product), receipt: bought,
                canSell: false, holdsName: true, localized: ProCatalog.lookup("es"),
                locale: Locale(identifier: "es")
            )
            XCTAssertEqual(after, before, "family: \(bought.isFamilyShared)")
            XCTAssertEqual(after.title, "Store Name")
            XCTAssertNil(after.subtitle)
            XCTAssertNil(after.value)
            XCTAssertNil(after.spokenValue)
        }
        // Without Pro the flag changes nothing: by day the price is there.
        XCTAssertEqual(
            SettingsProRow(
                isPro: false, displayName: "Store Name", product: .loaded(product), receipt: nil,
                canSell: true, holdsName: true, localized: ProCatalog.lookup("es"),
                locale: Locale(identifier: "es")
            ),
            row()
        )
        // Any other visit shows the purchase as it is.
        XCTAssertEqual(row(isPro: true, receipt: family).subtitle, "En familia")
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
