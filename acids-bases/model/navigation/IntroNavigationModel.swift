//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = IntroStatements.self

struct IntroNavigationModel {

    static func model(
        _ viewModel: IntroScreenViewModel
    ) -> NavigationModel<IntroScreenState> {
        NavigationModel(
            model: viewModel,
            states: states
        )
    }

    private static let states: [IntroScreenState] = [
        SetStatement(statements.intro),
        SetStatement(statements.explainTexture),
        SetStatement(statements.explainArrhenius),
        SetStatement(statements.explainBronstedLowry),
        SetStatement(statements.explainLewis),
        SetStatement(statements.explainSimpleDefinition),
        ChooseSubstance(statements.chooseStrongAcid, .strongAcid),
        PostChooseSubstance(statements.showPhScale),
        SetStatement(statements.explainPHConcept),
        SetStatement(statements.explainPOHConcept),
        SetStatement(statements.explainPRelation),
        SetStatement(statements.explainPConcentrationRelation1),
        SetStatement(statements.explainPConcentrationRelation2),
        SetWaterLevel(type: .strongAcid),
        AddSubstance(type: .strongAcid),
        PostAddSubstance(statements.showPhVsMolesGraph),
        ChooseSubstance(statements.chooseStrongBase, .strongBase),
        SetWaterLevel(type: .strongBase),
        AddSubstance(type: .strongBase),
        PostAddSubstance(statements.showPhVsMolesGraph),
        ChooseSubstance(statements.chooseWeakAcid, .weakAcid),
        PostChooseSubstance(statements.explainHEquivalence),
        SetStatement(statements.explainDoubleArrow, type: .weakAcid),
        SetStatement(statements.explainEquilibrium),
        SetWaterLevel(type: .weakAcid),
        AddSubstance(type: .weakAcid),
        ChooseSubstance(statements.chooseWeakBase, .weakBase),
        SetWeakBaseWaterLevel(),
        AddSubstance(type: .weakBase),
        PostAddSubstance(statements.end, showPhChart: false)
    ]

}

class IntroScreenState: ScreenState, SubState {

    typealias NestedState = IntroScreenState
    typealias Model = IntroScreenViewModel

    func apply(on model: IntroScreenViewModel) {
    }

    func reapply(on model: IntroScreenViewModel) {
        apply(on: model)
    }

    func delayedStates(model: IntroScreenViewModel) -> [DelayedState<IntroScreenState>] {
        []
    }

    func unapply(on model: IntroScreenViewModel) {
    }

    func nextStateAutoDispatchDelay(model: IntroScreenViewModel) -> Double? {
        nil
    }
}

private class SetStatement: IntroScreenState {

    let statement: (IntroScreenViewModel) -> [TextLine]

    init(_ statement: @escaping (IntroScreenViewModel) -> [TextLine]) {
        self.statement = statement
    }

    convenience init(_ statement: [TextLine]) {
        self.init { _ in statement }
    }

    convenience init(_ statement: @escaping (AcidOrBase) -> [TextLine], type: AcidOrBaseType) {
        self.init { model in
            statement(model.substance(forType: type))
        }
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement(model)
    }
}

private class ChooseSubstance: IntroScreenState {

    init(_ statement: [TextLine], _ type: AcidOrBaseType) {
        self.statement = statement
        self.type = type
    }

    let statement: [TextLine]
    let type: AcidOrBaseType

    override func apply(on model: IntroScreenViewModel) {
        let substances = AcidOrBase.substances(forType: type)
        model.addNewComponents(type: type)
        model.setSubstance(substances.first, type: type)

        doApply(on: model)
    }

    override func reapply(on model: IntroScreenViewModel) {
        doApply(on: model)
    }

    private func doApply(on model: IntroScreenViewModel) {
        model.statement = statement
        model.availableSubstances = AcidOrBase.substances(forType: type)
        model.inputState = .chooseSubstance(type: type)
        model.addMoleculesModel.stopAll()
    }

    override func unapply(on model: IntroScreenViewModel) {
        model.inputState = .none
        model.setSubstance(nil, type: type)
        model.popLastComponent()
    }
}

private class PostChooseSubstance: IntroScreenState {
    let statement: [TextLine]
    init(_ statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement
        model.inputState = .none
    }
}

private class SetWaterLevel: IntroScreenState {

    let type: AcidOrBaseType
    init(type: AcidOrBaseType) {
        self.type = type
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statements.setWaterLevel(
            substance: model.substance(forType: type)
        )
        model.inputState = .setWaterLevel
    }

    override func unapply(on model: IntroScreenViewModel) {
        model.inputState = .none
    }
}

private class SetWeakBaseWaterLevel: IntroScreenState {
    override func apply(on model: IntroScreenViewModel) {
        let substance = model.substance(forType: .weakBase)
        model.statement = statements.setWeakBaseWaterLevel(substance: substance)
        model.inputState = .setWaterLevel
    }

    override func unapply(on model: IntroScreenViewModel) {
        model.inputState = .none
    }
}

private class AddSubstance: IntroScreenState {
    let type: AcidOrBaseType
    init(type: AcidOrBaseType) {
        self.type = type
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statements.addSubstance(type)
        model.inputState = .addSubstance(type: type)
    }

    override func unapply(on model: IntroScreenViewModel) {
        withAnimation(.easeOut(duration: 0.35)) {
            model.components.reset()
        }
        model.addMoleculesModel.stopAll()
    }
}

private class PostAddSubstance: IntroScreenState {

    let showPhChart: Bool
    let statement: [TextLine]
    init(_ statement: [TextLine], showPhChart: Bool = true) {
        self.statement = statement
        self.showPhChart = showPhChart
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement
        model.inputState = .none
        model.addMoleculesModel.stopAll()
        if showPhChart {
            model.graphView = .ph
        }

    }
}

extension IntroScreenViewModel {
    fileprivate func substance(forType type: AcidOrBaseType) -> AcidOrBase {
        if let substance = selectedSubstances.value(for: type) {
            return substance
        }
        return availableSubstances.first!
    }
}

