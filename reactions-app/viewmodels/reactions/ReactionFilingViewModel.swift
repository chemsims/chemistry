//
// Reactions App
//
  

import SwiftUI

class ReactionFilingViewModel: ObservableObject {

    init(
        persistence: ReactionInputPersistence,
        initialOrder: ReactionOrder
    ) {
        zeroOrderViewModel = ZeroOrderReactionViewModel()
        firstOrderViewModel = FirstOrderReactionViewModel()
        secondOrderViewModel = SecondOrderReactionViewModel()

        let navigation = NavigationViewModel(reactionViewModel: zeroOrderViewModel, states: [ReactionState]())

        let zeroOrderScreen = ZeroOrderReactionScreen(
            reaction: zeroOrderViewModel,
            navigation: navigation
        )

        let firstOrderScreen = FirstOrderReactionScreen(
            reaction: firstOrderViewModel,
            navigation: navigation
        )

        let secondOrderScreen = SecondOrderReactionScreen(
            reaction: secondOrderViewModel,
            navigation: navigation
        )

        pages = [
            AnyView(CompletedReactionScreen(enabled: true) { zeroOrderScreen }),
            AnyView(CompletedReactionScreen(enabled: true) { firstOrderScreen }),
            AnyView(CompletedReactionScreen(enabled: false) { secondOrderScreen })
        ]
        currentPage = initialOrder.page

        setFinalState(viewModel: zeroOrderViewModel, input: persistence.get(order: .Zero) ?? ReactionComparisonDefaults.input)
        setFinalState(viewModel: firstOrderViewModel, input: persistence.get(order: .First) ?? ReactionComparisonDefaults.input)
        setFinalState(viewModel: secondOrderViewModel, input: persistence.get(order: .Second) ?? ReactionComparisonDefaults.input)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let pages: [AnyView]
    @Published var currentPage: Int

    private func setFinalState(viewModel: ZeroOrderReactionViewModel, input: ReactionInput) {
        viewModel.initialConcentration = input.c1
        viewModel.finalConcentration = input.c2
        viewModel.initialTime = input.t1
        viewModel.finalTime = input.t2
        viewModel.currentTime = viewModel.finalTime
        viewModel.reactionHasStarted = true
        viewModel.reactionHasEnded = true
    }

    private func next() {
        if (currentPage + 1 < pages.count) {
            currentPage += 1
        }
    }

    private func prev() {
        if (currentPage > 0) {
            currentPage -= 1
        }
    }

    let zeroOrderViewModel: ZeroOrderReactionViewModel
    let firstOrderViewModel: FirstOrderReactionViewModel
    let secondOrderViewModel: SecondOrderReactionViewModel

}

fileprivate extension ReactionOrder {
    var page: Int {
        switch (self) {
        case .Zero: return 0
        case .First: return 1
        case .Second: return 2
        }
    }
}
