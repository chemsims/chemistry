//
// Reactions App
//


import SwiftUI
import ReactionsCore

class AqueousReactionViewModel: ObservableObject {

    @Published var rows: CGFloat = CGFloat(AqueousReactionSettings.initialRows)

    @Published var moleculesA = [GridCoordinate]()
    @Published var moleculesB = [GridCoordinate]()

    var concentrationA: CGFloat {
        CGFloat(moleculesA.count) / CGFloat((availableRows * availableCols))
    }

    var equationA: Equation {
        EquilibriumReactionEquation(t1: 0, c1: 0.8, t2: 15, c2: 1)
    }

    var equationB: Equation {
        EquilibriumReactionEquation(t1: 0, c1: 0.6, t2: 15, c2: 0.3)
    }

    var equationC: Equation {
        EquilibriumReactionEquation(t1: 0, c1: 0, t2: 15, c2: 0.4)
    }

    var equationD: Equation {
        EquilibriumReactionEquation(t1: 0, c1: 0, t2: 15, c2: 0.5)
    }

    func incrementAMolecules() {
        moleculesA = addingMolecules(to: moleculesA, avoiding: moleculesB)
    }

    func incrementBMolecules() {
        moleculesB = addingMolecules(to: moleculesB, avoiding: moleculesA)
    }

    private func addingMolecules(to molecules: [GridCoordinate], avoiding: [GridCoordinate]) -> [GridCoordinate] {
        GridCoordinateList.addingRandomElementsTo(
            grid: molecules,
            count: AqueousReactionSettings.moleculesToIncrement,
            cols: availableCols,
            rows: availableRows,
            avoiding: avoiding
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
