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

        let zeroInput = persistence.get(order: .Zero)
        let firstInput = persistence.get(order: .First)
        let secondInput = persistence.get(order: .Second)

        pages = [
            AnyView(CompletedReactionScreen(enabled: zeroInput != nil) { zeroOrderScreen }),
            AnyView(CompletedReactionScreen(enabled: firstInput != nil) { firstOrderScreen }),
            AnyView(CompletedReactionScreen(enabled: secondInput != nil) { secondOrderScreen })
        ]
        currentPage = initialOrder.page

        setFinalState(viewModel: zeroOrderViewModel, order: .Zero, input: zeroInput, next: firstInput == nil ? nil : .First)
        setFinalState(viewModel: firstOrderViewModel, order: .First, input: firstInput, next: secondInput == nil ? nil : .Second)
        setFinalState(viewModel: secondOrderViewModel, order: .Second, input: secondInput, next: nil)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let pages: [AnyView]
    @Published var currentPage: Int

    private func setFinalState(
        viewModel: ZeroOrderReactionViewModel,
        order: ReactionOrder,
        input: ReactionInput?,
        next: ReactionOrder?
    ) {
        if let input = input {
            viewModel.initialConcentration = input.c1
            viewModel.finalConcentration = input.c2
            viewModel.initialTime = input.t1
            viewModel.finalTime = input.t2
            viewModel.currentTime = viewModel.finalTime
            viewModel.reactionHasStarted = true
            viewModel.reactionHasEnded = true

            viewModel.statement = ReactionFilingStatements.message(order: order, next: next)
        } else {
            viewModel.statement = ReactionFilingStatements.blankMessage
        }
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

    var next: ReactionOrder? {
        switch (self) {
        case .Zero: return .First
        case .First: return .Second
        case .Second: return nil
        }
    }
}
