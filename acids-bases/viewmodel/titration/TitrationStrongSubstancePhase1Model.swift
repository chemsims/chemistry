//
// Reactions App
//

import Foundation
import CoreGraphics
import ReactionsCore

class TitrationStrongSubstancePhase1Model: ObservableObject {

    init(
        cols: Int,
        rows: CGFloat,
        settings: TitrationSettings
    ) {
        self.settings = settings
        self.cols = cols
        self.rows = rows
        self.primaryIonCoords = BeakerMolecules(
            coords: [],
            color: .purple,
            label: "" // TODO label
        )
    }

    let settings: TitrationSettings
    let cols: Int
    var rows: CGFloat

    var gridRows: Int {
        GridCoordinateList.availableRows(for: rows)
    }

    @Published var primaryIonCoords: BeakerMolecules
}

// MARK: Incrementing
extension TitrationStrongSubstancePhase1Model {
    func incrementSubstance(count: Int) {
        guard count > 0 else {
            return
        }

        primaryIonCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: primaryIonCoords.coords,
            count: count,
            cols: cols,
            rows: gridRows
        )
    }
}
