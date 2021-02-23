//
// Reactions App
//


import SwiftUI
import ReactionsCore

class AqueousReactionViewModel: ObservableObject {

    @Published var rows: CGFloat = CGFloat(AqueousReactionSettings.initialRows)

    @Published var moleculesA = [GridCoordinate]()

    var concentrationA: CGFloat {
        CGFloat(moleculesA.count) / CGFloat((availableRows * availableCols))
    }

    func incrementAMolecules() {
        moleculesA = GridCoordinateList.addingRandomElementsTo(
            grid: moleculesA,
            count: AqueousReactionSettings.moleculesToIncrement,
            cols: availableCols,
            rows: availableRows
        )
    }

    /// Returns the number of rows available for molecules
    private var availableRows: Int {
        if rows - rows.rounded(.down) > 0.4 {
            assert(Int(rows) != Int(ceil(rows)), "\(rows)")
            return Int(ceil(rows))
        }
        return Int(rows)
    }

    /// Returns the number of cols available for molecules
    private var availableCols: Int {
        MoleculeGridSettings.cols
    }

}
