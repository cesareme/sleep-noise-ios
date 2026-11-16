import SwiftUI

struct MixerView: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("sleepnoise.trial.introDismissed.v1") private var trialIntroDismissed = false
    @AppStorage("sleepnoise.trial.endedDismissed.v1") private var trialEndedDismissed = false
    @State private var showTimer = false
    @State private var showBreathing = false
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

                if model.loadedMixWasStripped {
                    strippedNote
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                ScrollView {
                    VStack(spacing: 12) {
                        if showsTrialIntro {
                            TrialCard(kind: .intro, trialState: purchases.trialState, price: purchases.product?.displayPrice) {
                                trialIntroDismissed = true
                            } onMore: {
                                model.showPaywall = true
                            }
                        } else if showsTrialEnded {
                            TrialCard(kind: .ended, trialState: purchases.trialState, price: purchases.product?.displayPrice) {
                                trialEndedDismissed = true
                            } onMore: {
                                model.showPaywall = true
                            }
                        }
                        if purchases.hasFullAccess {
                            breathingCard
                        }
                        ForEach(SoundID.allCases) { sound in
                            SoundRowView(
                                sound: sound,
                                level: displayedLevel(sound),
                                isLocked: !AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess),
                                onChange: { model.setLevel(sound, $0) },
                                onLocked: { model.showPaywall = true }
                            )
                        }
                        if !purchases.hasFullAccess {
                            breathingCard
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
        .onChange(of: scenePhase) { _, phase in
            // A trial that ran out is only applied while nothing is playing.
            if phase == .active { purchases.refreshAccess(canDowngrade: !model.isPlaying) }
        }
        .onChange(of: purchases.hasFullAccess) { _, _ in
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
                hasFullAccess: purchases.hasFullAccess,
                onSelect: { model.selectTimer(minutes: $0) },
                onLocked: {
                    showTimer = false
                    Task { @MainActor in
                        model.showPaywall = true
                    }
                }
            )
        }
        .sheet(isPresented: $showBreathing) {
            BreathingSettingsView(guide: model.breathing) { settings in
                model.updateBreathing(settings)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showMixes) {
            SavedMixesView(store: model.mixStore) { mix in
                model.apply(mix)
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

    /// The disclosure stays until "Got it", even once the first Play has
    /// started the clock, so it cannot vanish before it was read.
    private var showsTrialIntro: Bool {
        !purchases.isPro && purchases.trialState != .ended && !trialIntroDismissed
    }

    private var showsTrialEnded: Bool {
        !purchases.isPro && purchases.trialState == .ended && !trialEndedDismissed
    }

    private var breathingCard: some View {
        BreathingCard(
            guide: model.breathing,
            isLocked: !model.breathingIsIncluded,
            note: model.breathingNote,
            onToggle: { model.setBreathingEnabled($0) },
            onOpenSettings: { showBreathing = true },
            onLocked: { model.showPaywall = true }
        )
    }

    private var strippedNote: some View {
        Button {
            model.showPaywall = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
                Text("mixes.stripped")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Palette.amber)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Palette.amber.opacity(0.12)))
        }
        .accessibilityIdentifier("strippedMixNote")
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
            accessChip
        }
    }

    /// Purchased: a quiet "Pro" badge. Trial: an outlined chip with the days
    /// left that opens the paywall. Free: the amber "Pro" button.
    @ViewBuilder
    private var accessChip: some View {
        if purchases.isPro {
            Text("common.pro")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Palette.amber.opacity(0.18)))
                .foregroundStyle(Palette.amber)
        } else {
            switch purchases.trialState {
            case .notStarted, .active:
                Button {
                    model.showPaywall = true
                } label: {
                    Text(trialChipTitle)
                        .font(.caption.weight(.bold).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().stroke(Palette.amber.opacity(0.7), lineWidth: 1))
                        .foregroundStyle(Palette.amber)
                }
                .accessibilityHint(Text("trial.chip.hint"))
                .accessibilityIdentifier("openPaywall")
            case .ended:
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
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else { return 0 }
        return model.levels[sound] ?? 0
    }

    private func beginSave() {
        guard AccessPolicy.canSave(existingCount: model.mixStore.mixes.count, hasFullAccess: purchases.hasFullAccess) else {
            model.showPaywall = true
            return
        }
        draftName = model.suggestedMixName()
        showSave = true
    }
}

/// First-launch disclosure (duration, what stays free, price) and the one-time
/// "trial over" note. Both dismiss for good.
private struct TrialCard: View {
    enum Kind { case intro, ended }

    var kind: Kind
    var trialState: TrialState
    var price: String?
    var onDismiss: () -> Void
    var onMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: kind == .intro ? "gift" : "hourglass.bottomhalf.filled")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Palette.amber)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Palette.text)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("trial.gotIt")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Palette.amber))
                        .foregroundStyle(Palette.background)
                }
                .accessibilityIdentifier("trialCardDismiss")
                Button(action: onMore) {
                    Text(kind == .intro ? "trial.intro.more" : "trial.ended.more")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Palette.mist)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.amber.opacity(0.10))
        )
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

/// Observes the timer directly. `MixerModel` does not republish its child's
/// `objectWillChange`, so a label read through the model would never tick.
private struct TimerButtonLabel: View {
    @ObservedObject var timer: SleepTimerController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.body.weight(.semibold))
                .symbolEffect(.pulse, options: .repeating, isActive: timer.isFading && !reduceMotion)
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
