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

    /// TimeInterval (i.e. time in seconds) to wait before automatically progressing to the next state
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

    let constantStatement: [TextLine]
    init(statement: [TextLine] = []) {
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

// MARK: Common reaction nodes

struct OrderedReactionInitialNodes {

    static func build(
        persistence: ReactionInputPersistence,
        standardFlow: [ReactionState],
        order: ReactionOrder
    ) -> ScreenStateTreeNode<ReactionState> {
        let node1 = BiConditionalScreenStateNode<ReactionState>(
            state: SelectReactionState(),
            applyAlternativeNode: { $0.selectedReaction != .A }
        )

        node1.staticNext = ScreenStateTreeNode<ReactionState>.build(states: standardFlow)
        node1.staticNextAlternative = alternativePathStates(persistence: persistence, order: order)
        return node1
    }

    private static func alternativePathStates(
        persistence: ReactionInputPersistence,
        order: ReactionOrder
    ) -> ScreenStateTreeNode<ReactionState> {
        ScreenStateTreeNode<ReactionState>.build(
            states: [
                SetT0ForFixedRate(order: order),
                SetT1ForFixedRate(),
                RunAnimation(
                    statement: ZeroOrderStatements.reactionInProgress,
                    order: order,
                    persistence: persistence,
                    initialiseCurrentTime: true
                ),
                EndAnimation(
                    statement: ZeroOrderStatements.end,
                    highlightChart: false
                )
            ]
        )!
    }
}

class SelectReactionState: ReactionState {
    init() {
        super.init(statement: ReactionStatements.chooseReaction)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = true
        model.canSelectReaction = true
        model.highlightedElements = [.reactionToggle]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }
}

class SetT0ForFixedRate: ReactionState {
    init(order: ReactionOrder) {
        self.order = order
    }

    let order: ReactionOrder

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = false
        model.canSelectReaction = false
        model.highlightedElements = []

        model.input = model.selectedReaction == .B ?
            ReactionInputWithoutC2(order: order) :
            ReactionInputWithoutT2(order: order)

        model.input.didSetC1 = model.didSetC1
        setStatement(model)
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        setStatement(model)
    }

    private func setStatement(_ model: ZeroOrderReactionViewModel) {
        let k = model.input.concentrationA?.rateConstant ?? 0
        model.statement = ReactionStatements.setInitialInputs(rateConstant: k)
    }
}

class SetT1ForFixedRate: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        setStatement(model)
        model.input.inputT2 = model.input.midTime
        model.input.inputC2 = model.input.midConcentration
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        setStatement(model)
    }

    private func setStatement(_ model: ZeroOrderReactionViewModel) {
        model.statement = model.selectedReaction == .B ?
            ReactionStatements.setT2ForFixedRate : ReactionStatements.setC2ForFixedRate
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.input.inputT2 = nil
        model.input.inputC2 = nil
    }
}

// MARK: Common reaction states


class PreReactionAnimation: ReactionState {

    let highlightedElements: [OrderedReactionScreenElement]
    init(highlightedElements: [OrderedReactionScreenElement]) {
        self.highlightedElements = highlightedElements
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = model.input.inputT1
        model.highlightedElements = highlightedElements
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = highlightedElements
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.input.inputT1
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
        statement: [TextLine],
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
        if let duration = model.reactionDuration, let finalTime = model.input.inputT2 {
            model.currentTime = model.input.inputT1
            withAnimation(.linear(duration: Double(duration))) {
                model.currentTime = finalTime
            }
        }

        if let input = model.inputToSave, let order = order, let persistence = persistence {
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
    init(statement: [TextLine], highlightChart: Bool) {
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
            if let finalTime = model.input.inputT2 {
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

    init(order: ReactionOrder, statement: [TextLine]) {
        self.order = order
        super.init(statement: statement)
    }

    private let order: ReactionOrder

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        let currentInput = model.input
        model.input = ReactionInputAllProperties(order: order)
        model.input.inputC1 = currentInput.inputC1
        model.input.inputT1 = 0
        model.input.inputT2 = ReactionSettings.initialT
        model.inputsAreDisabled = false
        model.highlightedElements = []
    }
}

class SetFinalConcentrationToNonNil: ReactionState {

    init() {
        super.init(statement: FirstOrderStatements.setC2)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.input.inputC2 = max(model.input.inputC1 / 2, ReactionSettings.minCInput)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.input.inputC2 = nil
    }
}


class FinalReactionState: ReactionState {

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
