//
// Reactions App
//

import Foundation
import SwiftKeychainWrapper

protocol ProductLocker {
    func unlock(_ product: InAppPurchase)
    func isUnlocked(_ product: InAppPurchase) -> Bool
}

class KeychainProductLocker: ProductLocker {
    func unlock(_ product: InAppPurchase) {
        guard !product.isConsumableTip else {
            return
        }
        let key = product.inAppPurchaseId
        KeychainWrapper.standard.set(true, forKey: key)
    }

    func isUnlocked(_ product: InAppPurchase) -> Bool {
        guard !product.isConsumableTip else {
            return false
        }
        let key = product.inAppPurchaseId
        return KeychainWrapper.standard.bool(forKey: key) ?? false
    }
}

class InMemoryProductLocker: ProductLocker {

    init(allProductsAreUnlocked: Bool = true) {
        self.allProductsAreUnlocked = allProductsAreUnlocked
    }

    let allProductsAreUnlocked: Bool
    private var unlockedProducts = Set<String>()

    func unlock(_ product: InAppPurchase) {
        guard !product.isConsumableTip else {
            return
        }
        unlockedProducts.insert(product.inAppPurchaseId)
    }

    func isUnlocked(_ product: InAppPurchase) -> Bool {
        let isConsumable = product.isConsumableTip
        let isUnlocked = unlockedProducts.contains(product.inAppPurchaseId)
        return !isConsumable && (allProductsAreUnlocked || isUnlocked)
    }
}
