//
// Reactions App
//
  

import SwiftUI

protocol ReactionState {

    /// The statement to display to the user
    var statement: [SpeechBubbleLine] { get }

    /// Applies the reaction state to the model
    func apply(on model: ZeroOrderReactionViewModel) -> Void

    /// Unapplies the reaction state to the model. i.e., reversing the effect of `apply`
    func unapply(on model: ZeroOrderReactionViewModel) -> Void

    /// Reapplies the state, when returning from a subsequent state.
    func reapply(on model: ZeroOrderReactionViewModel) -> Void

    /// Interval to wait before automatically progressing to the next state
    func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double?
}

extension ReactionState {
    func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double? {
        return nil
    }
}


// MARK: Common reaction states

struct RunAnimation: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.inProgress

    func apply(on model: ZeroOrderReactionViewModel) {
        model.reactionHasEnded = false
        if let duration = model.reactionDuration, let finalTime = model.finalTime {
            model.currentTime = model.initialTime
            model.moleculeBOpacity = 0
            model.timeChartHeadOpacity = 1
            withAnimation(.linear(duration: Double(duration))) {
                model.currentTime = finalTime
                model.moleculeBOpacity = 1
            }
        }
    }

    func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }

    func unapply(on model: ZeroOrderReactionViewModel) {
        withAnimation(.none) {
            model.currentTime = nil
            model.moleculeBOpacity = 0
        }
    }

    func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double? {
        if let duration = model.reactionDuration {
            return Double(duration)
        }
        return nil
    }

}

struct EndAnimation: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.endStatement

    func apply(on model: ZeroOrderReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            if let finalTime = model.finalTime {
                model.currentTime = finalTime * 1.001
                model.moleculeBOpacity = 1.001
            }
            model.reactionHasEnded = true
            model.timeChartHeadOpacity = 0
        }
    }

    func unapply(on model: ZeroOrderReactionViewModel) {
        model.timeChartHeadOpacity = 1
    }

    func reapply(on model: ZeroOrderReactionViewModel) { }
}

