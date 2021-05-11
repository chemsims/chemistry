//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = IntegrationStatements.self

struct IntegrationNavigationModel {
    private init() { }

    static func model(model: IntegrationViewModel) -> NavigationModel<IntegrationScreenState> {
        NavigationModel(model: model, states: states)
    }

    private static let states: [IntegrationScreenState] = [
        SetReactionType(),
        SetWater(),
        SetStatement(statement: statements.showPreviousEquations, highlights: [.integrationRateDefinitions]),
        SetStatement(statement: { statements.showRateConstantParts(reaction: $0.selectedReaction) }, highlights: [.integrationRateDefinitions]),
        SetStatement(statement: statements.compareRates, highlights: [.integrationRateValues]),
        AddReactants(),
        PrepareForwardReaction(),
        RunForwardReaction(),
        EndReaction(statement: statements.forwardEquilibrium),
        SetCurrentTime(),
        ShiftChart(),
        AddProduct(),
        PrepareReverseReaction(),
        RunReverseReaction(),
        EndReaction(statement: statements.reverseEquilibrium, highlightEquilibrium: false),
        FinalState()
    ]
}


class IntegrationScreenState: ScreenState, SubState {

    typealias NestedState = IntegrationScreenState
    typealias Model = IntegrationViewModel

    func apply(on model: IntegrationViewModel) {
    }

    func reapply(on model: IntegrationViewModel) {
        apply(on: model)
    }

    func unapply(on model: IntegrationViewModel) {
    }

    func delayedStates(model: IntegrationViewModel) -> [DelayedState<IntegrationScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: IntegrationViewModel) -> Double? {
        nil
    }
}

private class SetStatement: IntegrationScreenState {

    let statement: (IntegrationViewModel) -> [TextLine]
    let highlights: [AqueousScreenElement]

    convenience init(statement: [TextLine], highlights: [AqueousScreenElement] = []) {
        self.init(statement: { _ in statement }, highlights: highlights)
    }

    init(statement: @escaping (IntegrationViewModel) -> [TextLine], highlights: [AqueousScreenElement] = []) {
        self.statement = statement
        self.highlights = highlights
    }

    private var initialElements = [AqueousScreenElement]()

    override func apply(on model: IntegrationViewModel) {
        model.statement = statement(model)
        initialElements = model.highlightedElements.elements
        model.highlightedElements.elements = highlights
        model.canSetCurrentTime = false
    }

    override func unapply(on model: IntegrationViewModel) {
        model.highlightedElements.elements = initialElements
    }
}

private class SetReactionType: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.instructToChooseReaction
        model.inputState = .selectReactionType
        model.reactionSelectionIsToggled = true
    }
}

private class SetWater: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.instructToSetWaterLevel
        model.inputState = .setLiquidLevel
        model.highlightedElements.elements = [.waterSlider]
        model.reactionSelectionIsToggled = false
    }

    override func unapply(on model: IntegrationViewModel) {
        model.highlightedElements.clear()
        model.inputState = .none
    }
}

private class AddReactants: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.instructToAddReactant(selected: model.selectedReaction)
        model.highlightedElements.elements = [.moleculeContainers]
        model.inputState = .addReactants
        model.showConcentrationLines = true
        model.showEquationTerms = true
        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func unapply(on model: IntegrationViewModel) {
        model.inputState = .none
        model.highlightedElements.clear()
        model.resetMolecules()
        model.stopShaking()
        model.showConcentrationLines = false
        model.showEquationTerms = false
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

private class PrepareForwardReaction: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.preForwardReaction
        model.showQuotientLine = true
        model.inputState = .none
        model.stopShaking()
        model.highlightedElements.clear()
        DeferScreenEdgesState.shared.deferEdges = []
    }

    override func unapply(on model: IntegrationViewModel) {
        model.showQuotientLine = false
    }
}

private class RunForwardReaction: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = AqueousStatements.runAnimation
        model.reactionDefinitionDirection = .forward
        model.currentTime = 0
        withAnimation(.linear(duration: Double(model.timing.end))) {
            model.currentTime = model.timing.end
        }
    }

    override func unapply(on model: IntegrationViewModel) {
        model.reactionDefinitionDirection = .none
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.highlightedElements.clear()
        }
    }

    override func nextStateAutoDispatchDelay(model: IntegrationViewModel) -> Double? {
        Double(model.timing.end)
    }

    override func delayedStates(model: IntegrationViewModel) -> [DelayedState<IntegrationScreenState>] {
        [
            DelayedState(
                state: EquilibriumState(),
                delay: Double(model.timing.equilibrium)
            )
        ]
    }

    private class EquilibriumState: IntegrationScreenState {
        override func apply(on model: IntegrationViewModel) {
            model.statement = statements.forwardEquilibrium
            model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
            model.reactionDefinitionDirection = .equilibrium
        }
    }

}

private class EndReaction: IntegrationScreenState {

    let statement: [TextLine]
    let highlightEquilibrium: Bool

    init(
        statement: [TextLine],
        highlightEquilibrium: Bool = true
    ) {
        self.statement = statement
        self.highlightEquilibrium = highlightEquilibrium
    }


    override func apply(on model: IntegrationViewModel) {
        doApply(on: model, isReapplying: false)
    }

    override func reapply(on model: IntegrationViewModel) {
        doApply(on: model, isReapplying: true)
    }

    private func doApply(on model: IntegrationViewModel, isReapplying: Bool) {
        model.statement = statement
        model.reactionDefinitionDirection = .equilibrium
        if highlightEquilibrium && isReapplying {
            model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.end * 1.0001
            if highlightEquilibrium && !isReapplying {
                model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
            }
        }
    }

    override func unapply(on model: IntegrationViewModel) {
        model.highlightedElements.clear()
        model.reactionDefinitionDirection = .none
    }
}

private class SetCurrentTime: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = AqueousStatements.instructToChangeCurrentTime
        model.highlightedElements.clear()
        model.canSetCurrentTime = true
        model.reactionDefinitionDirection = .none
    }

    override func unapply(on model: IntegrationViewModel) {
        model.canSetCurrentTime = false
    }
}

private class ShiftChart: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.preAddProduct
        model.canSetCurrentTime = false
        model.timing = AqueousReactionSettings.secondReactionTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = model.timing.offset
            model.currentTime = model.timing.start
        }
    }

    override func reapply(on model: IntegrationViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        apply(on: model)
    }

    override func unapply(on model: IntegrationViewModel) {
        model.timing = AqueousReactionSettings.firstReactionTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = model.timing.offset
            model.currentTime = model.timing.end
        }
        model.canSetCurrentTime = true
    }
}

private class AddProduct: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.addProduct(selected: model.selectedReaction)
        model.inputState = .addProducts
        model.highlightedElements.elements = [.moleculeContainers]

        model.reactionPhase = .second
        DeferScreenEdgesState.shared.deferEdges = [.top]

        model.componentsWrapper = ReactionComponentsWrapper(
            previous: model.componentsWrapper,
            startTime: model.timing.start,
            equilibriumTime: model.timing.end
        )
    }

    override func reapply(on model: IntegrationViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        apply(on: model)
    }

    override func unapply(on model: IntegrationViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        model.inputState = .none
        model.highlightedElements.clear()
        model.stopShaking()
        DeferScreenEdgesState.shared.deferEdges = []
        model.reactionPhase = .first
    }
}

private class PrepareReverseReaction: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.preReverseReaction
        DeferScreenEdgesState.shared.deferEdges = []
        model.stopShaking()
        model.highlightedElements.clear()
        model.inputState = .none
    }
}

private class RunReverseReaction: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.reverseReactionRunning
        model.reactionDefinitionDirection = .reverse
        let duration = Double(model.timing.end - model.timing.start)
        withAnimation(.linear(duration: duration)) {
            model.currentTime = model.timing.end
        }
    }

    override func reapply(on model: IntegrationViewModel) {
        model.currentTime = model.timing.start
        apply(on: model)
    }

    override func unapply(on model: IntegrationViewModel) {
        model.reactionDefinitionDirection = .none
        withAnimation(.easeOut(duration: Double(0.5))) {
            model.currentTime = model.timing.start
            model.highlightedElements.clear()
        }
    }

    override func nextStateAutoDispatchDelay(model: IntegrationViewModel) -> Double? {
        Double(model.timing.end - model.timing.start)
    }
}

private class FinalState: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.end
        model.canSetCurrentTime = true
        model.highlightedElements.clear()
        model.reactionDefinitionDirection = .none
    }

    override func unapply(on model: IntegrationViewModel) {
        model.canSetCurrentTime = false
    }
}
