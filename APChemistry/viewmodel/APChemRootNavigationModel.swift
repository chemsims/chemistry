//
// Reactions App
//

import SwiftUI
import ReactionsCore
import ReactionRates
import Equilibrium

class APChemRootNavigationModel: ObservableObject {

    @Published var view: AnyView
    @Published var activeSheet: ActiveSheet? = nil

    init(injector: APChemInjector, tipOverlayModel: TipOverlayViewModel) {
        self.injector = injector
        self.tipOverlayModel = tipOverlayModel
        self.view = AnyView(EmptyView())
        let firstScreen = injector.lastOpenedUnitPersistence.lastOpened() ?? Unit.reactionRates
        let firstProvider = getScreenProvider(forUnit: firstScreen)
        providers[firstScreen] = firstProvider
        self.view = firstProvider.screen
    }

    private let injector: APChemInjector
    private let tipOverlayModel: TipOverlayViewModel
    private var selectedUnit = Unit.reactionRates
    private var providers = [Unit : ScreenProvider]()

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

extension APChemRootNavigationModel {
    enum ActiveSheet: Int, Identifiable {
        case unitSelection, about

        var id: Int {
            rawValue
        }
    }
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

    private let model: RootNavigationViewModel<ReactionRatesInjector>
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

    private let model: RootNavigationViewModel<EquilibriumNavInjector>
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
