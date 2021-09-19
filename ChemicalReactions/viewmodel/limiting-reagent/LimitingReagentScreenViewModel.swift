//
// Reactions App
//

import ReactionsCore
import SwiftUI

class LimitingReagentScreenViewModel: ObservableObject {

    init() {
        let reaction = LimitingReagentReaction.firstReaction
        self.components = LimitingReagentComponents(reaction: reaction)
        self.shakeReactantModel = .init(
            canAddMolecule: self.canAdd,
            addMolecules: self.add,
            useBufferWhenAddingMolecules: false // TODO test performance on old device
        )
    }

    @Published var statement = [TextLine]()
    @Published var components: LimitingReagentComponents

    private(set) var shakeReactantModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>!
    
}

// MARK: - Navigation
extension LimitingReagentScreenViewModel {
    func next() {

    }

    func back() {

    }

    var nextIsDisabled: Bool {
        false
    }
}

// MARK: Adding reactant
extension LimitingReagentScreenViewModel {
    func canAdd(reactant: LimitingReagentComponents.Reactant) -> Bool {
        true
    }

    func add(reactant: LimitingReagentComponents.Reactant, count: Int) {
        switch reactant {
        case .limiting:
            components.addLimitingReactant(count: count)
        default:
            break
        }
    }
}
