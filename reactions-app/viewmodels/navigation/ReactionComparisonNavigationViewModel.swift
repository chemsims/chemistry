//
// Reactions App
//
  

import SwiftUI

struct ReactionComparisonNavigation {

    static var states: [ReactionState] {
        [
            InitialState(),
            RunAnimation(
                statement: ReactionComparisonStatements.inProgress,
                order: nil,
                persistence: nil
            ),
            EndAnimation(statement: ReactionComparisonStatements.end)
        ]
    }



    static func model(reaction: ZeroOrderReactionViewModel) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}

struct ReactionComparisonNavigation2 {

    static var states: [ReactionState] {
        [
            InitialState2(),
            RunAnimation(
                statement: ReactionComparisonStatements.inProgress,
                order: nil,
                persistence: nil
            ),
            EndAnimation(statement: ReactionComparisonStatements.end)
        ]
    }



    static func model(reaction: ZeroOrderReactionViewModel) -> ReactionNavigationViewModel<ReactionState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}


fileprivate class InitialState: ReactionState {

    init() {
        super.init(statement: ReactionComparisonStatements.intro)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.initialConcentration = ReactionComparisonDefaults.c1
        model.finalConcentration = ReactionComparisonDefaults.c2
        model.initialTime = 0
        model.finalTime = ReactionComparisonDefaults.time
        model.currentTime = nil
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {

    }

    override func reapply(on model: ZeroOrderReactionViewModel) {

    }
}


fileprivate class InitialState2: ReactionState {

    init() {
        super.init(statement: ReactionComparisonStatements.intro)
    }

    override func apply(on model: ZeroOrderReactionViewModel) {
        model.currentTime = nil
    }

    override func unapply(on model: ZeroOrderReactionViewModel) {

    }

    override func reapply(on model: ZeroOrderReactionViewModel) {

    }
}
