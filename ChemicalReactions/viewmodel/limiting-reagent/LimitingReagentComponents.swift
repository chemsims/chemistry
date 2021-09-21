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
        rowsToVolume: Equation = ChemicalReactionsSettings.rowsToVolume,
        settings: Settings = Settings()
    ) {
        self.reaction = reaction
        self.rows = CGFloat(initialRows)
        self.beakerCols = cols
        self.rowsToVolume = rowsToVolume
        self.settings = settings
        self.equationData = Self.makeEquationData(
            reaction: reaction,
            volume: rowsToVolume.getY(at: CGFloat(initialRows)),
            limitingReactantMolarity: 0
        )
        self.reactionProgressModel = Self.reactionProgressModel(reaction: reaction)
    }

    let reaction: LimitingReagentReaction
    let beakerCols: Int
    let rowsToVolume: Equation
    let settings: Settings

    var shouldReactExcessReactant = true

    @Published var limitingReactantCoords = [GridCoordinate]()
    @Published var excessReactantCoords = [GridCoordinate]()
    @Published var equationData: LimitingReagentEquationData

    @Published var productCoords = [GridCoordinate]()
    @Published var reactionProgress: CGFloat = 0
    @Published var rows: CGFloat

    var reactionProgressModel: ReactionProgressChartViewModel<Element>

    func addLimitingReactant(count: Int) {
        let maxToAdd = maxLimitingReactantCount - limitingReactantCoords.count
        let toAdd = min(count, maxToAdd)
        guard toAdd > 0 else {
            return
        }

        limitingReactantCoords = GridCoordinateList.addingRandomElementsTo(
            grid: limitingReactantCoords,
            count: toAdd,
            cols: beakerCols,
            rows: roundedRows
        )
        updateEquationData()
    }

    func addExcessReactant(count: Int) {
        let maxToAdd = maxExcessReactantCoords - excessReactantCoords.count
        let toAdd = min(count, maxToAdd)
        guard toAdd > 0 else {
            return
        }
        excessReactantCoords = GridCoordinateList.addingRandomElementsTo(
            grid: excessReactantCoords,
            count: toAdd,
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

extension LimitingReagentComponents {
    func canAdd(reactant: Reactant) -> Bool {
        switch reactant {
        case .limiting:
            return limitingReactantCoords.count < maxLimitingReactantCount
        case .excess:
            return excessReactantCoords.count < maxExcessReactantCoords
        }
    }

    func hasAddedEnough(of reactant: Reactant) -> Bool {
        switch reactant {
        case .limiting:
            return limitingReactantCoords.count >= settings.minLimitingReactantCoords
        case .excess:
            return excessReactantCoords.count >= minExcessReactantCoords
        }
    }

    private var maxLimitingReactantCount: Int {
        let maxReactantCoords = gridCount - settings.minExtraReactantCoordsToAdd
        let result = maxReactantCoords / (1 + reaction.excessReactant.coefficient)
        assert(result >= settings.minLimitingReactantCoords)
        return result
    }

    private var maxExcessReactantCoords: Int {
        if shouldReactExcessReactant {
            return reactingExcessReactantCount
        }
        return gridCount - limitingReactantCoords.count
    }

    private var minExcessReactantCoords: Int {
        if shouldReactExcessReactant {
            return reactingExcessReactantCount
        }
        return reactingExcessReactantCount + settings.minExtraReactantCoordsToAdd
    }

    private var reactingExcessReactantCount: Int {
        limitingReactantCoords.count * reaction.excessReactant.coefficient
    }

    private var gridCount: Int {
        roundedRows * beakerCols
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

private extension LimitingReagentComponents {
    static func reactionProgressModel(reaction: LimitingReagentReaction) -> ReactionProgressChartViewModel<Element> {
        .init(
            molecules: .init { element in
                initialReactionProgressMolecules(reaction: reaction, element: element)
            },
            settings: .init(),
            timing: .init()
        )
    }

    private static func initialReactionProgressMolecules(
        reaction: LimitingReagentReaction,
        element: Element
    ) -> ReactionProgressChartViewModel<Element>.MoleculeDefinition {
        .init(
            label: element.label(reaction: reaction),
            columnIndex: element.colIndex,
            initialCount: 0,
            color: element.color(reaction: reaction)
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

    enum Element: Int, CaseIterable {
        case limitingReactant, excessReactant, product

        var colIndex: Int {
            self.rawValue
        }

        func label(reaction: LimitingReagentReaction) -> TextLine {
            switch self {
            case .limitingReactant: return reaction.limitingReactant.name
            case .excessReactant: return reaction.excessReactant.name
            case .product: return reaction.product.name
            }
        }

        func color(reaction: LimitingReagentReaction) -> Color {
            switch self {
            case .limitingReactant: return reaction.limitingReactant.color
            case .excessReactant: return reaction.excessReactant.color
            case .product: return reaction.product.color
            }
        }
    }

    struct Settings {

        init(
            minLimitingReactantCoords: Int = 12,
            minExtraReactantCoordsToAdd: Int = 12
        ) {
            self.minLimitingReactantCoords = minLimitingReactantCoords
            self.minExtraReactantCoordsToAdd = minExtraReactantCoordsToAdd
        }

        let minLimitingReactantCoords: Int
        let minExtraReactantCoordsToAdd: Int
    }
}


