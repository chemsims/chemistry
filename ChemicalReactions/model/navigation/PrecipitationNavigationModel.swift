//
// Reactions App
//

import Foundation
import ReactionsCore
import SwiftUI

private let statements = PrecipitationStatements.self

struct PrecipitationNavigationModel {
    private init() { }

    static func model(
        using viewModel: PrecipitationScreenViewModel,
        persistence: PrecipitationInputPersistence
    ) -> NavigationModel<PrecipitationScreenState> {
        NavigationModel(model: viewModel, states: states(persistence: persistence))
    }

    private static func states(persistence: PrecipitationInputPersistence) -> [PrecipitationScreenState] {
        firstReaction(persistence: persistence) + secondReaction(persistence: persistence)
    }

    private static func firstReaction(persistence: PrecipitationInputPersistence) -> [PrecipitationScreenState] {
        let initialReaction = [ChooseReaction(statements.intro, highlights: [.reactionToggle])]
        return initialReaction + commonExperiment(persistence: persistence)
    }

    private static func secondReaction(persistence: PrecipitationInputPersistence) -> [PrecipitationScreenState] {
        let initialReaction = [PrepareNewReaction(statements.chooseNextReaction)]
        return initialReaction + commonExperiment(persistence: persistence)
    }

    private static func commonExperiment(persistence: PrecipitationInputPersistence) -> [PrecipitationScreenState] {
        [
            StopInput(\.explainPrecipitation, highlights: [.reactionDefinition]),
            ExplainUnknownMetal(statements.explainUnknownMetal, highlights: [.reactionDefinition, .metalTable]),
            InstructToSetWaterLevel(statements.instructToSetWaterLevel, highlights: [.waterSlider]),
            InstructToAddKnownReactant(\.instructToAddKnownReactant, highlights: [.knownReactantContainer]),
            InstructToAddUnknownReactant(),
            RunInitialReaction(),
            EndInitialReaction(\.endOfInitialReaction, highlights: [.beaker, .beakerToggle]),
            InitialWeightProduct(\.instructToWeighProduct),
            PostWeighingProduct(),
            RevealUnknownMetal(),
            AddExtraKnownReactant(\.instructToAddFurtherUnknownReactant),
            RunFinalReaction(),
            EndFinalReaction(persistence: persistence)
        ]
    }
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
    
    var backBehaviour: NavigationModelBackBehaviour {
        .unapply
    }
}

private class SetStatement: PrecipitationScreenState {
    init(_ statement: [TextLine], highlights: [PrecipitationScreenViewModel.ScreenElement] = []) {
        self.getStatement = { _ in statement }
        self.highlights = highlights
    }

    init(
        _ statementKeyPath: KeyPath<PrecipitationReactionStatements, [TextLine]>,
        highlights: [PrecipitationScreenViewModel.ScreenElement] = []
    ) {
        self.getStatement = {
            let statements = PrecipitationReactionStatements(reaction: $0.chosenReaction)
            return statements[keyPath: statementKeyPath]
        }
        self.highlights = highlights
    }

    let getStatement: (PrecipitationScreenViewModel) -> [TextLine]
    let highlights: [PrecipitationScreenViewModel.ScreenElement]

    override func apply(on model: PrecipitationScreenViewModel) {
        model.statement = getStatement(model)
        model.highlights.elements = highlights
    }
}

private class ChooseReaction: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = .selectReaction
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
    }
}

private class StopInput: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = nil
    }
}

private class ExplainUnknownMetal: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.emphasiseUnknownMetalSymbol = true
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.emphasiseUnknownMetalSymbol = false
    }
}

private class InstructToSetWaterLevel: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = .setWaterLevel
        model.emphasiseUnknownMetalSymbol = false
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
    }
}

private class InstructToAddKnownReactant: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        model.components.goNextTo(phase: .addKnownReactant)
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.components.resetPhase()
        model.input = .addReactant(type: .known)
        model.equationState = .showKnownReactantMolarity
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
        model.components.goNextTo(phase: .addUnknownReactant)
        doApply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        model.components.resetPhase()
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        let molesAdded = model.equationData.knownReactantMoles
        model.statement = statements.instructToAddUnknownReactant(molesAdded: molesAdded)
        model.input = .addReactant(type: .unknown)
        model.shakeModel.stopAll()
        model.highlights.elements = [.unknownReactantContainer]
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.shakeModel.stopAll()
        model.components.goToPreviousPhase()
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
        model.components.goNextTo(phase: phase)
        doApply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        model.components.resetReaction()
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        model.shakeModel.stopAll()
        model.input = nil
        model.statement = statement(model)
        model.highlights.clear()

        reactionsToRun = model.components.reactionsToRun

        withAnimation(.linear(duration: reactionDuration)) {
            model.components.runReaction()
        }

        if reactionsToRun > 0 {
            model.components.runOneReactionProgressReaction()
        }
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        withAnimation(.easeOut(duration: 0.25)) {
            model.components.resetReaction()
            model.components.goToPreviousPhase()
        }
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
            model.components.runOneReactionProgressReaction()
        }
    }
}

private class RunInitialReaction: RunReaction {

    init() {
        super.init(
            statement: { model in
                let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
                let massAdded = model.components.unknownReactantMassAdded

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
            model.showReRunReactionButton = true
        }
        model.input = nil
        model.showReRunReactionButton = true
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.showReRunReactionButton = false
    }
}

private class InitialWeightProduct: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = .weighProduct
        model.precipitatePosition = .beaker
        model.beakerView = .macroscopic
        model.showReRunReactionButton = false
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.showMovingHand = false
    }

    override func delayedStates(model: PrecipitationScreenViewModel) -> [DelayedState<PrecipitationScreenState>] {
        [
            DelayedState(
                state: ShowDraggingHandState(),
                delay: 2
            )
        ]
    }

    private class ShowDraggingHandState: PrecipitationScreenState {
        override func apply(on model: PrecipitationScreenViewModel) {
            model.showMovingHand = true
        }
    }
}

private class PostWeighingProduct: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        let components = model.components

        let productMass = components.productMassProduced.getValue(at: components.reactionProgress)
        let productMoles = components.productMolesProduced.getValue(at: components.reactionProgress)

        model.input = nil
        model.statement = statements.showWeightOfProduct(
            productGrams: productMass,
            productMoles: productMoles,
            unknownReactantGrams: components.unknownReactantMassAdded,
            unknownReactantMoles: components.unknownReactantMolesAdded
        )
        model.equationState = .showAll
        model.showMovingHand = false
        model.highlights.elements = [.productMoles, .unknownReactantMoles]
        model.showReRunReactionButton = false
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.equationState = .showKnownReactantMolarity
    }
}

private class RevealUnknownMetal: PrecipitationScreenState {
    override func apply(on model: PrecipitationScreenViewModel) {
        let statements = PrecipitationReactionStatements(reaction: model.chosenReaction)
        model.statement = statements.revealKnownMetal(
            unknownReactantGrams: model.components.unknownReactantMassAdded,
            unknownReactantMoles: model.components.unknownReactantMolesAdded
        )
        model.showUnknownMetal = true
        model.highlights.elements = [.unknownReactantMolarMass, .correctMetalRow]
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.showUnknownMetal = false
    }
}

private class AddExtraKnownReactant: SetStatement {
    override func apply(on model: PrecipitationScreenViewModel) {
        model.components.goNextTo(phase: .addExtraUnknownReactant)
        doApply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        model.components.resetPhase()
        doApply(on: model)
    }

    private func doApply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .unknown)
        model.precipitatePosition = .beaker
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.input = nil
        model.shakeModel.stopAll()
        model.components.goToPreviousPhase()
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

private class EndFinalReaction: PrecipitationScreenState {

    init(persistence: PrecipitationInputPersistence) {
        self.persistence = persistence
    }

    let persistence: PrecipitationInputPersistence

    override func apply(on model: PrecipitationScreenViewModel) {
        model.statement = PrecipitationReactionStatements(reaction: model.chosenReaction).finalStatement
        withAnimation(.easeOut(duration: 0.35)) {
            model.components.completeReaction()
            model.showReRunReactionButton = true
        }
        if let input = model.components.input(rows: model.rows), let reactionIndex = model.reactionIndex {
            persistence.setComponentInput(reactionIndex: reactionIndex, input: input)
            persistence.setLastChosenReactionIndex(reactionIndex)
            persistence.setLastChosenReactionMetal(model.chosenReaction.unknownReactant.metal)
        }
        persistence.setBeakerView(model.beakerView)
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.showReRunReactionButton = false
    }
}

private class PrepareNewReaction: SetStatement {

    override func apply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.setNextReaction()
        reapply(on: model)
    }

    override func reapply(on model: PrecipitationScreenViewModel) {
        super.apply(on: model)
        model.showReRunReactionButton = false
        model.showUnknownMetal = false
        model.equationState = .blank
    }

    override func unapply(on model: PrecipitationScreenViewModel) {
        model.setPreviousReaction()
        model.showReRunReactionButton = true
        model.showUnknownMetal = true
        model.equationState = .showAll
    }
}
