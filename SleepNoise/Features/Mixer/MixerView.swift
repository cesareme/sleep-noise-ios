import SwiftUI

struct MixerView: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showTimer = false
    @State private var showMixes = false
    @State private var showSave = false
    @State private var draftName = ""

    var body: some View {
        ZStack {
            NightBackground(isPlaying: model.isPlaying)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: model.isPlaying)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                if let audioError = model.audioError {
                    Text(audioError)
                        .font(.footnote)
                        .foregroundStyle(Palette.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.28)))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(SoundID.allCases) { sound in
                            SoundRowView(
                                sound: sound,
                                level: displayedLevel(sound),
                                isLocked: !AccessPolicy.soundIsIncluded(sound, isPro: purchases.isPro),
                                onChange: { model.setLevel(sound, $0) },
                                onLocked: { model.showPaywall = true }
                            )
                        }
                        if model.isSilent {
                            Text("mixer.silent")
                                .font(.footnote)
                                .foregroundStyle(Palette.muted)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                bottomBar
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Palette.text)
        .preferredColorScheme(.dark)
        .onAppear { model.startIfNeeded() }
        .onChange(of: purchases.isPro) { _, _ in
            model.clampTimerToEntitlement()
            model.refreshEntitledAudio()
        }
        .sheet(isPresented: $model.showPaywall) {
            PaywallView(purchases: purchases)
                .onDisappear { purchases.clearNotice() }
        }
        .sheet(isPresented: $showTimer) {
            SleepTimerView(
                timer: model.timer,
                isPro: purchases.isPro,
                onSelect: { model.selectTimer(minutes: $0) },
                onLocked: {
                    showTimer = false
                    Task { @MainActor in
                        model.showPaywall = true
                    }
                }
            )
        }
        .sheet(isPresented: $showMixes) {
            SavedMixesView(store: model.mixStore) { mix in
                let stripped = model.apply(mix)
                if stripped {
                    Task { @MainActor in
                        model.showPaywall = true
                    }
                }
            }
        }
        .alert("mixes.save.title", isPresented: $showSave) {
            TextField("mixes.name.placeholder", text: $draftName)
            Button("common.save") {
                _ = model.saveCurrent(name: draftName)
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("mixes.save.message")
        }
        .sensoryFeedback(.selection, trigger: model.isPlaying)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("app.name")
                    .font(.title.weight(.semibold))
                Text(model.loadedMixName ?? String(localized: "mixer.tagline"))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
            }
            Spacer()
            Button {
                showMixes = true
            } label: {
                Image(systemName: "square.stack")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Palette.mist)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("control.mixes"))
            .accessibilityIdentifier("openMixes")
            if purchases.isPro {
                Text("common.pro")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Palette.amber.opacity(0.18)))
                    .foregroundStyle(Palette.amber)
            } else {
                Button {
                    model.showPaywall = true
                } label: {
                    Text("control.pro")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Palette.amber))
                        .foregroundStyle(Palette.background)
                }
                .accessibilityIdentifier("openPaywall")
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 16) {
            Button {
                showTimer = true
            } label: {
                TimerButtonLabel(timer: model.timer)
            }
            .accessibilityIdentifier("openTimer")

            Button {
                model.togglePlayback()
            } label: {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Palette.background)
                    .frame(width: 76, height: 76)
                    .background(Circle().fill(Palette.amber))
            }
            .accessibilityLabel(Text(LocalizedStringKey(model.isPlaying ? "control.pause" : "control.play")))
            .accessibilityIdentifier("playButton")

            barButton(
                title: String(localized: "control.save"),
                symbol: "square.and.arrow.down",
                action: beginSave
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Palette.background.opacity(0.92))
    }

    private func barButton(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.body.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Palette.mist)
            .frame(maxWidth: .infinity, minHeight: 64)
        }
    }

    private func displayedLevel(_ sound: SoundID) -> Float {
        guard AccessPolicy.soundIsIncluded(sound, isPro: purchases.isPro) else { return 0 }
        return model.levels[sound] ?? 0
    }

    private func beginSave() {
        guard AccessPolicy.canSave(existingCount: model.mixStore.mixes.count, isPro: purchases.isPro) else {
            model.showPaywall = true
            return
        }
        draftName = model.suggestedMixName()
        showSave = true
    }
}

/// Observes the timer directly. `MixerModel` does not republish its child's
/// `objectWillChange`, so a label read through the model would never tick.
private struct TimerButtonLabel: View {
    @ObservedObject var timer: SleepTimerController

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.body.weight(.semibold))
                .symbolEffect(.pulse, options: .repeating, isActive: timer.isFading)
            Text(title)
                .font(.caption.weight(.medium).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(timer.remaining != nil ? Palette.amber : Palette.mist)
        .frame(maxWidth: .infinity, minHeight: 64)
    }

    private var title: String {
        if let remaining = timer.remaining {
            return TimeFormat.clock(remaining)
        }
        if let minutes = timer.selectedMinutes {
            return TimeFormat.minutes(minutes)
        }
        return String(localized: "control.timer")
    }
}
