//
// Reactions App
//

import SwiftUI
import ReactionsCore
import ReactionRates
import AcidsBases
import Equilibrium
import ChemicalReactions

class APChemRootNavigationModel: ObservableObject {

    @Published var view: AnyView
    @Published var activeSheet: ActiveSheet? = nil
    @Published var showOnboarding = false

    init(injector: APChemInjector, tipOverlayModel: TipOverlayViewModel) {
        self.injector = injector
        self.tipOverlayModel = tipOverlayModel
        self.view = AnyView(EmptyView())

        let firstUnit: Unit
        if let lastOpened = injector.lastOpenedUnitPersistence.lastOpened(),
           Unit.available.contains(lastOpened) {
            firstUnit = lastOpened
        } else {
            firstUnit = .reactionRates
        }

        self.selectedUnit = firstUnit

        let firstProvider = getScreenProvider(forUnit: firstUnit)
        providers[firstUnit] = firstProvider

        self.view = firstProvider.screen

        if !injector.onboardingPersistence.hasCompletedOnboarding {
            doShowOnboarding()
        }
        setAllProviders()
    }

    private var injector: APChemInjector
    private let tipOverlayModel: TipOverlayViewModel
    private var selectedUnit: Unit
    private var providers = [Unit : ScreenProvider]()

    private(set) var onboardingModel: OnboardingViewModel?

    func goTo(unit: Unit) {
        defer { activeSheet = nil }
        guard selectedUnit != unit else {
            return
        }

        if let existingProvider = providers[unit] {
            self.view = existingProvider.screen
        } else {
            let provider = getScreenProvider(forUnit: unit)
            providers[unit] = provider
            self.view = provider.screen
        }

        injector.lastOpenedUnitPersistence.setLastOpened(unit)
        self.selectedUnit = unit

        if tipOverlayModel.shouldShowTipOverlay() {
            tipOverlayModel.show()
        }
    }

    private func setAllProviders() {
        Unit.available.forEach { unit in
            if providers[unit] == nil {
                providers[unit] = getScreenProvider(forUnit: unit)
            }
        }
    }

    private func getScreenProvider(forUnit unit: Unit) -> ScreenProvider {
        switch unit {
        case .reactionRates:
            return ReactionRatesScreenProvider(
                injector: injector,
                showUnitSelection: showUnitSelectionBinding,
                showAboutPage: showAboutPageBinding
            )

        case .equilibrium:
            return EquilibriumScreenProvider(
                injector: injector,
                showUnitSelection: showUnitSelectionBinding,
                showAboutPage: showAboutPageBinding
            )
        case .acidsBases:
            return AcidsBasesScreenProvider(
                injector: injector,
                showUnitSelection: showUnitSelectionBinding,
                showAboutPage: showAboutPageBinding
            )

        case .chemicalReactions:
            return ChemicalReactionsScreenProvider(
                injector: injector,
                showUnitSelection: showUnitSelectionBinding,
                showAboutPage: showAboutPageBinding
            )
        }
    }

    private var showUnitSelectionBinding: Binding<Bool> {
        showSheetBinding(.unitSelection)
    }

    private var showAboutPageBinding: Binding<Bool> {
        showSheetBinding(.about)
    }

    private func showSheetBinding(_ sheet: ActiveSheet) -> Binding<Bool> {
        Binding(
            get: { self.activeSheet == sheet },
            set: {
                self.activeSheet = $0 ? sheet : nil
            }
        )
    }
}

// MARK: - Branch menu items
extension APChemRootNavigationModel {

    var categories: [BranchMenu.Category] {
        [reactionRatesCategory, equilibriumCategory, acidBasesCategory, chemicalReactionsCategory].compactMap(identity)
    }

    private var reactionRatesCategory: BranchMenu.Category? {
        guard let provider = providers[.reactionRates] as? ReactionRatesScreenProvider else {
            return nil
        }
        let category = BranchMenu.Category(
            name: "Reaction rates",
            items: [
                provider.model.categoryItem(screen: .zeroOrderReaction, name: "Zero order reaction"),
                provider.model.categoryItem(screen: .firstOrderReaction, name: "First order reaction"),
                provider.model.categoryItem(screen: .secondOrderReaction, name: "Second order reaction"),
                provider.model.categoryItem(screen: .reactionComparison, name: "Reaction comparison"),
                provider.model.categoryItem(screen: .energyProfile, name: "Energy profile"),
            ]
        ).appendingAction({ self.goTo(unit: .reactionRates) })

        if selectedUnit != .reactionRates {
            return category.deselectAllItems()
        }
        return category
    }

    private var equilibriumCategory: BranchMenu.Category? {
        guard let provider = providers[.equilibrium] as? EquilibriumScreenProvider else {
            return nil
        }
        let category = BranchMenu.Category(
            name: "Equilibrium",
            items: [
                provider.model.categoryItem(screen: .aqueousReaction, name: "Aqueous reaction"),
                provider.model.categoryItem(screen: .gaseousReaction, name: "Gaseous reaction"),
                provider.model.categoryItem(screen: .solubility, name: "Solubility")
            ]
        ).appendingAction({ self.goTo(unit: .equilibrium) })

        if selectedUnit != .equilibrium {
            return category.deselectAllItems()
        }
        return category
    }

    private var acidBasesCategory: BranchMenu.Category? {
        guard let provider = providers[.acidsBases] as? AcidsBasesScreenProvider else {
            return nil
        }
        let category = BranchMenu.Category(
            name: "Acids & bases",
            items: [
                provider.model.categoryItem(screen: .introduction, name: "Introduction"),
                provider.model.categoryItem(screen: .buffer, name: "Buffers"),
                provider.model.categoryItem(screen: .titration, name: "Titration")
            ]
        ).appendingAction({ self.goTo(unit: .acidsBases) })

        if selectedUnit != .acidsBases {
            return category.deselectAllItems()
        }
        return category
    }

    private var chemicalReactionsCategory: BranchMenu.Category? {
        guard let provider = providers[.chemicalReactions] as? ChemicalReactionsScreenProvider else {
            return nil
        }
        let category = BranchMenu.Category(
            name: "Chemical reactions",
            items: [
                provider.model.categoryItem(screen: .balancedReactions, name: "Balanced reactions"),
                provider.model.categoryItem(screen: .limitingReagent, name: "Limiting reagent"),
                provider.model.categoryItem(screen: .precipitation, name: "Precipitation")
            ]
        ).appendingAction({ self.goTo(unit: .chemicalReactions) })

        if selectedUnit != .chemicalReactions {
            return category.deselectAllItems()
        }
        return category
    }
}

extension APChemRootNavigationModel {
    private func doShowOnboarding() {
        showOnboarding = true
        onboardingModel = OnboardingViewModel(
            namePersistence: injector.namePersistence,
            analytics: injector.analytics
        )

        onboardingModel?.navigation?.nextScreen = { [weak self] in
            withAnimation() {
                self?.showOnboarding = false
                self?.onboardingModel?.saveName() // always save name in case it was not committed
                self?.injector.onboardingPersistence.hasCompletedOnboarding = true
            }
        }
    }
}

extension APChemRootNavigationModel {
    enum ActiveSheet: Int, Identifiable {
        case unitSelection, about, share

        var id: Int {
            rawValue
        }
    }
}

protocol NavScreenProvider: ScreenProvider {

    associatedtype Injector: NavigationInjector

    var model: RootNavigationViewModel<Injector> { get }
}

private class ReactionRatesScreenProvider: ScreenProvider {

    init(
        injector: APChemInjector,
        showUnitSelection: Binding<Bool>,
        showAboutPage: Binding<Bool>
    ) {
        self.model = injector.reactionRatesInjector
        self.showUnitSelection = showUnitSelection
        self.showAboutPage = showAboutPage
    }

    let model: RootNavigationViewModel<ReactionRatesNavInjector>
    private let showUnitSelection: Binding<Bool>
    private let showAboutPage: Binding<Bool>

    var screen: AnyView {
        AnyView(
            ReactionsRateRootView(
                model: model,
                unitSelectionIsShowing: showUnitSelection,
                aboutPageIsShowing: showAboutPage
            )
        )
    }
}

private class EquilibriumScreenProvider: ScreenProvider {
    init(
        injector: APChemInjector,
        showUnitSelection: Binding<Bool>,
        showAboutPage: Binding<Bool>
    ) {
        self.model = injector.equilibriumInjector
        self.showUnitSelection = showUnitSelection
        self.showAboutPage = showAboutPage
    }

    let model: RootNavigationViewModel<EquilibriumNavInjector>
    private let showUnitSelection: Binding<Bool>
    private let showAboutPage: Binding<Bool>

    var screen: AnyView {
        AnyView(
            ReactionEquilibriumRootView(
                model: model,
                unitSelectionIsShowing: showUnitSelection,
                aboutPageIsShowing: showAboutPage
            )
        )
    }
}

private class AcidsBasesScreenProvider: ScreenProvider {
    init(
        injector: APChemInjector,
        showUnitSelection: Binding<Bool>,
        showAboutPage: Binding<Bool>
    ) {
        self.model = injector.acidsBasesInjector
        self.showUnitSelection = showUnitSelection
        self.showAboutPage = showAboutPage
    }

    let model: RootNavigationViewModel<AcidAppNavInjector>
    private let showUnitSelection: Binding<Bool>
    private let showAboutPage: Binding<Bool>

    var screen: AnyView {
        AnyView(
            AcidAppRootView(
                model: model,
                unitSelectionIsShowing: showUnitSelection,
                aboutPageIsShowing: showAboutPage
            )
        )
    }
}

private class ChemicalReactionsScreenProvider: ScreenProvider {

    init(
        injector: APChemInjector,
        showUnitSelection: Binding<Bool>,
        showAboutPage: Binding<Bool>
    ) {
        self.model = injector.chemicalReactionsInjector
        self.showUnitSelection = showUnitSelection
        self.showAboutPage = showAboutPage
    }

    let model: RootNavigationViewModel<ChemicalReactionsAppNavInjector>
    private let showUnitSelection: Binding<Bool>
    private let showAboutPage: Binding<Bool>

    var screen: AnyView {
        AnyView(
            ChemicalReactionsRootView(
                model: model,
                unitSelectionIsShowing: showUnitSelection,
                aboutPageIsShowing: showAboutPage
            )
        )
    }
}
