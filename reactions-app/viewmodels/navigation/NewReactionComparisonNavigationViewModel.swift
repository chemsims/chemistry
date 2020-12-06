//
// Reactions App
//
  

import SwiftUI

struct NewReactionComparisonNavigationViewModel {

    static var states: [ReactionComparisonState] {
        [
            InitialComparisonState(),
            ExplainEquationState(),
            ChartExplainerState(),
            DragAndDropExplainerState(),
            PreAnimationState(),
            RunComparisonAnimation()

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

    override func apply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = [
            .equations
        ]
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class ChartExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.chartExplainer)
    }

    override func apply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = [
            .charts,
            .beakers
        ]
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class DragAndDropExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.dragAndDropExplainer)
    }

    override func apply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = [
            .charts,
            .equations
        ]
        model.canDragOrders = true
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = []
        model.canDragOrders = false
    }
}

fileprivate class PreAnimationState: ReactionComparisonState {

    init() {
        super.init(statement: NewReactionComparisonStatements.preReaction)
    }

    override func apply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = [
            .charts
        ]
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class RunComparisonAnimation: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.reactionRunning)
    }

    override func apply(on model: NewReactionComparisonViewModel) {
        model.currentTime = model.initialTime
        model.highlightedElements = []
        withAnimation(.linear(duration: Double(model.finalTime - model.initialTime))) {
            model.currentTime = model.finalTime
        }
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.currentTime = nil
    }
}
