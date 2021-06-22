//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = TitrationStatements.self

struct TitrationNavigationModel {
    private init() { }

    static func model(_ viewModel: TitrationViewModel) -> NavigationModel<TitrationScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [TitrationScreenState] = [
        SelectSubstance(statements.intro),
        PostSelectSubstance(statements.explainNeutralization),
        SetStatement(statements.explainMolecularIonicEquations),
        SetStatement(statements.explainTitration),
        SetStatement(statements.explainEquivalencePoint),
        SetWaterLevel(statements.explainTitrationCurveAndInstructToSetWaterLevel),
        AddSubstance(statements.instructToAddStrongAcid),
        AddTitrantPreEP(["Add titrant"]),
        AddTitrantPostEP(["Add titrant post EP"])
    ]
}

private let containerInputAnimation = Animation.easeOut(duration: 0.35)
private let endReactionAnimation = Animation.easeOut(duration: 0.5)

class TitrationScreenState: ScreenState, SubState {
    typealias Model = TitrationViewModel
    typealias NestedState = TitrationScreenState

    func apply(on model: TitrationViewModel) {
    }

    func reapply(on model: TitrationViewModel) {
        apply(on: model)
    }

    func unapply(on model: TitrationViewModel) {
    }

    func delayedStates(model: TitrationViewModel) -> [DelayedState<TitrationScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: TitrationViewModel) -> Double? {
        nil
    }
}

private class SetStatement: TitrationScreenState {
    init(_ statement: [TextLine]) {
        self.getStatement = { _ in statement }
    }

    private let getStatement: (TitrationViewModel) -> [TextLine]

    override func apply(on model: TitrationViewModel) {
        model.statement = getStatement(model)
    }
}

private class SelectSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
    }

    override func unapply(on model: TitrationViewModel) {
        model.inputState = .none
    }
}

private class PostSelectSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .none
    }
}

private class SetWaterLevel: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .setWaterLevel
    }

    override func unapply(on model: TitrationViewModel) {
        model.inputState = .none
    }
}

private class AddSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addSubstance
        model.equationState = .strongSubstanceAddingSubstance
    }

    override func unapply(on model: TitrationViewModel) {
        model.inputState = .none
        model.equationState = .strongSubstanceBlank
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }
}

private class AddTitrantPreEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.strongSubstancePreEPModel = .init(previous: model.strongSubstancePreparationModel)
        model.inputState = .addTitrant
        model.equationState = .strongSubstancePreEPFilled
        model.reactionPhase = .strongSubstancePreEP
        model.shakeModel.stopAll()
    }
}

private class AddTitrantPostEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.equationState = .strongSubstancePostEP
        model.reactionPhase = .strongSubstancePostEP
        model.strongSubstancePostEPModel = .init(previous: model.strongSubstancePreEPModel)
    }
}
