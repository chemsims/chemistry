//
// Reactions App
//

import ReactionsCore
import AcidsBases
import SwiftUI

private let statements = LimitingReagentStatements.self

struct LimitingReagentNavigationModel {
    private init() { }

    static func model(using viewModel: LimitingReagentScreenViewModel) -> NavigationModel<LimitingReagentScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [LimitingReagentScreenState] = [
        SelectReaction(statements.intro),
        StopInput(statements.explainStoichiometry),
        SetStatement(statements.introducePhysicalStates),
        SetStatement(statements.explainStoichiometry),
        SetStatement(statements.explainMoles),
        SetStatement(statements.explainAvogadroNumber),
        SetWaterLevel(statements.instructToSetVolume),
        AddLimitingReactant(\.instructToAddLimitingReactant),
        StopInput(\.explainMolarity),
        SetStatement(\.showLimitingReactantMolarity),
        SetStatement(\.showLimitingReactantMoles),
        SetStatement(\.showNeededReactantMoles),
        SetStatement(\.showTheoreticalProductMoles),
        SetStatement(\.showTheoreticalProductMass),
        AddExcessReactant(\.instructToAddExcessReactant),
        RunReaction(\.reactionInProgress),
        EndOfReaction(\.endOfReaction),
        SetStatement(statements.explainYieldPercentage),
        SetStatement(\.showYield),
        AddNonReactantExcessReactant(\.instructToAddExtraReactant),
        StopInput(\.explainExtraReactantNotReacting),
        SetStatement(\.explainLimitingReagent),
        SetStatement(\.explainExcessReactant)
    ]
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
    init(_ statement: [TextLine]) {
        self.getStatement = { _ in statement }
    }

    init(_ keyPath: KeyPath<LimitingReagentReactionStatements, [TextLine]>) {
        self.getStatement = { model in
            LimitingReagentReactionStatements(components: model.components)[keyPath: keyPath]
        }
    }

    private let getStatement: (LimitingReagentScreenViewModel) -> [TextLine]

    override func apply(on model: LimitingReagentScreenViewModel) {
        model.statement = getStatement(model)
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

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
        model.equationState = .showVolume
        model.shakeReactantModel.stopAll()
    }
}

private class AddExcessReactant: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .excess)
        model.equationState = .showActualData
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
        model.equationState = .showTheoreticalData
        model.shakeReactantModel.stopAll()
    }
}

private class RunReaction: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = nil
        model.shakeReactantModel.stopAll()
        model.components.prepareReaction()
        withAnimation(.linear(duration: reactionDuration)) {
            model.components.reactionProgress = 1
        }
    }

    override func nextStateAutoDispatchDelay(model: LimitingReagentScreenViewModel) -> Double? {
        reactionDuration
    }
}

private class EndOfReaction: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        withAnimation(.easeOut(duration: 0.2)) {
            model.components.reactionProgress = 1.00001
        }
    }
}

private class AddNonReactantExcessReactant: SetStatement {
    override func apply(on model: LimitingReagentScreenViewModel) {
        super.apply(on: model)
        model.input = .addReactant(type: .excess)
        model.components.shouldReactExcessReactant = false
    }

    override func unapply(on model: LimitingReagentScreenViewModel) {
        model.input = nil
        model.components.shouldReactExcessReactant = true
    }
}
