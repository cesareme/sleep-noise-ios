import SwiftUI

/// The state word (03 §4.8): status said in words, in small caps.
///
/// Step 9, secondary ink, a little tracking. Never a background, never a
/// colour, never a badge or a capsule. When the content changes it fades;
/// nothing moves. Not for anything that is consulted at night: a time goes
/// in a full-size step.
struct StateWord: View {
    var text: String
    /// Speak the new state when it changes (session states only).
    var announcesChanges = false

    @Environment(\.nightPhase) private var phase

    var body: some View {
        Text(verbatim: text)
            .step(.stateWord)
            .foregroundStyle(Ink.secondary(phase))
            .contentTransition(.opacity)
            .animation(Motion.contentCurve, value: text)
            .onChange(of: text) { _, next in
                if announcesChanges {
                    AccessibilityNotification.Announcement(next).post()
                }
            }
    }
}

#Preview("State word") {
    VStack(alignment: .leading, spacing: Grid.inner) {
        StateWord(text: "pro")
        StateWord(text: "pro · 30")
        StateWord(text: "paused")
        StateWord(text: "trial · 5 nights left")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .grafitoRoot()
}
