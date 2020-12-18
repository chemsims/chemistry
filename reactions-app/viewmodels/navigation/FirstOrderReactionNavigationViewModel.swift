//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionNavigation {
    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialOrderedStep(statement: FirstOrderStatements.intro),
            SetFinalConcentrationToNonNil(),
            ExplainRateConstant1(),
            ExplainRateConstant2(),
            ExplainRate(),
            ExplainHalfLife(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .First,
                persistence: persistence,
                initialiseCurrentTime: false
            ),
            EndAnimation(
                statement: FirstOrderStatements.explainRatePostReaction1,
                highlightChart: true
            ),
            ExplainRatePostReaction2(),
            ExplainRatePostReaction3(),
            ExplainIntegratedRateLaw1(),
            ExplainIntegratedRateLaw2(),
            FinalState(statement: FirstOrderStatements.end)
        ]
    }

    static func model(
        reaction: FirstOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationViewModel<ReactionState> {
        NavigationViewModel(
            reactionViewModel: reaction,
            states: states(persistence: persistence)
        )
    }
}

fileprivate class ExplainRateConstant1: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainRateConstant1)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
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

fileprivate class ExplainRateConstant2: ReactionState {
    override func statement(model: ZeroOrderReactionViewModel) -> [SpeechBubbleLine] {
        FirstOrderStatements.explainRateConstant2(
            rate: model.concentrationEquationA?.rateConstant ?? 0
        )
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = [.rateConstantEquation]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        apply(on: model)
    }

}

fileprivate class ExplainRate: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainRate)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
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

    override func statement(model: ZeroOrderReactionViewModel) -> [SpeechBubbleLine] {
        FirstOrderStatements.explainHalfLife(
            halfLife: model.concentrationEquationA?.halfLife ?? 0
        )
    }
}

fileprivate class ExplainRatePostReaction2: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainRatePostReaction2)
    }
}
fileprivate class ExplainRatePostReaction3: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainRatePostReaction3)
    }
}

fileprivate class ExplainIntegratedRateLaw1: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainIntegratedRateLaw1)
    }
}

fileprivate class ExplainIntegratedRateLaw2: ReactionState {
    init() {
        super.init(statement: FirstOrderStatements.explainIntegratedRateLaw2)
    }
}
