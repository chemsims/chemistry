//
// Reactions App
//
  

import Foundation

class ZeroOrderUserFlowViewModel: ReactionNavigationViewModel {
    init(reactionViewModel: ZeroOrderReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialStep(),
                SetFinalValuesToNonNil(),
                RunAnimation(),
                EndAnimation(),
            ]
        )
    }
}

fileprivate struct InitialStep: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.initial

    func apply(on model: ZeroOrderReactionViewModel) { }

    func unapply(on model: ZeroOrderReactionViewModel) { }

    func reapply(on model: ZeroOrderReactionViewModel) { }
}

fileprivate struct SetFinalValuesToNonNil: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.setFinalValues

    func apply(on model: ZeroOrderReactionViewModel) {
        let initialConcentration = model.initialConcentration
        let minConcentration = ReactionSettings.minConcentration

        let initialTime = model.initialTime
        let maxTime = ReactionSettings.maxTime

        model.finalConcentration = (initialConcentration + minConcentration) / 2
        model.finalTime = (initialTime + maxTime) / 2
    }

    func reapply(on model: ZeroOrderReactionViewModel) { }

    func unapply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = nil
        model.finalTime = nil
    }
}
