//
// Reactions App
//

import Foundation
import ReactionRates
import Equilibrium
import ReactionsCore

protocol APChemInjector {

    /// Returns an instance responsible for purchasing/restoring units.
    /// This should be a single instance shared across the injector.
    var storeManager: StoreManager { get }

    var reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> { get }

    var equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> { get }
}

class ProductionAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: KeychainUnitLocker(),
        products: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> = .production

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> = .production
}

class DebugAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: InMemoryUnitLocker(allUnitsAreUnlocked: false),
        products: DebugProductLoader(),
        storeObserver: DebugStoreObserver()
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> = .inMemory

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> = .inMemory
}
