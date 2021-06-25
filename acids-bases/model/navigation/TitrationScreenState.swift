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
        AddStrongAcid(statements.instructToAddStrongAcid),
        AddStrongAcidTitrantPreEP(["Add titrant to strong acid"]),
        AddStrongAcidTitrantPostEP(["Add titrant to strong acid post EP"]),
        SelectStrongBase(["Choose strong base"]),
        AddStrongBase(["Add strong base"]),
        AddStrongBaseTitrantPreEP(["Add titrant to strong base pre EP"]),
        AddStrongBaseTitrantPostEP(["Add titrant to strong base post EP"]),
        SetWeakAcidSubstance(["Choose weak acid"]),
        AddWeakAcid(["Add weak acid"]),
        RunWeakAcidInitialReaction(["Running initial weak acid reaction"]),
        AddTitrantToWeakAcidPreEP(["Add titrant to weak acid"]),
        AddTitrantToWeakAcidPostEP(["Add titrant to weak acid post EP"]),
        SetWeakBaseSubstance(["Choose weak base"]),
        AddWeakBase(["Add weak base"]),
        RunWeakBaseInitialReaction(["Running initial weak base reaction"]),
        AddTitrantToWeakBasePreEP(["Add titrant to weak base"]),
        AddTitrantToWeakBasePostEP(["Add titrant to weak base post EP"])
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
        model.inputState = .selectSubstance
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

private class AddStrongAcid: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addSubstance
        model.equationState = .strongAcidAddingSubstance
    }

    override func unapply(on model: TitrationViewModel) {
        model.inputState = .none
        model.equationState = .strongAcidBlank
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }
}

private class AddStrongAcidTitrantPreEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .strongAcid, phase: .preEP))
        model.inputState = .addTitrant
        model.equationState = .strongAcidPreEPFilled
        model.shakeModel.stopAll()
    }
}

private class AddStrongAcidTitrantPostEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.equationState = .strongAcidPostEP
        model.components.assertGoTo(state: .init(substance: .strongAcid, phase: .postEP))
    }
}

private class SelectStrongBase: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .strongBase, phase: .preparation))
        model.equationState = .strongBaseBlank
        model.inputState = .selectSubstance
    }
}

private class AddStrongBase: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addSubstance
        model.equationState = .strongBaseAddingSubstance
    }
}

private class AddStrongBaseTitrantPreEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .strongBase, phase: .preEP))
        model.inputState = .addTitrant
        model.equationState = .strongBasePreEPFilled
        model.shakeModel.stopAll()
    }
}

private class AddStrongBaseTitrantPostEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .strongBase, phase: .postEP))
        model.equationState = .strongBasePostEP
    }
}


private class SetWeakAcidSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .weakAcid, phase: .preparation))
        model.equationState = .weakAcidBlank
        model.inputState = .selectSubstance
    }
}

private class AddWeakAcid: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addSubstance
        model.equationState = .weakAcidAddingSubstance
    }
}

private class RunWeakAcidInitialReaction: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.shakeModel.stopAll()
        withAnimation(.linear(duration: 2)) {
            model.components.weakSubstancePreparationModel.reactionProgress = 1
        }
    }
}

private class AddTitrantToWeakAcidPreEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .weakAcid, phase: .preEP))
        model.inputState = .addTitrant
        model.equationState = .weakAcidPreEPFilled
    }
}

private class AddTitrantToWeakAcidPostEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .weakAcid, phase: .postEP))
        model.inputState = .addTitrant
        model.equationState = .weakAcidPostEP
    }
}

private class SetWeakBaseSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .weakBase, phase: .preparation))
        model.equationState = .weakAcidBlank
        model.inputState = .selectSubstance
    }
}

private class AddWeakBase: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addSubstance
        model.equationState = .weakAcidAddingSubstance
    }
}

private class RunWeakBaseInitialReaction: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.shakeModel.stopAll()
        withAnimation(.linear(duration: 2)) {
            model.components.weakSubstancePreparationModel.reactionProgress = 1
        }
    }
}

private class AddTitrantToWeakBasePreEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .weakBase, phase: .preEP))
        model.inputState = .addTitrant
        model.equationState = .weakAcidPreEPFilled
    }
}

private class AddTitrantToWeakBasePostEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.components.assertGoTo(state: .init(substance: .weakBase, phase: .postEP))
        model.inputState = .addTitrant
        model.equationState = .weakAcidPostEP
    }
}
