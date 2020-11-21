//
// Reactions App
//
  

import Foundation

struct SecondOrderReactionNavigation {
    static var states: [ReactionState] {
        [
            InitialOrderedStep(order: "second"),
            SetFinalConcentrationToNonNil(),
            RunAnimation(statement: ReactionStatements.inProgress),
            EndAnimation(statement: ReactionStatements.end)
        ]
    }

    static func model(reaction: SecondOrderReactionViewModel) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}
