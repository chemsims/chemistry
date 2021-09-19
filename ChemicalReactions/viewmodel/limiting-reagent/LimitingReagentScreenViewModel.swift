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

    private(set) var shakeReactantModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>!
    private(set) var navigation: NavigationModel<LimitingReagentScreenState>!
}

// MARK: - Navigation
extension LimitingReagentScreenViewModel {
    func next() {
        guard !nextIsDisabled else {
            return
        }
        navigation.next()
    }

    func back() {
        navigation.back()
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
