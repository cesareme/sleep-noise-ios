import SwiftUI

struct MixerView: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("sleepnoise.trial.introDismissed.v1") private var trialIntroDismissed = false
    @AppStorage("sleepnoise.trial.endedDismissed.v1") private var trialEndedDismissed = false
    @State private var showMixer = false
    @State private var hapticTick = 0
    @ScaledMetric(relativeTo: .largeTitle) private var playDiameter: CGFloat = 128

    var body: some View {
        ZStack {
            NightBackground(isPlaying: model.isPlaying && !model.isBedtime)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: model.isPlaying)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, DesignTokens.Spacing.l)
                    .padding(.top, DesignTokens.Spacing.s)

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        if let audioError = model.audioError {
                            note(audioError, tint: .red)
                        }
                        if showsTrialIntro {
                            TrialCard(kind: .intro, trialState: purchases.trialState, price: purchases.product?.displayPrice) {
                                trialIntroDismissed = true
                            } onMore: {
                                openPaywall()
                            }
                        } else if showsTrialEnded {
                            TrialCard(kind: .ended, trialState: purchases.trialState, price: purchases.product?.displayPrice) {
                                trialEndedDismissed = true
                            } onMore: {
                                openPaywall()
                            }
                        }
                        if model.loadedMixWasStripped {
                            strippedNote
                        }

                        playControl
                        PlaybackStatusLine(
                            timer: model.timer,
                            title: model.loadedMixName,
                            isPlaying: model.isPlaying
                        )

                        Button(action: beginBedtime) {
                            Label("control.bedtime", systemImage: "moon.fill")
                                .tokenFont(.subheadline, weight: .medium)
                                .foregroundStyle(DesignTokens.Colors.text)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(DesignTokens.Colors.surface))
                        }
                        .accessibilityHint(Text("control.bedtime.hint"))
                        .accessibilityIdentifier("bedtimeButton")

                        PresetStrip(
                            presets: Array(SoundPreset.allCases),
                            active: model.activePreset,
                            hasFullAccess: purchases.hasFullAccess
                        ) { preset in
                            hapticTick += 1
                            _ = model.playPreset(preset)
                        }

                        LazyVGrid(columns: tileColumns, spacing: DesignTokens.Spacing.s) {
                            ForEach(SoundID.allCases) { sound in
                                SoundTileView(
                                    sound: sound,
                                    isOn: displayedLevel(sound) > 0.01,
                                    isLocked: !AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess)
                                ) {
                                    if AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) {
                                        hapticTick += 1
                                        model.toggleSound(sound)
                                    } else {
                                        openPaywall()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.l)
                    }
                    .padding(.top, DesignTokens.Spacing.l)
                    .padding(.bottom, DesignTokens.Spacing.xl)
                }

                Button {
                    hapticTick += 1
                    showMixer = true
                } label: {
                    VStack(spacing: 6) {
                        Capsule()
                            .fill(DesignTokens.Colors.secondary.opacity(0.45))
                            .frame(width: 36, height: 4)
                            .accessibilityHidden(true)
                        Text("control.mixer")
                            .tokenFont(.caption, weight: .semibold)
                            .foregroundStyle(DesignTokens.Colors.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                }
                .accessibilityIdentifier("openMixer")
            }
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(DesignTokens.Colors.text)
        .sensoryFeedback(.selection, trigger: model.isPlaying)
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTick)
        .onAppear { model.startIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { purchases.refreshAccess(canDowngrade: !model.isPlaying) }
        }
        .onChange(of: purchases.hasFullAccess) { _, _ in
            model.clampTimerToEntitlement()
            model.refreshEntitledAudio()
        }
        .sheet(isPresented: $model.showPaywall) {
            PaywallView(purchases: purchases)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .onDisappear { purchases.clearNotice() }
        }
        .sheet(isPresented: $showMixer) {
            MixSheet(model: model, purchases: purchases, onPaywall: openPaywall, onBedtime: beginBedtime)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        .fullScreenCover(isPresented: Binding(
            get: { model.isBedtime },
            set: { if !$0 { model.leaveBedtime() } }
        )) {
            BedtimeView(model: model)
        }
    }

    private var tileColumns: [GridItem] {
        let count = typeSize.isAccessibilitySize ? 2 : 3
        return Array(repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.s), count: count)
    }

    private var showsTrialIntro: Bool {
        !purchases.isPro && purchases.trialState != .ended && !trialIntroDismissed
    }

    private var showsTrialEnded: Bool {
        !purchases.isPro && purchases.trialState == .ended && !trialEndedDismissed
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("app.name")
                .tokenFont(.title3, weight: .semibold)
            Spacer()
            accessChip
        }
    }

    @ViewBuilder
    private var accessChip: some View {
        if purchases.isPro {
            Text("common.pro")
                .tokenFont(.caption, weight: .bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(DesignTokens.Colors.accent.opacity(0.18)))
                .foregroundStyle(DesignTokens.Colors.accent)
        } else {
            switch purchases.trialState {
            case .notStarted, .active:
                Button {
                    openPaywall()
                } label: {
                    Text(trialChipTitle)
                        .tokenFont(.caption, weight: .bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().stroke(DesignTokens.Colors.accent.opacity(0.7), lineWidth: 1))
                        .foregroundStyle(DesignTokens.Colors.accent)
                }
                .accessibilityHint(Text("trial.chip.hint"))
                .accessibilityIdentifier("openPaywall")
            case .ended:
                Button {
                    openPaywall()
                } label: {
                    Text("control.pro")
                        .tokenFont(.caption, weight: .bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(DesignTokens.Colors.accent))
                        .foregroundStyle(DesignTokens.Colors.onAccent)
                }
                .accessibilityIdentifier("openPaywall")
            }
        }
    }

    private var trialChipTitle: String {
        switch purchases.trialState {
        case .notStarted:
            return String(format: String(localized: "trial.chip.notStartedFormat"), Int64(AccessPolicy.trialDays))
        case .active(let days):
            return String.localizedStringWithFormat(String(localized: "trial.chip.daysFormat"), days)
        case .ended:
            return String(localized: "control.pro")
        }
    }

    private var playControl: some View {
        Button {
            model.togglePlayback()
        } label: {
            Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: playDiameter * 0.28, weight: .medium, design: .rounded))
                .foregroundStyle(DesignTokens.Colors.onAccent)
                .frame(width: playDiameter, height: playDiameter)
                .background(Circle().fill(DesignTokens.Colors.accent))
        }
        .accessibilityLabel(Text(LocalizedStringKey(model.isPlaying ? "control.pause" : "control.play")))
        .accessibilityIdentifier("playButton")
    }

    private var strippedNote: some View {
        Button(action: openPaywall) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
                Text("mixes.stripped")
                    .tokenFont(.footnote)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .foregroundStyle(DesignTokens.Colors.accent)
            .padding(DesignTokens.Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.s, style: .continuous).fill(DesignTokens.Colors.accent.opacity(0.12)))
        }
        .padding(.horizontal, DesignTokens.Spacing.l)
        .accessibilityIdentifier("strippedMixNote")
    }

    private func note(_ text: String, tint: Color) -> some View {
        Text(text)
            .tokenFont(.footnote)
            .foregroundStyle(DesignTokens.Colors.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.m)
            .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.s).fill(tint.opacity(0.28)))
            .padding(.horizontal, DesignTokens.Spacing.l)
    }

    private func displayedLevel(_ sound: SoundID) -> Float {
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else { return 0 }
        return model.levels[sound] ?? 0
    }

    private func openPaywall() {
        if showMixer {
            showMixer = false
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(280))
                model.showPaywall = true
            }
        } else {
            model.showPaywall = true
        }
    }

    private func beginBedtime() {
        let wasOpen = showMixer
        showMixer = false
        hapticTick += 1
        Task { @MainActor in
            if wasOpen {
                try? await Task.sleep(for: .milliseconds(280))
            }
            model.enterBedtime()
        }
    }
}

/// Timer digits have to observe the timer itself. `MixerModel` does not
/// republish its child's ticks, so a label read through the model stays still.
private struct PlaybackStatusLine: View {
    @ObservedObject var timer: SleepTimerController
    var title: String?
    var isPlaying: Bool

    var body: some View {
        Text(line)
            .tokenFont(.callout, weight: .medium)
            .monospacedDigit()
            .foregroundStyle(timer.remaining != nil ? DesignTokens.Colors.accent : DesignTokens.Colors.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, DesignTokens.Spacing.l)
    }

    private var line: String {
        if let remaining = timer.remaining {
            return TimeFormat.clock(remaining)
        }
        if let title, !title.isEmpty {
            return title
        }
        if isPlaying {
            return String(localized: "mixer.status.playing")
        }
        return String(localized: "mixer.tagline")
    }
}

/// First-launch disclosure and the one-time "trial over" note.
private struct TrialCard: View {
    enum Kind { case intro, ended }

    var kind: Kind
    var trialState: TrialState
    var price: String?
    var onDismiss: () -> Void
    var onMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: kind == .intro ? "gift" : "hourglass.bottomhalf.filled")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(DesignTokens.Colors.accent)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .tokenFont(.body, weight: .semibold)
                        .foregroundStyle(DesignTokens.Colors.text)
                    Text(detail)
                        .tokenFont(.caption)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("trial.gotIt")
                        .tokenFont(.caption, weight: .bold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(DesignTokens.Colors.accent))
                        .foregroundStyle(DesignTokens.Colors.onAccent)
                }
                .accessibilityIdentifier("trialCardDismiss")
                Button(action: onMore) {
                    Text(kind == .intro ? "trial.intro.more" : "trial.ended.more")
                        .tokenFont(.caption, weight: .semibold)
                        .foregroundStyle(DesignTokens.Colors.text)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(DesignTokens.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.m, style: .continuous)
                .fill(DesignTokens.Colors.accent.opacity(0.10))
        )
        .padding(.horizontal, DesignTokens.Spacing.l)
        .accessibilityIdentifier(kind == .intro ? "trialIntroCard" : "trialEndedCard")
    }

    private var title: String {
        switch kind {
        case .intro:
            return String(format: String(localized: "trial.intro.titleFormat"), Int64(AccessPolicy.trialDays))
        case .ended:
            return String(localized: "trial.ended.title")
        }
    }

    private var detail: String {
        let days = Int64(AccessPolicy.trialDays)
        switch (kind, trialState, price) {
        case (.intro, .active(let left), let price?):
            return String.localizedStringWithFormat(String(localized: "trial.intro.runningFormat"), left) + " " + String(format: String(localized: "trial.price.onceFormat"), price)
        case (.intro, .active(let left), nil):
            return String.localizedStringWithFormat(String(localized: "trial.intro.runningFormat"), left) + " " + String(localized: "trial.price.onceNoPrice")
        case (.intro, _, let price?):
            return String(format: String(localized: "trial.intro.detailFormat"), days) + " " + String(format: String(localized: "trial.price.onceFormat"), price)
        case (.intro, _, nil):
            return String(format: String(localized: "trial.intro.detailFormat"), days) + " " + String(localized: "trial.price.onceNoPrice")
        case (.ended, _, let price?):
            return String(format: String(localized: "trial.ended.detailFormat"), price)
        case (.ended, _, nil):
            return String(localized: "trial.ended.detailNoPrice")
        }
    }
}
