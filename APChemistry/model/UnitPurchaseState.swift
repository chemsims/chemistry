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
    var state: PurchaseState
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
