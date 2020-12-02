//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionNavigation {
    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(order: "first"),
            SetFinalConcentrationToNonNil(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .First,
                persistence: persistence
            ),
            EndAnimation(statement: ReactionStatements.end)
        ]
    }

    static func model(
        reaction: FirstOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states(persistence: persistence)
        )
    }
}
