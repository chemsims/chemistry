//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ZeroOrderReactionNavigation {

    static func model(
        reaction: ZeroOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationModel<ReactionState> {
        NavigationModel(
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

    private static func standardPathStates(
        persistence: ReactionInputPersistence
    ) -> [ReactionState] {
        [
            InitialStep(),
            SetFinalValuesToNonNil(),
            ExplainRateState(),
            ExplainHalfLifeState(),
            RunAnimation(
                makeStatement: {
                    ZeroOrderStatements.reactionInProgress(display: $0.selectedReaction.display)
                },
                order: .Zero,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: ZeroOrderStatements.endAnimation,
                highlightChart: true
            ),
            StaticStatementWithHighlight(
                ZeroOrderStatements.showConcentrationTable,
                [.concentrationTable]
            ),
            FinalReactionState(statement: ZeroOrderStatements.end)
        ]
    }
}

private class InitialStep: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.initial)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.inputsAreDisabled = false
        model.canSelectReaction = false
        model.highlightedElements = []

        model.input = ReactionInputAllProperties(order: .Zero)
    }
}

private class SetFinalValuesToNonNil: ReactionState {

    init() {
        super.init(statement: ZeroOrderStatements.setFinalValues)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        let initialConcentration = model.input.inputC1
        let minConcentration = ReactionSettings.Axis.minC

        let initialTime = model.input.inputT1
        let maxTime = ReactionSettings.Axis.maxT

        model.input.inputC2 = max((initialConcentration + minConcentration) / 2, ReactionSettings.Input.minC)
        model.input.inputT2 = max((initialTime + maxTime) / 2, ReactionSettings.Input.minT1)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.input.inputC2 = nil
        model.input.inputT2 = nil
    }
}

private class ExplainRateState: ReactionState {

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

private class ExplainHalfLifeState: PreReactionAnimation {

    init() {
        super.init(highlightedElements: [.halfLifeEquation])
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        setStatementAndHighlightedElements(model: model)
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        super.reapply(on: model)
        setStatementAndHighlightedElements(model: model)
    }

    private func setStatementAndHighlightedElements(model: ZeroOrderReactionViewModel) {
        model.statement = ZeroOrderStatements.halfLifeExplainer(
            halfLife: model.input.concentrationA?.halfLife ?? 0
        )
        model.highlightedElements = [.halfLifeEquation]
    }
}
