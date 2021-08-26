//
// Reactions App
//

import Foundation
import StoreKit

class ConcreteProductLoader: NSObject, ProductLoader {

    weak var delegate: ProductLoaderDelegate?

    private var products = [InAppPurchase : SKProduct]()

    func getSKProduct(for type: InAppPurchase) -> SKProduct? {
        products[type]
    }

    func loadSKProducts(types: [InAppPurchase]) {
        let ids = Set(types.map(\.inAppPurchaseId))
        let productRequest = SKProductsRequest(productIdentifiers: ids)
        productRequest.delegate = self
        productRequest.start()
    }
}

extension ConcreteProductLoader: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach { product in
            if let type = productType(withId: product.productIdentifier) {
                products[type] = product
            }
        }

        DispatchQueue.main.async {
            self.delegate?.didLoadProducts(response.products)
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.didLoadProducts([])
        }
    }

    private func productType(withId id: String) -> InAppPurchase? {
        InAppPurchase.allCases.first { $0.inAppPurchaseId == id }
    }
}
