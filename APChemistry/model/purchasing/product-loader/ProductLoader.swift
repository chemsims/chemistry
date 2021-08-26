//
// Reactions App
//

import Foundation
import StoreKit

protocol ProductLoader {
    func getSKProduct(for type: InAppPurchase) -> SKProduct?
    func loadSKProducts(types: [InAppPurchase])

    var delegate: ProductLoaderDelegate? { get set }
}

protocol ProductLoaderDelegate: AnyObject {
    func didLoadProducts(_ skProducts: [SKProduct])
}
