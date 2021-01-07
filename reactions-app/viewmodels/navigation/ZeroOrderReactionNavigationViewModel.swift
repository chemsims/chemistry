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
        let node1 = BiConditionalScreenStateNode<ReactionState>(
            state: SelectReactionState(),
            applyAlternativeNode: { $0.selectedReaction != .A }
        )

        node1.staticNext = standardPathStates(persistence: persistence)
        node1.staticNextAlternative = alternativePathStates(persistence: persistence)
        return node1
    }

    private static func alternativePathStates(
        persistence: ReactionInputPersistence
    ) -> ScreenStateTreeNode<ReactionState> {
        ScreenStateTreeNode<ReactionState>.build(
            states: [
                SetT0ForFixedRate(),
                SetT1ForFixedRate()
            ]
        )!
    }

    private static func standardPathStates(
        persistence: ReactionInputPersistence
    ) -> ScreenStateTreeNode<ReactionState> {
        ScreenStateTreeNode<ReactionState>.build(
            states: [
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
        )!
    }
}

fileprivate class SelectReactionState: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.chooseReaction)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = true
        model.highlightedElements = [.reactionToggle]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }
}

fileprivate class SetT0ForFixedRate: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.setT0FixedRate)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = false
        model.highlightedElements = []
    }
}

fileprivate class SetT1ForFixedRate: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.setT1FixedRate)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)

        // TODO refactor
        let maxTime = ReactionSettings.maxTime
        model.finalTime = max((model.initialTime + maxTime) / 2, ReactionSettings.minT2Input)
    }
}

fileprivate class InitialStep: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.initial)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = false
        model.highlightedElements = []
    }
}

fileprivate class SetFinalValuesToNonNil: ReactionState {

    init() {
        super.init(statement: ZeroOrderStatements.setFinalValues)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        let initialConcentration = model.initialConcentration
        let minConcentration = ReactionSettings.minConcentration

        let initialTime = model.initialTime
        let maxTime = ReactionSettings.maxTime

        model.finalConcentration = max((initialConcentration + minConcentration) / 2, ReactionSettings.minCInput)
        model.finalTime = max((initialTime + maxTime) / 2, ReactionSettings.minT2Input)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = nil
        model.finalTime = nil
    }
}

fileprivate class ExplainRateState: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = ZeroOrderStatements.rateExplainer(
            k: model.concentrationEquationA?.rateConstant ?? 0
        )
        model.currentTime = model.initialTime
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
            halfLife: model.concentrationEquationA?.halfLife ?? 0
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
