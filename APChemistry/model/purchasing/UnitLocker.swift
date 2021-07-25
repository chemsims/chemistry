//
// Reactions App
//

import Foundation
import SwiftKeychainWrapper

fileprivate let freeUnits: [Unit] = [.reactionRates]

protocol UnitLocker {
    func unlock(_ unit: Unit)
    func isUnlocked(_ unit: Unit) -> Bool
}

class KeychainUnitLocker: UnitLocker {
    func unlock(_ unit: Unit) {
        let key = unit.id
        KeychainWrapper.standard.set(true, forKey: key)
    }

    func isUnlocked(_ unit: Unit) -> Bool {
        if freeUnits.contains(unit) {
            return true
        }
        let key = unit.id
        return KeychainWrapper.standard.bool(forKey: key) ?? false
    }
}

class InMemoryUnitLocker: UnitLocker {

    init(allUnitsAreUnlocked: Bool = true) {
        self.allUnitsAreUnlocked = allUnitsAreUnlocked
    }

    let allUnitsAreUnlocked: Bool
    private var unlockedUnits = Set<String>()

    func unlock(_ unit: Unit) {
        unlockedUnits.insert(unit.id)
    }

    func isUnlocked(_ unit: Unit) -> Bool {
        allUnitsAreUnlocked || freeUnits.contains(unit) || unlockedUnits.contains(unit.id)
    }
}
