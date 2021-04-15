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
        GaseousSetStatement(statement: GaseousStatements.intro, highlights: [.reactionToggle]),
        GaseousAfterChoosingReaction(),
        GaseousSetStatement(
            statement: GaseousStatements.explainK,
            highlights: [.quotientToEquilibriumConstantDefinition]
        ),
        GaseousAddProducts(),
        GaseousRunReaction(
            timing: GaseousReactionSettings.forwardTiming,
            isForward: true,
            revealQuotientLine: true
        ),
        GaseousEndOfReaction(
            statement: GaseousStatements.forwardEquilibriumReached,
            timing: GaseousReactionSettings.forwardTiming
        ),
        GaseousSetCurrentTime(),
        GaseousShiftChart(
            statement: GaseousStatements.chatelier,
            timing: GaseousReactionSettings.pressureTiming,
            previousTiming: GaseousReactionSettings.forwardTiming
        ),
        GaseousSetVolume(),
        GaseousExplainChangeInVolume(),
        GaseousPrePressureReaction(),
        GaseousRunReaction(
            timing: GaseousReactionSettings.pressureTiming,
            isForward: true
        ),
        GaseousEndOfReaction(
            statement: GaseousStatements.forwardEquilibriumReached,
            timing: GaseousReactionSettings.pressureTiming
        ),
        GaseousSetCurrentTime(),
        GaseousSetStatement(statement: GaseousStatements.endOfPressureReaction),
        GaseousShiftChart(
            statement: GaseousStatements.chatelier2,
            timing: GaseousReactionSettings.heatTiming,
            previousTiming: GaseousReactionSettings.pressureTiming
        ),
        GaseousSetTemperature(),
        GaseousSetStatement(statement: GaseousStatements.preHeatReaction),
        GaseousRunReaction(
            timing: GaseousReactionSettings.heatTiming,
            isForward: true
        ),
        GaseousEndOfReaction(
            statement: GaseousStatements.forwardEquilibriumReached,
            timing: GaseousReactionSettings.heatTiming
        ),
        GaseousSetCurrentTime(),
        GaseousSetStatement(
            statement: GaseousStatements.end
        )
    ]
}

class GaseousScreenState: ScreenState, SubState {

    typealias Model = GaseousReactionViewModel
    typealias NestedState = GaseousScreenState

    func delayedStates(model: GaseousReactionViewModel) -> [DelayedState<GaseousScreenState>] {
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

    init(
        statement: [TextLine],
        highlights: [GaseousScreenElement] = []
    ) {
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
        model.highlightedElements.elements = [.pump]
        model.showConcentrationLines = true
    }

    override func unapply(on model: GaseousReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.resetMolecules()
            model.showConcentrationLines = false
        }
        model.inputState = .none
    }
}

private class GaseousRunReaction: GaseousScreenState {
    let timing: ReactionTiming
    let isForward: Bool
    let revealQuotientLine: Bool

    init(
        timing: ReactionTiming,
        isForward: Bool,
        revealQuotientLine: Bool = false
    ) {
        self.timing = timing
        self.isForward = isForward
        self.revealQuotientLine = revealQuotientLine
    }

    override func apply(on model: GaseousReactionViewModel) {
        model.statement = GaseousStatements.reactionRunning(direction: model.components.equation.direction)
        if revealQuotientLine {
            model.showQuotientLine = true
        }
        model.highlightForwardReactionArrow = isForward
        model.highlightReverseReactionArrow = !isForward
        model.currentTime = timing.start
        model.inputState = .none
        model.highlightedElements.clear()
        withAnimation(.linear(duration: Double(duration))) {
            model.currentTime = timing.end
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = timing.start
            model.highlightForwardReactionArrow = false
            model.highlightReverseReactionArrow = false
            if revealQuotientLine {
                model.showQuotientLine = false
            }
        }
    }

    override func nextStateAutoDispatchDelay(model: GaseousReactionViewModel) -> Double? {
        Double(duration)
    }

    private var duration: CGFloat {
        timing.end - timing.start
    }

    override func delayedStates(model: GaseousReactionViewModel) -> [DelayedState<GaseousScreenState>] {
        func delayedState(_ statement: [TextLine], _ highlights: [GaseousScreenElement]) -> DelayedState<GaseousScreenState> {
            DelayedState(
                state: GaseousSetStatement(statement: statement, highlights: highlights),
                delay: Double((timing.equilibrium - timing.start) / 2)
            )
        }

        return [
            delayedState(GaseousStatements.midReaction(direction: model.components.equation.direction), []),
            delayedState(GaseousStatements.forwardEquilibriumReached, [.chartEquilibrium])
        ]
    }
}

private class GaseousEndOfReaction: GaseousScreenState {

    let statement: [TextLine]
    let timing: ReactionTiming

    init(statement: [TextLine], timing: ReactionTiming) {
        self.statement = statement
        self.timing = timing
    }

    override func apply(on model: GaseousReactionViewModel) {
        doApply(on: model, isReapplying: false)
    }

    override func reapply(on model: GaseousReactionViewModel) {
        doApply(on: model, isReapplying: true)
    }

    private func doApply(on model: GaseousReactionViewModel, isReapplying: Bool) {
        model.statement = statement
        model.highlightForwardReactionArrow = false
        model.highlightReverseReactionArrow = false
        if isReapplying {
            model.highlightedElements.elements = [.chartEquilibrium]
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = timing.end * 1.001
            if !isReapplying {
                model.highlightedElements.elements = [.chartEquilibrium]
            }
            model.activeChartIndex = nil
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.canSetChartIndex = false
    }
}

private class GaseousSetCurrentTime: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        model.highlightedElements.clear()
        model.statement = GaseousStatements.instructToSetTime
        model.canSetCurrentTime = true
        model.canSetChartIndex = true
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.canSetCurrentTime = false
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
        model.highlightedElements.elements = [.pressureSlider]
        let timing = GaseousReactionSettings.pressureTiming
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .setBeakerVolume
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
        model.highlightedElements.clear()
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.rows = CGFloat(GaseousReactionSettings.initialRows)
        }
        if let previous = model.componentWrapper.previous {
            model.componentWrapper = previous
        }
    }
}

private class GaseousExplainChangeInVolume: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        let coeffs = model.selectedReaction.coefficients
        let productCoeffs = coeffs.productC + coeffs.productD
        let reactantCoeffs = coeffs.reactantA + coeffs.reactantB
        let productsHigher = productCoeffs > reactantCoeffs
        if model.volumeHasDecreased {
            model.statement = GaseousStatements.explainReducedVolume(productsHaveHigherExponents: productsHigher)
        } else {
            model.statement = GaseousStatements.explainIncreasedVolume(productsHaveHigherExponents: productsHigher)
        }
        model.inputState = .none
        model.highlightedElements.clear()
    }
}

private class GaseousShiftChart: GaseousScreenState {

    let statement: [TextLine]
    let timing: ReactionTiming
    let previousTiming: ReactionTiming

    init(
        statement: [TextLine],
        timing: ReactionTiming,
        previousTiming: ReactionTiming
    ) {
        self.statement = statement
        self.timing = timing
        self.previousTiming = previousTiming
    }

    override func apply(on model: GaseousReactionViewModel) {
        model.statement = statement
        model.canSetChartIndex = false
        model.canSetCurrentTime = false
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = timing.offset
            model.currentTime = timing.start
            model.activeChartIndex = nil
        }
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.canSetChartIndex = true
        model.canSetCurrentTime = true
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = previousTiming.offset
            model.currentTime = previousTiming.end
        }
    }
}

private class GaseousPrePressureReaction: GaseousScreenState {
    override func apply(on model: GaseousReactionViewModel) {
        model.statement = GaseousStatements.prePressureReaction(
            selected: model.selectedReaction,
            pressureIncreased: model.volumeHasDecreased,
            direction: model.components.equation.direction
        )
        model.highlightedElements.elements = [.reactionDefinition]
    }

    override func unapply(on model: GaseousReactionViewModel) {
        model.highlightedElements.clear()
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
        model.highlightedElements.elements = [.tempSlider]
        let timing = GaseousReactionSettings.heatTiming
        withAnimation(.easeOut(duration: 0.5)) {
            model.showFlame = true
            model.inputState = .setTemperature
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
        model.highlightedElements.clear()
        withAnimation(.easeOut(duration: 0.5)) {
            model.showFlame = false
            model.extraHeatFactor = 0
            model.inputState = .none
        }
        if let previous = model.componentWrapper.previous {
            model.componentWrapper = previous
        }
    }
}
