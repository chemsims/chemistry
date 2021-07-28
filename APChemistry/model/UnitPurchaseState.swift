//
// Reactions App
//

import Foundation
import StoreKit

struct UnitWithState: Identifiable, Equatable {

    init(
        unit: Unit,
        state: PurchaseState
    ) {
        self.unit = unit
        self.state = state
    }

    var id: String {
        unit.id
    }

    let unit: Unit
    private(set) var state: PurchaseState
}

extension UnitWithState {
    mutating func startLoadingProduct() {
        if shouldLoadProduct {
            self.state = .loadingProduct
        }
    }

    var shouldLoadProduct: Bool {
        switch state {
        case .waitingToLoadProduct, .failedToLoadProduct, .readyForPurchase:
            return true
        default:
            return false
        }
    }

    mutating func addLoadedProduct(_ product: SKProduct) {
        switch state {
        case .loadingProduct:
            self.state = .readyForPurchase(product: product)
        default:
            break;
        }
    }

    mutating func failedToLoadProduct() {
        switch state {
        case .loadingProduct:
            self.state = .failedToLoadProduct
        default:
            break;
        }
    }

    mutating func startPurchase() {
        switch state {
        case .readyForPurchase:
            self.state = .purchasing
        default:
            break
        }
    }

    mutating func deferPurchase() {
        switch state {
        case .purchasing:
            self.state = .deferred
        default:
            break;
        }
    }

    mutating func failedToPurchase(product: SKProduct?) {
        switch state {
        case .purchasing:
            if let p = product {
                self.state = .readyForPurchase(product: p)
            } else {
                self.state = .failedToLoadProduct
            }
        default:
            break
        }
    }

    mutating func purchased() {
        switch state {
        case .purchasing:
            self.state = .purchased
        default:
            break
        }
    }

    // Restoring can happen from any state, so we always set it
    mutating func restored() {
        self.state = .purchased
    }
}

enum PurchaseState: Equatable {
    case
        waitingToLoadProduct, // State before loading the products
        loadingProduct,
        failedToLoadProduct,
        readyForPurchase(product: SKProduct),
        purchasing,
        deferred, // e.g. pending parent approval
        purchased

    var locked: Bool {
        self != .purchased
    }
}
