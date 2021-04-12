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
                SetStatement(statement: statements.intro),
                SelectReaction(),
                PostSelectReaction(),
                SetStatement(statement: statements.explainSolubility2),
                ShowRecapQuotient(),
                ShowCrossedOutOldQuotient(),
                SetStatement(statement: statements.explainQEquation2),
                ShowCorrectQuotientAndRunDemo(),
                StopDemo(),
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

private class SelectReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainPrecipitationReactions
        model.inputState = .selectingReaction
        model.reactionSelectionToggled = true
    }

    override func unapply(on model: SolubilityViewModel) {
        model.inputState = .none
        model.reactionSelectionToggled = false
    }
}

private class PostSelectReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainSolubility1
        model.inputState = .none
        model.showSelectedReaction = true
    }

    override func unapply(on model: SolubilityViewModel) {
        model.showSelectedReaction = false
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

private class ShowCorrectQuotientAndRunDemo: SolubilityScreenState {

    private let catalystCount = 4
    private let catalystDelay: TimeInterval = 1

    override func apply(on model: SolubilityViewModel) {
        doApply(on: model, setComponents: true)
    }


    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: SolubilityViewModel, setComponents: Bool) {
        model.statement = statements.explainKspRatio1
        model.beakerState.goTo(state: .demoReaction, with: .none)
        withAnimation(.easeOut(duration: 0.3)) {
            model.equationState = .showCorrectQuotientNotFilledIn
        }

        if setComponents {
            model.componentsWrapper = DemoReactionComponentsWrapper(
                maxCount: catalystCount,
                previous: model.componentsWrapper,
                timing: model.timing,
                setColor: model.setColor
            )
        }
    }

    override func delayedStates(model: SolubilityViewModel) -> [DelayedState<SolubilityScreenState>] {
        let addSoluteState: DelayedState<SolubilityScreenState> = DelayedState(
            state: AutoAddSolute(),
            delay: 1
        )
        let count = 4
        return (0..<count).map { _ in addSoluteState }
    }

    private class AutoAddSolute: SolubilityScreenState {
        override func apply(on model: SolubilityViewModel) {
            model.shakingModel.shouldAddParticle = true
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .none, with: .cleanupDemoReaction)
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = RGB.beakerLiquid.color
            model.equationState = .crossOutOriginalQuotientDenominator

        }
    }
}

private class StopDemo: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainKspRatio2
        model.beakerState.goTo(state: .none, with: .cleanupDemoReaction)
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = RGB.beakerLiquid.color
        }
    }
}


private class SetWaterLevel: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToSetWaterLevel
        model.inputState = .setWaterLevel
    }

    override func unapply(on model: SolubilityViewModel) {
        model.inputState = .none
    }
}

private class AddSolute: SolubilityScreenState {

    let statement: [TextLine]

    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        model.componentsWrapper = PrimarySoluteComponentsWrapper(
            soluteToAddForSaturation: model.soluteToAddForSaturation,
            timing: model.timing,
            previous: nil,
            setTime: model.setTime
        )
        doApply(on: model)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        apply(on: model)
    }

    private func doApply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.inputState = .addSolute(type: .primary)
            model.activeSolute = nil
            model.waterColor = model.componentsWrapper.initialColor.color
        }

        model.equationState = .showCorrectQuotientFilledIn
        model.statement = statement
        model.beakerState.goTo(state: .addingSolute(type: .primary), with: .none)
        model.stopShaking()
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute = nil
            model.waterColor = model.componentsWrapper.initialColor.color
        }
    }
}

private class ShowSaturatedSolution: SolubilityScreenState {

    let statement: [TextLine]
    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .none, with: .none)
        doApply(on: model, setComponents: true)
    }

    override func reapply(on model: SolubilityViewModel) {
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: SolubilityViewModel, setComponents: Bool) {
        model.statement = statement
        model.stopShaking()

        if setComponents {
            model.componentsWrapper = PrimarySoluteSaturatedComponentsWrapper(
                previous: model.componentsWrapper,
                setTime: model.setTime
            )
        }

        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
    }
}

private class AddSoluteToSaturatedBeaker: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .addingSaturatedPrimary, with: .none)
        doApply(on: model)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        model.beakerState.goTo(state: .addingSaturatedPrimary, with: .removeSolute(duration: 0.5))
        doApply(on: model)
    }

    private func doApply(on model: SolubilityViewModel) {
        model.statement = statements.instructToAddSaturatedSolute

        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.equilibrium
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
        model.beakerState.goTo(state: .none, with: .removeSolute(duration: 0.5))
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
        model.beakerState.goTo(state: .none, with: .none)
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
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        model.beakerState.goTo(state: .none, with: .hideSolute(duration: 1))
        model.stopShaking()
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = model.timing.end
            model.waterColor = model.componentsWrapper.finalColor.color

        }
        model.beakerState.goTo(state: .none, with: .reAddSolute(duration: 1))
    }
}

private class AddCommonIonSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        doApply(on: model, setComponents: true)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: SolubilityViewModel, setComponents: Bool) {
        model.statement = statements.instructToAddCommonIon
        model.inputState = .addSolute(type: .commonIon)
        model.beakerState.goTo(state: .addingSolute(type: .commonIon), with: .none)
        if setComponents {
            model.componentsWrapper = CommonIonComponentsWrapper(
                timing: SolubleReactionSettings.firstReactionTiming,
                previous: model.componentsWrapper,
                setColor: model.setColor
            )
        }
    }


    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
    }
}

private class AddSoluteToCommonIonSolution: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        doApply(on: model, setWrapper: true)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        doApply(on: model, setWrapper: false)
    }

    private func doApply(on model: SolubilityViewModel, setWrapper: Bool) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.inputState = .addSolute(type: .primary)
            model.activeSolute = nil
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        model.equationState = .showCorrectQuotientFilledIn
        model.statement = statements.instructToAddPrimarySolutePostCommonIon
        model.beakerState.goTo(state: .addingSolute(type: .primary), with: .none)
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
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.activeSolute = nil
        }
        model.stopShaking()
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
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = model.timing.end
        }
    }
}

private class AddAcidSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .addingSolute(type: .acid), with: .none)
        doApply(on: model, setComponents: true)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: SolubilityViewModel, setComponents: Bool) {
        model.statement = statements.instructToAddH
        model.inputState = .addSolute(type: .acid)

        if setComponents {
            model.componentsWrapper = AddAcidComponentsWrapper(
                previous: model.componentsWrapper,
                timing: SolubleReactionSettings.secondReactionTiming,
                setColor: model.setColor
            )
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = model.componentsWrapper.finalColor.color
            model.activeSolute = nil
            model.inputState = .none
        }
        model.stopShaking()
    }
}

private class RunAcidReaction: SolubilityScreenState {

    override func apply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .none, with: .runReaction)
        doApply(on: model)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .none, with: [.undoReaction, .runReaction])
        doApply(on: model)
    }

    private func doApply(on model: SolubilityViewModel) {
        model.statement = statements.acidReactionRunning
        let dt = model.timing.end - model.timing.start

        model.stopShaking()
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
            model.currentTime = model.timing.start
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        withAnimation(.linear(duration: Double(dt))) {
            model.currentTime = model.timing.end
            model.waterColor = model.componentsWrapper.finalColor.color
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .addingSolute(type: .acid), with: .undoReaction)
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.start
            model.waterColor = model.componentsWrapper.initialColor.color
        }
    }

    override func nextStateAutoDispatchDelay(model: SolubilityViewModel) -> Double? {
        Double(model.timing.end - model.timing.start)
    }
}

private class EndAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.acidEquilibriumReached
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.end * 1.001
            model.waterColor = model.componentsWrapper.finalColor.incremented(by: 1).color
        }
        model.beakerState.goTo(state: .none, with: .completeReaction)
    }
}

private extension RGB {
    func incremented(by delta: Double) -> RGB {
        RGB(r: r + delta, g: g + delta, b: b + delta)
    }
}

