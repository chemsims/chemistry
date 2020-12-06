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

    var canSelectState: Bool {
        true
    }

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
        model.correctOrderSelections = []
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

        model.showDragTutorial = true
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = []
        model.showDragTutorial = false
    }

    override func nextStateAutoDispatchDelay(model: NewReactionComparisonViewModel) -> Double? {
        0.2
    }
}

fileprivate class DragAndDropExplainerState1: ReactionComparisonState {

    init() {
        super.init(statement: NewReactionComparisonStatements.dragAndDropExplainer)
    }

    override var canSelectState: Bool {
        false
    }

    override func apply(on model: NewReactionComparisonViewModel) {
        withAnimation(.linear(duration: 0.25)) {
            model.dragTutorialHandIsMoving = true
        }
        withAnimation(.linear(duration: 2)) {
            model.dragTutorialHandIsComplete = true
        }
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.dragTutorialHandIsMoving = false
        model.dragTutorialHandIsComplete = false
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
        model.canStartAnimation = true
    }

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.highlightedElements = []
        model.canStartAnimation = false
    }
}

fileprivate class RunComparisonAnimation: ReactionComparisonState {
    init() {
        super.init(statement: NewReactionComparisonStatements.reactionRunning)
    }

    override func apply(on model: NewReactionComparisonViewModel) {
        model.currentTime0 = model.initialTime
        model.currentTime1 = model.initialTime
        model.currentTime2 = model.initialTime
        model.canDragOrders = true
        model.highlightedElements = []

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

    override func reapply(on model: NewReactionComparisonViewModel) {
        apply(on: model)
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
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

    override func apply(on model: NewReactionComparisonViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime0 = 1.00001 * model.finalTime0
            model.currentTime1 = 1.00001 * model.finalTime1
            model.currentTime2 = 1.00001 * model.finalTime2
            model.reactionHasEnded = true
        }
    }

    override func unapply(on model: NewReactionComparisonViewModel) {
        model.reactionHasEnded = false
    }

}
