//
// Reactions App
//
  

import SwiftUI

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView

    private let persistence: ReactionInputPersistence

    private var zeroOrderViewModel: ZeroOrderReactionViewModel?
    private var zeroOrderNavigation: ReactionNavigationViewModel<ReactionState>?

    private var firstOrderViewModel: FirstOrderReactionViewModel?
    private var firstOrderNavigation: ReactionNavigationViewModel<ReactionState>?

    private var secondOrderViewModel: SecondOrderReactionViewModel?
    private var secondOrderNavigation: ReactionNavigationViewModel<ReactionState>?

    private var comparisonViewModel: ReactionComparisonViewModel?
    private var comparisonNavigation: ReactionNavigationViewModel<ReactionComparisonState>?

    init(
        persistence: ReactionInputPersistence
    ) {
        self.view = AnyView(EmptyView())
        self.persistence = persistence
        goToComparison()
    }

    private func goToZeroOrder() {
        let reaction = zeroOrderViewModel ?? ZeroOrderReactionViewModel()
        let navigation = zeroOrderNavigation ?? ZeroOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.zeroOrderViewModel = reaction
        self.zeroOrderNavigation = navigation
        self.view = AnyView(ZeroOrderReactionScreen(reaction: reaction, navigation: navigation))
        navigation.nextScreen = goToFirstOrder
    }

    private func goToFirstOrder() {
        let reaction = firstOrderViewModel ?? FirstOrderReactionViewModel()
        let navigation = firstOrderNavigation ?? FirstOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.firstOrderViewModel = reaction
        self.firstOrderNavigation = navigation
        navigation.prevScreen = goToZeroOrder
        navigation.nextScreen = goToSecondOrder
        self.view = AnyView(FirstOrderReactionScreen(reaction: reaction, navigation: navigation))
    }

    private func goToSecondOrder() {
        let reaction = secondOrderViewModel ?? SecondOrderReactionViewModel()
        let navigation = secondOrderNavigation ?? SecondOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.secondOrderViewModel = reaction
        self.secondOrderNavigation = navigation
        navigation.prevScreen = goToFirstOrder
        navigation.nextScreen = goToComparison
        self.view = AnyView(SecondOrderReactionScreen(reaction: reaction, navigation: navigation))
    }

    private func goToComparison() {
        let reaction = comparisonViewModel ?? ReactionComparisonViewModel(persistence: persistence)
        let navigation = comparisonNavigation ?? ReactionComparisonNavigationViewModel.model(reaction: reaction)
        self.comparisonViewModel = reaction
        self.comparisonNavigation = navigation
        navigation.prevScreen = goToSecondOrder
        navigation.nextScreen = goToEnergyProfile
        self.view = AnyView(ReactionComparisonScreen(navigation: navigation))
    }

    private func goToEnergyProfile() {
        let model = EnergyProfileViewModel()
        model.goToPreviousScreen = goToComparison
        let view = EnergyProfileScreen(model: model)
        self.view = AnyView(view)
    }


}

enum AppScreen {
    case zeroOrder
    case firstOrder
    case secondOrder
    case comparison
}
