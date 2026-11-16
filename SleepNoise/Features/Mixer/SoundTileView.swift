import SwiftUI

/// A sound on the main grid. The tile is on or off; volume lives in the sheet.
struct SoundTileView: View {
    let sound: SoundID
    var isOn: Bool
    var isLocked: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.s) {
                HStack {
                    Image(systemName: sound.symbolName)
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .accessibilityHidden(true)
                    Spacer(minLength: 0)
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2.weight(.bold))
                            .accessibilityHidden(true)
                    }
                }
                Text(LocalizedStringKey(sound.nameKey))
                    .tokenFont(.subheadline, weight: .semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(isOn && !isLocked ? DesignTokens.Colors.accent : DesignTokens.Colors.text)
            .padding(DesignTokens.Spacing.m)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.tile, style: .continuous)
                    .fill(DesignTokens.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.tile, style: .continuous)
                    .strokeBorder(
                        isOn && !isLocked ? DesignTokens.Colors.accent.opacity(0.9) : DesignTokens.Colors.hairline,
                        lineWidth: isOn && !isLocked ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(sound.nameKey)))
        .accessibilityValue(Text(isOn && !isLocked ? "sound.on" : "sound.off"))
        .accessibilityHint(Text(isLocked ? "sound.locked" : "sound.tile.hint"))
        .accessibilityAddTraits(isOn && !isLocked ? .isSelected : [])
        .accessibilityIdentifier("soundTile.\(sound.rawValue)")
    }
}
