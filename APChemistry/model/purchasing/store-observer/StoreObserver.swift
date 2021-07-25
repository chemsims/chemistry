//
// Reactions App
//

import Foundation
import StoreKit

protocol StoreObserver {
    func buy(product: SKProduct)

    func restorePurchases()

    func initialise()

    func cleanup()

    var canMakePurchase: Bool { get }

    var delegate: StoreObserverDelegate? { get set }
}

protocol StoreObserverDelegate: AnyObject {

    func didDefer(productId: String)

    func didRestore(productId: String)

    func didPurchase(productId: String)

    func didFail(productId: String)
}
