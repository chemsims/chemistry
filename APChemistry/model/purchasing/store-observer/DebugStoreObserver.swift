//
// Reactions App
//

import Foundation
import StoreKit

class DebugStoreObserver: StoreObserver {

    // number of times to fail before succeeding
    private let failCount = 0
    private var buyCounts = 0

    private let actionDelay = 1

    func buy(product: SKProduct) {
        buyCounts += 1
        let shouldFail = buyCounts <= failCount
        runAfterDelay {
            let productId = product.productIdentifier
            if shouldFail {
                self.delegate?.didFail(productId: productId)
            } else {
                self.delegate?.didPurchase(productId: productId)
            }
        }
    }

    func restorePurchases() {
        runAfterDelay {
            self.delegate?.didRestore(productId: Unit.all.first!.inAppPurchaseID)
        }
    }

    func initialise() {
    }

    func cleanup() {
    }

    let canMakePurchase: Bool = true

    private func runAfterDelay(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(actionDelay)) {
            action()
        }
    }

    var delegate: StoreObserverDelegate?
}
