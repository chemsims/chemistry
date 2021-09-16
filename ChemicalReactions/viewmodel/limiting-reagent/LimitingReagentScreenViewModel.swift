//
// Reactions App
//

import ReactionsCore
import SwiftUI

class LimitingReagentScreenViewModel: ObservableObject {

    init() {
        self.shakeReactantModel = .init(
            canAddMolecule: self.canAdd,
            addMolecules: self.add,
            useBufferWhenAddingMolecules: false // TODO test performance on old device
        )
    }


    @Published var statement = [TextLine]()

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

    }
}
