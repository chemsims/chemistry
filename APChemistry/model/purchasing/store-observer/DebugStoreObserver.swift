//
// Reactions App
//

import Foundation
import StoreKit

class DebugStoreObserver: StoreObserver {

    func buy(product: SKProduct) {
        runAfterDelay {
            self.delegate?.didPurchase(productId: product.productIdentifier)
        }
    }

    func restorePurchases() {
    }

    func initialise() {
    }

    func cleanup() {
    }

    private func runAfterDelay(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            action()
        }
    }

    var delegate: StoreObserverDelegate?
}
