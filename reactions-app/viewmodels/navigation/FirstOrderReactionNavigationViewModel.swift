//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionNavigation {
    static var states: [ReactionState] {
        [
            InitialOrderedStep(order: "first"),
            SetFinalConcentrationToNonNil(),
            RunAnimation(statement: ReactionStatements.inProgress),
            EndAnimation(statement: ReactionStatements.end)
        ]
    }

    static func model(reaction: FirstOrderReactionViewModel) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}
