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
                SetStatement(statement: statements.intro, highlights: [.reactionSelectionToggle]),
                SelectReaction(),
                PostSelectReaction(),
                SetStatement(statement: statements.explainSolubility2),
                ShowRecapQuotient(),
                ShowCrossedOutOldQuotient(),
                SetStatement(statement: statements.explainQEquation2, highlights: [.quotientToKspDefinition]),
                ShowCorrectQuotientAndRunDemo(),
                StopDemo(),
                SetWaterLevel(),
                AddSolute(),
                ShowFirstReactionSaturatedSolution(),
                AddSoluteToSaturatedBeaker(),
                PostAddingSoluteToSaturatedBeaker(statement: statements.explainSuperSaturated),
                SetStatement(statement: { statements.explainSaturatedEquilibrium1(product: $0.selectedReaction.products) }),
                SetStatement(statement: statements.explainSaturatedEquilibrium2),
                SetCurrentTime(),
                PrepareCommonIonReaction(),
                AddCommonIonSolute(),
                AddSoluteToCommonIonSolution(),
                ShowCommonIonSaturatedSolution(),
                AddSoluteToSaturatedBeaker(),
                PostAddingSoluteToSaturatedBeaker(statement: statements.explainSuperSaturated),
                SetCurrentTime(),
                PrepareAcidReaction(),
                SetStatement(statement: { statements.explainPh2(product: $0.selectedReaction.products) }),
                AddAcidSolute(),
                RunAcidReaction(),
                EndAcidReaction(),
                SetCurrentTime(),
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

    private let statement: (SolubilityViewModel) -> [TextLine]
    private let highlights: [SolubleScreenElement]

    init(
        statement: @escaping (SolubilityViewModel) -> [TextLine],
        highlights: [SolubleScreenElement] = []
    ) {
        self.statement = statement
        self.highlights = highlights
    }

    convenience init(statement: [TextLine], highlights: [SolubleScreenElement] = []) {
        self.init(statement: { _ in statement }, highlights: highlights)
    }

    override func apply(on model: SolubilityViewModel) {
        model.statement = statement(model)
        model.highlights.elements = highlights
    }

    override func unapply(on model: SolubilityViewModel) {
        model.highlights.clear()
    }
}

private class SelectReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainPrecipitationReactions
        model.inputState = .selectingReaction
        model.reactionSelectionToggled = true
        model.highlights.elements = [.reactionSelectionToggle]
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
        model.reactionSelectionToggled = false
        model.highlights.clear()
    }

    override func unapply(on model: SolubilityViewModel) {
        model.showSelectedReaction = false
    }
}

private class ShowRecapQuotient: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainRecapEquation
        model.equationState = .showOriginalQuotientAndQuotientRecap
        model.highlights.elements = [.quotientRecap]
    }

    override func unapply(on model: SolubilityViewModel) {
        model.equationState = .showOriginalQuotient
    }
}

private class ShowCrossedOutOldQuotient: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainQEquation1(solute: model.selectedReaction.products.salt)
        model.highlights.elements = [.quotientToConcentrationDefinition]
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
        model.highlights.clear()
        withAnimation(.easeOut(duration: 0.3)) {
            model.equationState = .showCorrectQuotientNotFilledIn
        }
        model.shakingModel.shouldAddParticle = true
        model.beakerLabel = .demo

        if setComponents {
            model.componentsWrapper = DemoReactionComponentsWrapper(
                maxCount: catalystCount,
                previous: model.componentsWrapper,
                timing: model.timing,
                solubilityCurve: model.selectedReaction.solubility,
                setColor: model.setColor,
                reaction: model.selectedReaction
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
        model.shakingModel.shouldAddParticle = false
        model.beakerLabel = .clear
    }
}

private class StopDemo: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainKspRatio2
        model.beakerState.goTo(state: .none, with: .cleanupDemoReaction)
        model.shakingModel.shouldAddParticle = false
        model.beakerLabel = .clear
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = RGB.beakerLiquid.color
        }
    }
}


private class SetWaterLevel: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToSetWaterLevel
        model.inputState = .setWaterLevel
        model.highlights.elements = [.waterSlider]
        model.setMilligramsAdded()
    }

    override func unapply(on model: SolubilityViewModel) {
        model.inputState = .none
        model.highlights.clear()
    }
}

private class AddSolute: SolubilityScreenState {

    override func apply(on model: SolubilityViewModel) {
        model.componentsWrapper = PrimarySoluteComponentsWrapper(
            soluteToAddForSaturation: model.soluteToAddForSaturation,
            timing: model.timing,
            previous: nil,
            solubilityCurve: model.selectedReaction.solubility,
            setTime: model.setTime,
            reaction: model.selectedReaction
        )
        doApply(on: model)
    }

    override func reapply(on model: SolubilityViewModel) {
        model.componentsWrapper.reset()
        model.setMilligramsAdded()
        apply(on: model)
    }

    private func doApply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.inputState = .addSolute(type: .primary)
            model.activeSolute.setValue(.primary)
            model.waterColor = model.componentsWrapper.initialColor.color
            model.showShakeText = true
        }

        model.equationState = .showCorrectQuotientFilledIn
        model.statement = statements.instructToAddSolute(product: model.selectedReaction.products)
        model.beakerState.goTo(state: .addingSolute(type: .primary), with: .none)
        model.startShaking()
        model.highlights.clear()
        model.reactionArrowDirection = .forward
        model.beakerLabel = .addingSolute
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute.setValue(nil)
            model.waterColor = model.componentsWrapper.initialColor.color
            model.showShakeText = false
        }
        model.stopShaking()
        model.reactionArrowDirection = .none
        model.beakerLabel = .clear
    }
}

private class ShowSaturatedSolution: SolubilityScreenState {

    override func apply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .none, with: .none)
        doApply(on: model, setComponents: true)
    }

    override func reapply(on model: SolubilityViewModel) {
        doApply(on: model, setComponents: false)
    }

    private func doApply(on model: SolubilityViewModel, setComponents: Bool) {
        model.stopShaking()
        model.reactionArrowDirection = .none
        model.beakerLabel = .saturated

        if setComponents {
            model.componentsWrapper = PrimarySoluteSaturatedComponentsWrapper(
                previous: model.componentsWrapper,
                solubilityCurve: model.selectedReaction.solubility,
                setTime: model.setTime
            )
        }

        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute.setValue(nil)
            model.showShakeText = false
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
    }
}

private class ShowFirstReactionSaturatedSolution: ShowSaturatedSolution {
    override func apply(on model: SolubilityViewModel) {
        super.apply(on: model)
        setStatement(model)
    }

    override func reapply(on model: SolubilityViewModel) {
        super.reapply(on: model)
        setStatement(model)
    }

    private func setStatement(_ model: SolubilityViewModel) {
        model.statement = statements.primaryEquilibriumReached(
            amount: SolubleReactionSettings.milligrams(for: model.soluteToAddForSaturation),
            solute: model.selectedReaction.products.salt
        )
    }
}

private class ShowCommonIonSaturatedSolution: ShowSaturatedSolution {
    override func apply(on model: SolubilityViewModel) {
        super.apply(on: model)
        setStatement(model)
    }

    override func reapply(on model: SolubilityViewModel) {
        super.reapply(on: model)
        setStatement(model)
    }

    private func setStatement(_ model: SolubilityViewModel) {
        model.statement = statements.commonIonEquilibriumReached(
            amount: SolubleReactionSettings.milligrams(for: model.commonIonSoluteToAddForSaturation),
            product: model.selectedReaction.products
        )
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
        model.statement = statements.instructToAddSaturatedSolute(solute: model.selectedReaction.products.salt)
        model.beakerLabel = .addingSaturatedSolute
        model.reactionArrowDirection = .equilibrium

        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.equilibrium
            model.inputState = .addSaturatedSolute
            model.activeSolute.setValue(.primary)
            model.showShakeText = true
        }
        model.startShaking()
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.equilibrium
            model.showShakeText = false
        }
        model.componentsWrapper.reset()
        model.beakerState.goTo(state: .none, with: .removeSolute(duration: 0.5))
        model.reactionArrowDirection = .none
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
            model.activeSolute.setValue(nil)
            model.showShakeText = false
        }
        model.reactionArrowDirection = .none
        model.beakerLabel = .superSaturated
    }
}

private class SetCurrentTime: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.instructToSetCurrentTime
        model.canSetCurrentTime = true
    }

    override func unapply(on model: SolubilityViewModel) {
        model.canSetCurrentTime = false
    }
}

private class PrepareCommonIonReaction: SolubilityScreenState {

    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainCommonIonEffect(product: model.selectedReaction.products)
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute.setValue(nil)
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        model.beakerState.goTo(state: .none, with: .hideSolute(duration: 1))
        model.stopShaking()
        model.canSetCurrentTime = false
        model.beakerLabel = .clear
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = model.timing.end
            model.waterColor = model.componentsWrapper.finalColor.color

        }
        model.beakerState.goTo(state: .none, with: .reAddSolute(duration: 1))
        model.beakerLabel = .superSaturated
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
        model.statement = statements.instructToAddCommonIon(product: model.selectedReaction.products)
        model.inputState = .addSolute(type: .commonIon)
        model.beakerState.goTo(state: .addingSolute(type: .commonIon), with: .none)
        withAnimation(.easeOut(duration: 0.5)) {
            model.activeSolute.setValue(.commonIon)
            model.showShakeText = true
            model.showSoluteReactionLabel = true
        }
        model.startShaking()
        if setComponents {
            model.componentsWrapper = CommonIonComponentsWrapper(
                timing: SolubleReactionSettings.firstReactionTiming,
                previous: model.componentsWrapper,
                solubilityCurve: model.selectedReaction.solubility,
                setColor: model.setColor,
                reaction: model.selectedReaction
            )
        }
        model.setMilligramsAdded()
        model.beakerLabel = .addingCommonIon
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.showShakeText = false
            model.showSoluteReactionLabel = false
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
            model.activeSolute.setValue(.primary)
            model.waterColor = model.componentsWrapper.initialColor.color
            model.showShakeText = true
            model.showSoluteReactionLabel = false
        }
        model.equationState = .showCorrectQuotientFilledIn
        model.statement = statements.instructToAddPrimarySolutePostCommonIon(product: model.selectedReaction.products)
        model.beakerState.goTo(state: .addingSolute(type: .primary), with: .none)
        model.startShaking()
        model.reactionArrowDirection = .forward
        if setWrapper {
            model.componentsWrapper = PrimarySoluteComponentsWrapper(
                soluteToAddForSaturation: model.commonIonSoluteToAddForSaturation,
                timing: SolubleReactionSettings.firstReactionTiming,
                previous: model.componentsWrapper,
                solubilityCurve: model.selectedReaction.solubility,
                setTime: model.setTime,
                reaction: model.selectedReaction
            )
        }
        model.setMilligramsAdded()
        model.beakerLabel = .addingSolute
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
        }
        model.reactionArrowDirection = .none
    }
}

private class PrepareAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.explainPh1
        model.stopShaking()
        model.canSetCurrentTime = false
        withAnimation(.easeOut(duration: 1)) {
            model.inputState = .none
            model.activeSolute.setValue(nil)
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
        model.statement = statements.instructToAddH(product: model.selectedReaction.products)
        model.inputState = .addSolute(type: .acid)
        withAnimation(.easeOut(duration: 0.5)) {
            model.activeSolute.setValue(.acid)
            model.showShakeText = true
            model.showSoluteReactionLabel = true
        }
        model.startShaking()
        model.beakerLabel = .addingAcid

        if setComponents {
            model.componentsWrapper = AddAcidComponentsWrapper(
                previous: model.componentsWrapper,
                timing: SolubleReactionSettings.secondReactionTiming,
                solubilityCurve: model.selectedReaction.solubility,
                setColor: model.setColor,
                reaction: model.selectedReaction
            )
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.waterColor = model.componentsWrapper.finalColor.color
            model.activeSolute.setValue(nil)
            model.inputState = .none
            model.showShakeText = false
            model.showSoluteReactionLabel = false
        }
        model.stopShaking()
        model.beakerLabel = .superSaturated
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
        model.statement = statements.acidReactionRunning(product: model.selectedReaction.products)
        let dt = model.timing.equilibrium - model.timing.start

        model.stopShaking()
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute.setValue(nil)
            model.currentTime = model.timing.start
            model.waterColor = model.componentsWrapper.initialColor.color
            model.showSoluteReactionLabel = false
        }
        withAnimation(.linear(duration: Double(dt))) {
            model.currentTime = model.timing.equilibrium
            model.waterColor = model.componentsWrapper.finalColor.color
        }
        model.reactionArrowDirection = .forward
        model.beakerLabel = .runningAcidReaction
    }

    override func unapply(on model: SolubilityViewModel) {
        model.beakerState.goTo(state: .addingSolute(type: .acid), with: .undoReaction)
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.start
            model.waterColor = model.componentsWrapper.initialColor.color
        }
        model.reactionArrowDirection = .none
    }

    override func delayedStates(model: SolubilityViewModel) -> [DelayedState<SolubilityScreenState>] {
        [
            DelayedState(state: CompleteAnimation(), delay: Double(model.timing.equilibrium - model.timing.start))
        ]
    }

    override func nextStateAutoDispatchDelay(model: SolubilityViewModel) -> Double? {
        Double(model.timing.end - model.timing.start)
    }

    private class CompleteAnimation: SolubilityScreenState {
        override func apply(on model: SolubilityViewModel) {
            model.statement = statements.acidEquilibriumReached(product: model.selectedReaction.products)
            model.reactionArrowDirection = .equilibrium
            let dt = model.timing.end - model.timing.equilibrium
            withAnimation(.linear(duration: Double(dt))) {
                model.currentTime = model.timing.end
            }
        }
    }
}

private class EndAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = statements.acidEquilibriumReached(product: model.selectedReaction.products)
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = model.timing.end * 1.001
            model.waterColor = model.componentsWrapper.finalColor.incremented(by: 1).color
        }
        model.beakerState.goTo(state: .none, with: .completeReaction)
        model.reactionArrowDirection = .none
        model.beakerLabel = .saturated
    }
}

private extension RGB {
    func incremented(by delta: Double) -> RGB {
        RGB(r: r + delta, g: g + delta, b: b + delta)
    }
}
