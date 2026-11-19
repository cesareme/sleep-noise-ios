# SleepNoise

[![iOS 17 or later](https://img.shields.io/badge/iOS-17%2B-black)](project.yml)
[![iPhone](https://img.shields.io/badge/iPhone-only-black)](project.yml)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138)](project.yml)
[![CI](https://github.com/cesareme/sleep-noise-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/cesareme/sleep-noise-ios/actions/workflows/ci.yml)

Sleep sound, synthesized on the iPhone as it plays, with one payment and nothing collected.

SleepNoise is an offline sleep-sound app for iPhone. Every sound is generated on the device with `AVAudioEngine` while it plays. There are no bundled audio files. The app is English and Spanish, dark, and built for the night table: a page, a mixer of up to six sounding layers, a timer that fades out, a Night screen, and Small Hours. It asks for no account.

The interface direction is Grafito, documented in [`docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md`](docs/design/03-DIRECCION-DE-DISENO-2026-11-16.md): one typeface, one accent that exists only while sound is playing or under a finger, and a Horizon whose thickness is the real output level.

## What is included

Eleven generated sounds. Five stay free. Pro adds the other six, the Tide, and saved mixes past the third. The free list is only allowed to grow.

| | Free, always | Pro |
|---|---|---|
| Sounds | White, pink, brown, rain, wind | Ocean, fan, thunder, campfire, brook, cabin |
| Tide | Small Hours only (see below) | The Tide on the page: the ocean paced to a breath, six per minute by default, then it recedes |
| Timer | The whole timer, for any length from 1 to 360 minutes, or until an hour of the clock | The same timer. It is not part of Pro |
| Saved mixes | Three | No limit |
| House mixes | Pink and rain, Wall. Sea and wind, and Brown and fire, load with their Pro layers left out | All four, complete |

A sounding mix never exceeds six layers. Extra layers keep their levels and stay silent until a slot opens. That rule is `LayerCap`.

**Small Hours** is twenty minutes of low ocean with the Tide at eight breaths a minute. It plays for everyone and does not offer a purchase. A Shortcut can start it. On screen, it is offered when the Night screen was already up as the night ended.

**Night.** From 21:00 to 07:00, local time, the Pro sheet and the trial stay closed. The app never asks for a rating. Restore stays available from Settings in that window, with no price and no sheet.

**Shortcuts.** Five actions, in English and Spanish: play the last mix, pause, play a mix by name, set the timer, and Small Hours. None of them starts the trial or opens a purchase. A Pro sound without access simply does not play.

The app makes no health claims. It does not measure sleep, and it does not read or write HealthKit. `Info.plist` sets the category to Health & Fitness.

## Privacy

The app collects no data. Mixes, levels, and settings stay on the iPhone. The seven-night trial record stays in the Keychain of that device and is not synced. Purchases are Apple's: StoreKit is the only network path, and it runs only when a price is loaded or a purchase is made or restored. There is no account, no analytics, no advertising, and no third-party SDK. The privacy manifest declares no tracking and no collected data types.

The policy written for App Store Connect is [`docs/PRIVACY.md`](docs/PRIVACY.md). It is not ready to paste into App Store Connect until the owner's legal name, a contact address, and a retention period for email are filled in. The same blanks are in [`docs/privacy/index.md`](docs/privacy/index.md), the draft prepared for a public page.

## Architecture

The render callback does not allocate, lock, or touch reference-counted objects. The main thread publishes one value-type command through a seqlock. The callback reads it, and if the write moved mid-read it keeps the previous command. Left and right run independent generators so the noise is wide in stereo, while swells stay centred. A layer whose gain has settled at zero is skipped. Output is soft-clipped, then scaled by a master gain that never touches the system volume. The same callback publishes the output level for the Horizon.

There are no sample loops in the bundle. The noise generator is a 32-bit state with fixed seeds, apart from the thunder schedule, which is chosen at launch. A very long run can therefore repeat, and two launches follow the same sequence except for thunder. The store notes treat "never loops" as a claim this version does not yet support. Detail, and a diagram of the pipeline, are in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Status and version

| | |
|---|---|
| Marketing version | **1.0.0** (`MARKETING_VERSION` in `project.yml`) |
| Build | **1** (`CURRENT_PROJECT_VERSION`) |
| Bundle id | `com.cesareme.sleepnoise` |
| In-app purchase | `com.cesareme.sleepnoise.pro`, non-consumable |
| Git tags | None |
| App Store | Not submitted |

`CFBundleShortVersionString` and `CFBundleVersion` take the two project settings above. The version string is already 1.0.0 because that is the release being built. Nothing has been tagged or shipped.

The 1.0 product surface is in the tree: the page and Layers, the timer, the Tide, Night, Small Hours, mixes, the Pro sheet and receipt, Settings, the five Shortcuts, the icon, English and Spanish strings, store-listing drafts, and screenshot tooling. The CI check `verify` ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) last succeeded on `main` for `5e9beb8` on 17 November 2026. The gate rebuilds the project, compiles Debug and the Release configuration that ships, and requires at least 700 tests (`scripts/verify-min-tests.txt`).

Still open before submission, as recorded in the plan and the launch notes:

- The textures have not been signed off by ear on a device. A full night on hardware, and a real StoreKit purchase, restore, Ask to Buy, and Family Sharing pass, are not recorded as done.
- App Store Connect still has to be created: the app record, the non-consumable, its price, and Family Sharing. None of that lives in this repository.
- The privacy URL cannot be filed until [`docs/PRIVACY.md`](docs/PRIVACY.md) names a controller, a contact address, and how long a reply email is kept. The in-app page "What's not here" does not yet carry that text.
- "Write a review" and "Write to the author" stay hidden while `AppLinks` in `SleepNoise/Features/Pro/ProSheetLogic.swift` is empty.
- The working name is SleepNoise. The plan schedules a final name check for 4 December 2026.
- A short TestFlight beta, then submission.

## Roadmap

Dates below are the ones written in [`docs/PLAN-SIMPLE-1.0.md`](docs/PLAN-SIMPLE-1.0.md). They are a plan, not a result.

**1.0 — App Store submission, mid-December 2026.** The plan targets Friday 11 December 2026, ahead of the App Review holiday pause. If that date slips, the same plan records 18 December 2026 as the fallback. After submission, the following weeks are Apple's review. 1.0 is the app described above: on-device synthesis, the free tier, one non-consumable, a local seven-night trial, English and Spanish, iPhone on iOS 17 or later.

**1.1 — after launch.** Live Activity, StandBy and Dynamic Island, a Home Screen widget, Control Center, a light appearance, a timbre control, two short pages on what the app does and does not claim, a diagnostic the person can choose to send, and iCloud for mixes. The plan allows three to five weeks after launch and says each of these waits on real reviews and sales. The list does not add an account, ads, or analytics. iCloud and a chosen diagnostic would be the first sync and the first network path that is not StoreKit, and neither is in the app today.

**1.2.** An Apple Watch remote for the iPhone session, HealthKit only with an explicit opt-in, and iPad if sales justify it. Reading or writing HealthKit would change the privacy label in that release.

[`docs/ROADMAP.md`](docs/ROADMAP.md) is an earlier sketch of widgets and the watch. Where it still describes a 60-minute free timer, one saved mix, or six sounds in total, the table in this README and `AccessPolicy.swift` are the ones that match the code.

## Business model

One payment. The line in the product is "No subscription. No account. No tracking."

Pro is a non-consumable, `com.cesareme.sleepnoise.pro`, intended to be shared with Family Sharing. The local StoreKit file marks it family-shareable. Turning that on in App Store Connect is still a launch task.

The price on screen is whatever StoreKit returns as `displayPrice`. The app does not hard-code a figure. Two numbers exist in the repository, and they are not the same thing:

- The development store (`SleepNoise/Resources/SleepNoise.storekit`) prices the product at **29.99** on the **US** storefront. That file is for local testing.
- The product decision in the 1.0 plan is **€29.99** once, with no launch discount.

The price that will ship is the one entered in App Store Connect. It is not in this repository, and there is no sales history here.

The seven-night trial is local. It starts only from "Start the trial · 7 nights" on the Pro sheet, never from Play and never from a Shortcut. It stores two dates and the time consumed, in the Keychain, so a reinstall does not start it again. It is judged when a session starts: a trial that runs out in the middle of the night waits until the next start. When it ends, saved mixes stay as they are. There is no card and no StoreKit product for the trial.

Between 21:00 and 07:00 the app does not sell. The sheet stays closed on the night page as well, whatever the clock says.

## Build

Requirements: a Mac with Xcode 26.6 (the version CI selects), [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.38 or newer, and Homebrew. Deployment target iOS 17. Swift language mode 5.9. This repository does not commit an `.xcodeproj`.

```bash
brew install xcodegen
xcodegen generate
open SleepNoise.xcodeproj
```

The simulator needs no signing. For a device or an archive, copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig`, set `DEVELOPMENT_TEAM`, and run `xcodegen generate` again. Git ignores the local file. `Config/Signing.xcconfig` includes it only when it exists, so CI builds with no team.

Scheme **SleepNoise** points its Run action at `SleepNoise/Resources/SleepNoise.storekit`. A run from Xcode uses that local store. A TestFlight or App Store build ignores the file.

The gate, on a Mac:

```bash
SN_SIM='iPhone 17' scripts/verify.sh
```

Use a simulator name that exists on that Mac. The script prints `VERIFY OK · N tests` or `VERIFY FAIL · reason`. The log is `.build/verify.log`. `--fast` skips the clean build and is not the gate. CI runs `scripts/verify.sh --ci` on every pull request and on every push to `main`.

## Repository

```
project.yml                 XcodeGen spec. Version, bundle id, iPhone-only
Config/                     Signing include. The team id stays out of Git
SleepNoise/App              Entry
SleepNoise/Audio            Session, engine, Now Playing
SleepNoise/Audio/DSP        Generators, mailbox, render state, fades
SleepNoise/Design           Grafito tokens and components
SleepNoise/Features         Page, mixer, timer, Tide, Night, Small Hours,
                            mixes, Pro, Settings
SleepNoise/Intents          The five Shortcuts
SleepNoise/Model            Sounds, access, trial, night window, policies
SleepNoise/StoreKit         Purchase manager behind a store protocol
SleepNoise/Resources        Strings, icon, Info.plist, privacy manifest, store
SleepNoiseTests             Unit tests, including spectral checks
scripts/verify.sh           The gate
scripts/screenshots.sh      Seven App Store captures, English and Spanish
scripts/paint/              Generator of the painted bands of the house mixes (build-time PNG)
docs/ARCHITECTURE.md        Audio pipeline
docs/PRIVACY.md             Privacy policy draft
docs/SECURITY.md            How to report a vulnerability
docs/PLAN-SIMPLE-1.0.md     What 1.0 ships, and when
docs/store/                 Listing drafts, review notes, Connect answers
CHANGELOG.md                History reconstructed from merged pull requests
LICENSE                     All rights reserved
```

## License

Copyright (c) 2026 cesareme. All rights reserved. The source is public so the product can be read. It is not open source. See [`LICENSE`](LICENSE).
