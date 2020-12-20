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
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplainFastRate, highlights: [.rateCurveLhs]),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplainSlowRate, highlights: [.rateCurveRhs]),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain4, highlights: [.concentrationChart]),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain5, highlights: [.concentrationChart]),
            PostReactionExplanation(statement: SecondOrderStatements.postReactionExplain6, highlights: [.concentrationChart]),
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
}

fileprivate class PostReactionExplanation: ReactionState {
    init(statement: [SpeechBubbleLine], highlights: [OrderedReactionScreenHighlightingElements]) {
        self.highlights = highlights
        super.init(statement: statement)
    }

    let highlights: [OrderedReactionScreenHighlightingElements]

    override func apply(on model: ZeroOrderReactionViewModel) {
        super.apply(on: model)
        model.highlightedElements = highlights
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }
}
