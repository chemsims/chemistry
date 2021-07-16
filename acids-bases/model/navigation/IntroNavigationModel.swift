//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = IntroStatements.self

struct IntroNavigationModel {

    static func model(
        _ viewModel: IntroScreenViewModel,
        namePersistence: NamePersistence
    ) -> NavigationModel<IntroScreenState> {
        NavigationModel(
            model: viewModel,
            states: states(namePersistence: namePersistence)
        )
    }

    private static func states(namePersistence: NamePersistence) -> [IntroScreenState] {
        [
            SetStatement(statements.intro),
            SetStatement(statements.explainTexture),
            SetStatement(statements.explainArrhenius),
            SetStatement(statements.explainBronstedLowry),
            SetStatement(statements.explainLewis),
            SetStatement(statements.explainSimpleDefinition),
            ChooseSubstance(statements.chooseStrongAcid, .strongAcid),
            PostChooseSubstance(statements.showPhScale, highlights: [.pHScale]),
            SetStatement(statements.explainPHConcept, highlights: [.pHEquation]),
            SetStatement(statements.explainPOHConcept, highlights: [.pOHEquation]),
            SetStatement(statements.explainPRelation),
            SetStatement(statements.explainPConcentrationRelation1),
            SetStatement(statements.explainPConcentrationRelation2),
            SetWaterLevel(type: .strongAcid),
            AddSubstance(type: .strongAcid),
            PostAddSubstance(statements.showPhVsMolesGraph, namePersistence: namePersistence, highlights: [.phChart]),
            ChooseSubstance(statements.chooseStrongBase, .strongBase),
            SetWaterLevel(type: .strongBase),
            AddSubstance(type: .strongBase),
            PostAddSubstance(statements.showPhVsMolesGraph, namePersistence: namePersistence),
            ChooseSubstance(statements.chooseWeakAcid, .weakAcid),
            PostChooseSubstance(statements.explainHEquivalence),
            SetStatement(statements.explainDoubleArrow, type: .weakAcid),
            SetStatement(statements.explainEquilibrium),
            SetWaterLevel(type: .weakAcid),
            AddSubstance(type: .weakAcid),
            ChooseSubstance(statements.chooseWeakBase, .weakBase),
            SetWeakBaseWaterLevel(),
            AddSubstance(type: .weakBase),
            PostAddSubstance(statements.end, namePersistence: namePersistence, showPhChart: false)
        ]
    }
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
    let highlights: [IntroScreenElement]

    init(_ statement: @escaping (IntroScreenViewModel) -> [TextLine], highlights: [IntroScreenElement] = []) {
        self.statement = statement
        self.highlights = highlights
    }

    convenience init(_ statement: [TextLine], highlights: [IntroScreenElement] = []) {
        self.init({ _ in statement }, highlights: highlights)
    }

    convenience init(
        _ statement: @escaping (AcidOrBase) -> [TextLine],
        type: AcidOrBaseType,
        highlights: [IntroScreenElement] = []
    ) {
        self.init(
            { model in
                statement(model.substance(forType: type))
            },
            highlights: highlights
        )
    }

    convenience init(
        _ statement: @escaping (NamePersistence) -> [TextLine],
        namePersistence: NamePersistence,
        highlights: [IntroScreenElement] = []
    ) {
        self.init(
            { model in
                statement(namePersistence)
            },
            highlights: highlights
        )
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement(model)
        model.highlights.elements = highlights
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
        model.highlights.elements = [.reactionSelection]
    }

    override func unapply(on model: IntroScreenViewModel) {
        model.inputState = .none
        model.setSubstance(nil, type: type)
        model.popLastComponent()
        model.highlights.clear()
    }
}

private class PostChooseSubstance: IntroScreenState {
    let statement: [TextLine]
    let highlights: [IntroScreenElement]

    init(_ statement: [TextLine], highlights: [IntroScreenElement] = []) {
        self.statement = statement
        self.highlights = highlights
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement
        model.inputState = .none
        model.highlights.elements = highlights
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
        model.highlights.elements = [.waterSlider]
    }

    override func unapply(on model: IntroScreenViewModel) {
        model.inputState = .none
        model.highlights.clear()
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
        model.highlights.elements = [.beakerTools]
    }

    override func unapply(on model: IntroScreenViewModel) {
        withAnimation(.easeOut(duration: 0.35)) {
            model.components.reset()
        }
        model.addMoleculesModel.stopAll()
        model.highlights.clear()
    }
}

private class PostAddSubstance: IntroScreenState {

    let showPhChart: Bool
    let statement: (NamePersistence) -> [TextLine]
    let namePersistence: NamePersistence
    let highlights: [IntroScreenElement]

    init(
        _ statement: @escaping (NamePersistence) -> [TextLine],
        namePersistence: NamePersistence,
        showPhChart: Bool = true,
        highlights: [IntroScreenElement] = []
    ) {
        self.showPhChart = showPhChart
        self.namePersistence = namePersistence
        self.statement = statement
        self.highlights = highlights
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement(namePersistence)
        model.inputState = .none
        model.addMoleculesModel.stopAll()
        model.highlights.elements = highlights
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

