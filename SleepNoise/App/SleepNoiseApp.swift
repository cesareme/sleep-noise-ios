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
                // Outside the page, so the page itself reads the forced
                // text size: how many rows fit depends on it.
                PageView(model: root.mixer, purchases: root.purchases)
                    .modifier(DebugDynamicType())
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
