//
// Reactions App
//

import Foundation
import StoreKit

class ConcreteProductLoader: NSObject, ProductLoader {

    weak var delegate: ProductLoaderDelegate?

    private var products = [Unit : SKProduct]()

    func getProduct(forUnit unit: Unit) -> SKProduct? {
        products[unit]
    }

    func loadProducts(units: [Unit]) {
        let ids = Set(units.compactMap(\.inAppPurchaseID))
        let productRequest = SKProductsRequest(productIdentifiers: ids)
        productRequest.delegate = self
        productRequest.start()
    }
}

extension ConcreteProductLoader: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach { product in
            if let unit = unit(withId: product.productIdentifier) {
                products[unit] = product
            }
        }

        DispatchQueue.main.async {
            self.delegate?.didLoadProducts(response.products)
        }
    }

    private func unit(withId id: String) -> Unit? {
        Unit.all.first { $0.inAppPurchaseID == id }
    }
}
