//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousNavigationModel {

    static func model(
        model: AqueousReactionViewModel
    ) -> NavigationModel<AqueousScreenState> {
        NavigationModel(
            model: model,
            states: states
        )
    }

    private static let states = [
        SetStatementState(statement: AqueousStatements.intro, highlights: [.reactionToggle]),
        HasSelectedReactionState(),
        SetStatementState(statement: AqueousStatements.explainQuotient1),
        SetStatementState(statement: AqueousStatements.explainQuotient2, highlights: [.quotientToConcentrationDefinition]),
        SetStatementState(statement: AqueousStatements.explainQuotient3, highlights: [.quotientToEquilibriumConstantDefinition]),
        SetStatementState(statement: AqueousStatements.explainQuotient4, highlights: [.quotientToConcentrationDefinition]),
        SetStatementState(statement: AqueousStatements.explainQuotient5, highlights: [.quotientToConcentrationDefinition]),
        SetStatementState(statement: AqueousStatements.explainK, highlights: [.quotientToEquilibriumConstantDefinition]),
        SetWaterLevelState(),
        AddReactantState(),
        PreRunAnimationState(),
        RunAnimationState(),
        EndAnimationState(statement: AqueousStatements.reachedEquilibrium, endTime: AqueousReactionSettings.forwardReactionTime),
        CanSetCurrentTimeState(),
        SetStatementState(statement: AqueousStatements.leChatelier),
        ShiftChartState(),
        InstructToAddProductState(),
        PreReverseAnimation(),
        RunReverseAnimation(),
        EndAnimationState(
            statement: AqueousStatements.reverseEquilibriumReached,
            endTime: AqueousReactionSettings.endOfReverseReaction
        ),
        CanSetCurrentTimeState(),
        FinalState()
    ]
}

class AqueousScreenState: ScreenState, SubState {

    typealias Model = AqueousReactionViewModel
    typealias NestedState = AqueousScreenState

    func delayedStates(model: AqueousReactionViewModel) -> [DelayedState<AqueousScreenState>] {
        []
    }

    func apply(on model: AqueousReactionViewModel) { }

    func unapply(on model: AqueousReactionViewModel) { }

    func reapply(on model: AqueousReactionViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        nil
    }
    
    var backBehaviour: NavigationModelBackBehaviour {
        .unapply
    }
}

private class SetStatementState: AqueousScreenState {

    let statement: [TextLine]
    let highlights: [AqueousScreenElement]
    init(statement: [TextLine], highlights: [AqueousScreenElement] = []) {
        self.statement = statement
        self.highlights = highlights
    }

    private var initialElements = [AqueousScreenElement]()

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = statement
        initialElements = model.highlightedElements.elements
        model.highlightedElements.elements = highlights
        model.canSetCurrentTime = false
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.highlightedElements.elements = initialElements
    }
}

private class HasSelectedReactionState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.explainEquilibrium
        model.inputState = .none
        model.reactionSelectionIsToggled = false
        model.highlightedElements.clear()
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.reactionSelectionIsToggled = true
        model.inputState = .selectReactionType
    }

}

private class SetWaterLevelState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.inputState = .setLiquidLevel
        model.statement = AqueousStatements.instructToSetWaterLevel
        model.highlightedElements.elements = [.waterSlider]
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.inputState = .none
    }
}

private class AddReactantState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToAddReactant(selected: model.selectedReaction)
        model.inputState = .addReactants
        model.showConcentrationLines = true
        model.showEquationTerms = true
        model.highlightedElements.elements = [.moleculeContainers]
        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func reapply(on model: AqueousReactionViewModel) {
        model.resetMolecules()
        super.reapply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.stopShaking()
        model.resetMolecules()
        model.showConcentrationLines = false
        model.showEquationTerms = false
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

private class PreRunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.preAnimation
        model.inputState = .none
        model.showQuotientLine = true
        model.stopShaking()
        model.highlightedElements.clear()
        DeferScreenEdgesState.shared.deferEdges = []
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.showQuotientLine = false
    }
}

private class RunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.runAnimation
        model.reactionDefinitionDirection = .forward
        let time = AqueousReactionSettings.forwardReactionTime
        model.currentTime = 0
        withAnimation(.linear(duration: Double(time))) {
            model.currentTime = time
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.reactionDefinitionDirection = .none
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.highlightedElements.clear()
        }
    }

    override func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.forwardReactionTime)
    }

    override func delayedStates(model: AqueousReactionViewModel) -> [DelayedState<AqueousScreenState>] {
        func delayedState(
            _ statement: [TextLine],
            _ delay: Double,
            _ elements: [AqueousScreenElement] = [],
            _ direction: ReactionDefinitionArrowDirection? = nil
        ) -> DelayedState<AqueousScreenState> {
            DelayedState(
                state: RunReactionDelayedState(
                    statement: statement,
                    highlights: elements,
                    reactionDirection: direction
                ),
                delay: delay
            )
        }
        let delay = Double(AqueousReactionSettings.timeForConvergence / 2)
        return [
            delayedState(AqueousStatements.midAnimation, delay),
            delayedState(
                AqueousStatements.reachedEquilibrium,
                delay,
                [.chartEquilibrium, .reactionDefinition],
                .equilibrium
            ),
        ]
    }
}

private class RunReactionDelayedState: AqueousScreenState {
    init(
        statement: [TextLine],
        highlights: [AqueousScreenElement],
        reactionDirection: ReactionDefinitionArrowDirection?
    ) {
        self.statement = statement
        self.highlights = highlights
        self.reactionDirection = reactionDirection
    }

    let statement: [TextLine]
    let highlights: [AqueousScreenElement]
    let reactionDirection: ReactionDefinitionArrowDirection?

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = statement
        model.highlightedElements.elements = highlights
        if let direction = reactionDirection {
            model.reactionDefinitionDirection = direction
        }
    }
}

private class EndAnimationState: AqueousScreenState {

    let statement: [TextLine]
    let endTime: CGFloat

    init(statement: [TextLine], endTime: CGFloat) {
        self.statement = statement
        self.endTime = endTime
    }

    override func apply(on model: AqueousReactionViewModel) {
        doApply(on: model, isReapplying: false)
    }

    override func reapply(on model: AqueousReactionViewModel) {
        doApply(on: model, isReapplying: true)
    }

    private func doApply(on model: AqueousReactionViewModel, isReapplying: Bool) {
        model.statement = statement
        model.reactionDefinitionDirection = .equilibrium
        if isReapplying {
            model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = endTime * endOfReactionFactor
            if !isReapplying {
                model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
            }
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.highlightedElements.clear()
        model.reactionDefinitionDirection = .none
    }
}

private class CanSetCurrentTimeState: AqueousScreenState {

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToChangeCurrentTime
        model.highlightedElements.clear()
        model.canSetCurrentTime = true
        model.reactionDefinitionDirection = .none
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = false
    }

}

private class ShiftChartState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.introToReverse
        model.canSetCurrentTime = false
        model.timing = AqueousReactionSettings.secondReactionTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = model.timing.offset
            model.currentTime = model.timing.start
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.timing = AqueousReactionSettings.firstReactionTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = model.timing.offset
            model.currentTime = model.timing.end
        }
        model.canSetCurrentTime = true
    }
}

private class InstructToAddProductState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToAddProduct(selected: model.selectedReaction)
        model.inputState = .addProducts
        model.highlightedElements.elements = [.moleculeContainers]
        model.componentsWrapper = ReactionComponentsWrapper(
            previous: model.componentsWrapper,
            startTime: AqueousReactionSettings.timeToAddProduct,
            equilibriumTime: AqueousReactionSettings.timeForReverseConvergence
        )
        model.reactionPhase = .second
        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func reapply(on model: AqueousReactionViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        apply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.inputState = .none
        model.highlightedElements.clear()
        model.stopShaking()
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        DeferScreenEdgesState.shared.deferEdges = []
        model.reactionPhase = .first
    }
}

private class PreReverseAnimation: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.preReverseReaction
        model.inputState = .none
        model.highlightedElements.clear()
        model.stopShaking()
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

private class RunReverseAnimation: AqueousScreenState {

    private let tAddProduct = AqueousReactionSettings.timeToAddProduct
    private let tConvergence = AqueousReactionSettings.timeForReverseConvergence
    private let tEnd = AqueousReactionSettings.endOfReverseReaction

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.reverseReactionStarted
        model.reactionDefinitionDirection = .reverse
        withAnimation(.linear(duration: Double(tEnd - tAddProduct))) {
            model.currentTime = tEnd
        }
    }

    override func reapply(on model: AqueousReactionViewModel) {
        model.currentTime = tAddProduct
        super.reapply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.reactionDefinitionDirection = .none
        withAnimation(.easeOut(duration: Double(0.5))) {
            model.currentTime = tAddProduct
            model.highlightedElements.clear()
        }
    }

    override func delayedStates(model: AqueousReactionViewModel) -> [DelayedState<AqueousScreenState>] {
        let tToConvergence = tConvergence - tAddProduct
        let delay = Double(tToConvergence / 2)
        return [
            DelayedState(
                state: RunReactionDelayedState(
                    statement: AqueousStatements.midReverseReaction,
                    highlights: [],
                    reactionDirection: nil
                ),
                delay: delay
            ),
            DelayedState(
                state: RunReactionDelayedState(
                    statement: AqueousStatements.reverseEquilibriumReached,
                    highlights: [.chartEquilibrium],
                    reactionDirection: .equilibrium
                ),
                delay: delay
            )
        ]
    }

    override func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.endOfReverseReaction - AqueousReactionSettings.timeToAddProduct)
    }
}

private class FinalState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.endStatement
        model.canSetCurrentTime = false
        model.highlightedElements.clear()
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = true
    }
}

private let endOfReactionFactor: CGFloat = 1.0001
