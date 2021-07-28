//
// Reactions App
//

import Foundation
import StoreKit

protocol ProductLoader {
    func getProduct(forUnit unit: Unit) -> SKProduct?
    func loadProducts(units: [Unit])

    var delegate: ProductLoaderDelegate? { get set }
}

protocol ProductLoaderDelegate: AnyObject {
    func didLoadProducts(_ products: [SKProduct])
}
