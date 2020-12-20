//
// Reactions App
//
  

import SwiftUI

protocol ScreenState {
    associatedtype Model
    associatedtype NestedState: SubState where NestedState.Model == Model

    /// Optionally provide delayed states which will be automatically applied. Each delay is relative to the previous state,
    /// as opposed to an absolute delay.
    ///
    /// The difference between a delayed state and `nextStateAutoDispatchDelay` is that the
    /// latter is a state which can be navigated to/from by the user, whereas a substate will only be applied
    /// while the parent state is still selected.
    ///
    /// Note that if `nextStateAutoDispatchDelays` is set, it's value is respected and any
    /// delayed states which have yet to be run will be ignored.
    var delayedStates: [DelayedState<NestedState>] { get }

    /// Applies the reaction state to the model
    func apply(on model: Model) -> Void

    /// Unapplies the reaction state to the model. i.e., reversing the effect of `apply`
    func unapply(on model: Model) -> Void

    /// Reapplies the state, when returning from a subsequent state.
    func reapply(on model: Model) -> Void

    /// Interval to wait before automatically progressing to the next state
    func nextStateAutoDispatchDelay(model: Model) -> Double?

    /// When clicking back, should this state be ignored
    var ignoreOnBack: Bool { get }
}

extension ScreenState {
    var ignoreOnBack: Bool {
        false
    }
}

protocol SubState {
    associatedtype Model
    func apply(on model: Model)
}

struct DelayedState<State: SubState> {
    let state: State
    let delay: Double
}

class ReactionState: ScreenState, SubState {

    typealias Model = ZeroOrderReactionViewModel
    typealias NestedState = ReactionState

    let constantStatement: [SpeechBubbleLine]
    init(statement: [SpeechBubbleLine] = []) {
        self.constantStatement = statement
    }

    func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = constantStatement
    }

    func unapply(on model: ZeroOrderReactionViewModel) { }

    func reapply(on model: ZeroOrderReactionViewModel) {
        model.statement = constantStatement
    }

    func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double? { nil }

    let delayedStates = [DelayedState<ReactionState>]()

}


// MARK: Common reaction states

class PreReactionAnimation: ReactionState {

    let highlightedElements: [OrderedReactionScreenHighlightingElements]
    init(highlightedElements: [OrderedReactionScreenHighlightingElements]) {
        self.highlightedElements = highlightedElements
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = model.initialTime
        model.highlightedElements = highlightedElements
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = highlightedElements
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.initialTime
        }
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = []
    }
}

class RunAnimation: ReactionState {

    let order: ReactionOrder?
    let persistence: ReactionInputPersistence?
    let initialiseCurrentTime: Bool

    init(
        statement: [SpeechBubbleLine],
        order: ReactionOrder?,
        persistence: ReactionInputPersistence?,
        initialiseCurrentTime: Bool
    ) {
        self.order = order
        self.persistence = persistence
        self.initialiseCurrentTime = initialiseCurrentTime
        super.init(statement: statement)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.reactionHasEnded = false
        model.reactionHasStarted = true
        model.highlightedElements = []
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
        if (initialiseCurrentTime) {
            model.currentTime = nil
        }
        model.reactionHasStarted = false
    }

    override func nextStateAutoDispatchDelay(model: ZeroOrderReactionViewModel) -> Double? {
        if let duration = model.reactionDuration {
            return Double(duration)
        }
        return nil
    }

}

class EndAnimation: ReactionState {

    let highlightChart: Bool
    init(statement: [SpeechBubbleLine], highlightChart: Bool) {
        self.highlightChart = highlightChart
        super.init(statement: statement)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        if (highlightChart) {
            model.highlightedElements = [.concentrationChart, .secondaryChart]
        }
        // For the current time to 'sprint' to the end, it must animate to a value
        // which is not equal to the current value
        withAnimation(.easeOut(duration: 0.5)) {
            if let finalTime = model.finalTime {
                model.currentTime = finalTime * 1.00001
            }
            if (!highlightChart) {
                model.reactionHasEnded = true
            }
        }
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        if (highlightChart) {
            model.highlightedElements = []
        }
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        if (highlightChart) {
            model.highlightedElements = [.concentrationChart, .secondaryChart]
        }
    }
}


// MARK: Common states for first/second order reactions

class InitialOrderedStep: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.initialTime = 0
        model.finalTime = ReactionSettings.initialT
    }
}

class SetFinalConcentrationToNonNil: ReactionState {

    init() {
        super.init(statement: FirstOrderStatements.setC2)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.finalConcentration = max(model.initialConcentration / 2, ReactionSettings.minCInput)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = nil
    }

}


class FinalState: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.highlightedElements = []
        model.reactionHasEnded = true
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.reactionHasEnded = false
        model.highlightedElements = [.concentrationChart, .secondaryChart]
    }
}
