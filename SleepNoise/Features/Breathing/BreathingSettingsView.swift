import SwiftUI

/// Settings of the breathing tide, as a sheet. The page presents it as it
/// was; the tide is rebuilt with its own package.
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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("breath.hint")
                        .font(.body)
                        .foregroundStyle(Palette.muted)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("breath.rate")
                            .font(.headline)
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
                            .font(.headline)
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
        .preferredColorScheme(.dark)
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
                .foregroundStyle(selected ? Palette.background : Palette.text)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selected ? Palette.amber : Color.white.opacity(0.06))
                )
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
