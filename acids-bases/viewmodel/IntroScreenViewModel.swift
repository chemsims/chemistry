//
// Reactions App
//

import SwiftUI
import ReactionsCore

class IntroScreenViewModel: ObservableObject {

    @Published var components: IntroScreenComponents
    @Published var rows: CGFloat {
        didSet {
            components.rows = GridCoordinateList.availableRows(for: rows)
        }
    }
    @Published var substance: AcidOrBase

    init() {
        let initialRows = 10
        let initialSubstance = AcidOrBase.strongAcid(name: "", secondaryIon: .A)
        self.substance = initialSubstance
        self.rows = CGFloat(initialRows)
        self.components = GeneralScreenComponents(
            substance: initialSubstance,
            cols: 10,
            rows: initialRows
        )
    }

}
