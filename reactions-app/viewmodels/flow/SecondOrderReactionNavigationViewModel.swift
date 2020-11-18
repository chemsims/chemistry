//
// Reactions App
//
  

import Foundation

class SecondOrderReactionNavigationViewModel: ReactionNavigationViewModel {
    init(reactionViewModel: SecondOrderReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialOrderedStep(order: "second"),
                SetFinalConcentrationToNonNil(),
                RunAnimation(),
                EndAnimation()
            ]
        )
    }
}
