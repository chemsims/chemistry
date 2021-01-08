//
// Reactions App
//
  

import SwiftUI

class ReactionFilingViewModel: ObservableObject {

    private(set) var pages: [CompletedReactionScreen<AnyView>]
    @Published var currentPage: Int

    init(
        persistence: ReactionInputPersistence,
        order: ReactionOrder
    ) {
        self.currentPage = 0
        self.pages = []

        func makeScreen(reactionType: ReactionType) -> AnyView {
            switch (order) {
            case .Zero:
                let model = ZeroOrderReactionViewModel()
                model.navigation = navigation(model: model, reactionType: reactionType)
                return AnyView(ZeroOrderReactionScreen(reaction: model))
            case .First:
                let model = FirstOrderReactionViewModel()
                model.navigation = navigation(model: model, reactionType: reactionType)
                return AnyView(FirstOrderReactionScreen(reaction: model))
            case .Second:
                let model = SecondOrderReactionViewModel()
                model.navigation = navigation(model: model, reactionType: reactionType)
                return AnyView(SecondOrderReactionScreen(reaction: model))
            }
        }

        func navigation(
            model: ZeroOrderReactionViewModel,
            reactionType: ReactionType
        ) -> NavigationViewModel<ReactionState> {
            let input = persistence.get(order: order, reaction: reactionType)
            let state: ReactionState =
                ReactionFilingState(
                    order: order,
                    reactionType: reactionType,
                    input: input
                )
            let nav = NavigationViewModel(
                model: model,
                rootNode: ScreenStateTreeNode<ReactionState>.build(states: [state])!
            )
            nav.prevScreen = prev
            nav.nextScreen = next
            return nav
        }

        let inputA = persistence.get(order: order, reaction: .A)
        let inputB = persistence.get(order: order, reaction: .B)
        let inputC = persistence.get(order: order, reaction: .C)

        let statement = ReactionFilingStatements.pageNotEnabledMessage(order: order)
        pages = [
            CompletedReactionScreen(enabled: inputA != nil, disabledStatement: statement) { makeScreen(reactionType: .A) },
            CompletedReactionScreen(enabled: inputB != nil, disabledStatement: statement) { makeScreen(reactionType: .B) },
            CompletedReactionScreen(enabled: inputC != nil, disabledStatement: statement) { makeScreen(reactionType: .C) }
        ]
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
}

fileprivate class ReactionFilingState: ReactionState {

    init(
        order: ReactionOrder,
        reactionType: ReactionType,
        input: ReactionInput?
    ) {
        self.order = order
        self.reactionType = reactionType
        self.input = input
    }

    let order: ReactionOrder
    let reactionType: ReactionType
    let input: ReactionInput?

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.input = ReactionInputAllProperties(order: order)
        if let input = input {
            model.input.inputC1 = input.c1
            model.input.inputC2 = input.c2
            model.input.inputT1 = input.t1
            model.input.inputT2 = input.t2
            model.currentTime = model.input.inputT2
            model.reactionHasStarted = true
            model.reactionHasEnded = true
            model.statement = ReactionFilingStatements.message(order: order, reactionType: reactionType)
        } else {
            model.statement = ReactionFilingStatements.blankMessage
        }
    }
}

