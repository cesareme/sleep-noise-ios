import SwiftUI

/// One layer of the mix as a level row, on the page and in the Layers sheet.
///
/// The row writes through the model, so its rules hold wherever the row is:
/// a Pro layer without access does not move, and a seventh layer is not
/// added. When that happens the dead channel under the row says "Six at
/// once" for three seconds and nothing else changes.
///
/// A locked row opens the Pro sheet only while something may be sold. At
/// night the row has no tap at all.
struct LayerRow: View {
    @ObservedObject var model: MixerModel
    let sound: SoundID
    let hasFullAccess: Bool
    /// Read by the screen when it draws; the model checks again on the tap.
    let canSell: Bool

    @State private var capHits = 0
    @State private var showsCap = false

    /// Seconds the cap note stays after the last refused change.
    static let capNoteSeconds: TimeInterval = 3

    private var isLocked: Bool {
        !AccessPolicy.soundIsIncluded(sound, hasFullAccess: hasFullAccess)
    }

    var body: some View {
        LevelRule(
            id: sound.rawValue,
            name: sound.localizedName,
            subtitle: Localized.string(sound.detailKey),
            level: Binding(
                get: { model.levels[sound] ?? 0 },
                set: { write($0) }
            ),
            isLocked: isLocked,
            channelNote: showsCap ? Localized.string("capas.tope") : nil,
            onLockedTap: canSell ? { model.offerPro() } : nil,
            // The levels go to disk when the finger leaves, not on every
            // sample of the drag.
            onDragActive: { active in
                if active {
                    model.beginLevelGesture()
                } else {
                    model.endLevelGesture()
                }
            }
        )
        .task(id: capHits) {
            guard capHits > 0 else { return }
            if !showsCap {
                showsCap = true
                // Caused by a touch, so it may be spoken.
                AccessibilityNotification.Announcement(Localized.string("capas.tope")).post()
            }
            try? await Task.sleep(for: .seconds(Self.capNoteSeconds))
            if !Task.isCancelled { showsCap = false }
        }
        #if DEBUG
        .onAppear {
            if PageArguments.capNoteSound == sound { showsCap = true }
        }
        #endif
    }

    private func write(_ value: Float) {
        if model.setLevel(sound, value) == .capReached {
            capHits += 1
        }
    }
}
