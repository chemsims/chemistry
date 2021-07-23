//
// Reactions App
//

import Foundation
import StoreKit

class DebugStoreObserver: StoreObserver {

    func buy(product: SKProduct) {
    }

    func restorePurchases() {
    }

    func initialise() {
    }

    func cleanup() {
    }

    var delegate: StoreObserverDelegate?
}
