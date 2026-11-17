# Changelog

All notable changes to SleepNoise are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The Xcode project already carries marketing version **1.0.0** and build **1**. No git tag exists, and no build has been submitted to the App Store, so there is no released section yet. Everything below is unreleased work on `main`, reconstructed from commits and merged pull requests. Pull request #1 and pull request #3 were closed without being merged. The work that replaced them is noted where it landed.

## [Unreleased]

### Added

- On-device synthesizer for iPhone: white, pink, and brown noise, rain, fan, and ocean, generated with `AVAudioEngine` and no bundled audio. A sleep timer, saved mixes, and a StoreKit non-consumable. English and Spanish. Landed on `main` on 14 November 2026, before the pull-request workflow.
- Breathing Tide, a local trial, and real-time engine fixes: seqlock fences on both sides of the mailbox, independent stereo generators, a bounded soft clipper, silent generators skipped, and a restart when the audio route changes configuration. Headphones unplugged pause playback. The audio session is released when playback stops. — [#2](https://github.com/cesareme/sleep-noise-ios/pull/2) (16 November 2026)
- Market notes, the Grafito design direction, and the simplified 1.0 plan. — [#4](https://github.com/cesareme/sleep-noise-ios/pull/4) (16 November 2026)
- `scripts/verify.sh` as the only gate, a macOS GitHub Actions check named `verify`, and an iPhone-only target. — [#5](https://github.com/cesareme/sleep-noise-ios/pull/5) (17 November 2026)
- Five further generated textures: thunder, campfire, brook, wind, and cabin, plus the earlier Shortcuts (a sound, a preset, the timer, and stop). This is the engine, model, and intents from the unmerged pull request #3, brought in without that pull request's interface. The five Shortcuts that ship now replaced that set in [#11](https://github.com/cesareme/sleep-noise-ios/pull/11). — [#6](https://github.com/cesareme/sleep-noise-ios/pull/6) (17 November 2026)
- Night window (21:00–07:00), the seven-night trial clock in the Keychain, the Small Hours recipe, and the access matrix: five free sounds, the whole timer, three saved mixes. — [#8](https://github.com/cesareme/sleep-noise-ios/pull/8) (17 November 2026)
- Mix format v2 with a reader for v1, four house mixes, and policies for interruptions and for a lost headphone route. A lost output pauses and does not resume by itself on the speaker. — [#9](https://github.com/cesareme/sleep-noise-ios/pull/9) (17 November 2026)
- Grafito tokens and components, the main page, the Layers sheet, and the Horizon fed by the real output level from the render thread. — [#10](https://github.com/cesareme/sleep-noise-ios/pull/10) (17 November 2026)
- Timer with "Until I sleep" and "Blanket", the Tide sheet, Night, Small Hours, mixes in the new interface, a master gain ramped in whole samples, and the five Shortcuts wired to that interface. — [#11](https://github.com/cesareme/sleep-noise-ios/pull/11) (17 November 2026)
- App Store listing drafts in English and Spanish, review notes, and a privacy-policy draft. — [#12](https://github.com/cesareme/sleep-noise-ios/pull/12) (17 November 2026)
- App icon, "the rule and the tide", including dark and tinted appearances. — [#13](https://github.com/cesareme/sleep-noise-ios/pull/13) (17 November 2026)
- Pro sheet, receipt, Settings, and "What's not here". The seven-night trial starts from the sheet, behind a store protocol, and no longer starts on Play. — [#14](https://github.com/cesareme/sleep-noise-ios/pull/14) (17 November 2026)
- String-catalogue audit, copy lint, six App Store captures per language, and fixes from a walk through the app. The test floor was raised to 650, then 672. — [#15](https://github.com/cesareme/sleep-noise-ios/pull/15) (17 November 2026)
- Launch guide, device-test notes, and an owner decision list. — [#16](https://github.com/cesareme/sleep-noise-ios/pull/16) (17 November 2026)
- "Restore purchase" in Settings while nothing may be sold, one rule that keeps a mix to six sounding layers, and an ended Night that gives way to the day page. The test floor is 700. — [#18](https://github.com/cesareme/sleep-noise-ios/pull/18) (17 November 2026)

### Changed

- The local trial moved from seven days, started by the first Play, to seven nights, started only by "Start the trial · 7 nights" on the Pro sheet. State lives in the Keychain and is evaluated when a session starts. — [#8](https://github.com/cesareme/sleep-noise-ios/pull/8), [#14](https://github.com/cesareme/sleep-noise-ios/pull/14)
- The free tier grew. Wind is free. The timer is free at every length up to 360 minutes. Saved mixes went from one to three. The old paywall that described a 60-minute cap was removed. — [#8](https://github.com/cesareme/sleep-noise-ios/pull/8), [#11](https://github.com/cesareme/sleep-noise-ios/pull/11), [#14](https://github.com/cesareme/sleep-noise-ios/pull/14)
- Play rises over 0.8 seconds, easing out. Pause fades over 1.5 seconds. — [#10](https://github.com/cesareme/sleep-noise-ios/pull/10), current `PlaybackFade`
- House mixes replaced the earlier one-tap presets. A house mix that contains Pro layers loads trimmed, and does not open the Pro sheet. — [#9](https://github.com/cesareme/sleep-noise-ios/pull/9)
- Signing reads `DEVELOPMENT_TEAM` from a gitignored xcconfig, so the simulator and CI build with no team id in the repository. — [#15](https://github.com/cesareme/sleep-noise-ios/pull/15)

### Fixed

- A torn read of the parameter mailbox could pass on ARM. Both sides of the seqlock now fence in `AtomicBridge.c`. A concurrent test covers it. — [#2](https://github.com/cesareme/sleep-noise-ios/pull/2)
- The soft clipper no longer hard-clips a loud mix. Output stays inside full scale. — [#2](https://github.com/cesareme/sleep-noise-ios/pull/2)
- Changing audio route without a sample-rate change no longer leaves the engine silent. The engine adopts the route's sample rate instead of forcing 44.1 kHz. — [#2](https://github.com/cesareme/sleep-noise-ios/pull/2)
- Review notes and store texts were corrected against every trial and purchase state the code can be in. — [#17](https://github.com/cesareme/sleep-noise-ios/pull/17) (17 November 2026)
- More than six layers could sound when access returned, or when an old mix was loaded. `LayerCap` now keeps the six included layers with the highest level, and leaves the others stored and silent. — [#18](https://github.com/cesareme/sleep-noise-ios/pull/18)

[Unreleased]: https://github.com/cesareme/sleep-noise-ios/commits/main
