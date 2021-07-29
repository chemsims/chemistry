//
// Reactions App
//

import Foundation
import StoreKit

class DebugStoreObserver: StoreObserver {

    init(actionDelay: Int? = 1) {
        self.actionDelay = actionDelay
    }

    // number of times to fail before succeeding
    private let failCount = 0
    
    private let actionDelay: Int?

    private var buyCounts = 0

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
            let id = Unit.all.compactMap(\.inAppPurchaseID).first ?? ""
            self.delegate?.didRestore(productId: id)
            self.delegate?.restoreComplete()
        }
    }

    func initialise() {
    }

    func cleanup() {
    }

    let canMakePurchase: Bool = true

    private func runAfterDelay(_ action: @escaping () -> Void) {
        if let delay = actionDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                action()
            }
        } else {
            action()
        }

    }

    var delegate: StoreObserverDelegate?
}
