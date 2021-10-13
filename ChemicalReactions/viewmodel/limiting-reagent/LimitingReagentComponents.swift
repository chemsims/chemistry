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
    @Published var rows: CGFloat {
        didSet {
            updateEquationData()
            didSetRows?()
        }
    }

    // It would be better to have a delegate, or just move rows up
    // to the limiting reagent screen view model. For now, just
    // put this here though
    var didSetRows: (() -> Void)? = nil

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
        updateReactionProgressPostAddingLimitingReactant()
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
        updateReactionProgressPostAddingExcessReactant()
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

        productCoords = Array(coordsFromLimiting + coordsFromExcess).shuffled()
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
    func resetLimitingReactantCoords() {
        limitingReactantCoords.removeAll()
        reactionProgressModel = reactionProgressModel.copy(withCounts: .constant(0))
    }

    func resetExcessReactantCoords() {
        excessReactantCoords.removeAll()
        reactionProgressModel = reactionProgressModel.copy(
            withCounts: .init {
                switch $0 {
                case .limitingReactant:
                    return reactionProgressModel.moleculeCounts(ofType: .limitingReactant)
                default:
                    return 0
                }
            }
        )
    }

    func resetReactionCoords() {
        reactionProgressModel = reactionProgressModel.copy(
            withCounts: .init {
                switch $0 {
                case .limitingReactant:
                    let eq = getEquationOfLimitingBeakerCoordsToReactionProgressMolecules()
                    return eq.getY(
                        at: CGFloat(limitingReactantCoords.count)
                    ).roundedInt()

                case .excessReactant:
                    let limitingEq = getEquationOfLimitingBeakerCoordsToReactionProgressMolecules()
                    let coeff = reaction.excessReactant.coefficient
                    let limitingCount = limitingEq.getY(
                        at: CGFloat(limitingReactantCoords.count)
                    ).roundedInt()
                    return coeff * limitingCount
                    
                case .product: return 0
                }
            }
        )
    }

    func resetNonReactingExcessReactantCoords() {
        let extraCoords = excessReactantCoords.count - reactingExcessReactantCount
        if extraCoords > 0 {
            excessReactantCoords.removeLast(extraCoords)
        }
        reactionProgressModel = reactionProgressModel.copy(
            withCounts: .init {
                switch $0 {
                case .limitingReactant: return 0
                case .excessReactant: return 0
                case .product:
                    return reactionProgressModel.moleculeCounts(ofType: .product)
                }
            }
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

// MARK: - Updating reaction progress
extension LimitingReagentComponents {

    var reactionProgressReactionsToRun: Int {
        reactionProgressModel.moleculeCounts(ofType: .limitingReactant)
    }

    func runOneReactionProgressReaction() {
        reactionProgressModel.startReactionFromExisting(
            consuming: [
                (.limitingReactant, 1),
                (.excessReactant, reaction.excessReactant.coefficient)
            ],
            producing: [.product]
        )
    }

    func runAllReactionProgressReactions(duration: TimeInterval) {
        let count = reactionProgressModel.moleculeCounts(ofType: .limitingReactant)
        reactionProgressModel.startReactionFromExisting(
            consuming: [
                (.limitingReactant, 1),
                (.excessReactant, reaction.excessReactant.coefficient)
            ],
            producing: [.product],
            count: count,
            duration: duration
        )
    }

    private func updateReactionProgressPostAddingLimitingReactant() {
        let currentCount = reactionProgressModel.moleculeCounts(ofType: .limitingReactant)
        let equation = getEquationOfLimitingBeakerCoordsToReactionProgressMolecules()
        let desiredCount = equation.getY(
            at: CGFloat(limitingReactantCoords.count)
        ).roundedInt()

        addToReactionProgress(
            .limitingReactant,
            currentCount: currentCount,
            desiredCount: desiredCount
        )
    }

    private func updateReactionProgressPostAddingExcessReactant() {
        let equation = getEquationOfExcessBeakerCoordsToReactionProgressMolecules()
        let currentCount = reactionProgressModel.moleculeCounts(ofType: .excessReactant)
        let desiredCount = equation.getY(
            at: CGFloat(excessReactantCoords.count)
        ).roundedInt()

        addToReactionProgress(
            .excessReactant,
            currentCount: currentCount,
            desiredCount: desiredCount
        )
    }

    private func addToReactionProgress(
        _ element: Element,
        currentCount: Int,
        desiredCount: Int
    ) {
        let deficit = desiredCount - currentCount
        if deficit > 0 {
            reactionProgressModel.addMolecules(element, count: deficit, duration: 1)
        }
    }

    private func getEquationOfExcessBeakerCoordsToReactionProgressMolecules() -> Equation {
        if shouldReactExcessReactant {
            let limitingCount = CGFloat(
                reactionProgressModel.moleculeCounts(ofType: .limitingReactant)
            )
            let coeff = CGFloat(reaction.excessReactant.coefficient)
            return LinearEquation(
                x1: 0,
                y1: 0,
                x2: CGFloat(maxExcessReactantCoords),
                y2: coeff * CGFloat(limitingCount)
            )
        }

        return LinearEquation(
            x1: CGFloat(reactingExcessReactantCount),
            y1: 0,
            x2: CGFloat(minExcessReactantCoords),
            y2: CGFloat(settings.minLimitingReactantReactionProgressMolecules )
        ).within(min: 0, max: CGFloat(settings.maxReactionProgressMolecules))
    }

    private func getEquationOfLimitingBeakerCoordsToReactionProgressMolecules() -> Equation {
        let maxMolecules = settings.maxReactionProgressMolecules / reaction.excessReactant.coefficient

        let endPoint = CGPoint(
            x: CGFloat(maxLimitingReactantCount),
            y: CGFloat(maxMolecules)
        )

        // Ideally we just linearly add reaction molecules as
        // beaker molecules are added
        let idealEquation = LinearEquation(
            x1: 0,
            y1: 0,
            x2: endPoint.x,
            y2: endPoint.y
        )

        let moleculesAtMinBeakerCoords = idealEquation.getY(
            at: CGFloat(settings.minLimitingReactantCoords)
        ).roundedInt()

        let requiredAtMinBeakerCoords = settings.minLimitingReactantReactionProgressMolecules

        // If the ideal equation produces too few molecules at the min beaker molecules,
        // then we need to use a switching equation
        if moleculesAtMinBeakerCoords < requiredAtMinBeakerCoords {
            return SwitchingEquation.linear(
                initial: .zero,
                mid: CGPoint(
                    x: settings.minLimitingReactantCoords,
                    y: settings.minLimitingReactantReactionProgressMolecules
                ),
                final: endPoint
            )
        }

        return idealEquation
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
            minExtraReactantCoordsToAdd: Int = 12,
            minLimitingReactantReactionProgressMolecules: Int = 2
        ) {
            self.minLimitingReactantCoords = minLimitingReactantCoords
            self.minExtraReactantCoordsToAdd = minExtraReactantCoordsToAdd
            self.minLimitingReactantReactionProgressMolecules = minLimitingReactantReactionProgressMolecules
        }

        let minLimitingReactantCoords: Int
        let minExtraReactantCoordsToAdd: Int
        let minLimitingReactantReactionProgressMolecules: Int

        // Max number of molecules for any column
        let maxReactionProgressMolecules = 10
    }
}


