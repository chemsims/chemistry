//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionComparisonNavigationViewModel {

    static var states: [ReactionComparisonState] {
        [
            InitialComparisonState(),
            ExplainEquationState(),
            ChartExplainerState(),
            DragAndDropExplainerState(),
            PreAnimationState(),
            RunComparisonAnimation(),
            EndComparisonAnimation(),
            FinalComparisonState()
        ]
    }

    static func model(reaction: ReactionComparisonViewModel) -> NavigationModel<ReactionComparisonState> {
        NavigationModel(
            model: reaction,
            states: states
        )
    }
}

class ReactionComparisonState: ScreenState {

    typealias Model = ReactionComparisonViewModel
    typealias NestedState = ReactionComparisonSubstate

    let statement: [TextLine]

    init(statement: [TextLine]) {
        self.statement = statement
    }

    func apply(on model: ReactionComparisonViewModel) {
        model.statement = statement
    }

    func unapply(on model: ReactionComparisonViewModel) { }

    func reapply(on model: ReactionComparisonViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: ReactionComparisonViewModel) -> Double? { nil }

    func delayedStates(model: ReactionComparisonViewModel) -> [DelayedState<ReactionComparisonSubstate>] {
        []
    }
    
    var backBehaviour: NavigationModelBackBehaviour {
        .unapply
    }
}

class ReactionComparisonSubstate: SubState {

    typealias Model = ReactionComparisonViewModel

    func apply(on model: ReactionComparisonViewModel) {

    }
}

private class InitialComparisonState: ReactionComparisonState {
    init() {
        super.init(statement: ReactionComparisonStatements.intro)
    }
}

private class ExplainEquationState: ReactionComparisonState {
    init() {
        super.init(statement: ReactionComparisonStatements.equationExplainer)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        super.apply(on: model)
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

private class ChartExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: ReactionComparisonStatements.chartExplainer)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        super.apply(on: model)
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

private class DragAndDropExplainerState: ReactionComparisonState {
    init() {
        super.init(statement: ReactionComparisonStatements.dragAndDropExplainer)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        super.apply(on: model)
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

    override func delayedStates(model: Model) -> [DelayedState<ReactionComparisonSubstate>] {
        [
            DelayedState(state: DragAndDropExplainerSubstate(), delay: 0.5)
        ]
    }
}

private class DragAndDropExplainerSubstate: ReactionComparisonSubstate {

    override func apply(on model: ReactionComparisonViewModel) {
        withAnimation(.linear(duration: 0.25)) {
            model.dragTutorialHandIsMoving = true
        }
        withAnimation(.easeInOut(duration: 1.5)) {
            model.dragTutorialHandIsComplete = true
        }
    }

}

private class PreAnimationState: ReactionComparisonState {

    init() {
        super.init(statement: ReactionComparisonStatements.preReaction)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        super.apply(on: model)
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

private class RunComparisonAnimation: ReactionComparisonState {
    init() {
        super.init(statement: ReactionComparisonStatements.reactionRunning)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        super.apply(on: model)
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
        withAnimation(.easeOut(duration: 0.25)) {
            model.currentTime0 = model.initialTime
            model.currentTime1 = model.initialTime
            model.currentTime2 = model.initialTime
        }
        model.currentTime0 = nil
        model.currentTime1 = nil
        model.currentTime2 = nil
        model.canDragOrders = false
        model.correctOrderSelections = []
    }
}

private class EndComparisonAnimation: ReactionComparisonState {

    init() {
        super.init(statement: ReactionComparisonStatements.instructToScrubReaction)
    }

    override func apply(on model: ReactionComparisonViewModel) {
        super.apply(on: model)
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

private class FinalComparisonState: ReactionComparisonState {
    init() {
        super.init(statement: ReactionComparisonStatements.end)
    }
}
