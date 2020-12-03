//
// Reactions App
//
  

import Foundation

struct ZeroOrderReactionNavigation {

    static func states(persistence: ReactionInputPersistence) -> [ReactionState] {
        [
            InitialStep(),
            SetFinalValuesToNonNil(),
            RunAnimation(
                statement: ReactionStatements.inProgress,
                order: .Zero,
                persistence: persistence
            ),
            EndAnimation(statement: ZeroOrderStatements.end),
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
