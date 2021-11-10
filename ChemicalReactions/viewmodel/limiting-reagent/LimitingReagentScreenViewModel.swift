//
// Reactions App
//

import ReactionsCore
import SwiftUI

class LimitingReagentScreenViewModel: ObservableObject {

    init(persistence: LimitingReagentPersistence) {
        let reaction = LimitingReagentReaction.availableReactions.first!
        self.reaction = reaction
        self.components = LimitingReagentComponents(reaction: reaction)
        self.navigation = LimitingReagentNavigationModel.model(using: self, persistence: persistence)
        self.shakeReactantModel = .init(
            canAddMolecule: self.canAdd,
            addMolecules: self.add,
            useBufferWhenAddingMolecules: false // TODO test performance on old device
        )
        self.components.didSetRows = { [weak self] in
            self?.highlights.clear()
        }
    }

    @Published var statement = [TextLine]()
    @Published var components: LimitingReagentComponents

    @Published var reaction: LimitingReagentReaction {
        didSet {
            components = LimitingReagentComponents(reaction: reaction)
        }
    }

    @Published var input: InputState? = nil
    @Published var equationState = EquationState.showVolume

    @Published var highlights = HighlightedElements<ScreenElement>()

    private(set) var shakeReactantModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>!
    var navigation: NavigationModel<LimitingReagentScreenState>!
}

// MARK: - Navigation
extension LimitingReagentScreenViewModel {
    func next() {
        guard !nextIsDisabled else {
            return
        }
        doGoNext()
    }

    func back() {
        navigation.back()
    }

    func didSelectReaction() {
        doGoNext()
    }

    private func doGoNext() {
        navigation.next()
    }

    var nextIsDisabled: Bool {
        switch input {
        case let .addReactant(type):
            return !components.hasAddedEnough(of: type)
        case .selectReaction:
            return true
        default: return false
        }
    }
}

// MARK: Adding reactant
extension LimitingReagentScreenViewModel {
    func canAdd(reactant: LimitingReagentComponents.Reactant) -> Bool {
        input == .addReactant(type: reactant) && components.canAdd(reactant: reactant)
    }

    func add(reactant: LimitingReagentComponents.Reactant, count: Int) {
        guard input == .addReactant(type: reactant) else {
            return
        }
        switch reactant {
        case .limiting:
            components.addLimitingReactant(count: count)
        case .excess:
            components.addExcessReactant(count: count)
        }
        if !components.canAdd(reactant: reactant) {
            doGoNext()
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
    }
}

// MARK: - Input and equation states
extension LimitingReagentScreenViewModel {
    enum InputState: Equatable {
        case selectReaction,
             setWaterLevel,
             addReactant(type: LimitingReagentComponents.Reactant)
    }

    enum EquationState: Int, Comparable {

        case showVolume, showTheoreticalData, showActualData

        static func < (lhs: EquationState, rhs: EquationState) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum ScreenElement {
        case selectReaction,
             reactionDefinitionStates,
             beakerSlider,
             limitingReactantContainer,
             excessReactantContainer,
             limitingReactantMolesToVolume,
             neededExcessReactantMoles,
             theoreticalProductMass,
             productYieldPercentage
    }
}
