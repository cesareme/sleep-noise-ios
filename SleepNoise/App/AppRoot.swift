import Combine
import Foundation

@MainActor
final class AppRoot: ObservableObject {
    let purchases: PurchaseManager
    let mixer: MixerModel

    init() {
        let purchases = PurchaseManager()
        self.purchases = purchases
        mixer = MixerModel(purchases: purchases)
    }
}
