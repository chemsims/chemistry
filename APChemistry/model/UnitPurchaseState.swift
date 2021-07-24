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
        guard state.canTransitionTo(newState) else {
            return
        }
        self.state = newState
    }
}

extension PurchaseState {

    fileprivate func canTransitionTo(_ newState: PurchaseState) -> Bool {
        switch self {
        case .purchased:
            return false

        case .deferred:
            return newState.paymentEndedOrFailed

        case .failedToLoadProduct:
            return true

        case .loadingProduct:
            return true

        case .purchasing:
            return newState.paymentEndedOrFailed

        case .readyForPurchase:
            return true
        }
    }

    private var paymentEndedOrFailed: Bool {
        mayHaveProduct || self == .purchased
    }

    private var mayHaveProduct: Bool {
        isReadyForPurchase || self == .failedToLoadProduct
    }

    private var isReadyForPurchase: Bool {
        if case .readyForPurchase = self {
            return true
        }
        return false
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
