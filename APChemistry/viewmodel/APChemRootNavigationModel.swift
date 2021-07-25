//
// Reactions App
//

import SwiftUI
import ReactionsCore
import ReactionRates
import Equilibrium

class APChemRootNavigationModel: ObservableObject {

    @Published var view: AnyView
    @Published var showUnitSelection = false

    init(injector: APChemInjector) {
        self.injector = injector
        self.view = AnyView(EmptyView())
        let firstScreen = Unit.reactionRates
        let firstProvider = getScreenProvider(forUnit: firstScreen)
        providers[firstScreen] = firstProvider
        self.view = firstProvider.screen
    }

    private let injector: APChemInjector
    private var selectedUnit = Unit.reactionRates
    private var providers = [Unit : ScreenProvider]()

    func goTo(unit: Unit) {
        defer { showUnitSelection = false }
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

        self.selectedUnit = unit
    }

    private func getScreenProvider(forUnit unit: Unit) -> ScreenProvider {
        switch unit {
        case .reactionRates:
            return ReactionRatesScreenProvider(
                injector: injector,
                showUnitSelection: showUnitSelectionBinding
            )

        case .equilibrium:
            return EquilibriumScreenProvider(
                injector: injector,
                showUnitSelection: showUnitSelectionBinding
            )
        }
    }

    private var showUnitSelectionBinding: Binding<Bool> {
        Binding(
            get: { self.showUnitSelection },
            set: { self.showUnitSelection = $0 }
        )
    }
}

private class ReactionRatesScreenProvider: ScreenProvider {

    init(
        injector: APChemInjector,
        showUnitSelection: Binding<Bool>
    ) {
        self.model = injector.reactionRatesInjector
        self.showUnitSelection = showUnitSelection
    }

    private let model: RootNavigationViewModel<ReactionRatesInjector>
    private let showUnitSelection: Binding<Bool>

    var screen: AnyView {
        AnyView(
            ReactionsRateRootView(
                model: model,
                unitSelectionIsShowing: showUnitSelection
            )
        )
    }
}

private class EquilibriumScreenProvider: ScreenProvider {
    init(
        injector: APChemInjector,
        showUnitSelection: Binding<Bool>
    ) {
        self.model = injector.equilibriumInjector
        self.showUnitSelection = showUnitSelection
    }

    private let model: RootNavigationViewModel<EquilibriumNavInjector>
    private let showUnitSelection: Binding<Bool>

    var screen: AnyView {
        AnyView(
            ReactionEquilibriumRootView(
                model: model,
                unitSelectionIsShowing: showUnitSelection
            )
        )
    }
}
