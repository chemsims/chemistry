//
// Reactions App
//

import CoreGraphics
import ReactionsCore

class PrecipitationScreenViewModel: ObservableObject {

    init() {
        self.shakeModel = .init(
            canAddMolecule: self.canAdd,
            addMolecules: self.add,
            useBufferWhenAddingMolecules: false // TODO perf test
        )
        self.navigation = PrecipitationNavigationModel.model(
            using: self
        )
    }

    @Published var statement = [TextLine]()
    @Published var input: Input? = nil
    @Published var rows: CGFloat = CGFloat(ChemicalReactionsSettings.initialRows)

    private(set) var navigation: NavigationModel<PrecipitationScreenState>!

    let components = PrecipitationComponents()
    private(set) var shakeModel: MultiContainerShakeViewModel<PrecipitationComponents.Reactant>!
}

// MARK: - Navigation
extension PrecipitationScreenViewModel {
    func next() {
        if !nextIsDisabled {
            navigation.next()
        }
    }

    func back() {
        navigation.back()
    }

    var nextIsDisabled : Bool {
        false
    }
}

// MARK: - Adding molecules
extension PrecipitationScreenViewModel {
    private func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
        input == .addReactant(type: reactant) && components.canAdd(reactant: reactant)
    }

    private func add(reactant: PrecipitationComponents.Reactant, count: Int) {
        if canAdd(reactant: reactant) {
            components.add(reactant: reactant, count: count)
        }
    }
}

// MARK: - Input state
extension PrecipitationScreenViewModel {
    enum Input: Equatable {
        case setWaterLevel
        case addReactant(type: PrecipitationComponents.Reactant)
    }
}
