//
// Reactions App
//

import CoreGraphics
import ReactionsCore

class PrecipitationScreenViewModel: ObservableObject {

    init() {
        self.shakeModel = .init(
            canAddMolecule: { _ in true },
            addMolecules: { _, _ in  },
            useBufferWhenAddingMolecules: false // TODO perf test
        )
        self.navigation = PrecipitationNavigationModel.model(
            using: self
        )
    }

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<PrecipitationScreenState>!

    @Published var rows: CGFloat = CGFloat(ChemicalReactionsSettings.initialRows)

    let components = PrecipitationComponents()
    let shakeModel: MultiContainerShakeViewModel<PrecipitationComponents.Reactant>
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
