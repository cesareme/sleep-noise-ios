import SwiftUI

struct SoundRowView: View {
    let sound: SoundID
    let level: Float
    let isLocked: Bool
    let onChange: (Float) -> Void
    let onLocked: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: sound.symbolName)
                    .tokenFont(.body, weight: .medium)
                    .foregroundStyle(level > 0.01 && !isLocked ? Palette.amber : Palette.muted)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(DesignTokens.Colors.hairline))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(LocalizedStringKey(sound.nameKey))
                            .tokenFont(.body, weight: .semibold)
                            .foregroundStyle(Palette.text)
                        if isLocked {
                            Text("sound.proOnly")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Palette.amber)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Palette.amber.opacity(0.16)))
                        }
                    }
                    Text(LocalizedStringKey(sound.detailKey))
                        .tokenFont(.caption)
                        .foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text("\(Int((level * 100).rounded()))")
                    .tokenFont(.caption)
                    .monospacedDigit()
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(minWidth: 28, alignment: .trailing)
                    .accessibilityHidden(true)
            }

            slider
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.card)
        )
        .opacity(isLocked ? 0.72 : 1)
    }

    private var slider: some View {
        ZStack {
            Slider(
                value: Binding(
                    get: { Double(level) },
                    set: { onChange(Float($0)) }
                ),
                in: 0...1
            )
            .tint(Palette.amber)
            .disabled(isLocked)
            .allowsHitTesting(!isLocked)
            .accessibilityLabel(Text(LocalizedStringKey(sound.nameKey)))
            .accessibilityValue(Text(TimeFormat.percentSpoken(Int((level * 100).rounded()))))
            .accessibilityHint(Text(isLocked ? "sound.locked" : "sound.slider.hint"))

            if isLocked {
                Button(action: onLocked) {
                    Color.clear
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("sound.locked"))
            }
        }
    }
}
