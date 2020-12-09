//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReactionNavigation {

    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialStep(),
            SetFinalValuesToNonNil(),
            ExplainRateState(),
            ExplainHalflifeState(),
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
            FinalState()
        ]
    }

    static func model(
        reaction: ZeroOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states(persistence: persistence)
        )
    }

}

fileprivate class InitialStep: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.initial)
    }
}

fileprivate class SetFinalValuesToNonNil: ReactionState {

    init() {
        super.init(statement: ZeroOrderStatements.setFinalValues)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        let initialConcentration = model.initialConcentration
        let minConcentration = ReactionSettings.minConcentration

        let initialTime = model.initialTime
        let maxTime = ReactionSettings.maxTime

        model.finalConcentration = (initialConcentration + minConcentration) / 2
        model.finalTime = (initialTime + maxTime) / 2
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.finalConcentration = nil
        model.finalTime = nil
    }
}

fileprivate class ExplainRateState: ReactionState {

    override func statement(model: ZeroOrderReactionViewModel) -> [SpeechBubbleLine] {
        ZeroOrderStatements.rateExplainer(
            k: model.concentrationEquationA?.rateConstant ?? 0
        )
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

fileprivate class ExplainHalflifeState: ReactionState {
    override func statement(model: ZeroOrderReactionViewModel) -> [SpeechBubbleLine] {
        ZeroOrderStatements.halfLifeExplainer(halfLife: model.halfTime ?? 0)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = model.initialTime
        model.highlightedElements = [.halfLifeEquation]
    }

    override func reapply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = [.halfLifeEquation]
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.initialTime
        }
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class FinalState: ReactionState {
    init() {
        super.init(statement: ZeroOrderStatements.end)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.highlightedElements = []
        model.reactionHasEnded = true
    }
}
