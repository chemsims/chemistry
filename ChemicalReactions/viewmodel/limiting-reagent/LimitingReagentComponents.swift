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
        self.equationData = Self.makeEquationData(
            reaction: reaction,
            volume: rowsToVolume.getY(at: CGFloat(initialRows)),
            limitingReactantMolarity: 0
        )
    }

    let reaction: LimitingReagentReaction
    let beakerCols: Int
    let rowsToVolume: Equation

    @Published var limitingReactantCoords = [GridCoordinate]()
    @Published var excessReactantCoords = [GridCoordinate]()
    @Published var equationData: LimitingReagentEquationData

    @Published var productCoords = [GridCoordinate]()
    @Published var reactionProgress: CGFloat = 0
    @Published var rows: CGFloat

    func addLimitingReactant(count: Int) {
        limitingReactantCoords = GridCoordinateList.addingRandomElementsTo(
            grid: limitingReactantCoords,
            count: count,
            cols: beakerCols,
            rows: roundedRows
        )
        updateEquationData()
    }

    func addExcessReactant(count: Int) {
        excessReactantCoords = GridCoordinateList.addingRandomElementsTo(
            grid: excessReactantCoords,
            count: count,
            cols: beakerCols,
            rows: roundedRows,
            avoiding: limitingReactantCoords
        )
    }

    var volume: CGFloat {
        rowsToVolume.getY(at: rows)
    }

    var limitingReactantMolarity: CGFloat {
        let gridSize = CGFloat(beakerCols * roundedRows)
        let coordCount = CGFloat(limitingReactantCoords.count)
        return coordCount / gridSize
    }

    private var roundedRows: Int {
        GridCoordinateList.availableRows(for: rows)
    }
}

extension LimitingReagentComponents {

    func prepareReaction() {
        let coordsFromLimiting = limitingReactantCoords.dropLast()
        let coordsFromExcess = excessReactantCoords.dropLast()

        productCoords = Array(coordsFromLimiting + coordsFromExcess)
    }

    func updateEquationData() {
        self.equationData = Self.makeEquationData(
            reaction: reaction,
            volume: volume,
            limitingReactantMolarity: limitingReactantMolarity
        )
    }
}

private extension LimitingReagentComponents {
    static func makeEquationData(
        reaction: LimitingReagentReaction,
        volume: CGFloat,
        limitingReactantMolarity: CGFloat
    ) -> LimitingReagentEquationData {

        let limitingMoles = limitingReactantMolarity * volume
        let excessCoeff = CGFloat(reaction.excessReactant.coefficient)
        let theoreticalProductMoles = limitingMoles
        let theoreticalProductMass = CGFloat(reaction.product.molarMass) * theoreticalProductMoles

        let yield = LinearEquation(x1: 0, y1: 0, x2: 1, y2: reaction.yield)
        let productMass = theoreticalProductMass * yield
        let productMoles = productMass / CGFloat(reaction.product.molarMass)

        let excessReactantMoles = excessCoeff * productMoles
        let excessReactantMass = CGFloat(reaction.excessReactant.molarMass) * excessReactantMoles

        return LimitingReagentEquationData(
            reaction: reaction,
            volume: volume,
            limitingReactantMoles: limitingMoles,
            limitingReactantMolarity: limitingReactantMolarity,
            neededExcessReactantMoles: excessCoeff * limitingMoles,
            theoreticalProductMass: theoreticalProductMass,
            theoreticalProductMoles: theoreticalProductMoles,
            reactingExcessReactantMoles: excessReactantMoles,
            reactingExcessReactantMass: excessReactantMass,
            actualProductMass: productMass,
            actualProductMoles: productMoles,
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
