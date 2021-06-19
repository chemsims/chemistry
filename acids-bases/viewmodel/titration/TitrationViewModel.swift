//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        self.components = TitrationComponents(
            cols: MoleculeGridSettings.cols,
            rows: AcidAppSettings.initialRows,
            settings: .standard
        )
        self.rows = CGFloat(initialRows)
        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in true },
            addMolecules: { (_, _) in }
        )
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat
    let components: TitrationComponents

    var shakeModel: MultiContainerShakeViewModel<TempMolecule>!

    enum TempMolecule: String, CaseIterable {
        case A
    }
}
