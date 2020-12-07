//
// Reactions App
//
  

import Foundation

struct SecondOrderReactionNavigation {

    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(statement: SecondOrderStatements.intro),
            SetFinalConcentrationToNonNil(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .Second,
                persistence: persistence,
                initialiseCurrentTime: true
            ),
            EndAnimation(
                statement: SecondOrderStatements.end,
                highlightChart: false
            )
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
