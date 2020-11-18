//
// Reactions App
//
  

import SwiftUI

class ReactionComparisonNavigationViewModel: ReactionNavigationViewModel {

    init(reactionViewModel: ZeroOrderReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialState(),
                RunAnimation(statement: ReactionComparisonStatements.inProgress),
                EndAnimation(statement: ReactionComparisonStatements.end)
            ]
        )
    }

    static let c1: CGFloat = 1
    static let c2: CGFloat = 0.1
    static let time: CGFloat = 15

}



fileprivate struct InitialState: ReactionState {

    var statement: [SpeechBubbleLine] = ReactionComparisonStatements.intro

    func apply(on model: ZeroOrderReactionViewModel) {
        model.initialConcentration = ReactionComparisonNavigationViewModel.c1
        model.finalConcentration = ReactionComparisonNavigationViewModel.c2
        model.initialTime = 0
        model.finalTime = ReactionComparisonNavigationViewModel.time
        model.currentTime = nil
    }

    func unapply(on model: ZeroOrderReactionViewModel) {

    }

    func reapply(on model: ZeroOrderReactionViewModel) {

    }


}
