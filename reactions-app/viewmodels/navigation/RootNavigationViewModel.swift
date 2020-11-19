//
// Reactions App
//
  

import SwiftUI

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView

    init() {
        self.view = AnyView(EmptyView())
        goToFirstOrder()
    }

    private func goToZeroOrder() {
        let reaction = ZeroOrderReactionViewModel()
        let navigation = ZeroOrderUserFlowViewModel(reactionViewModel: reaction)
        self.view = AnyView(ZeroOrderReaction(beakyModel: navigation))
        navigation.nextScreen = goToFirstOrder
    }

    private func goToFirstOrder() {
        let reaction = FirstOrderReactionViewModel()
        let navigation = FirstOrderReactionNavigationViewModel(reactionViewModel: reaction)
        navigation.prevScreen = goToZeroOrder
        navigation.nextScreen = goToSecondOrder
        self.view = AnyView(FirstOrderReactionView(reaction: reaction, flow: navigation))
    }

    private func goToSecondOrder() {
        let reaction = SecondOrderReactionViewModel()
        let navigation = SecondOrderReactionNavigationViewModel(reactionViewModel: reaction)
        navigation.prevScreen = goToFirstOrder
        navigation.nextScreen = goToComparison
        self.view = AnyView(SecondOrderReactionView(reaction: reaction, navigation: navigation))
    }

    private func goToComparison() {
        let reaction = ZeroOrderReactionViewModel()
        let navigation = ReactionComparisonNavigationViewModel(reactionViewModel: reaction)
        navigation.prevScreen = goToSecondOrder
        self.view = AnyView(ReactionComparison(reaction: reaction, navigation: navigation))
    }


}

enum AppScreen {
    case zeroOrder
    case firstOrder
    case secondOrder
    case comparison
}
