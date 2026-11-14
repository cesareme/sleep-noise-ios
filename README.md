# SleepNoise

Offline sleep-noise synthesizer for iPhone and iPad. Every sound is generated on the device with `AVAudioEngine` and an `AVAudioSourceNode`. There are no bundled audio files, no analytics, and no networking of our own. StoreKit is the only system service that contacts Apple, and only when someone loads or buys Pro.

Free includes white, pink, and brown noise, the rain texture, a 15 or 30 minute timer, and one saved mix. Pro (`com.cesareme.sleepnoise.pro`, non-consumable) unlocks fan and ocean, timers up to 6 hours including a custom length, and unlimited saved mixes.

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
  -destination 'platform=iOS Simulator,name=iPhone 16'
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

The render callback copies a value-type `RenderState` once per buffer and reads gains through a seqlock (`AtomicBridge.c`). It does not allocate, take a lock, or touch reference-counted objects. Pink noise is Paul Kellet’s economy filter. Brown noise is a leaky integrator. Rain, fan, and ocean are filtered noise with LFOs (rain also fires short droplet envelopes).

Saved mixes and the last slider positions are `Codable` values in `UserDefaults`. Strings live in `Localizable.xcstrings` (English and Spanish).

## Privacy

The privacy manifest declares no tracking and no collected data. `UserDefaults` is listed under reason `CA92.1` because the app stores mixes on device. The App Store nutrition label should be **Data Not Collected**.

## What has not been verified

This tree was written on a machine without Xcode or the iOS SDK. It has not been compiled, the unit tests have not been executed, and the audio has not been heard. Build and run the tests on a Mac before you treat the app as shippable. See `docs/ROADMAP.md` for the launch checklist.
