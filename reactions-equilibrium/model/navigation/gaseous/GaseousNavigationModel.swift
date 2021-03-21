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
        GaseousRunReaction(
            statement: GaseousStatements.forwardReactionIsRunning,
            timing: GaseousReactionSettings.forwardTiming,
            isForward: true
        ),
        GaseousEndOfReaction(
            statement: GaseousStatements.forwardEquilibriumReached,
            timing: GaseousReactionSettings.forwardTiming
        ),
        GaseousSetStatement(statement: GaseousStatements.chatelier),
        GaseousSetVolume(),
        GaseousRunReaction(
            statement: GaseousStatements.forwardReactionIsRunning,
            timing: GaseousReactionSettings.pressureTiming,
            isForward: true
        ),
        GaseousEndOfReaction(
            statement: GaseousStatements.forwardEquilibriumReached,
            timing: GaseousReactionSettings.pressureTiming
        ),
        GaseousSetStatement(statement: GaseousStatements.endOfPressureReaction),
        GaseousSetStatement(statement: GaseousStatements.chatelier2),
        GaseousSetTemperature(),
        GaseousRunReaction(
            statement: GaseousStatements.forwardReactionIsRunning,
            timing: GaseousReactionSettings.heatTiming,
            isForward: true
        ),
        GaseousEndOfReaction(
            statement: GaseousStatements.forwardEquilibriumReached,
            timing: GaseousReactionSettings.heatTiming
        )
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

    override func unapply(on model: GaseousReactionViewModel) {
        model.resetMolecules()
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

private class GaseousRunReaction: GaseousScreenState {
    let statement: [TextLine]
    let timing: GaseousReactionSettings.ReactionTiming
    let isForward: Bool

    init(
        statement: [TextLine],
        timing: GaseousReactionSettings.ReactionTiming,
        isForward: Bool
    ) {
        self.statement = statement
        self.timing = timing
        self.isForward = isForward
    }

    override func apply(on model: GaseousReactionViewModel) {
        model.showQuotientLine = true
        model.highlightForwardReactionArrow = isForward
        model.highlightReverseReactionArrow = !isForward
        model.currentTime = timing.start
        model.inputState = .none
        withAnimation(.linear(duration: Double(duration))) {
            model.currentTime = timing.end
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.highlightForwardReactionArrow = false
        model.highlightReverseReactionArrow = false
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = timing.start
        }
    }

    override func nextStateAutoDispatchDelay(model: GaseousReactionViewModel) -> Double? {
        Double(duration)
    }

    private var duration: CGFloat {
        timing.end - timing.start
    }

}

private class GaseousEndOfReaction: GaseousScreenState {

    let statement: [TextLine]
    let timing: GaseousReactionSettings.ReactionTiming

    init(statement: [TextLine], timing: GaseousReactionSettings.ReactionTiming) {
        self.statement = statement
        self.timing = timing
    }

    override func apply(on model: GaseousReactionViewModel) {
        model.statement = statement
        model.highlightForwardReactionArrow = false
        model.highlightReverseReactionArrow = false
        model.canSetChartIndex = true
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = timing.end * 1.001
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.canSetChartIndex = false
    }
}

private class GaseousSetVolume: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        doApply(on: model, setComponents: true)
    }

    override func reapply(on model: GaseousReactionViewModel) {
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: GaseousReactionViewModel, setComponents: Bool) {
        model.statement = GaseousStatements.instructToChangeVolume(selected: model.selectedReaction)
        model.inputState = .setBeakerVolume
        let timing = GaseousReactionSettings.pressureTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = timing.offset
            model.currentTime = timing.start
            model.canSetChartIndex = false
        }
        if setComponents {
            model.componentWrapper = ReactionComponentsWrapper(
                previous: model.componentWrapper,
                startTime: timing.start,
                equilibriumTime: timing.equilibrium
            )
        }

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

private class GaseousSetTemperature: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        doApply(on: model, setComponents: true)
    }

    override func reapply(on model: GaseousReactionViewModel) {
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: GaseousReactionViewModel, setComponents: Bool) {
        model.statement = GaseousStatements.instructToSetTemp
        let timing = GaseousReactionSettings.heatTiming
        withAnimation(.easeOut(duration: 1)) {
            model.showFlame = true
            model.inputState = .setTemperature
            model.chartOffset = timing.offset
            model.currentTime = timing.start
        }
        if setComponents {
            model.componentWrapper = ReactionComponentsWrapper(
                previous: model.componentWrapper,
                startTime: timing.start,
                equilibriumTime: timing.equilibrium
            )
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        if let previous = model.componentWrapper.previous {
            model.componentWrapper = previous
        }
    }
}
