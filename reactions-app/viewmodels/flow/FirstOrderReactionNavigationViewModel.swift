//
// Reactions App
//
  

import SwiftUI

class FirstOrderReactionNavigationViewModel: ReactionNavigationViewModel {
    init(reactionViewModel: ZeroOrderReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialStep(),
                SetFinalConcentrationToNonNil(),
                RunAnimation(),
                EndAnimation()
            ]
        )
    }
}

fileprivate struct InitialStep: ReactionState {

    var statement: [SpeechBubbleLine] = FirstOrderStatements.intro


    func apply(on model: ZeroOrderReactionViewModel) {
        model.initialTime = 0
        model.finalTime = 10
    }

    func unapply(on model: ZeroOrderReactionViewModel) {

    }

    func reapply(on model: ZeroOrderReactionViewModel) {

    }
}

fileprivate struct SetFinalConcentrationToNonNil: ReactionState {

    var statement: [SpeechBubbleLine] = FirstOrderStatements.setC2

    func apply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = model.initialConcentration / 2
    }

    func unapply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = nil
    }

    func reapply(on model: ZeroOrderReactionViewModel) {

    }
}
