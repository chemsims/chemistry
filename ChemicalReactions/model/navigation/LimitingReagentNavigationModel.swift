//
// Reactions App
//

import ReactionsCore
import SwiftUI

private let statements = LimitingReagentStatements.self

struct LimitingReagentNavigationModel {
    private init() { }

    static func model(
        using viewModel: LimitingReagentScreenViewModel,
        persistence: LimitingReagentPersistence
    ) -> NavigationModel<LimitingReagentScreenState> {
        NavigationModel(model: viewModel, states: states(persistence: persistence))
    }

    private static func states(persistence: LimitingReagentPersistence) -> [LimitingReagentScreenState] {
        let firstReaction = firstReactionStates(persistence: persistence)
        let secondReaction = secondReactionStates(persistence: persistence)
        return firstReaction + secondReaction
    }

    private static func firstReactionStates(persistence: LimitingReagentPersistence) -> [LimitingReagentScreenState] {
        let initial = [
            SelectReaction(statements.intro, highlights: [.selectReaction]),
            StopInput(statements.explainStoichiometry),
            SetStatement(statements.introducePhysicalStates, highlights: [.reactionDefinitionStates]),
            SetStatement(statements.explainEachPhysicalState),
            SetStatement(statements.explainMoles),
            SetStatement(statements.explainAvogadroNumber)
        ]
        return initial + commonStates(persistence: persistence)
    }

    private static func secondReactionStates(persistence: LimitingReagentPersistence) -> [LimitingReagentScreenState] {
        let initial = [PrepareNewReaction(statements.repeatWithOtherReaction)]
        return initial + commonStates(persistence: persistence)
    }

    private static func commonStates(persistence: LimitingReagentPersistence) -> [LimitingReagentScreenState] {
        [
            SetWaterLevel(statements.instructToSetVolume, highlights: [.beakerSlider]),
            AddLimitingReactant(\.instructToAddLimitingReactant, highlights: [.limitingReactantContainer]),
            StopInput(\.explainMolarity),
            SetStatement(\.showLimitingReactantMolarity),
            SetStatement(\.showLimitingReactantMoles, highlights: [.limitingReactantMolesToVolume]),
            SetStatement(\.showNeededReactantMoles, highlights: [.neededExcessReactantMoles]),
            SetStatement(\.showTheoreticalProductMoles),
            SetStatement(\.showTheoreticalProductMass, highlights: [.theoreticalProductMass]),
            AddExcessReactant(\.instructToAddExcessReactant, highlights: [.excessReactantContainer]),
            RunReaction(\.reactionInProgress),
            EndOfReaction(\.endOfReaction),
            SetStatement(statements.explainYieldPercentage),
            SetStatement(\.showYield, highlights: [.productYieldPercentage]),
            AddNonReactantExcessReactant(\.instructToAddExtraReactant, highlights: [.excessReactantContainer]),
            StopInput(\.explainExtraReactantNotReacting),
            SetStatement(\.explainLimitingReagent),
            FinalState(persistence: persistence)
        ]
    }
}

private let reactionDuration: TimeInterval = 3

class LimitingReagentScreenState: ScreenState, SubState {

    typealias Model = LimitingReagentScreenViewModel
    typealias NestedState = LimitingReagentScreenState

    func apply(on model: LimitingReagentScreenViewModel) {
    }

    func reapply(on model: LimitingReagentScreenViewModel) {
        apply(on: model)
    }

    func unapply(on model: LimitingReagentScreenViewModel) {
    }

    func delayedStates(model: LimitingReagentScreenViewModel) -> [DelayedState<LimitingReagentScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: LimitingReagentScreenViewModel) -> Double? {
        nil
    }
}

private class SetStatement: LimitingReagentScreenState {
    init(
        _ statement: [TextLine],
        highlights: [LimitingReagentScreenViewModel.ScreenElement] = []
    ) {
        self.getStatement = { _ in statement }
        self.highlightedElements = highlights
    }

    init(
        _ keyPath: KeyPath<LimitingReagentReactionStatements, [TextLine]>,
        highlights: [LimitingReagentScreenViewModel.ScreenElement] = []
    ) {
        self.getStatement = { model in
            LimitingReagentReactionStatements(components: model.components)[keyPath: keyPath]
        }
        self.highlightedElements = highlights
    }

    private let getStatement: (LimitingReagentScreenViewModel) -> [TextLine]
    private let highlightedElements: [LimitingReagentScreenViewModel.ScreenElement]

    override func apply(on model: LimitingReagentScreenViewModel) {
        model.statement = getStatement(model)
        model.highlights.elements = highlightedElements
    }
}

private class StopInput: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = nil
        model.shakeReactantModel.stopAll()
    }
}

private class SelectReaction: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .selectReaction
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
    }
}

private class SetWaterLevel: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .setWaterLevel
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
    }
}

private class AddLimitingReactant: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .limiting)
        model.equationState = .showTheoreticalData
    }

    override func reapply(on model: LimitingReagentScreenViewModel) {
        model.components.resetLimitingReactantCoords()
        apply(on: model)
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
        model.equationState = .showVolume
        model.shakeReactantModel.stopAll()
        model.components.resetLimitingReactantCoords()
    }
}

private class AddExcessReactant: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .excess)
    }

    override func reapply(on model: LimitingReagentScreenViewModel) {
        model.components.resetExcessReactantCoords()
        apply(on: model)
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
        model.shakeReactantModel.stopAll()
        model.components.resetExcessReactantCoords()
    }
}

private class RunReaction: SetStatement {

    private var reactionsToRun: Int = 0

    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = nil
        model.equationState = .showActualData
        model.shakeReactantModel.stopAll()
        model.components.prepareReaction()
        reactionsToRun = model.components.reactionProgressReactionsToRun
        withAnimation(.linear(duration: reactionDuration)) {
            model.components.reactionProgress = 1
        }
        model.components.runOneReactionProgressReaction()
    }

    override func reapply(on model: LimitingReagentScreenViewModel) {
        model.components.resetReactionCoords()
        model.components.reactionProgress = 0
        apply(on: model)
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.components.reactionProgress = 0
        model.components.resetReactionCoords()
        model.equationState = .showTheoreticalData
    }

    override func nextStateAutoDispatchDelay(model: LimitingReagentScreenViewModel) -> Double? {
        reactionDuration
    }

    override func delayedStates(model: LimitingReagentScreenViewModel) -> [DelayedState<LimitingReagentScreenState>] {
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

    private class RunOneReactionState: LimitingReagentScreenState {
        override func apply(on model: LimitingReagentScreenViewModel) {
            model.components.runOneReactionProgressReaction()
        }
    }
}

private class EndOfReaction: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        let duration = 0.2
        withAnimation(.easeOut(duration: duration)) {
            model.components.reactionProgress = 1.00001
        }
        model.components.runAllReactionProgressReactions(duration: duration)
    }
}

private class AddNonReactantExcessReactant: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .excess)
        model.components.shouldReactExcessReactant = false
    }

    override func reapply(on model: LimitingReagentScreenViewModel) {
        model.components.resetNonReactingExcessReactantCoords()
        apply(on: model)
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
        model.components.shouldReactExcessReactant = true
        model.components.resetNonReactingExcessReactantCoords()
        model.shakeReactantModel.stopAll()
    }
}

private class FinalState: LimitingReagentScreenState {
    init(persistence: LimitingReagentPersistence) {
        self.persistence = persistence
    }

    let persistence: LimitingReagentPersistence

    override func apply(on model: LimitingReagentScreenViewModel) {
        let statements = LimitingReagentReactionStatements(components: model.components)
        model.statement = statements.explainExcessReactant
        persistence.saveInput(model.components.input)
    }
}

private class PrepareNewReaction: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.setNextReaction()
        reapply(on: model)
    }

    override func reapply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = nil
        model.highlights.clear()
        model.equationState = .showVolume
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.equationState = .showActualData
        model.setPreviousReaction()
    }
}
