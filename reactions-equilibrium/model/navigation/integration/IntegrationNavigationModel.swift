//
// Reactions App
//

import Foundation
import ReactionsCore

private let statements = IntegrationStatements.self

struct IntegrationNavigationModel {
    private init() { }

    static func model(model: IntegrationViewModel) -> NavigationModel<IntegrationScreenState> {
        NavigationModel(model: model, states: states)
    }

    private static let states: [IntegrationScreenState] = [
        SetStatement(statement: statements.instructToChooseReaction),
        SetWater(),
        SetStatement(statement: statements.showPreviousEquations, highlights: [.integrationRateDefinitions]),
        SetStatement(statement: { statements.showRateConstantParts(model: $0) }, highlights: [.integrationRateDefinitions]),
        SetStatement(statement: statements.compareRates, highlights: [.integrationRateValues]),
        AddReactants()
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

private class SetWater: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.instructToSetWaterLevel
        model.inputState = .setLiquidLevel
        model.highlightedElements.elements = [.waterSlider]
    }

    override func unapply(on model: IntegrationViewModel) {
        model.highlightedElements.clear()
        model.inputState = .none
    }
}

private class AddReactants: IntegrationScreenState {
    override func apply(on model: IntegrationViewModel) {
        model.statement = statements.instructToAddReactant(selected: model.selectedReaction)
        model.inputState == .addReactants
        model.highlightedElements.elements = [.moleculeContainers]
    }

    override func unapply(on model: IntegrationViewModel) {
        model.inputState = .none
        model.highlightedElements.clear()
    }
}
