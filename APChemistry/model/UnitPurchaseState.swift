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

    mutating func setState(_ newState: PurchaseState) {
        // There's never a case where we leave the purchased state, so don't
        // allow setting state when state is purchased
        guard self.state != .purchased else {
            return
        }
        self.state = newState
    }
}

enum PurchaseState: Equatable {
    case loadingProduct,
         failedToLoadProduct,
         readyForPurchase(product: SKProduct),
         purchasing,
         deferred, // e.g. pending parent approval
         purchased

    var locked: Bool {
        self != .purchased
    }
}
