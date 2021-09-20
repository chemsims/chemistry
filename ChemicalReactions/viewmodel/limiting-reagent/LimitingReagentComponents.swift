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
        self.underlyingRows = CGFloat(initialRows)
        self.beakerCols = cols
        self.rowsToVolume = rowsToVolume
        self.shuffledCoords = GridCoordinateList.list(cols: cols, rows: initialRows).shuffled()
    }

    let reaction: LimitingReagentReaction
    let beakerCols: Int
    let rowsToVolume: Equation

    @Published var limitingReactantCoords = [GridCoordinate]()
    @Published var excessReactantCoords = [GridCoordinate]()

    @Published var productCoords = [GridCoordinate]()
    @Published var reactionProgress: CGFloat = 0

    var state = State.settingRows {
        didSet {
            handleStateTransition(from: oldValue)
        }
    }

    var rowsBinding: Binding<CGFloat> {
        Binding(
            get: { self.rows },
            set: self.setRows
        )
    }

    var rows: CGFloat {
        underlyingRows
    }

    func setRows(to newValue: CGFloat) {
        if state == .settingRows {
            underlyingRows = newValue
        }
    }

    private var underlyingRows: CGFloat

    private var shuffledCoords: [GridCoordinate]

    func addLimitingReactant(count: Int) {
        guard state == .addingLimitingReactant else {
            return
        }
        let currentCount = limitingReactantCoords.count
        let desiredCount = currentCount + count
        limitingReactantCoords = Array(shuffledCoords[0..<desiredCount])
    }

    func addExcessReactant(count: Int) {
        let currentCount = excessReactantCoords.count
        let desiredCount = currentCount + count
        let offset = limitingReactantCoords.count
        let endIndex = offset + desiredCount
        excessReactantCoords = Array(shuffledCoords[offset..<endIndex])
//
//        excessReactantCoords = GridCoordinateList.addingRandomElementsTo(
//            grid: excessReactantCoords,
//            count: count,
//            cols: beakerCols,
//            rows: roundedRows,
//            avoiding: limitingReactantCoords
//        )
//        let p = CGFloat(excessReactantCoords.count) / CGFloat(limitingReactantCoords.count)
//        withAnimation(.linear(duration: 1)) {
//            reactionProgress = p
//        }
    }

    private var roundedRows: Int {
        GridCoordinateList.availableRows(for: rows)
    }

    var volume: CGFloat {
        rowsToVolume.getY(at: rows)
    }

    var limitingReactantMolarity: CGFloat {
        let gridSize = CGFloat(beakerCols * roundedRows)
        let coordCount = CGFloat(limitingReactantCoords.count)
        return coordCount / gridSize
    }
}

extension LimitingReagentComponents {
    private func handleStateTransition(from prevState: State) {
        switch (prevState, state) {
        case (.settingRows, _): stoppedEditingRows()
        default: break
        }
    }

    /// Should be called whenever the rows have finished editing
    private func stoppedEditingRows() {
        shuffledCoords = GridCoordinateList.list(cols: beakerCols, rows: roundedRows).shuffled()
    }
}

extension LimitingReagentComponents {
    var equationData: LimitingReagentEquationData {
        Self.makeEquationData(
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

    enum State {
        case settingRows, addingLimitingReactant, addingExcessReactant
    }

    enum Reactant: Int, CaseIterable, Identifiable {
        case limiting, excess

        var id: Int {
            self.rawValue
        }
    }
}
