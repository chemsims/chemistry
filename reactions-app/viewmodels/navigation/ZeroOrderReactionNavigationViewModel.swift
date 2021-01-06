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

    static func model(
        reaction: ZeroOrderReactionViewModel,
        persistence: ReactionInputPersistence
    ) -> NavigationViewModel<ReactionState> {
        NavigationViewModel(
            model: reaction,
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
