import SwiftUI

/// Volumes, timer, breathing, saved mixes. The main screen stays a play
/// control and a grid; this sheet is where the night is tuned.
struct MixSheet: View {
    @ObservedObject var model: MixerModel
    @ObservedObject var purchases: PurchaseManager
    var onPaywall: () -> Void
    var onBedtime: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showSave = false
    @State private var draftName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.l) {
                    Button(action: onBedtime) {
                        Label("control.bedtime", systemImage: "moon.fill")
                            .tokenFont(.body, weight: .semibold)
                            .foregroundStyle(DesignTokens.Colors.onAccent)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.m, style: .continuous).fill(DesignTokens.Colors.accent))
                    }
                    .accessibilityHint(Text("control.bedtime.hint"))
                    .accessibilityIdentifier("bedtimeButtonSheet")

                    TimerLink(
                        timer: model.timer,
                        hasFullAccess: purchases.hasFullAccess,
                        onSelect: { model.selectTimer(minutes: $0) },
                        onLocked: onPaywall
                    )

                    BreathingCard(
                        guide: model.breathing,
                        isLocked: !model.breathingIsIncluded,
                        note: model.breathingNote,
                        onToggle: { model.setBreathingEnabled($0) },
                        onOpenSettings: {},
                        onLocked: onPaywall,
                        onUpdate: model.breathingIsIncluded ? { model.updateBreathing($0) } : nil
                    )

                    VStack(spacing: DesignTokens.Spacing.s) {
                        ForEach(SoundID.allCases) { sound in
                            SoundRowView(
                                sound: sound,
                                level: displayedLevel(sound),
                                isLocked: !AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess),
                                onChange: { model.setLevel(sound, $0) },
                                onLocked: onPaywall
                            )
                        }
                    }

                    if model.isSilent {
                        Text("mixer.silent")
                            .tokenFont(.footnote)
                            .foregroundStyle(DesignTokens.Colors.secondary)
                    }

                    HStack(spacing: DesignTokens.Spacing.s) {
                        sheetAction("control.save", systemImage: "square.and.arrow.down", action: beginSave)
                            .accessibilityIdentifier("saveMix")
                        NavigationLink {
                            SavedMixesView(store: model.mixStore) { model.apply($0) }
                        } label: {
                            Label("control.mixes", systemImage: "square.stack")
                                .tokenFont(.callout, weight: .semibold)
                                .foregroundStyle(DesignTokens.Colors.text)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.s, style: .continuous).fill(DesignTokens.Colors.surface))
                        }
                        .accessibilityIdentifier("openMixes")
                    }
                }
                .padding(DesignTokens.Spacing.l)
            }
            .background(DesignTokens.Colors.background.ignoresSafeArea())
            .navigationTitle(Text("control.mixer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
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
    }

    private func displayedLevel(_ sound: SoundID) -> Float {
        guard AccessPolicy.soundIsIncluded(sound, hasFullAccess: purchases.hasFullAccess) else { return 0 }
        return model.levels[sound] ?? 0
    }

    private func beginSave() {
        guard AccessPolicy.canSave(existingCount: model.mixStore.mixes.count, hasFullAccess: purchases.hasFullAccess) else {
            onPaywall()
            return
        }
        draftName = model.suggestedMixName()
        showSave = true
    }

    private func sheetAction(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .tokenFont(.callout, weight: .semibold)
                .foregroundStyle(DesignTokens.Colors.text)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.s, style: .continuous).fill(DesignTokens.Colors.surface))
        }
    }
}

/// Observes the timer directly so the row keeps ticking while the sheet is open.
private struct TimerLink: View {
    @ObservedObject var timer: SleepTimerController
    var hasFullAccess: Bool
    var onSelect: (Int?) -> Void
    var onLocked: () -> Void

    var body: some View {
        NavigationLink {
            SleepTimerView(
                timer: timer,
                hasFullAccess: hasFullAccess,
                onSelect: onSelect,
                onLocked: onLocked
            )
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "timer")
                    .foregroundStyle(DesignTokens.Colors.accent)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("control.timer")
                        .tokenFont(.body, weight: .semibold)
                    Text(detail)
                        .tokenFont(.caption)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                        .monospacedDigit()
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(DesignTokens.Colors.text)
            .padding(DesignTokens.Spacing.m)
            .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.m, style: .continuous).fill(DesignTokens.Colors.surface))
        }
        .accessibilityIdentifier("openTimer")
    }

    private var detail: String {
        if let remaining = timer.remaining {
            return TimeFormat.clock(remaining)
        }
        if let minutes = timer.selectedMinutes {
            return TimeFormat.minutes(minutes)
        }
        return String(localized: "timer.off")
    }
}
