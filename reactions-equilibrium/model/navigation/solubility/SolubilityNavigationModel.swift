//
// Reactions App
//

import ReactionsCore
import SwiftUI

private let statements = SolubilityStatements.self
class SolubilityNavigationModel {

    static func model(model: SolubilityViewModel) -> NavigationModel<SolubilityScreenState> {
        NavigationModel(
            model: model,
            states: [
//                SetStatement(statement: statements.intro),
//                SetStatement(statement: statements.explainPrecipitationReactions),
//                SetStatement(statement: statements.explainSolubility1),
//                SetStatement(statement: statements.explainSolubility2),
//                ShowRecapQuotient(),
//                ShowCrossedOutOldQuotient(),
//                SetStatement(statement: statements.explainQEquation2),
//                ShowCorrectQuotient(),
//                SetStatement(statement: statements.explainKspRatio2),
                SetWaterLevel(),
                AddSolute(statement: statements.instructToAddSolute),
                ShowSaturatedSolution(statement: statements.primaryEquilibriumReached),
                AddSoluteToSaturatedBeaker(),
                PostAddingSoluteToSaturatedBeaker(statement: statements.explainSuperSaturated),
                SetStatement(statement: statements.explainSaturatedEquilibrium1),
                SetStatement(statement: statements.explainSaturatedEquilibrium2),
                PrepareCommonIonReaction(),
                AddCommonIonSolute(),
                AddSoluteToCommonIonSolution(),
                ShowSaturatedSolution(statement: statements.commonIonEquilibriumReached),
                AddSoluteToSaturatedBeaker(),
                PostAddingSoluteToSaturatedBeaker(statement: statements.explainSuperSaturated),
                PrepareAcidReaction(),
                SetStatement(statement: statements.explainPh2),
                AddAcidSolute(),
                RunAcidReaction(),
                EndAcidReaction(),
                SetStatement(statement: statements.end)
            ]
        )
    }
}

class SolubilityScreenState: ScreenState, SubState {

    typealias Model = SolubilityViewModel
    typealias NestedState = SolubilityScreenState

    func apply(on model: SolubilityViewModel) {

    }

    func reapply(on model: SolubilityViewModel) {
        apply(on: model)
    }

    func unapply(on model: SolubilityViewModel) {

    }

    func delayedStates(model: SolubilityViewModel) -> [DelayedState<SolubilityScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: SolubilityViewModel) -> Double? {
        nil
    }
}

private class SetStatement: SolubilityScreenState {

    let statement: [TextLine]

    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        model.statement = statement
    }
}

private class ShowRecapQuotient: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainRecapEquation
        model.equationState = .showOriginalQuotientAndQuotientRecap
    }

    override func unapply(on model: SolubilityViewModel) {
        model.equationState = .showOriginalQuotient
    }
}

private class ShowCrossedOutOldQuotient: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainQEquation1
        withAnimation(.easeOut(duration: 0.3)) {
            model.equationState = .crossOutOriginalQuotientDenominator
        }
    }
}

private class ShowCorrectQuotient: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainKspRatio1
        withAnimation(.easeOut(duration: 0.3)) {
            model.equationState = .showCorrectQuotientNotFilledIn
        }

    }
}

private class SetWaterLevel: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToSetWaterLevel
        model.inputState = .setWaterLevel
    }
}

private class AddSolute: SolubilityScreenState {

    let statement: [TextLine]

    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.inputState = .addSolute(type: .primary)
            model.activeSolute = nil
        }
        model.equationState = .showCorrectQuotientFilledIn
        model.statement = statement
        model.beakerSoluteState = .addingSolute(type: .primary, clearPrevious: false)
//        model.soluteCounts = SoluteContainer(maxAllowed: model.soluteToAddForSaturation)
        model.stopShaking()
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute = nil
        }
        model.componentsWrapper.reset()
    }
}

private class ShowSaturatedSolution: SolubilityScreenState {

    let statement: [TextLine]
    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        model.statement = statement
        model.stopShaking()
        model.beakerSoluteState = .addingSolute(type: .primary, clearPrevious: false)

        model.componentsWrapper = PrimarySoluteSaturatedComponentsWrapper(
            previous: model.componentsWrapper,
            setTime: model.setTime
        )

        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
        }
    }

    override func reapply(on model: SolubilityViewModel) {
        apply(on: model)
//        model.soluteCounts = SoluteContainer(maxAllowed: model.soluteToAddForSaturation, isSaturated: true)
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
    }
}

private class AddSoluteToSaturatedBeaker: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToAddSaturatedSolute
        model.beakerSoluteState = .addingSaturatedPrimary
//        model.soluteCounts = SoluteContainer(maxAllowed: SolubleReactionSettings.saturatedSoluteParticlesToAdd)
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .addSaturatedSolute
            model.activeSolute = .primary
        }
        model.startShaking()
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.equilibrium
        }
        model.componentsWrapper.reset()
    }
}

private class PostAddingSoluteToSaturatedBeaker: SolubilityScreenState {
    let statement: [TextLine]
    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        model.statement = statement
        model.stopShaking()
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
        }
    }
}

private class PrepareCommonIonReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainCommonIonEffect
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute = nil
        }
        model.beakerSoluteState = .addingSolute(type: .commonIon, clearPrevious: true)
        model.reactionPhase = .commonIon
        model.stopShaking()
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 1
        }
        model.reactionPhase = .primarySolute
    }
}

private class AddCommonIonSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToAddCommonIon
        model.inputState = .addSolute(type: .commonIon)
        model.beakerSoluteState = .addingSolute(type: .commonIon, clearPrevious: false)
        model.componentsWrapper = CommonIonComponentsWrapper(
            timing: SolubleReactionSettings.firstReactionTiming
        )
//        model.soluteCounts = SoluteContainer(maxAllowed: SolubleReactionSettings.commonIonSoluteParticlesToAdd)
    }

    override func reapply(on model: SolubilityViewModel) {
        apply(on: model)
//        withAnimation(.easeOut(duration: 0.5)) {
//            model.extraB0 = 0
//        }
    }

    override func unapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
//        withAnimation(.easeOut(duration: 0.5)) {
//            model.extraB0 = 0
//        }
    }
}

private class AddSoluteToCommonIonSolution: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        doApply(on: model, setWrapper: true)
    }

    override func reapply(on model: SolubilityViewModel) {
        doApply(on: model, setWrapper: false)
    }

    private func doApply(on model: SolubilityViewModel, setWrapper: Bool) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.inputState = .addSolute(type: .primary)
            model.activeSolute = nil
        }
        model.equationState = .showCorrectQuotientFilledIn
        model.statement = statements.instructToAddPrimarySolutePostCommonIon
        model.beakerSoluteState = .addingSolute(type: .primary, clearPrevious: false)
        model.stopShaking()
        if setWrapper {
            model.componentsWrapper = PrimarySoluteComponentsWrapper(
                soluteToAddForSaturation: model.soluteToAddForSaturation,
                timing: SolubleReactionSettings.firstReactionTiming,
                previous: model.componentsWrapper,
                setTime: model.setTime
            )
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
    }
}

private class PrepareAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainPh1
        model.stopShaking()
        withAnimation(.easeOut(duration: 1)) {
            model.inputState = .none
            model.activeSolute = nil
            model.chartOffset = SolubleReactionSettings.secondReactionTiming.offset
            model.currentTime = SolubleReactionSettings.secondReactionTiming.start
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        let previousEquation = model.components.previousEquation
//        model.components = SolubilityComponents(
//            equilibriumConstant: model.components.equilibriumConstant,
//            initialConcentration: model.components.initialConcentration,
//            startTime: model.components.startTime,
//            equilibriumTime: model.components.equilibriumTime,
//            previousEquation: nil
//        )
        model.reactionPhase = .commonIon
//        if let previousEquation = previousEquation {
//            model.extraB0 = previousEquation.initialConcentration.value(for: .B)
//        }
//        model.timing = SolubleReactionSettings.firstReactionTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = model.timing.end
        }
    }
}

private class AddAcidSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToAddH
        model.inputState = .addSolute(type: .acid)
        model.beakerSoluteState = .addingSolute(type: .acid, clearPrevious: false)
        model.componentsWrapper = AddAcidComponentsWrapper(
            previous: model.componentsWrapper,
            timing: SolubleReactionSettings.secondReactionTiming
        )
//        model.soluteCounts = SoluteContainer(maxAllowed: SolubleReactionSettings.acidSoluteParticlesToAdd)
//        model.components = SolubilityComponents(
//            equilibriumConstant: model.components.equilibriumConstant,
//            initialConcentration: model.components.equation.finalConcentration,
//            startTime: model.components.startTime,
//            equilibriumTime: model.components.equilibriumTime,
//            previousEquation: model.components.equation
//        )
//        model.timing = SolubleReactionSettings.secondReactionTiming
//        model.extraB0 = 0
        model.reactionPhase = .acidity
    }
}

private class RunAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.acidReactionRunning
        let dt = model.timing.end - model.timing.start
        model.beakerSoluteState = .dissolvingSuperSaturatedPrimary
        model.stopShaking()
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
        }
        withAnimation(.linear(duration: Double(dt))) {
            model.currentTime = model.timing.end
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.start
        }
    }
}

private class EndAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.acidEquilibriumReached
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.end * 1.5
        }
        model.beakerSoluteState = .completedSuperSaturatedReaction
    }
}
