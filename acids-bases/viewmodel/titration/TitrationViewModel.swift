//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        self.components = TitrationComponents(
            substance: .weakAcids.first!,
            cols: MoleculeGridSettings.cols,
            rows: AcidAppSettings.initialRows,
            settings: .standard
        )
        self.rows = CGFloat(initialRows)
        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in true },
            addMolecules: { (_, _) in }
        )
        self.dropperEmitModel = MoleculeEmittingViewModel(
            canAddMolecule: { true },
            doAddMolecule: { _ in }
        )
        self.buretteEmitModel = MoleculeEmittingViewModel(
            canAddMolecule: { true },
            doAddMolecule: { _ in }
        )
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat
    let components: TitrationComponents

    var shakeModel: MultiContainerShakeViewModel<TempMolecule>!
    var dropperEmitModel: MoleculeEmittingViewModel!
    var buretteEmitModel: MoleculeEmittingViewModel!

    enum TempMolecule: String, CaseIterable {
        case A
    }
}
