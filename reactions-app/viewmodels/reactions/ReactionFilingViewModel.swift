//
// Reactions App
//
  

import SwiftUI

class ReactionFilingViewModel: ObservableObject {

    let persistence: ReactionInputPersistence
    let order: ReactionOrder
    @Published var currentPage = 0

    init(
        persistence: ReactionInputPersistence,
        order: ReactionOrder
    ) {
        self.persistence = persistence
        self.order = order
    }

    func makeView(
        reactionType: ReactionType
    ) -> AnyView {
        switch (order) {
        case .Zero:
            let model = ZeroOrderReactionViewModel()
            model.navigation = navigation(model: model, reactionType: reactionType)
            return AnyView(
                ZeroOrderReactionScreen(reaction: model)
            )
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

    func enabled(reactionType: ReactionType) -> Bool {
        persistence.get(order: order, reaction: reactionType) != nil
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

    private func next() {
        if (currentPage < 2) {
            currentPage += 1
        }
    }

    private func prev() {
        if (currentPage > 0) {
            currentPage -= 1
        }
    }

    private var statement: String {
        ReactionFilingStatements.pageNotEnabledMessage(order: order)
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
        model.usedReactions = [reactionType]
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

