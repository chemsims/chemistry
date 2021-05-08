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
        SetStatement(statement: { statements.showRateConstantParts(model: $0) }, highlights: [.integrationRateDefinitions]),
        SetStatement(statement: statements.compareRates, highlights: [.integrationRateValues]),
        AddReactants(),
        PrepareForwardReaction(),
        RunForwardReaction(),
        EndForwardReaction()
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
}

private class EndForwardReaction: IntegrationScreenState {



    override func apply(on model: IntegrationViewModel) {
        doApply(on: model, isReapplying: false)
    }

    override func reapply(on model: IntegrationViewModel) {
        doApply(on: model, isReapplying: true)
    }

    private func doApply(on model: IntegrationViewModel, isReapplying: Bool) {
        model.statement = statements.equilibriumReached(rate: model.kf)
        model.reactionDefinitionDirection = .equilibrium
        if isReapplying {
            model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.end * 1.0001
            if !isReapplying {
                model.highlightedElements.elements = [.chartEquilibrium, .reactionDefinition]
            }
        }
    }

    override func unapply(on model: IntegrationViewModel) {
        model.highlightedElements.clear()
        model.reactionDefinitionDirection = .none
    }
}
