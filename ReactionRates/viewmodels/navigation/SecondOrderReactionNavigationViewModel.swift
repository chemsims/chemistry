//
// Reactions App
//

import Foundation
import ReactionsCore

struct SecondOrderReactionNavigation {

    static func model(
        reaction: SecondOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationModel<ReactionState> {
        NavigationModel(
            model: reaction,
            rootNode: rootNode(persistence: persistence)
        )
    }

    private static func rootNode(
        persistence: ReactionInputPersistence
    ) -> ScreenStateTreeNode<ReactionState> {
        OrderedReactionInitialNodes.build(
            persistence: persistence,
            standardFlow: standardFlow(persistence: persistence),
            order: .Second
        )
    }

    private static func standardFlow(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(order: .Second, statement: SecondOrderStatements.intro),
            SetFinalConcentrationToNonNil(),
            ExplainRateConstant(),
            StaticStatementWithHighlight(
                SecondOrderStatements.explainRate,
                [.rateEquation, .concentrationChart]
            ),
            ExplainHalfLife(),
            RunAnimation(
                makeStatement: {
                    ReactionStatements.inProgress(display: $0.selectedReaction.display)
                },
                order: .Second,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: SecondOrderStatements.postReactionExplain1,
                highlightChart: true
            ),
            StaticStatementWithHighlight(
                SecondOrderStatements.postReactionExplainFastRate,
                [.rateCurveLhs]
            ),
            StaticStatementWithHighlight(
                SecondOrderStatements.postReactionExplainSlowRate,
                [.rateCurveRhs]
            ),
            StaticStatementWithHighlight(
                SecondOrderStatements.postReactionExplain4,
                .charts
            ),
            StaticStatementWithHighlight(
                SecondOrderStatements.postReactionExplain5,
                .charts
            ),
            StaticStatementWithHighlight(
                SecondOrderStatements.postReactionExplain6,
                .charts
            ),
            FinalReactionState(statement: SecondOrderStatements.end)
        ]
    }
}

private class ExplainRateConstant: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = SecondOrderStatements.explainRateConstant(
            rateConstant: model.input.concentrationA?.rateConstant ?? 0
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

private class ExplainHalfLife: PreReactionAnimation {

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
        model.statement = SecondOrderStatements.explainHalfLife(
            halfLife: model.input.concentrationA?.halfLife ?? 0
        )
        model.highlightedElements = [.halfLifeEquation]
    }
}
