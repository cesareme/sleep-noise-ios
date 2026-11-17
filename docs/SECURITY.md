# Security policy

SleepNoise is an offline iPhone app. It has no server, no account system, and no analytics endpoint of its own. The only network path is Apple's StoreKit, used when a price is loaded or a purchase is made or restored.

## Supported versions

No version has been released. The tree under development is `main`. The project version is marketing version 1.0.0, build 1. A fix for a vulnerability in that tree belongs on `main` before submission.

## Reporting a vulnerability

Report privately. Use GitHub private vulnerability reporting if it is enabled for this repository:

[https://github.com/cesareme/sleep-noise-ios/security/advisories/new](https://github.com/cesareme/sleep-noise-ios/security/advisories/new)

There is no security contact address in this repository. Do not invent one, and do not put exploit details in a public issue. A public issue is fine for a bug that does not put anyone's data or device at risk.

## In scope

- Memory safety and data races on the audio render thread.
- The Keychain item that stores the trial, and the on-device record of a purchase.
- Any behaviour that would send data off the device, or that would let one person affect another's install. The app is designed to do neither.

## Out of scope

- The local StoreKit configuration (`SleepNoise.storekit`). It is a development fixture, and a TestFlight or App Store build does not use it.
- A jailbroken device, or physical access to an unlocked phone.
- Setting the device clock back before each launch, which can stretch the local seven-night trial. That limit is documented on `NightTrial`. It does not leave the device, and it does not reveal anyone else's data. A report of that behaviour will be read as a product note.

## Notes for a report

The app sets `ITSAppUsesNonExemptEncryption` to false. It does not implement its own cryptography. The trial item uses the iOS Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` and is not synchronized. The render path is described in [`ARCHITECTURE.md`](ARCHITECTURE.md).
