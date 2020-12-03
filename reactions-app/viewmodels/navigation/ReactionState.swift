//
// Reactions App
//
  

import SwiftUI

protocol ScreenState {
    associatedtype Model

    /// The statement to display to the user
    var statement: [SpeechBubbleLine] { get }

    /// Applies the reaction state to the model
    func apply(on model: Model) -> Void

    /// Unapplies the reaction state to the model. i.e., reversing the effect of `apply`
    func unapply(on model: Model) -> Void

    /// Reapplies the state, when returning from a subsequent state.
    func reapply(on model: Model) -> Void

    /// Interval to wait before automatically progressing to the next state
    func nextStateAutoDispatchDelay(model: Model) -> Double?
}

class ReactionState: ScreenState {

    typealias Model = ZeroOrderReactionViewModel

    let statement: [SpeechBubbleLine]
    init(statement: [SpeechBubbleLine]) {
        self.statement = statement
    }

    func apply(on model: ZeroOrderReactionViewModel) { }

    func unapply(on model: ZeroOrderReactionViewModel) { }

    func reapply(on model: ZeroOrderReactionViewModel) { }

    func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double? { nil }

}


// MARK: Common reaction states

class RunAnimation: ReactionState {

    let order: ReactionOrder?
    let persistence: ReactionInputPersistence?

    init(
        statement: [SpeechBubbleLine],
        order: ReactionOrder?,
        persistence: ReactionInputPersistence?
    ) {
        self.order = order
        self.persistence = persistence
        super.init(statement: statement)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.reactionHasEnded = false
        if let duration = model.reactionDuration, let finalTime = model.finalTime {
            model.currentTime = model.initialTime
            withAnimation(.linear(duration: Double(duration))) {
                model.currentTime = finalTime
            }
        }

        if let input = model.input, let order = order, let persistence = persistence {
            persistence.save(input: input, order: order)
        }

    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = nil
    }

    override func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double? {
        if let duration = model.reactionDuration {
            return Double(duration)
        }
        return nil
    }

}

class EndAnimation: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        // For the current time to 'sprint' to the end, it must animate to a value
        // which is not equal to the current value
        withAnimation(.easeOut(duration: 0.5)) {
            if let finalTime = model.finalTime {
                model.currentTime = finalTime * 1.00001
            }
            model.reactionHasEnded = true
        }
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
    }

    override func reapply(on model: ZeroOrderReactionViewModel) { }
}


// MARK: Common states for first/second order reactions

class InitialOrderedStep: ReactionState {

    let order: String
    init(order: String) {
        self.order = order
        super.init(statement: ReactionStatements.orderIntro(order: order))
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.initialTime = 0
        model.finalTime = 10
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {

    }

    override func reapply(on model: ZeroOrderReactionViewModel) {

    }
}

class SetFinalConcentrationToNonNil: ReactionState {

    init() {
        super.init(statement: FirstOrderStatements.setC2)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = model.initialConcentration / 2
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = nil
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {

    }
}
