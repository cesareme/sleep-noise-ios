# Roadmap

SleepNoise 1.0 is an on-device mixer: six synthesized beds, a fading sleep timer, saved mixes, and a single non-consumable Pro unlock. Later versions should stay offline-first. Do not add accounts, ads, or analytics to “complete” these items.

## v1.1 — Widgets and Live Activity

- Home Screen widgets (small and medium) that show the active mix name, whether audio is running, and the timer remaining.
- A Lock Screen widget with the same snapshot.
- App Intents for Play, Pause, and “start my last mix” so the widgets and Shortcuts can drive the existing engine. The intent should call the same entitlement checks as the mixer. A free user cannot start fan or ocean from a widget.
- A Live Activity (and Dynamic Island presentation on supported iPhones) for a running timer: remaining time, a calm icon, and pause. Update it from the timer’s existing end date rather than a second clock.
- Widget timelines should not spin the audio engine. They read a small `Codable` snapshot the app already writes (levels, mix name, end date, playing flag).
- Keep the widget extension free of third-party code and of any network client.

## v1.2 — Apple Watch and HealthKit sleep

- A watchOS companion whose first job is a remote control for the iPhone session: play, pause, timer remaining, and volume of the current mix. The phone stays the thing that actually renders audio.
- A later, optional on-watch bed using the same DSP structs, stripped to one or two layers so the watch stays cool overnight. Do not ship a second, unrelated synthesizer.
- HealthKit only with an explicit opt-in:
  - Read the sleep schedule, if the person allows it, to suggest a timer (“wind down until your scheduled bedtime”).
  - Do not write sleep analysis samples unless a reviewer-facing explanation and a visible toggle exist. A wind-down timer is not a measurement of sleep.
  - The privacy nutrition label changes the moment HealthKit is read or written. Update the policy, the manifest, and the App Store questionnaire in the same release.
- Watch complications for the same snapshot as the v1.1 widgets.

## App Store launch checklist

Do these before submitting 1.0. The implementation in this repo does not replace them.

### Identity and binary

- [ ] App ID `com.cesareme.sleepnoise` with In-App Purchase enabled.
- [ ] Non-consumable `com.cesareme.sleepnoise.pro` created in App Store Connect, priced, shared with the family, and localized in English and Spanish. The display name and description are the ones of `SleepNoise/Resources/SleepNoise.storekit` and match the Pro sheet: every texture (ocean, fan, thunder, campfire, brook and cabin), the tide and unlimited mixes. The timer is free in full and is not part of Pro. No StoreKit introductory offer and no subscription: the seven-night trial is local, starts only with "Start the trial · 7 nights" in the Pro sheet and involves no transaction, so the IAP description never calls it a free trial.
- [ ] Fill `AppLinks.appStoreID` and `AppLinks.authorAddress` (`SleepNoise/Features/Pro/ProSheetLogic.swift`) once the app exists in App Store Connect and there is a public address. While they are empty the app shows neither "Write a review" on the receipt nor "Write to the author" in Settings, and nothing fails to warn about it. Capture Settings and the receipt again with both in place.
- [ ] A screenshot of the Pro sheet uploaded for the in-app purchase review.
- [ ] Version and build numbers match `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`.
- [ ] Archive with a distribution certificate. Confirm `PrivacyInfo.xcprivacy` is inside the bundle.
- [ ] Export compliance: the app sets `ITSAppUsesNonExemptEncryption` to false (HTTPS via StoreKit only, no custom crypto).
- [ ] Age rating questionnaire. There is no unrestricted web, no user content, and no medical claims. Do not describe the app as treating insomnia.

### Privacy nutrition label and policy

- [ ] Nutrition label: **Data Not Collected**. No tracking, no identifiers, no diagnostics, no purchases linked to you outside Apple’s own transaction.
- [ ] Privacy policy URL, even though the label is empty. The page should say, in English and Spanish: audio is synthesized on device, mixes stay in `UserDefaults`, there is no account, no analytics, no ads, and purchases are handled by Apple. Link it from App Store Connect and, if you add a Settings screen later, from the app.
- [ ] Privacy manifest stays in sync with that page. Today it declares no collected data types and `UserDefaults` access reason `CA92.1`.
- [ ] No App Tracking Transparency prompt. There is nothing to track.

### Screenshots and metadata

- [ ] iPhone 6.7-inch and 6.5-inch screenshots, plus 13-inch iPad if the universal target stays. Capture the mixer, the timer, and the paywall. Use a device status bar, not a mock.
- [ ] Localized screenshots for English and Spanish, or a single set only if every caption is in the language of that localization. Don’t put English marketing text on the Spanish set.
- [ ] App name, subtitle, description, keywords, and promotional text written separately in English and Spanish. Keywords describe the utility (sleep, noise, rain, timer) without trademarked competitor names and without stuffing.
- [ ] Support URL and a contact address that someone reads.

### Review notes

- [ ] Tell App Review that background audio is the product: a person presses Play and the noise continues with the screen locked. The app does not start audio by itself and does not play silence to stay resident.
- [ ] Say where the purchase is and when: the Pro sheet only opens between 07:00 and 21:00 on the device's clock, by design (nothing is sold at night). By day it opens from **Mixes → Settings → Pro**, from the tide switch and from any Pro layer in **All layers**. "Restore purchase" is in that sheet. A reviewer whose device is inside the night window sees the Pro rows and no way in: say so in the notes, and see the open decision about restoring at night in `docs/agents/ESTADO.md`. Give a sandbox account only if they are not using StoreKit Testing.
- [ ] Explain the trial: a fresh install is the free tier. Seven nights of everything start only when the person taps "Start the trial · 7 nights" in the Pro sheet, locally, with no transaction and no card; the line under the buttons states how long it lasts, that nothing is charged and what stays when it ends. Pro can be bought at any time from the same sheet. The trial is evaluated when a sound session starts: to see it end, start it, set the device date forward 8 days and press Play. Its state lives in the Keychain, so it runs once per device and a reinstall does not start a new one. There is no hidden switch.
- [ ] Breathing tide is a sound feature, not a health feature: it paces the swell of the ocean to a slow breath. No HealthKit, no claims.
- [ ] Mention that the Ring/Silent switch does not mute playback, because the session category is `.playback`.

### Guideline 4.3 (spam and copycats)

Apple rejects noise and sleep apps that look like a template with the art swapped. This project is easier to defend when the submission shows the work is specific:

- The beds are original procedural DSP (Kellet pink, leaky-integrator brown, filtered noise plus LFOs). There are no looped recordings and no asset packs.
- The UI, copy, and icon are original. Don’t reskin this target into a second listing (“Baby Noise”, “Focus Noise”) with the same binary.
- Metadata names what the app does and doesn’t repeat a keyword block across languages.
- One non-consumable, with Restore, and a free tier that is usable without paying (white, pink, brown, rain, up to 60 minutes, one mix). Don’t lock the entire mixer behind the paywall.
- No private APIs, no repackaged web view, no “minimal experience” that is only a play button and a color.

If a 4.3 rejection arrives, reply with the DSP location (`SleepNoise/Audio/DSP`), the entitlement split, and the fact that audio is generated at runtime. Don’t ship a trivial palette change and resubmit the same product.

## Explicitly out of scope

- Third-party audio or UI libraries.
- Bundled samples.
- Accounts, social features, or a backend.
- Analytics, ads, or attribution SDKs.
