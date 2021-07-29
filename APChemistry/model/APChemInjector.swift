//
// Reactions App
//

import Foundation
import ReactionRates
import Equilibrium
import AcidsBases
import ReactionsCore

protocol APChemInjector {

    /// Returns an instance responsible for purchasing/restoring units.
    /// This should be a single instance shared across the injector.
    var storeManager: StoreManager { get }

    var reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> { get }

    var equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> { get }

    var acidsBasesInjector: RootNavigationViewModel<AcidAppNavInjector> { get }

    var lastOpenedUnitPersistence: AnyScreenPersistence<Unit> { get }

    var onboardingPersistence: OnboardingPersistence { get set }

    var namePersistence: NamePersistence { get }
}

class ProductionAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: KeychainUnitLocker(),
        products: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> = .production

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> = .production

    let acidsBasesInjector: RootNavigationViewModel<AcidAppNavInjector> = .production

    let lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: "apchem")
        )

    var onboardingPersistence: OnboardingPersistence = UserDefaultsOnboardingPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

class DebugAPChemInjector: APChemInjector {
    let storeManager: StoreManager = StoreManager(
        locker: InMemoryUnitLocker(allUnitsAreUnlocked: false),
        products: DebugProductLoader(loadDelay: 1),
        storeObserver: DebugStoreObserver(actionDelay: 1)
    )

    // A store manager which uses the real store kit, but stores the
    // unlock in memory
//    let storeManager: StoreManager = StoreManager(
//        locker: InMemoryUnitLocker(allUnitsAreUnlocked: false),
//        products: ConcreteProductLoader(),
//        storeObserver: ConcreteStoreObserver.shared
//    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector> = .inMemory

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> = .inMemory

    let acidsBasesInjector: RootNavigationViewModel<AcidAppNavInjector> = .inMemory

    let lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(InMemoryScreenPersistence())

    var onboardingPersistence: OnboardingPersistence = InMemoryOnboardingPersistence()

    let namePersistence: NamePersistence = InMemoryNamePersistence.shared
}
