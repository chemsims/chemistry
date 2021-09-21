//
// Reactions App
//

import ReactionsCore
import SwiftUI

class LimitingReagentScreenViewModel: ObservableObject {

    init() {
        let reaction = LimitingReagentReaction.availableReactions.first!
        self.reaction = reaction
        self.components = LimitingReagentComponents(reaction: reaction)
        self.navigation = LimitingReagentNavigationModel.model(using: self)
        self.shakeReactantModel = .init(
            canAddMolecule: self.canAdd,
            addMolecules: self.add,
            useBufferWhenAddingMolecules: false // TODO test performance on old device
        )
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

    private(set) var shakeReactantModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>!
    private(set) var navigation: NavigationModel<LimitingReagentScreenState>!
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
            if !components.canAdd(reactant: reactant) {
                doGoNext()
            }
        case .excess:
            components.addExcessReactant(count: count)
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
}
