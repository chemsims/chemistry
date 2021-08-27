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

    var lastOpenedUnitPersistence: AnyScreenPersistence<Unit> { get }

    var tipOverlayPersistence: TipOverlayPersistence { get }

    var sharePromptPersistence: SharePromptPersistence { get }
}

class ProductionAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: KeychainProductLocker(),
        productLoader: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> = .production

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> = .production

    let lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: "apchem")
        )

    let tipOverlayPersistence: TipOverlayPersistence = UserDefaultsTipOverlayPersistence()

    let sharePromptPersistence: SharePromptPersistence = UserDefaultsSharePromptPersistence()
}

class DebugAPChemInjector: APChemInjector {
//    let storeManager: StoreManager = StoreManager(
//        locker: InMemoryProductLocker(allProductsAreUnlocked: true),
//        productLoader: DebugProductLoader(loadDelay: 5),
//        storeObserver: DebugStoreObserver(actionDelay: 2)
//    )

    // A store manager which uses the real store kit, but stores the
    // unlock in memory
    let storeManager: StoreManager = StoreManager(
        locker: InMemoryProductLocker(allProductsAreUnlocked: false),
        productLoader: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> = .inMemory

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> = .inMemory

    var lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(InMemoryScreenPersistence())

    let tipOverlayPersistence: TipOverlayPersistence = UserDefaultsTipOverlayPersistence()

    let sharePromptPersistence: SharePromptPersistence = UserDefaultsSharePromptPersistence()
}
