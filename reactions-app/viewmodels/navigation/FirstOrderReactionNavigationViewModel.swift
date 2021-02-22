//
// Reactions App
//

import SwiftUI

struct FirstOrderReactionNavigation {

    static func model(
        reaction: FirstOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationViewModel<ReactionState> {
        NavigationViewModel(
            model: reaction,
            rootNode: rootNode(persistence: persistence)
        )
    }

    private static func rootNode(
        persistence: ReactionInputPersistence
    ) -> ScreenStateTreeNode<ReactionState> {
        OrderedReactionInitialNodes.build(
            persistence: persistence,
            standardFlow: states(persistence: persistence),
            order: .First
        )
    }

    private static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(order: .First, statement: FirstOrderStatements.intro),
            SetFinalConcentrationToNonNil(),
            ExplainRateConstant1(),
            ExplainRateConstant2(),
            StaticStatementWithHighlight(
                FirstOrderStatements.explainRate,
                [.rateEquation, .concentrationChart]
            ),
            ExplainHalfLife(),
            RunAnimation(
                makeStatement: {
                    ReactionStatements.inProgress(display: $0.selectedReaction.display)
                },
                order: .First,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: FirstOrderStatements.explainRatePostReaction1,
                highlightChart: true
            ),
            StaticStatementWithHighlight(
                FirstOrderStatements.explainRatePostReaction2,
                .charts
            ),
            StaticStatementWithHighlight(
                FirstOrderStatements.explainChangeInRate,
                [.rateCurveLhs]
            ),
            StaticStatementWithHighlight(
                FirstOrderStatements.explainIntegratedRateLaw1,
                .charts
            ),
            StaticStatementWithHighlight(
                FirstOrderStatements.explainIntegratedRateLaw2,
                .charts
            ),
            FinalReactionState(statement: FirstOrderStatements.end)
        ]
    }
}

private class ExplainRateConstant1: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainRateConstant1)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
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

private class ExplainRateConstant2: ReactionState {
    override func apply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = [.rateConstantEquation]
        model.statement = FirstOrderStatements.explainRateConstant2(
            rate: model.input.concentrationA?.rateConstant ?? 0
        )
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
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
        model.statement = FirstOrderStatements.explainHalfLife(
            halfLife: model.input.concentrationA?.halfLife ?? 0
        )
        model.highlightedElements = [.halfLifeEquation]
    }
}
