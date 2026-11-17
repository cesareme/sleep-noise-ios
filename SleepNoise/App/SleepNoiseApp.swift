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
                PageView(model: root.mixer, purchases: root.purchases)
            }
            #else
            PageView(model: root.mixer, purchases: root.purchases)
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
        PageView(model: root.mixer, purchases: root.purchases)
    }
}
