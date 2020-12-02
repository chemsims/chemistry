//
// Reactions App
//
  

import SwiftUI

struct ReactionComparisonNavigation {

    static var states: [ReactionState] {
        [
            InitialState(),
            RunAnimation(
                statement: ReactionComparisonStatements.inProgress,
                order: nil,
                persistence: nil
            ),
            EndAnimation(statement: ReactionComparisonStatements.end)
        ]
    }



    static func model(reaction: ZeroOrderReactionViewModel) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}


fileprivate class InitialState: ReactionState {

    init() {
        super.init(statement: ReactionComparisonStatements.intro)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
//        model.initialConcentration = ReactionComparisonNavigation.c1
//        model.finalConcentration = ReactionComparisonNavigation.c2
//        model.initialTime = 0
//        model.finalTime = ReactionComparisonNavigation.time
        model.currentTime = nil
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {

    }

    override func reapply(on model: ZeroOrderReactionViewModel) {

    }
}
