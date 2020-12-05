//
// Reactions App
//
  

import Foundation

struct NewReactionComparisonNavigationViewModel {

    static var states: [ReactionComparisonState] {
        [
            InitialComparisonState(),
            ExplainEquationState(),
            ChartExplainerState(),
            DragAndDropExplainerState(),
            PreAnimationState()

        ]
    }

    static func model(reaction: NewReactionComparisonViewModel) -> ReactionNavigationViewModel<ReactionComparisonState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}

class ReactionComparisonState: ScreenState {

    typealias Model = NewReactionComparisonViewModel


    let statement: [SpeechBubbleLine]
    init(statement: [SpeechBubbleLine]) {
        self.statement = statement
    }

    func apply(on model: NewReactionComparisonViewModel) { }

    func unapply(on model: NewReactionComparisonViewModel) { }

    func reapply(on model: NewReactionComparisonViewModel) { }

    func nextStateAutoDispatchDelay(model: NewReactionComparisonViewModel) -> Double? { nil }

}


fileprivate class InitialComparisonState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.intro)
    }
}

fileprivate class ExplainEquationState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.equationExplainer)
    }
}

fileprivate class ChartExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.chartExplainer)
    }
}

fileprivate class DragAndDropExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.dragAndDropExplainer)
    }
}

fileprivate class PreAnimationState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.preReaction)
    }
}
