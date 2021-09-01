//
// Reactions App
//

import Foundation
import StoreKit

class DebugProductLoader: ProductLoader {

    init(loadDelay: Int? = nil) {
        self.loadDelay = loadDelay
    }

    private var products = [InAppPurchase : SKProduct]()

    private let loadDelay: Int?

    func getSKProduct(for type: InAppPurchase) -> SKProduct? {
        products[type]
    }

    func loadSKProducts(types: [InAppPurchase]) {
        
        if let delay = loadDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                self.doLoadProducts(types: types)
            }
        } else {
            self.doLoadProducts(types: types)
        }
    }

    private func doLoadProducts(types: [InAppPurchase]) {
        var loadedProducts = [SKProduct]()

        types.forEach { type in
            let id = type.inAppPurchaseId
            let p = SKProduct()
            p.setValue(NSDecimalNumber(value: type.debugPrice), forKey: "price")
            p.setValue(id, forKey: "productIdentifier")
            p.setValue(
                Locale(identifier: "en_us"), forKey: "priceLocale"
            )
            loadedProducts.append(p)
            products[type] = p
        }

        delegate?.didLoadProducts(loadedProducts)
    }

    var delegate: ProductLoaderDelegate?
}

private extension InAppPurchase {
    var debugPrice: Double {
        switch self {
        case .tipWithBadge1, .extraTip1: return 0.99
        case .tipWithBadge2, .extraTip2: return 1.99
        case .tipWithBadge3, .extraTip3: return 2.99
        case .tipWithBadge4, .extraTip4: return 3.99
        case .tipWithBadge5, .extraTip5: return 4.99
        case .tipWithBadge6, .extraTip6: return 5.99
        }
    }
}
