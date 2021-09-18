//
// Reactions App
//

import ReactionsCore
import SwiftUI

class LimitingReagentScreenViewModel: ObservableObject {

    init() {
        let reaction = LimitingReagentReaction(
            yield: 0.98,
            excessReactantCoefficient: 1,
            excessReactantMolecularMass: 1,
            productMolecularMass: 50
        )
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

extension LimitingReagentScreenViewModel {
    var equationData: LimitingReagentEquationData {
        LimitingReagentEquationData(
            limitingReactant: "A",
            excessReactant: "B",
            product: "C",
            excessReactantCoefficient: 2,
            excessReactantMolarMass: 10,
            productMolarMass: 10,
            volume: components.volume,
            limitingReactantMoles: components.limitingReactantMoles,
            limitingReactantMolarity: components.limitingReactantMolarity,
            neededExcessReactantMoles: components.excessReactantTheoreticalMoles,
            theoreticalProductMass: components.productTheoreticalMass,
            theoreticalProductMoles: components.productTheoreticalMoles,
            reactingExcessReactantMoles: components.excessReactantActualMoles,
            reactingExcessReactantMass: components.excessReactantActualMass,
            actualProductMass: components.productActualMass,
            actualProductMoles: components.productActualMoles,
            yield: components.yield
        )
    }
}
