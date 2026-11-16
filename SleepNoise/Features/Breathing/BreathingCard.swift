import SwiftUI

/// The breathing-tide row in the mixer. Observes the guide directly:
/// `MixerModel` does not republish its children, so reading the guide through
/// the model would never update the indicator.
struct BreathingCard: View {
    @ObservedObject var guide: BreathingGuideController
    var isLocked: Bool
    var note: String?
    var onToggle: (Bool) -> Void
    var onOpenSettings: () -> Void
    var onLocked: () -> Void
    var onUpdate: ((BreathingSettings) -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                BreathIndicator(guide: guide, tint: isOn ? Palette.amber : Palette.muted, reduceMotion: reduceMotion)
                    .frame(width: 36, height: 36)
                    .accessibilityHidden(true)

                settingsTitle
                    .accessibilityHint(Text(isLocked ? "sound.locked" : "breath.settings.hint"))

                if isLocked {
                    Button(action: onLocked) {
                        Image(systemName: "lock.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Palette.muted)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(Text("sound.locked"))
                    .accessibilityIdentifier("breathLocked")
                } else {
                    Toggle("", isOn: Binding(
                        get: { guide.settings.isEnabled },
                        set: { onToggle($0) }
                    ))
                    .labelsHidden()
                    .tint(Palette.amber)
                    .accessibilityLabel(Text("breath.title"))
                    .accessibilityIdentifier("breathToggle")
                }
            }
            if let note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(Palette.amber)
                    .transition(.opacity)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.card)
        )
        .opacity(isLocked ? 0.72 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: note)
    }

    @ViewBuilder
    private var settingsTitle: some View {
        let block = VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text("breath.title")
                    .tokenFont(.body, weight: .semibold)
                    .foregroundStyle(Palette.text)
                if isLocked {
                    Text("sound.proOnly")
                        .tokenFont(.caption2, weight: .bold)
                        .foregroundStyle(Palette.muted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(DesignTokens.Colors.hairline))
                }
            }
            Text(subtitle)
                .tokenFont(.caption)
                .foregroundStyle(Palette.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())

        if isLocked {
            Button(action: onLocked) { block }
                .buttonStyle(.plain)
        } else if let onUpdate {
            NavigationLink {
                BreathingSettingsView(guide: guide, onChange: onUpdate)
            } label: {
                block
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("openBreathing")
        } else {
            Button(action: onOpenSettings) { block }
                .buttonStyle(.plain)
        }
    }

    private var isOn: Bool { guide.settings.isEnabled && !isLocked }

    private var subtitle: String {
        if isLocked || !guide.settings.isEnabled {
            return String(localized: "breath.subtitle.off")
        }
        switch guide.phase {
        case .guiding:
            return String(localized: "breath.state.guiding")
        case .dissolving:
            return String(localized: "breath.state.dissolving")
        case .idle:
            let rate = Int64(guide.settings.breathsPerMinute)
            if guide.settings.guidesAllNight {
                return String(format: String(localized: "breath.subtitle.allNightFormat"), rate)
            }
            return String(format: String(localized: "breath.subtitle.format"), rate, Int64(guide.settings.guideMinutes))
        }
    }
}

/// A disc that swells with the breath, from the same curve and anchor the
/// audio uses. Kept in its own view so the timeline only re-evaluates this
/// circle, never the slider list. Under reduce motion it fades instead of
/// scaling. It is still when the guide is idle and after twenty minutes.
private struct BreathIndicator: View {
    @ObservedObject var guide: BreathingGuideController
    var tint: Color
    var reduceMotion: Bool

    /// Flipped when the twenty-minute visual window closes, so the timeline
    /// pauses instead of redrawing a still disc all night.
    @State private var windowClosed = false

    var body: some View {
        let active = guide.isVisuallyActive() && !windowClosed
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !active)) { context in
            let breath: Float = {
                guard let anchor = guide.anchor, guide.isVisuallyActive(now: context.date) else { return 0.35 }
                return BreathCurve.value(
                    secondsSinceStart: context.date.timeIntervalSince(anchor),
                    parameters: BreathParameters.guided(breathsPerMinute: guide.settings.breathsPerMinute)
                )
            }()
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.hairline)
                if reduceMotion {
                    Circle()
                        .fill(tint.opacity(0.3 + 0.6 * Double(breath)))
                        .padding(6)
                } else {
                    Circle()
                        .fill(tint.opacity(0.22 + 0.5 * Double(breath)))
                        .padding(CGFloat(10 - 7 * breath))
                }
            }
        }
        .task(id: guide.anchor) {
            windowClosed = false
            guard let windowStart = guide.windowStart else { return }
            let remaining = BreathingGuideController.visualSeconds - Date().timeIntervalSince(windowStart)
            guard remaining > 0 else { windowClosed = true; return }
            try? await Task.sleep(for: .seconds(remaining))
            if !Task.isCancelled { windowClosed = true }
        }
    }
}

struct BreathingSettingsView: View {
    @ObservedObject var guide: BreathingGuideController
    var onChange: (BreathingSettings) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: BreathingSettings

    init(guide: BreathingGuideController, onChange: @escaping (BreathingSettings) -> Void) {
        self.guide = guide
        self.onChange = onChange
        _draft = State(initialValue: guide.settings)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                    Text("breath.hint")
                        .tokenFont(.body)
                        .foregroundStyle(Palette.muted)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("breath.rate")
                            .tokenFont(.headline, weight: .semibold)
                            .foregroundStyle(Palette.text)
                        Stepper(value: $draft.breathsPerMinute, in: BreathingSettings.rateRange) {
                            Text(String(format: String(localized: "breath.rate.format"), Int64(draft.breathsPerMinute)))
                                .foregroundStyle(Palette.text)
                                .monospacedDigit()
                        }
                        .tint(Palette.amber)
                        .onChange(of: draft.breathsPerMinute) { _, _ in onChange(draft) }
                        Text("breath.comfort")
                            .font(.footnote)
                            .foregroundStyle(Palette.muted)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.card))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("breath.duration")
                            .tokenFont(.headline, weight: .semibold)
                            .foregroundStyle(Palette.text)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(BreathingSettings.durationChoices.filter { $0 != 0 }, id: \.self) { minutes in
                                durationButton(minutes)
                            }
                        }
                        durationButton(0)
                        Text(draft.guidesAllNight ? "breath.allNight.note" : "breath.dissolve")
                            .font(.footnote)
                            .foregroundStyle(Palette.muted)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.card))
            }
            .padding(24)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle(Text("breath.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.close") { dismiss() }
            }
        }
    }

    private func durationButton(_ minutes: Int) -> some View {
        let selected = draft.guideMinutes == minutes
        let title = minutes == 0 ? String(localized: "breath.allNight") : TimeFormat.minutes(minutes)
        return Button {
            draft.guideMinutes = minutes
            onChange(draft)
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(selected ? Palette.onAccent : Palette.text)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selected ? Palette.amber : DesignTokens.Colors.hairline)
                )
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
