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

    private var comparison1ViewModel: ZeroOrderReactionViewModel?
    private var comparison1Navigation: ReactionNavigationViewModel<ReactionState>?

    private var comparison2ViewModel: ReactionComparisonViewModel?
    private var comparison2Navigation: ReactionNavigationViewModel<ReactionState>?


    init(
        persistence: ReactionInputPersistence
    ) {
        self.view = AnyView(EmptyView())
        self.persistence = persistence
        goToNewComparison()
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
        let reaction = comparison1ViewModel ?? ZeroOrderReactionViewModel()
        let navigation = comparison1Navigation ?? ReactionComparisonNavigation.model(reaction: reaction)
        self.comparison1ViewModel = reaction
        self.comparison1Navigation = navigation
        navigation.prevScreen = goToSecondOrder
        navigation.nextScreen = goToComparison2
        self.view = AnyView(ReactionComparisonScreen(reaction: reaction, navigation: navigation))
    }

    private func goToComparison2() {
        let reaction = comparison2ViewModel ?? ReactionComparisonViewModel(persistence: persistence)
        let navigation = comparison2Navigation ?? ReactionComparisonNavigation2.model(reaction: reaction)
        self.comparison2ViewModel = reaction
        self.comparison2Navigation = navigation
        navigation.prevScreen = goToComparison
        navigation.nextScreen = goToNewComparison
        self.view = AnyView(ReactionComparisonScreen2(reaction: reaction, navigation: navigation))
    }

    private func goToNewComparison() {
        let reaction = NewReactionComparisonViewModel()
        let navigation = NewReactionComparisonNavigationViewModel.model(reaction: reaction)
        navigation.prevScreen = goToComparison2
        navigation.nextScreen = goToEnergyProfile
        self.view = AnyView(NewReactionComparisonScreen(navigation: navigation))

    }

    private func goToEnergyProfile() {
        let model = EnergyProfileViewModel()
        model.goToPreviousScreen = goToComparison2
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
