//
// Reactions App
//

import Foundation
import StoreKit

struct InAppPurchaseWithState: Identifiable, Equatable {

    init(
        type: InAppPurchase,
        state: PurchaseState
    ) {
        self.type = type
        self.state = state
    }

    var id: String {
        type.inAppPurchaseId
    }

    let type: InAppPurchase
    private(set) var state: PurchaseState
    private(set) var skProduct: SKProduct?
}

extension InAppPurchaseWithState {
    mutating func startLoadingProduct() {
        if shouldLoadProduct {
            self.state = .loadingProduct
        }
    }

    var shouldLoadProduct: Bool {
        switch state {
        case .waitingToLoadProduct, .failedToLoadProduct:
            return true
        default:
            return false
        }
    }

    mutating func addLoadedProduct(_ product: SKProduct) {
        switch state {
        case .loadingProduct:
            self.state = .readyForPurchase(product: product)
            self.skProduct = product
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
        if type.isConsumableTip {
            didPurchaseConsumableTip()
        } else {
            switch state {
            case .purchasing:
                self.state = .purchased
            default:
                break
            }
        }

    }

    // Restoring can happen from any state, so we always set it
    mutating func restored() {
        if type.isConsumableTip {
            didPurchaseConsumableTip()
        } else {
            self.state = .purchased
        }
    }

    private mutating func didPurchaseConsumableTip() {
        if let product = skProduct {
            self.state = .readyForPurchase(product: product)
        } else {
            self.state = .failedToLoadProduct
        }
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

    var isReadyForPurchase: Bool {
        if case .readyForPurchase = self {
            return true
        }
        return false
    }
}
