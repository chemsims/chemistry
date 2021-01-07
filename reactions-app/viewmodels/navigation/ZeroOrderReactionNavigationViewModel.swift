//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReactionNavigation {

    static func model(
        reaction: ZeroOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationViewModel<ReactionState> {
        NavigationViewModel(
            model: reaction,
            rootNode: rootNode(persistence: persistence)
        )
    }

    static func rootNode(persistence: ReactionInputPersistence) -> ScreenStateTreeNode<ReactionState> {
        OrderedReactionInitialNodes.build(
            persistence: persistence,
            standardFlow: standardPathStates(persistence: persistence),
            order: .Zero
        )
    }

    private static func alternativePathStates(
        persistence: ReactionInputPersistence
    ) -> ScreenStateTreeNode<ReactionState> {
        ScreenStateTreeNode<ReactionState>.build(
            states: [
                SetT0ForFixedRate(order: .Zero),
                SetT1ForFixedRate(),
                RunAnimation(
                    statement: ZeroOrderStatements.reactionInProgress,
                    order: .Zero,
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

    private static func standardPathStates(
        persistence: ReactionInputPersistence
    ) -> [ReactionState] {
        [
            InitialStep(),
            SetFinalValuesToNonNil(),
            ExplainRateState(),
            ExplainHalfLifeState(),
            RunAnimation(
                statement: ZeroOrderStatements.reactionInProgress,
                order: .Zero,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: ZeroOrderStatements.endAnimation,
                highlightChart: true
            ),
            ShowConcentrationTableState(),
            FinalReactionState(statement: ZeroOrderStatements.end)
        ]
    }
}

// MARK: Initial states
fileprivate class InitialStep: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.initial)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = false
        model.canSelectReaction = false
        model.highlightedElements = []

        let currentInput = model.input
        model.input = ReactionInputAllProperties(order: .Zero)
        model.input.didSetC1 = currentInput.didSetC1
    }
}

// MARK: Reaction A states
fileprivate class SetFinalValuesToNonNil: ReactionState {

    init() {
        super.init(statement: ZeroOrderStatements.setFinalValues)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        let initialConcentration = model.input.inputC1
        let minConcentration = ReactionSettings.minConcentration

        let initialTime = model.input.inputT1
        let maxTime = ReactionSettings.maxTime

        model.input.inputC2 = max((initialConcentration + minConcentration) / 2, ReactionSettings.minCInput)
        model.input.inputT2 = max((initialTime + maxTime) / 2, ReactionSettings.minT2Input)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.input.inputC2 = nil
        model.input.inputT2 = nil
    }
}

fileprivate class ExplainRateState: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = ZeroOrderStatements.rateExplainer(
            k: model.input.concentrationA?.rateConstant ?? 0
        )
        model.currentTime = model.input.inputT1
        model.highlightedElements = [.rateConstantEquation]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = nil
        model.highlightedElements = []
    }

}

fileprivate class ExplainHalfLifeState: PreReactionAnimation {

    init() {
        super.init(highlightedElements: [.halfLifeEquation])
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = ZeroOrderStatements.halfLifeExplainer(
            halfLife: model.input.concentrationA?.halfLife ?? 0
        )
    }

}

fileprivate class ShowConcentrationTableState: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.showConcentrationTable)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.highlightedElements = [.concentrationTable]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }
}
