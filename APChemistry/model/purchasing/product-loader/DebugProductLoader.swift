//
// Reactions App
//

import Foundation
import StoreKit

class DebugProductLoader: ProductLoader {

    func getProduct(forUnit unit: Unit) -> SKProduct? {
        nil
    }

    func loadProducts() {
    }

    var delegate: ProductLoaderDelegate?

    let isLoading: Bool = false
}
