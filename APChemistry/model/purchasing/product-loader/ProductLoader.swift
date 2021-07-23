//
// Reactions App
//

import Foundation
import StoreKit

protocol ProductLoader {
    func getProduct(forUnit unit: Unit) -> SKProduct?
    func loadProducts()

    var delegate: ProductLoaderDelegate? { get set }
    var isLoading: Bool { get }
}

protocol ProductLoaderDelegate: AnyObject {
    func didLoadProducts(_ products: [SKProduct])
}
