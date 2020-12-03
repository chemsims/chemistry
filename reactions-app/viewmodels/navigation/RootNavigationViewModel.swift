//
// Reactions App
//
  

import SwiftUI

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView

    private let persistence: ReactionInputPersistence

    init(
        persistence: ReactionInputPersistence
    ) {
        self.view = AnyView(EmptyView())
        self.persistence = persistence
        goToEnergyProfile()
    }

    private func goToZeroOrder() {
        let reaction = ZeroOrderReactionViewModel()
        let navigation = ZeroOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.view = AnyView(ZeroOrderReaction(reaction: reaction, navigation: navigation))
        navigation.nextScreen = goToFirstOrder
    }

    private func goToFirstOrder() {
        let reaction = FirstOrderReactionViewModel()
        let navigation = FirstOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        navigation.prevScreen = goToZeroOrder
        navigation.nextScreen = goToSecondOrder
        self.view = AnyView(FirstOrderReactionView(reaction: reaction, navigation: navigation))
    }

    private func goToSecondOrder() {
        let reaction = SecondOrderReactionViewModel()
        let navigation = SecondOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        navigation.prevScreen = goToFirstOrder
        navigation.nextScreen = goToComparison
        self.view = AnyView(SecondOrderReactionView(reaction: reaction, navigation: navigation))
    }

    private func goToComparison() {
        let reaction = ZeroOrderReactionViewModel()
        let navigation = ReactionComparisonNavigation.model(reaction: reaction)
        navigation.prevScreen = goToSecondOrder
        navigation.nextScreen = goToComparison2
        self.view = AnyView(ReactionComparisonScreen(reaction: reaction, navigation: navigation))
    }

    private func goToComparison2() {
        let reaction = ReactionComparisonViewModel(persistence: persistence)
        let navigation = ReactionComparisonNavigation2.model(reaction: reaction)
        navigation.prevScreen = goToComparison
        navigation.nextScreen = goToEnergyProfile
        self.view = AnyView(ReactionComparisonScreen2(reaction: reaction, navigation: navigation))
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
