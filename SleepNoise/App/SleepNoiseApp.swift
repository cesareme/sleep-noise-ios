import SwiftUI

@main
struct SleepNoiseApp: App {
    @StateObject private var root = AppRoot()

    var body: some Scene {
        WindowGroup {
            MixerView(model: root.mixer, purchases: root.purchases)
                .tint(Palette.amber)
        }
    }
}

#Preview {
    PreviewHost()
}

private struct PreviewHost: View {
    @StateObject private var root = AppRoot()

    var body: some View {
        MixerView(model: root.mixer, purchases: root.purchases)
    }
}
