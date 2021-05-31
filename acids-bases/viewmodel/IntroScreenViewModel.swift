//
// Reactions App
//

import SwiftUI
import ReactionsCore

class IntroScreenViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        let initialSubstance = AcidOrBase.strongAcid(
            name: "",
            secondaryIon: .A,
            color: .blue
        )
        self.substance = initialSubstance
        self.rows = CGFloat(initialRows)
        self.components = GeneralScreenComponents(
            substance: initialSubstance,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )
        self.addMoleculesModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in true },
            addMolecules: { _, _ in self.components.increment(count: 1) }
        )
    }

    @Published var components: IntroScreenComponents
    @Published var rows: CGFloat {
        didSet {
            components.rows = GridCoordinateList.availableRows(for: rows)
        }
    }
    @Published var substance: AcidOrBase
    @Published var selectedSubstances = AcidOrBaseMap<AcidOrBase?>.constant(nil)

    private(set) var addMoleculesModel: MultiContainerShakeViewModel<AcidOrBaseType>!


    func increment() {
        components.increment(count: 1)
    }
}
