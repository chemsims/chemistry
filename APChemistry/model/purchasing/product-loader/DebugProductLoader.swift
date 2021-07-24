//
// Reactions App
//

import Foundation
import StoreKit

class DebugProductLoader: ProductLoader {

    private var products = [Unit : SKProduct]()

    func getProduct(forUnit unit: Unit) -> SKProduct? {
        products[unit]
    }

    func loadProducts(units: [Unit]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.doLoadProducts(units: units)
        }
    }

    private func doLoadProducts(units: [Unit]) {
        var loadedProducts = [SKProduct]()

        units.forEach { unit in
            let p = SKProduct()
            p.setValue(NSDecimalNumber(1.99), forKey: "price")
            p.setValue(unit.id, forKey: "productIdentifier")
            p.setValue(
                Locale(identifier: "en_us"), forKey: "priceLocale"
            )
            loadedProducts.append(p)
            products[unit] = p
        }

        delegate?.didLoadProducts(loadedProducts)
    }

    var delegate: ProductLoaderDelegate?

    let isLoading: Bool = false
}
