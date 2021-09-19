//
// Reactions App
//

import ReactionsCore
import SwiftUI

class LimitingReagentComponents: ObservableObject {

    init(
        reaction: LimitingReagentReaction,
        initialRows: Int = ChemicalReactionsSettings.initialRows,
        cols: Int = MoleculeGridSettings.cols,
        rowsToVolume: Equation = ChemicalReactionsSettings.rowsToVolume
    ) {
        self.reaction = reaction
        self.rows = CGFloat(initialRows)
        self.beakerCols = cols
        self.rowsToVolume = rowsToVolume
    }

    let reaction: LimitingReagentReaction
    let beakerCols: Int
    let rowsToVolume: Equation

    @Published var limitingReactantCoords = [GridCoordinate]()
    @Published var excessReactantCoords = [GridCoordinate]()
    @Published var rows: CGFloat
    @Published var reactionProgress: CGFloat = 0

    func addLimitingReactant(count: Int) {
        limitingReactantCoords = GridCoordinateList.addingRandomElementsTo(
            grid: limitingReactantCoords,
            count: count,
            cols: beakerCols,
            rows: roundedRows
        )
    }

    private var roundedRows: Int {
        GridCoordinateList.availableRows(for: rows)
    }

    var volume: CGFloat {
        rowsToVolume.getY(at: rows)
    }

    var productCoords: FractionedCoordinates {
        .init(coordinates: [], fractionToDraw: ConstantEquation(value: 0))
    }

    var limitingReactantMolarity: CGFloat {
        let gridSize = CGFloat(beakerCols * roundedRows)
        let coordCount = CGFloat(limitingReactantCoords.count)
        return coordCount / gridSize
    }

    var limitingReactantMoles: CGFloat {
        limitingReactantMolarity * volume
    }

    var excessReactantTheoreticalMoles: CGFloat {
        CGFloat(reaction.excessReactant.coefficient) * limitingReactantMoles
    }

    var productTheoreticalMoles: CGFloat {
        limitingReactantMoles
    }

    var productTheoreticalMass: CGFloat {
        CGFloat(reaction.product.molecularMass) * productTheoreticalMoles
    }

    /// Yield as a percentage between 0 and 1
    var yield: Equation {
        LinearEquation(x1: 0, y1: 0, x2: 1, y2: reaction.yield)
    }

    var productActualMass: Equation {
        productTheoreticalMass * yield
    }

    var productActualMoles: Equation {
        productActualMass / CGFloat(reaction.product.molecularMass)
    }

    var excessReactantActualMoles: Equation {
        CGFloat(reaction.excessReactant.coefficient) * productActualMoles
    }

    var excessReactantActualMass: Equation {
        CGFloat(reaction.excessReactant.molecularMass) * excessReactantActualMoles
    }
}

extension LimitingReagentComponents {
    var equationData: LimitingReagentEquationData {
        LimitingReagentEquationData(
            reaction: reaction,
            volume: volume,
            limitingReactantMoles: limitingReactantMoles,
            limitingReactantMolarity: limitingReactantMolarity,
            neededExcessReactantMoles: excessReactantTheoreticalMoles,
            theoreticalProductMass: productTheoreticalMass,
            theoreticalProductMoles: productTheoreticalMoles,
            reactingExcessReactantMoles: excessReactantActualMoles,
            reactingExcessReactantMass: excessReactantActualMass,
            actualProductMass: productActualMass,
            actualProductMoles: productActualMoles,
            yield: yield
        )
    }
}

// MARK: - Types
extension LimitingReagentComponents {
    enum Reactant: Int, CaseIterable, Identifiable {
        case limiting, excess

        var id: Int {
            self.rawValue
        }
    }
}
