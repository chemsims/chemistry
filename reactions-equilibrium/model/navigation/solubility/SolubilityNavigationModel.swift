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
                AddCommonIonSolute()
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
        }
        model.resetParticles()
        model.statement = ["Now, add solute"]
        model.inputState = .addSolute(type: .primary)
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
        model.componentWrapper = SolubilityComponentsWrapper(
            equilibriumConstant: 0.1,
            startTime: SolubleReactionSettings.firstReactionTiming.start,
            equilibriumTime: SolubleReactionSettings.firstReactionTiming.equilibrium
        )
        withAnimation(.easeOut(duration: 1)) {
            model.currentTime = 0
            model.inputState = .none
            model.activeSolute = nil
        }
        model.beakerSoluteState = .addingSolute(type: .commonIon, clearPrevious: true)
        model.resetParticles()
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
        model.soluteCounts = SoluteContainer(maxAllowed: SolubleReactionSettings.commonIonSoluteParticlesToAdd)
    }
}
