import SwiftUI

struct SavedMixesView: View {
    @ObservedObject var store: MixStore
    var onApply: (SavedMix) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
                if store.mixes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.stack")
                            .font(.title)
                            .foregroundStyle(Palette.amber)
                        Text("mixes.empty")
                            .tokenFont(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Palette.muted)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.mixes) { mix in
                            Button {
                                onApply(mix)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mix.name)
                                        .tokenFont(.body, weight: .semibold)
                                        .foregroundStyle(Palette.text)
                                    Text(summary(mix))
                                        .font(.caption)
                                        .foregroundStyle(Palette.muted)
                                        .lineLimit(2)
                                    Text(mix.createdAt, format: .dateTime.month().day())
                                        .font(.caption2)
                                        .foregroundStyle(Palette.muted)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Palette.card)
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { store.mixes[$0].id }
                            ids.forEach(store.delete)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle(Text("mixes.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
                }
            }
    }

    private func summary(_ mix: SavedMix) -> String {
        let parts = mix.levels
            .filter { $0.value > 0.01 }
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { level in
                "\(level.sound.localizedName) \(Int((level.value * 100).rounded()))"
            }
        return parts.joined(separator: " · ")
    }
}
