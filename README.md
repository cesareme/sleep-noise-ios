# SleepNoise

Offline sleep-noise synthesizer for iPhone. Every sound is generated on the device with `AVAudioEngine` and an `AVAudioSourceNode`. There are no bundled audio files, no analytics, and no networking of our own. StoreKit is the only system service that contacts Apple, and only when someone loads or buys Pro.

Free includes white, pink, and brown noise, the rain texture, a 15, 30 or 60 minute timer, and one saved mix. Pro (`com.cesareme.sleepnoise.pro`, non-consumable) unlocks the rest of the generated sounds (fan, ocean, thunder, campfire, brook and cabin among them), the breathing tide, timers up to 6 hours including a custom length, and unlimited saved mixes. Every install gets a local 7-day trial of everything: no card, no StoreKit product, the clock starts at the first Play and the first-launch card says so.

Siri and the Shortcuts app can play a single sound, start the sleep timer and stop playback, in English and Spanish. A request that needs Pro is answered in words.

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
2. Tap **Pro**, then the purchase button. The local transaction completes immediately.
3. Fan, ocean, custom timers, and extra mixes should unlock.
4. Use **Debug → StoreKit → Manage Transactions** to delete the transaction and return to the free tier.
5. Tap **Restore purchases**. With the transaction deleted, the app reports that there is nothing to restore. Buy again, then Restore on a fresh launch should turn Pro back on while the transaction still exists.
6. The configuration’s storefront defaults to the US. Change it in Xcode’s StoreKit editor (or the transaction manager) to try the Spanish product localization (`es_ES`).

A TestFlight or App Store build ignores this file and uses App Store Connect.

## Layout

```
project.yml                  XcodeGen spec (app + unit tests)
scripts/verify.sh            The gate: clean build, tests, no warnings
SleepNoise/App               Entry point and colors
SleepNoise/Audio             Session, engine, Now Playing
SleepNoise/Audio/DSP         Real-time generators, fade, mailbox
SleepNoise/Features          Mixer, timer, saved mixes, paywall
SleepNoise/Model             Sound ids and the free/Pro rules
SleepNoise/StoreKit          StoreKit 2 purchase manager
SleepNoise/Resources         Strings, assets, Info.plist, .storekit
SleepNoiseTests              DSP, fade, policy, and persistence tests
docs/ROADMAP.md              v1.1, v1.2, and the App Store checklist
```

The render callback copies a value-type `RenderState` once per buffer and reads gains through a seqlock (`AtomicBridge.c`, with explicit fences on both sides). It does not allocate, take a lock, or touch reference-counted objects. Left and right channels run independent noise generators with shared LFO phases, so the beds are decorrelated in stereo while swells stay centred. Pink noise is Paul Kellet’s economy filter. Brown noise is a leaky integrator. Rain is a hiss bed plus five overlapping resonant droplet voices with Poisson arrivals; the fan is a drifting resonant whoosh with a quiet motor hum; the ocean is a rumble under two incommensurate swells plus a surf band whose crest leads the wave.

Saved mixes and the last slider positions are `Codable` values in `UserDefaults`. Strings live in `Localizable.xcstrings` (English and Spanish).

## Privacy

The privacy manifest declares no tracking and no collected data. `UserDefaults` is listed under reason `CA92.1` because the app stores mixes on device. The App Store nutrition label should be **Data Not Collected**.

## Verification status

Built and tested on a Mac with Xcode 26.6 (iOS 26 SDK) against the iPhone 17 simulator: the project compiles with no warnings, all unit tests pass, and playback, the sleep timer, saved mixes, the paywall and the Spanish localization were exercised in the simulator. The audio has been analysed offline (level, spectrum, modulation, stereo correlation) but not yet heard on a device.

Still to verify on hardware: background playback with the screen locked, route changes (pairing AirPods mid-session), phone-call interruptions, Now Playing controls, and the StoreKit purchase and restore flow, which needs a Run from Xcode so the `.storekit` configuration is loaded. See `docs/REVIEW-2026-11-15.md` for the review findings and `docs/ROADMAP.md` for the launch checklist.
