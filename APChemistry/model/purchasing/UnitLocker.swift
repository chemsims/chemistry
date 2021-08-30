//
// Reactions App
//

import Foundation
import SwiftKeychainWrapper

protocol ProductLocker {
    func unlock(_ unit: NonConsumableProduct)
    func isUnlocked(_ unit: NonConsumableProduct) -> Bool
}

class KeychainUnitLocker: ProductLocker {
    func unlock(_ unit: NonConsumableProduct) {
        let key = unit.inAppPurchaseId
        KeychainWrapper.standard.set(true, forKey: key)
    }

    func isUnlocked(_ unit: NonConsumableProduct) -> Bool {
        let key = unit.inAppPurchaseId
        return KeychainWrapper.standard.bool(forKey: key) ?? false
    }
}

class InMemoryUnitLocker: ProductLocker {

    init(allUnitsAreUnlocked: Bool = true) {
        self.allUnitsAreUnlocked = allUnitsAreUnlocked
    }

    let allUnitsAreUnlocked: Bool
    private var unlockedUnits = Set<String>()

    func unlock(_ unit: NonConsumableProduct) {
        unlockedUnits.insert(unit.inAppPurchaseId)
    }

    func isUnlocked(_ unit: NonConsumableProduct) -> Bool {
        allUnitsAreUnlocked || unlockedUnits.contains(unit.inAppPurchaseId)
    }
}
