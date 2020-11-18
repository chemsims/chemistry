//
// Reactions App
//
  

import SwiftUI

class FirstOrderReactionNavigationViewModel: ReactionNavigationViewModel {
    init(reactionViewModel: ZeroOrderReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialOrderedStep(order: "first"),
                SetFinalConcentrationToNonNil(),
                RunAnimation(statement: ReactionStatements.inProgress),
                EndAnimation(statement: ReactionStatements.end)
            ]
        )
    }
}
