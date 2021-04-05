//
// Reactions App
//

import ReactionsCore
import SwiftUI

class SolubilityNavigationModel {
    static func model(model: SolubilityViewModel) -> NavigationModel<SolubilityScreenState> {
        NavigationModel(
            model: model,
            states: [
                SetStatement(statement: ["Click next to add solute"]),
                AddSolute(),
                ShowSaturatedSolution(),
                AddSoluteToSaturatedBeaker(),
                PrepareCommonIonReaction(),
                AddCommonIonSolute(),
                AddSolute(),
                ShowSaturatedSolution(),
                AddSoluteToSaturatedBeaker(),
                PrepareAcidReaction(),
                AddAcidSolute()
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

private class AddSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.inputState = .addSolute(type: .primary)
            model.activeSolute = nil
        }
        model.statement = ["Now, add solute"]
        model.beakerSoluteState = .addingSolute(type: .primary, clearPrevious: false)
        model.soluteCounts = SoluteContainer(maxAllowed: model.soluteToAddForSaturation)
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute = nil
        }
    }
}

private class ShowSaturatedSolution: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Solution is now saturated"]
        model.stopShaking()
        model.beakerSoluteState = .addingSolute(type: .primary, clearPrevious: false)

        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
        }
    }

    override func reapply(on model: SolubilityViewModel) {
        apply(on: model)
        model.soluteCounts = SoluteContainer(maxAllowed: model.soluteToAddForSaturation, isSaturated: true)
    }
}

private class AddSoluteToSaturatedBeaker: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Now add a little more solute"]
        model.beakerSoluteState = .addingSaturatedPrimary
        model.soluteCounts = SoluteContainer(maxAllowed: SolubleReactionSettings.saturatedSoluteParticlesToAdd)
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
    }
}

private class PrepareCommonIonReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["This is a common ion reaction"]
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute = nil
        }
        model.beakerSoluteState = .addingSolute(type: .commonIon, clearPrevious: true)
        model.shouldRemoveSolute = true
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 1
            model.shouldRemoveSolute = false
            model.shouldAddRemovedSolute = true
        }
    }
}

private class AddCommonIonSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Now, add common ion solute"]
        model.inputState = .addSolute(type: .commonIon)
        model.beakerSoluteState = .addingSolute(type: .commonIon, clearPrevious: false)
        model.soluteCounts = SoluteContainer(maxAllowed: SolubleReactionSettings.commonIonSoluteParticlesToAdd)
    }

    override func reapply(on model: SolubilityViewModel) {
        apply(on: model)
        withAnimation(.easeOut(duration: 0.5)) {
            model.extraB0 = 0
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.extraB0 = 0
        }
    }
}

private class PrepareAcidReaction: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Next, we will add acid"]
        model.components = SolubilityComponents(
            equilibriumConstant: model.components.equilibriumConstant,
            initialConcentration: model.components.equation.finalConcentration,
            startTime: model.components.startTime,
            equilibriumTime: model.components.equilibriumTime,
            previousEquation: model.components.equation
        )
        model.timing = SolubleReactionSettings.secondReactionTiming
        model.extraB0 = 0
        withAnimation(.easeOut(duration: 1)) {
            model.inputState = .none
            model.activeSolute = nil
            model.chartOffset = model.timing.offset
            model.currentTime = model.timing.start
        }
    }

    override func unapply(on model: SolubilityViewModel) {
        let previousEquation = model.components.previousEquation
        model.components = SolubilityComponents(
            equilibriumConstant: model.components.equilibriumConstant,
            initialConcentration: model.components.initialConcentration,
            startTime: model.components.startTime,
            equilibriumTime: model.components.equilibriumTime,
            previousEquation: nil
        )
        if let previousEquation = previousEquation {
            model.extraB0 = previousEquation.initialConcentration.value(for: .B)
        }
        model.timing = SolubleReactionSettings.firstReactionTiming
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = model.timing.end
        }
    }
}

private class AddAcidSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Now, add acid solute"]
        model.inputState = .addSolute(type: .acid)
        model.beakerSoluteState = .addingSolute(type: .acid, clearPrevious: false)
    }
}
