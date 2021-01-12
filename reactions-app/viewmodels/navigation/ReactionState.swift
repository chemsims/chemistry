//
// Reactions App
//
  

import SwiftUI

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
        assert(!standardFlow.isEmpty)
        var states = standardFlow
        states += secondaryReactionStates(persistence: persistence, order: order, hasNext: true)
        states += secondaryReactionStates(persistence: persistence, order: order, hasNext: false)
        return ScreenStateTreeNode<ReactionState>.build(states: states)!
    }

    private static func secondaryReactionStates(
        persistence: ReactionInputPersistence,
        order: ReactionOrder,
        hasNext: Bool
    ) -> [ReactionState] {
        let finalStatement = hasNext ?
            ReactionStatements.endOfSecondReaction :
            ReactionStatements.end
        return [
            SelectReactionState(),
            SetT0ForFixedRate(order: order),
            SetT1ForFixedRate(),
            RunAnimation(
                statement: reactionInProgressStatement(order: order),
                order: order,
                persistence: persistence,
                initialiseCurrentTime: true
            ),
            EndAnimation(
                statement: finalStatement,
                highlightChart: false
            )
        ]
    }

    private static func reactionInProgressStatement(order: ReactionOrder) -> [TextLine] {
        switch (order) {
        case .Zero: return ZeroOrderStatements.reactionInProgress
        default: return ReactionStatements.inProgress
        }
    }
}

class SelectReactionState: ReactionState {
    
    init() {
        super.init(statement: ReactionStatements.chooseReaction)
    }

    private var previousInput: ReactionInputModel?
    private var previousReaction: ReactionType?

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        previousInput = model.input
        previousReaction = model.selectedReaction
        model.inputsAreDisabled = true
        model.canSelectReaction = true
        model.highlightedElements = [.reactionToggle]

        model.reactionHasStarted = true
        model.reactionHasEnded = true
        if let t2 = model.input.inputT2 {
            model.currentTime = model.currentTime ?? reactionEndTime(t2: t2)
        }

        let availableReaction = ReactionType.allCases.filter {
            !model.usedReactions.contains($0)
        }

        assert(!availableReaction.isEmpty)
        let nextReaction = availableReaction.first
        model.pendingReactionSelection = nextReaction!
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        if let previousInput = previousInput {
            model.input = previousInput
        }
        apply(on: model)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        if let previousInput = previousInput {
            model.input = previousInput
        }
        model.canSelectReaction = false
        model.inputsAreDisabled = false
        model.highlightedElements = []
    }
}

class SetT0ForFixedRate: ReactionState {
    init(order: ReactionOrder) {
        self.order = order
    }

    let order: ReactionOrder

    private var insertedReaction: ReactionType?

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        assert(model.pendingReactionSelection != .A)

        model.inputsAreDisabled = false
        model.canSelectReaction = false
        model.highlightedElements = []

        insertedReaction = model.pendingReactionSelection
        model.usedReactions.append(model.pendingReactionSelection)

        model.input = model.selectedReaction == .B ?
            ReactionInputWithoutC2(order: order) :
            ReactionInputWithoutT2(order: order)

        setStatement(model)

        model.currentTime = nil
        model.reactionHasStarted = false
        model.reactionHasEnded = false
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        setStatement(model)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        if let reaction = insertedReaction {
            model.usedReactions.removeAll { $0 == reaction }
        }
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
            persistence.save(input: input, order: order, reaction: model.selectedReaction)
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
                model.currentTime = reactionEndTime(t2: finalTime)
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
        model.canSelectReaction = false
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

fileprivate func reactionEndTime(t2: CGFloat) -> CGFloat {
    t2 * 1.00001
}
