# SleepNoise

Offline sleep-noise synthesizer for iPhone and iPad. Every sound is generated on the device with `AVAudioEngine` and an `AVAudioSourceNode`. There are no bundled audio files, no analytics, and no networking of our own. StoreKit is the only system service that contacts Apple, and only when someone loads or buys Pro.

Free includes white, pink, and brown noise, the rain texture, a 15, 30 or 60 minute timer, and one saved mix. Pro (`com.cesareme.sleepnoise.pro`, non-consumable) unlocks fan, ocean, thunder, campfire, brook, wind and cabin, the breathing tide, timers up to 6 hours including a custom length, and unlimited saved mixes. Every install gets a local 7-day trial of everything: no card, no StoreKit product, the clock starts at the first Play and the first-launch card says so.

The main screen is a play control, one-tap presets and a grid of sound tiles. Volumes, the timer and the breathing tide sit in a bottom sheet. Bedtime starts the current mix with a timer (60 minutes when none is set) and covers the UI with a black screen; it does not change system brightness and it leaves the idle timer enabled, so the display can sleep while audio continues. Siri and Shortcuts can play a sound or a preset, start the sleep timer, or stop. A locked sound or preset uses the same free/Pro rules as the mixer.

## Requirements

- A Mac with Xcode 15 or newer (iOS 17 SDK, Swift 5.9)
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
3. Pick an iPhone or iPad simulator, or a device, on iOS 17 or newer.
4. Product → Run (⌘R).

Background audio uses `UIBackgroundModes` → `audio` and `AVAudioSession` category `.playback`. That category keeps playing with the screen locked and ignores the Ring/Silent switch. Unplugging headphones pauses playback. A phone call pauses it and resumes afterward when the system says it should.

Enable the In-App Purchase capability on the App ID in the developer portal before you ship. StoreKit purchases do not need an extra entitlement key. Create the non-consumable `com.cesareme.sleepnoise.pro` in App Store Connect with English and Spanish names; the price in the `.storekit` file is only for local testing.

## Tests

Product → Test (⌘U), or from the command line after `xcodegen generate`:

```bash
xcrun simctl list devices available
xcodebuild test \
  -project SleepNoise.xcodeproj \
  -scheme SleepNoise \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Use a simulator name that exists on your Mac. The tests cover bounded, finite generator output, pink and brown spectral tilt, the smoothstep fade, the render mix, the parameter mailbox, the free/Pro gates, and saved-mix persistence.

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
SleepNoise/App               Entry point, design tokens, background
SleepNoise/Audio             Session, engine, Now Playing
SleepNoise/Audio/DSP         Real-time generators, fade, mailbox
SleepNoise/Features          Mixer, bedtime, timer, saved mixes, paywall
SleepNoise/Intents           Siri and Shortcuts (App Intents)
SleepNoise/Model             Sound ids, presets, free/Pro rules
SleepNoise/StoreKit          StoreKit 2 purchase manager
SleepNoise/Resources         Strings, assets, Info.plist, .storekit
SleepNoiseTests              DSP, fade, policy, and persistence tests
docs/ROADMAP.md              v1.1, v1.2, and the App Store checklist
```

The render callback copies a value-type `RenderState` once per buffer and reads gains through a seqlock (`AtomicBridge.c`, with explicit fences on both sides). It does not allocate, take a lock, or touch reference-counted objects. Left and right channels run independent noise generators with shared LFO phases, so the beds are decorrelated in stereo while swells stay centred. Pink noise is Paul Kellet’s economy filter. Brown noise is a leaky integrator. Rain is a hiss bed plus five overlapping resonant droplet voices with Poisson arrivals; the fan is a drifting resonant whoosh with a quiet motor hum; the ocean is a rumble under two incommensurate swells plus a surf band whose crest leads the wave. Thunder is that rain bed with sparse centred rumbles. Campfire is a flickering flame plus short crackles. Brook is mid-band water and lower bubbles. Wind is gusting air with no motor tone. Cabin is a low roar with a quiet beating hum. Generators whose gain has settled at zero are skipped.

Saved mixes and the last slider positions are `Codable` values in `UserDefaults`. Strings live in `Localizable.xcstrings` (English and Spanish).

## Privacy

The privacy manifest declares no tracking and no collected data. `UserDefaults` is listed under reason `CA92.1` because the app stores mixes on device. The App Store nutrition label should be **Data Not Collected**.

## Shortcuts

App Intents run inside the app (`openAppWhenRun`) and call the same mixer as the screen, including the free/Pro checks. Phrases ship in English and Spanish:

- “Play Brown in SleepNoise” / “Reproduce Marrón en SleepNoise” (the sound name is the one in the app)
- “Play Deep sleep in SleepNoise” / “Reproduce Sueño profundo en SleepNoise”
- “Start sleep timer in SleepNoise” and “Start a 30 minute sleep timer in SleepNoise”
- “Stop SleepNoise” / “Detén SleepNoise”

A free install cannot start fan, ocean, thunder, campfire, brook, wind, cabin, or a preset that uses them. The app opens the paywall instead.

## Verification status

The build that landed in PR #2 was compiled and tested on a Mac with Xcode 26.6 (iOS 26 SDK) against the iPhone 17 simulator: no warnings, unit tests passing, and playback, the sleep timer, saved mixes, the paywall and Spanish exercised in the simulator. That pass did not include the presets, bedtime screen, new textures or Shortcuts in this branch.

This branch was not compiled here: the environment has no Xcode and no Swift toolchain, so there are no new simulator screenshots and the unit tests were not run. On a Mac, after `xcodegen generate`, run the SleepNoise tests and check the main screen in light and dark, a Pro preset during and after the trial, bedtime (black screen, tap to show controls, idle timer still enabled), and a Shortcut for play, timer and stop in English and Spanish.

Still to verify on hardware: background playback with the screen locked, route changes (pairing AirPods mid-session), phone-call interruptions, Now Playing controls, and the StoreKit purchase and restore flow, which needs a Run from Xcode so the `.storekit` configuration is loaded. The new textures have not been heard on a device. See `docs/REVIEW-2026-11-15.md` for the earlier review and `docs/ROADMAP.md` for the launch checklist.
