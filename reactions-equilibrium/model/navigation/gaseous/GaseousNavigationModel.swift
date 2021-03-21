//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct GaseousNavigationModel {
    static func model(
        model: GaseousReactionViewModel
    ) -> NavigationModel<GaseousScreenState> {
        NavigationModel(
            model: model,
            states: states
        )
    }

    private static let states = [
        GaseousSetStatement(statement: GaseousStatements.intro),
        GaseousAfterChoosingReaction(),
        GaseousSetStatement(
            statement: GaseousStatements.explainK,
            highlights: [.quotientToEquilibriumConstantDefinition]
        ),
        GaseousAddProducts(),
        GaseousRunForwardReaction(),
        GaseousEndOfReaction(),
        GaseousSetStatement(statement: GaseousStatements.chatelier),
        GaseousSetVolume()
    ]
}

class GaseousScreenState: ScreenState, SubState {

    typealias Model = GaseousReactionViewModel
    typealias NestedState = GaseousScreenState

    var delayedStates: [DelayedState<GaseousScreenState>] {
        []
    }

    func apply(on model: GaseousReactionViewModel) { }

    func unapply(on model: GaseousReactionViewModel) { }

    func reapply(on model: GaseousReactionViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: GaseousReactionViewModel) -> Double? {
        nil
    }
}

private class GaseousSetStatement: GaseousScreenState {

    let statement: [TextLine]
    let highlights: [GaseousScreenElement]


    init(statement: [TextLine], highlights: [GaseousScreenElement] = []) {
        self.statement = statement
        self.highlights = highlights
    }

    override func apply(on model: GaseousReactionViewModel) {
        model.statement = statement
        model.highlightedElements.elements = highlights
    }
}

private class GaseousAfterChoosingReaction: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        model.statement = GaseousStatements.explainQEquation
        model.highlightedElements.elements = [.quotientToConcentrationDefinition]
        model.inputState = .none
        model.reactionSelectionIsToggled = false
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.reactionSelectionIsToggled = true
        model.inputState = .selectReactionType
    }
}

private class GaseousAddProducts: GaseousScreenState {

    override func apply(on model: GaseousReactionViewModel) {
        model.statement = GaseousStatements.instructToAddReactants(
            reaction: model.selectedReaction
        )
        model.inputState = .addReactants
        model.highlightedElements.clear()
        model.showConcentrationLines = true
    }
}

private class GaseousRunForwardReaction: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        model.showQuotientLine = true
        model.highlightForwardReactionArrow = true
        let time = GaseousReactionSettings.forwardTiming.end
        model.currentTime = 0
        model.inputState = .none
        withAnimation(.linear(duration: Double(time))) {
            model.currentTime = time
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.highlightForwardReactionArrow = false
        model.showQuotientLine = false
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
        }
    }

    override func nextStateAutoDispatchDelay(model: GaseousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.forwardReactionTime)
    }
}

private class GaseousEndOfReaction: GaseousScreenState {

    override func apply(on model: GaseousReactionViewModel) {
        model.statement = GaseousStatements.forwardEquilibriumReached
        model.highlightForwardReactionArrow = false
        model.canSetChartIndex = true
        let endTime = GaseousReactionSettings.forwardTiming.end
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = endTime * 1.001
        }
    }
}

private class GaseousSetVolume: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        model.statement = GaseousStatements.instructToChangeVolume(selected: model.selectedReaction)
        model.inputState = .setBeakerVolume
        let timing = GaseousReactionSettings.pressureTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = timing.offset
            model.currentTime = timing.start
            model.canSetChartIndex = false
        }
        model.componentWrapper = ReactionComponentsWrapper(
            previous: model.componentWrapper,
            startTime: timing.start,
            equilibriumTime: timing.equilibrium
        )
    }

    override func unapply(on model: GaseousReactionViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = GaseousReactionSettings.forwardTiming.end
            model.canSetChartIndex = false
        }
        if let previous = model.componentWrapper.previous {
            model.componentWrapper = previous
        }
    }
}
