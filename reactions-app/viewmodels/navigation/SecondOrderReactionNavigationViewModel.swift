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
            ExplainHalfLife(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .Second,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: SecondOrderStatements.end,
                highlightChart: true
            ),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain1),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain2),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain3),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain4),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain5),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain6),
        ]
    }

    static func model(
        reaction: SecondOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states(persistence: persistence)
        )
    }
}

fileprivate class ExplainRateConstant: ReactionState {
    override func statement(model: ZeroOrderReactionViewModel) -> [SpeechBubbleLine] {
        SecondOrderStatements.explainRateConstant(rateConstant: model.concentrationEquationA?.rateConstant ?? 0)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = model.initialTime
        model.highlightedElements = [.rateEquation]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = nil
        model.highlightedElements = []
    }
}

fileprivate class ExplainHalfLife: PreReactionAnimation {

    init() {
        super.init(highlightedElements: [.halfLifeEquation])
    }

    override func statement(model: ZeroOrderReactionViewModel) -> [SpeechBubbleLine] {
        SecondOrderStatements.explainHalfLife(
            halfLife: model.concentrationEquationA?.halfLife ?? 0
        )
    }
}

fileprivate class PostReactionExplanation: ReactionState {

}

fileprivate class FinalState: ReactionState {
    init() {
        super.init(statement: SecondOrderStatements.end)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = []
    }
}
