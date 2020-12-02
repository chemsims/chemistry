//
// Reactions App
//
  

import Foundation

struct SecondOrderReactionNavigation {

    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(order: "second"),
            SetFinalConcentrationToNonNil(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .Second,
                persistence: persistence
            ),
            EndAnimation(statement: ReactionStatements.end)
        ]
    }

    static func model(
        reaction: SecondOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states(persistence: persistence)
        )
    }
}
