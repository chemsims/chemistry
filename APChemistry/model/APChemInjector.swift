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

    var reactionRatesInjector: RootNavigationViewModel<ReactionRatesNavInjector> { get }

    var equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector> { get }

    var acidsBasesInjector: RootNavigationViewModel<AcidAppNavInjector> { get }

    var lastOpenedUnitPersistence: AnyScreenPersistence<Unit> { get }

    var tipOverlayPersistence: TipOverlayPersistence { get }

    var sharePrompter: SharePrompter { get }

    var appLaunchPersistence: AppLaunchPersistence { get }

    var onboardingPersistence: OnboardingPersistence { get set }

    var namePersistence: NamePersistence { get }

    var analytics: GeneralAppAnalytics { get }
}

class ProductionAPChemInjector: APChemInjector {

    init() {
        let appLaunch = UserDefaultsAppLaunchPersistence()
        let analytics = GoogleAnalytics<DummyQuestionSet, DummyScreen>(
            unitName: "",
            includeUnitInEventNames: false
        )
        let sharePrompter = SharePrompter(
            persistence: UserDefaultsSharePromptPersistence(),
            appLaunches: appLaunch,
            analytics: analytics
        )

        self.sharePrompter = sharePrompter
        self.appLaunchPersistence = appLaunch
        self.analytics = analytics
        self.reactionRatesInjector = .production(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch,
            analytics: analytics
        )
        self.equilibriumInjector = .production(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch,
            analytics: analytics
        )
        self.acidsBasesInjector = .production(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch,
            analytics: analytics
        )
    }

    let storeManager: StoreManager = StoreManager(
        locker: KeychainProductLocker(),
        productLoader: ConcreteProductLoader(),
        storeObserver: ConcreteStoreObserver.shared
    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesNavInjector>

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector>

    let acidsBasesInjector: RootNavigationViewModel<AcidAppNavInjector>

    let lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: "apchem")
        )

    let tipOverlayPersistence: TipOverlayPersistence = UserDefaultsTipOverlayPersistence()

    let sharePrompter: SharePrompter

    let appLaunchPersistence: AppLaunchPersistence

    var onboardingPersistence: OnboardingPersistence = UserDefaultsOnboardingPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()

    let analytics: GeneralAppAnalytics
}

// TODO refactor the common analytics so that it doesn't require dummy types
extension ProductionAPChemInjector {
    enum DummyQuestionSet: String, HasAnalyticsLabel {
        case A

        var analyticsLabel: String {
            rawValue
        }
    }
    enum DummyScreen: String {
        case A
    }
}

class DebugAPChemInjector: APChemInjector {

    init() {
        let appLaunch = InMemoryAppLaunchPersistence()
        let analytics = NoOpGeneralAnalytics()
        let sharePrompter = SharePrompter(
            persistence: InMemorySharePromptPersistence(),
            appLaunches: appLaunch,
            analytics: analytics
        )

        self.sharePrompter = sharePrompter
        self.appLaunchPersistence = appLaunch
        self.analytics = analytics
        self.reactionRatesInjector = .inMemory(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch,
            analytics: analytics
        )
        self.equilibriumInjector = .inMemory(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch,
            analytics: analytics
        )
        self.acidsBasesInjector = .inMemory(
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunch,
            analytics: analytics
        )
    }

    let storeManager: StoreManager = StoreManager(
        locker: InMemoryProductLocker(allProductsAreUnlocked: false),
        productLoader: DebugProductLoader(loadDelay: 5),
        storeObserver: DebugStoreObserver(actionDelay: 2)
    )

    // A store manager which uses the real store kit, but stores the
    // unlock in memory
//    let storeManager: StoreManager = StoreManager(
//        locker: InMemoryProductLocker(allProductsAreUnlocked: false),
//        productLoader: ConcreteProductLoader(),
//        storeObserver: ConcreteStoreObserver.shared
//    )

    let reactionRatesInjector: RootNavigationViewModel<ReactionRatesNavInjector>

    let equilibriumInjector: RootNavigationViewModel<EquilibriumNavInjector>

    let acidsBasesInjector: RootNavigationViewModel<AcidAppNavInjector>

    var lastOpenedUnitPersistence: AnyScreenPersistence<Unit> =
        AnyScreenPersistence(InMemoryScreenPersistence())

    let tipOverlayPersistence: TipOverlayPersistence = InMemoryTipOverlayPersistence()

    let sharePrompter: SharePrompter

    let appLaunchPersistence: AppLaunchPersistence

    var onboardingPersistence: OnboardingPersistence = InMemoryOnboardingPersistence()

    let namePersistence: NamePersistence = InMemoryNamePersistence.shared

    let analytics: GeneralAppAnalytics
}
