//
// Reactions App
//

import SwiftUI
import ReactionsCore
import CoreMotion

class AddingMoleculesViewModel: MultiContainerShakeViewModel {

    @Published var activeMolecule: AqueousMolecule?

    init(
        canAddMolecule: @escaping (AqueousMolecule) -> Bool,
        addMolecules: @escaping (AqueousMolecule, Int) -> Void
    ) {
        self.models = MoleculeValue { molecule in
            ShakeContainerViewModel(
                canAddMolecule: { canAddMolecule(molecule) },
                addMolecules: { addMolecules(molecule, $0) }
            )
        }
    }

    let models: MoleculeValue<ShakeContainerViewModel>

    var allModels: [ShakeContainerViewModel] {
        models.all
    }

    func model(for molecule: AqueousMolecule) -> ShakeContainerViewModel {
        models.value(for: molecule)
    }
}
