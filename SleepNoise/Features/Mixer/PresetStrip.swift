import SwiftUI

struct PresetStrip: View {
    var presets: [SoundPreset]
    var active: SoundPreset?
    var hasFullAccess: Bool
    var onSelect: (SoundPreset) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.s) {
                ForEach(presets) { preset in
                    chip(preset)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.l)
        }
        .accessibilityLabel(Text("preset.section"))
    }

    private func chip(_ preset: SoundPreset) -> some View {
        let locked = preset.requiresFullAccess && !hasFullAccess
        let selected = active == preset
        return Button {
            onSelect(preset)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: preset.symbolName)
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
                Text(LocalizedStringKey(preset.nameKey))
                    .tokenFont(.subheadline, weight: .medium)
                    .lineLimit(1)
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.caption2.weight(.bold))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(selected ? DesignTokens.Colors.onAccent : DesignTokens.Colors.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(selected ? DesignTokens.Colors.accent : DesignTokens.Colors.surface)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(preset.nameKey)))
        .accessibilityHint(Text(locked ? "sound.locked" : "preset.hint"))
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("preset.\(preset.rawValue)")
    }
}
