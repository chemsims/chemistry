//
// Reactions App
//

import Foundation

protocol APChemInjector {

    /// Returns an instance responsible for purchasing/restoring units.
    /// This should be a single instance shared across the injector.
    var storeManager: StoreManager { get }
}

class ProductionAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: KeychainUnitLocker(),
        products: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )
}

class DebugAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: InMemoryUnitLocker(allUnitsAreUnlocked: false),
        products: DebugProductLoader(),
        storeObserver: DebugStoreObserver()
    )
}
