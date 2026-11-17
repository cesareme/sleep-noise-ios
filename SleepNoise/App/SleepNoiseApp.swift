import SwiftUI

@main
struct SleepNoiseApp: App {
    @StateObject private var root = AppRoot()

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if GalleryArguments.isRequested {
                // Design gallery, debug builds only: launch with -gallery.
                SystemGallery(model: root.mixer)
            } else {
                MixerView(model: root.mixer, purchases: root.purchases)
                    .tint(Palette.amber)
            }
            #else
            MixerView(model: root.mixer, purchases: root.purchases)
                .tint(Palette.amber)
            #endif
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
