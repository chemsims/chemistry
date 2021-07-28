//
// Reactions App
//

import Foundation
import StoreKit

class DebugProductLoader: ProductLoader {

    init(loadDelay: Int? = nil) {
        self.loadDelay = loadDelay
    }

    private var products = [Unit : SKProduct]()

    private let loadDelay: Int?

    func getProduct(forUnit unit: Unit) -> SKProduct? {
        products[unit]
    }

    func loadProducts(units: [Unit]) {
        
        if let delay = loadDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                self.doLoadProducts(units: units)
            }
        } else {
            self.doLoadProducts(units: units)
        }

    }

    private func doLoadProducts(units: [Unit]) {
        var loadedProducts = [SKProduct]()

        units.forEach { unit in
            if let id = unit.inAppPurchaseID {
                let p = SKProduct()
                p.setValue(NSDecimalNumber(1.99), forKey: "price")
                p.setValue(id, forKey: "productIdentifier")
                p.setValue(
                    Locale(identifier: "en_us"), forKey: "priceLocale"
                )
                loadedProducts.append(p)
                products[unit] = p
            }

        }

        delegate?.didLoadProducts(loadedProducts)
    }

    var delegate: ProductLoaderDelegate?
}
