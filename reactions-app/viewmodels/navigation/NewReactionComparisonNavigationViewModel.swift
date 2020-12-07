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
            RunComparisonAnimation(),
            EndComparisonAnimation()
        ]
    }

    static func model(reaction: ReactionComparisonViewModel) -> ReactionNavigationViewModel<ReactionComparisonState> {
        ReactionNavigationViewModel(
            reactionViewModel: reaction,
            states: states
        )
    }
}

class ReactionComparisonState: ScreenState {

    typealias Model = ReactionComparisonViewModel
    typealias NestedState = ReactionComparisonSubstate

    let statement: [SpeechBubbleLine]

    init(statement: [SpeechBubbleLine]) {
        self.statement = statement
    }

    func statement(model: ReactionComparisonViewModel) -> [SpeechBubbleLine] {
        statement
    }

    func apply(on model: ReactionComparisonViewModel) { }

    func unapply(on model: ReactionComparisonViewModel) { }

    func reapply(on model: ReactionComparisonViewModel) { }

    func nextStateAutoDispatchDelay(model: ReactionComparisonViewModel) -> Double? { nil }

    var delayedStates: [DelayedState<ReactionComparisonSubstate>] {
        []
    }

}

class ReactionComparisonSubstate: SubState {

    typealias Model = ReactionComparisonViewModel

    func apply(on model: ReactionComparisonViewModel) {

    }

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

    override func apply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = [
            .equations
        ]
    }

    override func reapply(on model: ReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class ChartExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.chartExplainer)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = [
            .charts,
            .beakers
        ]
        model.correctOrderSelections = []
    }

    override func reapply(on model: ReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class DragAndDropExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.dragAndDropExplainer)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = [
            .charts,
            .equations
        ]

        model.showDragTutorial = true
    }

    override func reapply(on model: ReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = []
        model.showDragTutorial = false
        model.dragTutorialHandIsMoving = false
        model.dragTutorialHandIsComplete = false
    }

    override var delayedStates: [DelayedState<ReactionComparisonSubstate>] {
        [
            DelayedState(state: DragAndDropExplainerSubstate(), delay: 0.5)
        ]
    }
}

fileprivate class DragAndDropExplainerSubstate: ReactionComparisonSubstate {

    override func apply(on model: ReactionComparisonViewModel) {
        withAnimation(.linear(duration: 0.25)) {
            model.dragTutorialHandIsMoving = true
        }
        withAnimation(.easeInOut(duration: 1.5)) {
            model.dragTutorialHandIsComplete = true
        }
    }

}

fileprivate class PreAnimationState: ReactionComparisonState {

    init() {
        super.init(statement: NewReactionComparisonStatements.preReaction)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = [
            .charts
        ]
        model.canStartAnimation = true
        model.showDragTutorial = false
        model.dragTutorialHandIsMoving = false
        model.dragTutorialHandIsComplete = false
    }

    override func reapply(on model: ReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ReactionComparisonViewModel) {
        model.highlightedElements = []
        model.canStartAnimation = false
    }
}

fileprivate class RunComparisonAnimation: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.reactionRunning)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        model.currentTime0 = model.initialTime
        model.currentTime1 = model.initialTime
        model.currentTime2 = model.initialTime
        model.canDragOrders = true
        model.highlightedElements = []
        model.correctOrderSelections = []

        withAnimation(.linear(duration: Double(model.finalTime0))) {
            model.currentTime0 = model.finalTime0
        }
        withAnimation(.linear(duration: Double(model.finalTime1))) {
            model.currentTime1 = model.finalTime1
        }
        withAnimation(.linear(duration: Double(model.finalTime2))) {
            model.currentTime2 = model.finalTime2
        }
    }

    override func reapply(on model: ReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: ReactionComparisonViewModel) {
        model.currentTime0 = nil
        model.currentTime1 = nil
        model.currentTime2 = nil
        model.canDragOrders = false
    }
}

fileprivate class EndComparisonAnimation: ReactionComparisonState {

    init() {
        super.init(statement: NewReactionComparisonStatements.end)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime0 = 1.00001 * model.finalTime0
            model.currentTime1 = 1.00001 * model.finalTime1
            model.currentTime2 = 1.00001 * model.finalTime2
            model.reactionHasEnded = true
        }
    }

    override func unapply(on model: ReactionComparisonViewModel) {
        model.reactionHasEnded = false
    }

}
