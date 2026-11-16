import SwiftUI

struct SleepTimerView: View {
    @ObservedObject var timer: SleepTimerController
    var hasFullAccess: Bool
    var onSelect: (Int?) -> Void
    var onLocked: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var customMinutes = 45

    private let presets = [15, 30, 60, 90]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                if let remaining = timer.remaining {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("timer.remaining")
                            .font(.caption)
                            .foregroundStyle(Palette.muted)
                        Text(TimeFormat.clock(remaining))
                            .font(.system(size: 44, weight: .light, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Palette.text)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    presetButton(title: String(localized: "timer.off"), minutes: nil)
                    ForEach(presets, id: \.self) { minutes in
                        presetButton(
                            title: TimeFormat.minutes(minutes),
                            minutes: minutes
                        )
                    }
                }

                customRow

                Text("timer.note")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)

                Spacer()
            }
            .padding(24)
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle(Text("timer.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func presetButton(title: String, minutes: Int?) -> some View {
        let locked = minutes.map { !AccessPolicy.timerIsIncluded(minutes: $0, hasFullAccess: hasFullAccess) } ?? false
        let selected = timer.selectedMinutes == minutes
        return Button {
            if locked {
                onLocked()
            } else {
                onSelect(minutes)
                dismiss()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.body.weight(.medium))
                Spacer()
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                }
            }
            .foregroundStyle(selected ? Palette.background : Palette.text)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? Palette.amber : Palette.card)
            )
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var customRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("timer.custom")
                    .font(.headline)
                    .foregroundStyle(Palette.text)
                Spacer()
                if !hasFullAccess {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(Palette.amber)
                }
            }
            if hasFullAccess {
                Stepper(value: $customMinutes, in: 5...AccessPolicy.maxTimerMinutes, step: 5) {
                    Text(TimeFormat.minutes(customMinutes))
                        .foregroundStyle(Palette.text)
                        .monospacedDigit()
                }
                .tint(Palette.amber)
                Button {
                    onSelect(customMinutes)
                    dismiss()
                } label: {
                    Text("timer.custom")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.amber)
                .foregroundStyle(Palette.background)
            } else {
                Button(action: onLocked) {
                    Text("timer.locked")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.card)
        )
    }
}
