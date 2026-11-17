import Combine
import Foundation

@MainActor
final class AppRoot: ObservableObject {
    let purchases: PurchaseManager
    let mixer: MixerModel

    init() {
        #if DEBUG
        if let state = PageArguments.state {
            // A staged launch for the reference captures: its own defaults
            // and a pinned clock. See `PageStage`.
            (purchases, mixer) = PageStage.make(state)
            IntentBridge.attach(mixer)
            return
        }
        #endif
        let purchases = PurchaseManager()
        self.purchases = purchases
        mixer = MixerModel(purchases: purchases)
        IntentBridge.attach(mixer)
    }
}
