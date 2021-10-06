//
// Reactions App
//


import Foundation
import ReactionsCore
import SwiftUI

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
        InstructToAddUnknownReactant(),
        RunInitialReaction(),
        EndInitialReaction(\.instructToWeighProduct),
        PostWeighingProduct(),
        RevealUnknownMetal(),
        AddExtraKnownReactant(\.instructToAddFurtherUnknownReactant),
        RunFinalReaction(),
        EndFinalReaction(\.finalStatement)
    ]
}

private let reactionDuration: TimeInterval = 3

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

    let getStatement: (PrecipitationScreenViewModel) -> [TextLine]

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
        model.components.phase = .addKnownReactant
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.equationState = .blank
        model.shakeModel.stopAll()
        model.components.resetPhase()
    }
}

private class InstructToAddUnknownReactant: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        model.components.phase = .addUnknownReactant
        doApply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        let molesAdded = model.equationData.knownReactantMoles
        model.statement = statements.instructToAddUnknownReactant(molesAdded: molesAdded)
        model.input = .addReactant(type: .unknown)
        model.shakeModel.stopAll()
        model.components.phase = .addUnknownReactant
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.shakeModel.stopAll()
        model.components.goBackToPreviousPhase()
    }
}

private class RunReaction: PrecipitationScreenState {
    init(
        statement: @escaping (PrecipitationScreenViewModel) -> [TextLine],
        phase: PrecipitationComponents.Phase
    ) {
        self.statement = statement
        self.phase = phase
    }

    let statement: (PrecipitationScreenViewModel) -> [TextLine]
    let phase: PrecipitationComponents.Phase

    private var reactionsToRun: Int = 0

    override func apply(on model: PrecipitationScreenViewModel) {
        model.components.phase = phase
        doApply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        model.shakeModel.stopAll()
        model.input = nil
        model.statement = statement(model)

        reactionsToRun = model.components.currentComponents.reactionsToRun

        withAnimation(.linear(duration: reactionDuration)) {
            model.components.runReaction()
        }

        if reactionsToRun > 0 {
            model.components.currentComponents.runOneReactionProgressReaction()
        }
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.components.goBackToPreviousPhase()
    }

    override func nextStateAutoDispatchDelay(model: PrecipitationScreenViewModel) -> Double? {
        reactionDuration
    }

    override func delayedStates(model: PrecipitationScreenViewModel) -> [DelayedState<PrecipitationScreenState>] {
        guard reactionsToRun > 1 else {
            return []
        }

        // note we run the first reaction in the apply method, so only
        // need to trigger the remaining ones
        let dt = reactionDuration / Double(reactionsToRun)
        let indices = (1..<reactionsToRun)

        return indices.map { _ in
            DelayedState(
                state: RunOneReactionState(),
                delay: dt
            )
        }
    }

    private class RunOneReactionState: PrecipitationScreenState {
        override func apply(on model: PrecipitationScreenViewModel) {
            model.components.currentComponents.runOneReactionProgressReaction()
        }
    }
}

private class RunInitialReaction: RunReaction {

    init() {
        super.init(
            statement: { model in
                let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
                let massEquation = model.components.reactingMassOfUnknownReactant
                let reactionProgress = model.components.currentComponents.endOfReaction
                let massAdded = massEquation.getY(at: reactionProgress)

                return statements.runInitialReaction(unknownReactantGramsAdded: massAdded)
            },
            phase: .runReaction
        )
    }
}

private class EndInitialReaction: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        withAnimation(.easeOut(duration: 0.35)) {
            model.components.completeReaction()
        }
        model.input = .weighProduct
    }
}

private class PostWeighingProduct: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        let components = model.components
        model.statement = statements.showWeightOfProduct(
            productGrams: components.productMass.getY(at: components.reactionProgress),
            productMoles: components.productMoles.getY(at: components.reactionProgress),
            unknownReactantGrams: components.unknownReactantMass,
            unknownReactantMoles: components.unknownReactantMoles
        )
        model.input = nil
        model.equationState = .showAll
    }
}

private class RevealUnknownMetal: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        model.statement = statements.revealKnownMetal(
            unknownReactantGrams: model.components.unknownReactantMass,
            unknownReactantMoles: model.components.unknownReactantMoles
        )
        model.showUnknownMetal = true
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.showUnknownMetal = false
    }
}

private class AddExtraKnownReactant: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        model.components.phase = .addExtraUnknownReactant
        doApply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        model.statement = getStatement(model)
        model.input = .addReactant(type: .unknown)
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.shakeModel.stopAll()
        model.components.goBackToPreviousPhase()
    }
}

private class RunFinalReaction: RunReaction {

    init() {
        super.init(
            statement: { model in
                let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
                return statements.runFinalReaction
            },
            phase: .runFinalReaction
        )
    }
}

private class EndFinalReaction: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        withAnimation(.easeOut(duration: 0.35)) {
            model.components.completeReaction()
        }
    }
}
