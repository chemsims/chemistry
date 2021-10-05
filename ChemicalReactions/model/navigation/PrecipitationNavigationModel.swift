//
// Reactions App
//


import Foundation
import ReactionsCore

private let statements = PrecipitationStatements.self

struct PrecipitationNavigationModel {
    private init() { }

    static func model(using viewModel: PrecipitationScreenViewModel) -> NavigationModel<PrecipitationScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [PrecipitationScreenState] = [
        SetStatement(statements.intro),
        StopInput(\.explainPrecipitation),
        SetStatement(statements.explainUnknownMetal),
        InstructToSetWaterLevel(statements.instructToSetWaterLevel),
        InstructToAddKnownReactant(\.instructToAddKnownReactant),
        InstructToAddUnknownReactant()
    ]
}

class PrecipitationScreenState: ScreenState, SubState {
    typealias Model = PrecipitationScreenViewModel
    typealias NestedState = PrecipitationScreenState

    func apply(on model: PrecipitationScreenViewModel) {
    }

    func reapply(on model: PrecipitationScreenViewModel) {
        apply(on: model)
    }

    func unapply(on model: PrecipitationScreenViewModel) {
    }

    func delayedStates(model: PrecipitationScreenViewModel) -> [DelayedState<PrecipitationScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: PrecipitationScreenViewModel) -> Double? {
        nil
}
}

private class SetStatement: PrecipitationScreenState {
    init(_ statement: [TextLine]) {
        self.getStatement = { _ in statement }
    }

    init(_ statementKeyPath: KeyPath<PrecipitationReactionStatements, [TextLine]>) {
        self.getStatement = {
            let statements = PrecipitationReactionStatements(reaction: $0.chosenReaction)
            return statements[keyPath: statementKeyPath]
        }
    }

    private let getStatement: (PrecipitationScreenViewModel) -> [TextLine]

    override func apply(on model: PrecipitationScreenViewModel) {
        model.statement = getStatement(model)
    }
}

private class StopInput: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = nil
    }
}

private class InstructToSetWaterLevel: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = .setWaterLevel
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
    }
}

private class InstructToAddKnownReactant: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .known)
        model.equationState = .showKnownReactantMolarity
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.equationState = .blank
    }
}

private class InstructToAddUnknownReactant: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        let molesAdded = model.equationData.knownReactantMoles
        model.statement = statements.instructToAddUnknownReactant(molesAdded: molesAdded)
        model.input = .addReactant(type: .unknown)
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
    }
}

private class RunReaction: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        let massEquation = model.equationData.unknownReactantMass
        let reactionProgress = PrecipitationComponents.reactionProgressAtEndOfFinalReaction
        let massAdded = massEquation.getY(at: reactionProgress)
        model.statement = statements.runInitialReaction(unknownReactantGramsAdded: massAdded)
        model.input = nil
    }
}
