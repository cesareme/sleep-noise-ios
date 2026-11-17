# SleepNoise

Offline sleep-noise synthesizer for iPhone. Every sound is generated on the device with `AVAudioEngine` and an `AVAudioSourceNode`. There are no bundled audio files, no analytics, and no networking of our own. StoreKit is the only system service that contacts Apple, and only when someone loads or buys Pro.

Free includes white, pink, and brown noise, the rain and wind textures, the whole sleep timer ("Until I sleep" with a fade at the end, or "Blanket" until an hour of the clock), and three saved mixes. Pro (`com.cesareme.sleepnoise.pro`, non-consumable) unlocks the rest of the generated sounds (fan, ocean, thunder, campfire, brook and cabin), the breathing tide, and unlimited saved mixes. A local seven-night trial of everything starts only from the Pro sheet ("Start the trial · 7 nights"), never with Play and never from a Shortcut: no card, no StoreKit product. Its state lives in the Keychain, it is evaluated when a night starts and never in the middle of one, and when it ends nothing saved is lost or rewritten. The page says how many nights are left, and says nothing at all about Pro or the trial between 21:00 and 07:00: nothing is sold at night.

The Pro sheet takes its name and its price from StoreKit (`displayName`, `displayPrice`); no string in the app carries either. Bought, the same sheet is the receipt. Settings is the last row of Mixes: "Keep screen on" for the Night screen, the state of Pro, and "What's not here". Two things stay hidden until their constants in `AppLinks` are filled in: "Write a review" needs the App Store id of the app, and "Write to the author" needs a public address.

Siri and the Shortcuts app have five actions, in English and Spanish: play the last mix, pause, play a mix by name, set the timer, and Small Hours (twenty quiet minutes of low sea for whoever wakes in the night). None of them sells anything or starts the trial: what needs Pro without access simply does not sound.

## Requirements

- A Mac with Xcode 26.6, the version the CI gate runs (deployment target iOS 17, Swift 5.9 language mode)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.38 or newer
- Homebrew

This repository does not commit an `.xcodeproj`. XcodeGen builds it from `project.yml`.

## Build on a Mac

```bash
brew install xcodegen
cd sleep-noise-ios
xcodegen generate
open SleepNoise.xcodeproj
```

In Xcode:

1. Select the **SleepNoise** target, open **Signing & Capabilities**, and choose your Team. The simulator can run with “Sign to Run Locally” if you only need a local build.
2. Scheme **SleepNoise** is already selected. Its Run action points at `SleepNoise/Resources/SleepNoise.storekit`.
3. Pick an iPhone simulator, or an iPhone, on iOS 17 or newer.
4. Product → Run (⌘R).

Background audio uses `UIBackgroundModes` → `audio` and `AVAudioSession` category `.playback`. That category keeps playing with the screen locked and ignores the Ring/Silent switch. Unplugging headphones pauses playback. A phone call pauses it and resumes afterward when the system says it should.

Enable the In-App Purchase capability on the App ID in the developer portal before you ship. StoreKit purchases do not need an extra entitlement key. Create the non-consumable `com.cesareme.sleepnoise.pro` in App Store Connect with English and Spanish names; the price in the `.storekit` file is only for local testing.

## Tests

The gate is one script. Nothing is merged unless it ends in `VERIFY OK`:

```bash
xcrun simctl list devices available
SN_SIM='iPhone 17' scripts/verify.sh
```

Use a simulator name that exists on your Mac. The script regenerates the project, does a clean build, runs the tests and prints `VERIFY OK · N tests` or `VERIFY FAIL · reason` as its last line; the full log is in `.build/verify.log`. It fails on a build error, a failing or skipped test, any compiler or App Intents metadata warning, or fewer tests than the floor in `scripts/verify-min-tests.txt`. `--fast` skips the clean step for a quick loop and does not count as the gate. Product → Test (⌘U) in Xcode is fine while you work, but it is not the gate either. CI runs the same script on every pull request (`.github/workflows/ci.yml`).

The tests cover bounded, finite generator output, pink and brown spectral tilt, the smoothstep fade, the render mix, the parameter mailbox, the free/Pro gates, and saved-mix persistence.

## StoreKit testing

The scheme loads `SleepNoise/Resources/SleepNoise.storekit`, so a Run from Xcode uses a local store. You do not need a Sandbox Apple ID for that path.

1. Run the app from Xcode.
2. Between 07:00 and 21:00, open the Pro sheet: turn the tide on, raise a Pro layer in **All layers**, or go to **Mixes → Settings** and tap the Pro row. At night none of these opens anything; change the simulator's clock if you need to.
3. Tap **Buy**. The local transaction completes immediately, the sheet says "Thank you" and closes.
4. Fan, ocean, the tide and a fourth saved mix should open. **Mixes → Settings → Pro** now opens the receipt.
5. Use **Debug → StoreKit → Manage Transactions** to delete the transaction and return to the free tier.
6. Tap **Restore purchase**. With the transaction deleted, the app reports that there is nothing to restore. Buy again, then Restore on a fresh launch should turn Pro back on while the transaction still exists.
7. "Start the trial · 7 nights" is offered once per install and lives in the Keychain: erase the simulator to see it again.
8. The configuration’s storefront defaults to the US. Change it in Xcode’s StoreKit editor (or the transaction manager) to try the Spanish product localization (`es_ES`).

A TestFlight or App Store build ignores this file and uses App Store Connect.

## Layout

```
project.yml                  XcodeGen spec (app + unit tests)
scripts/verify.sh            The gate: clean build, tests, no warnings
SleepNoise/App               Entry point and colors
SleepNoise/Audio             Session, engine, Now Playing
SleepNoise/Audio/DSP         Real-time generators, fade, mailbox, output meter
SleepNoise/Design            Grafito design system: tokens, components, debug gallery
SleepNoise/Features          Page and layers, mixer model, timer, tide, Night,
                             Small Hours, mixes, the Pro sheet, Settings
SleepNoise/Intents           The five Shortcuts
SleepNoise/Model             Sound ids, the free/Pro rules, the seven-night trial
SleepNoise/StoreKit          Purchase manager and the store behind a protocol
SleepNoise/Resources         Strings, assets, Info.plist, .storekit
SleepNoiseTests              DSP, fade, policy, and persistence tests
docs/ROADMAP.md              v1.1, v1.2, and the App Store checklist
```

The render callback copies a value-type `RenderState` once per buffer and reads gains through a seqlock (`AtomicBridge.c`, with explicit fences on both sides). It does not allocate, take a lock, or touch reference-counted objects. Left and right channels run independent noise generators with shared LFO phases, so the beds are decorrelated in stereo while swells stay centred. Pink noise is Paul Kellet’s economy filter. Brown noise is a leaky integrator. Rain is a hiss bed plus five overlapping resonant droplet voices with Poisson arrivals; the fan is a drifting resonant whoosh with a quiet motor hum; the ocean is a rumble under two incommensurate swells plus a surf band whose crest leads the wave.

The same callback keeps a running mean square of what it outputs and stores it once per buffer in one atomic word; the main thread reads it to draw the Horizon, the line whose thickness is the real level of the sound.

A debug build launched with `-pageState <name>` opens the app in a fixed state for the reference captures, on its own defaults, a pinned clock and a scripted store (`PageDebugState` lists the names: `proOffer`, `proReceipt`, `trialNight7`, `settings`…). Launched with `-gallery` it opens the design gallery instead of the app: every Grafito component in its states. `-gallerySection <name>` shows one section, `-galleryType <size>` forces a Dynamic Type size and `-silentOutput` keeps the engine rendering without sending anything to the speaker.

Saved mixes and the last slider positions are `Codable` values in `UserDefaults`. Strings live in `Localizable.xcstrings` (English and Spanish).

## Privacy

The privacy manifest declares no tracking and no collected data. `UserDefaults` is listed under reason `CA92.1` because the app stores mixes on device. The App Store nutrition label should be **Data Not Collected**.

## Verification status

Built and tested on a Mac with Xcode 26.6 (iOS 26 SDK) against the iPhone 17 simulator: the project compiles with no warnings, all unit tests pass, and playback, the sleep timer, saved mixes, the Pro sheet in every state of a scripted store, Settings and both languages were looked at in the simulator. The audio has been analysed offline (level, spectrum, modulation, stereo correlation) but not yet heard on a device.

Still to verify on hardware: background playback with the screen locked, route changes (pairing AirPods mid-session), phone-call interruptions, Now Playing controls, VoiceOver on every screen, and the real StoreKit purchase, restore, Ask to Buy and Family Sharing flows, which need a Run from Xcode with the `.storekit` configuration or the sandbox. See `docs/REVIEW-2026-11-15.md` for the review findings and `docs/ROADMAP.md` for the launch checklist.
