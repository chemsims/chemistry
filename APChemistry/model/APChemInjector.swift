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

    var sharePrompter: SharePrompter { get }

    var appLaunchPersistence: AppLaunchPersistence { get }

    var onboardingPersistence: OnboardingPersistence { get set }

    var namePersistence: NamePersistence { get }
}

class ProductionAPChemInjector: APChemInjector {

    init() {
        let appLaunch = UserDefaultsAppLaunchPersistence()
        let sharePrompter = SharePrompter(
            persistence: UserDefaultsSharePromptPersistence(),
            appLaunches: appLaunch
        )

        self.sharePrompter = sharePrompter
        self.appLaunchPersistence = appLaunch
        self.reactionRatesInjector = .production(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch
        )
        self.equilibriumInjector = .production(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch
        )
    }

    let storeManager: StoreManager = StoreManager(
        locker: KeychainProductLocker(),
        productLoader: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector>

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector>

    let lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: "apchem")
        )

    let tipOverlayPersistence: TipOverlayPersistence = UserDefaultsTipOverlayPersistence()

    let sharePrompter: SharePrompter

    let appLaunchPersistence: AppLaunchPersistence

    var onboardingPersistence: OnboardingPersistence = UserDefaultsOnboardingPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

class DebugAPChemInjector: APChemInjector {

    init() {
        let appLaunch = InMemoryAppLaunchPersistence()
        let sharePrompter = SharePrompter(
            persistence: InMemorySharePromptPersistence(),
            appLaunches: appLaunch
        )

        self.sharePrompter = sharePrompter
        self.appLaunchPersistence = appLaunch
        self.reactionRatesInjector = .inMemory(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch
        )
        self.equilibriumInjector = .inMemory(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch
        )
    }

    let storeManager: StoreManager = StoreManager(
        locker: InMemoryProductLocker(allProductsAreUnlocked: false),
        productLoader: DebugProductLoader(loadDelay: 2),
        storeObserver: DebugStoreObserver(actionDelay: 2)
    )

    // A store manager which uses the real store kit, but stores the
    // unlock in memory
//    let storeManager: StoreManager = StoreManager(
//        locker: InMemoryProductLocker(allProductsAreUnlocked: false),
//        productLoader: ConcreteProductLoader(),
//        storeObserver: ConcreteStoreObserver.shared
//    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesInjector>

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector>

    var lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(InMemoryScreenPersistence())

    let tipOverlayPersistence: TipOverlayPersistence = InMemoryTipOverlayPersistence()

    let sharePrompter: SharePrompter

    let appLaunchPersistence: AppLaunchPersistence

    var onboardingPersistence: OnboardingPersistence = InMemoryOnboardingPersistence()

    let namePersistence: NamePersistence = InMemoryNamePersistence()
}
