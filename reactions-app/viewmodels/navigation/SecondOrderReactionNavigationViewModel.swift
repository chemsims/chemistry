//
// Reactions App
//
  

import Foundation

struct SecondOrderReactionNavigation {

    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(statement: SecondOrderStatements.intro),
            SetFinalConcentrationToNonNil(),
            ExplainRateConstant(),
            ExplainRate(),
            ExplainHalfLife(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .Second,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: SecondOrderStatements.postReactionExplain1,
                highlightChart: true
            ),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain2),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain3),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain4),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain5),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain6),
            FinalState(statement: SecondOrderStatements.end)
        ]
    }

    static func model(
        reaction: SecondOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationViewModel<ReactionState> {
        NavigationViewModel(
            reactionViewModel: reaction,
            states: states(persistence: persistence)
        )
    }
}

fileprivate class ExplainRateConstant: ReactionState {

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = SecondOrderStatements.explainRateConstant(rateConstant: model.concentrationEquationA?.rateConstant ?? 0)
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

fileprivate class ExplainRate: ReactionState {
    init() {
        super.init(statement: SecondOrderStatements.explainRate)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.highlightedElements = [.rateEquation, .concentrationChart]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = []
    }

}

fileprivate class ExplainHalfLife: PreReactionAnimation {

    init() {
        super.init(highlightedElements: [.halfLifeEquation])
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.statement = SecondOrderStatements.explainHalfLife(
            halfLife: model.concentrationEquationA?.halfLife ?? 0
        )
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }
}

fileprivate class PostReactionExplanation: ReactionState {

}
