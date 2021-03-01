//
// Reactions App
//

import SwiftUI
import ReactionsCore

class AqueousReactionViewModel: ObservableObject {

    private var navigation: NavigationModel<AqueousScreenState>?

    init() {
        self.navigation = AqueousNavigationModel.model(model: self)
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat = CGFloat(AqueousReactionSettings.initialRows)

    @Published var moleculesA = [GridCoordinate]()
    @Published var moleculesB = [GridCoordinate]()
    @Published var gridMoleculesA = [GridCoordinate]()
    @Published var gridMoleculesB = [GridCoordinate]()

    @Published var inputState = AqueousReactionInputState.none

    @Published var canSetCurrentTime = false
    @Published var currentTime: CGFloat = 0

    @Published var reactionSelectionIsToggled = false
    @Published var selectedReaction = AqueousReactionType.A

    @Published var showQuotientLine = false

    private let shuffledEquilibriumGrid = EquilibriumGridSettings.grid.shuffled()
    private let inputSettings = AqueousReactionSettings.ConcentrationInput.self

    var equations: BalancedReactionEquations {
        let coeffs = selectedReaction.coefficients
        return BalancedReactionEquations(
            coefficients: coeffs,
            a0: initialConcentrationA,
            b0: initialConcentrationB,
            finalTime: AqueousReactionSettings.timeForConvergence
        )
    }

    var quotientEquation: Equation {
        ReactionQuotientEquation(equations: equations)
    }

    var productMolecules: BeakerMoleculesSetter {
        BeakerMoleculesSetter(
            totalMolecules: availableMolecules,
            endOfReactionTime: AqueousReactionSettings.timeForConvergence,
            moleculesA: moleculesA,
            moleculesB: moleculesB,
            reactionEquation: equations
        )
    }

    var gridMoleculesC: [GridCoordinate] {
        let concentration = equations.productC.getY(at: AqueousReactionSettings.timeForConvergence)
        let num = equilibriumGridCount(for: concentration)
        return Array(shuffledEquilibriumGrid.prefix(num))
    }

    var gridMoleculesD: [GridCoordinate] {
        let concentration = equations.productD.getY(at: AqueousReactionSettings.timeForConvergence)
        let num = equilibriumGridCount(for: concentration)
        let suffixedCoords = shuffledEquilibriumGrid.dropFirst(gridMoleculesC.count)
        return Array(suffixedCoords.prefix(num))
    }

    var gridMoleculesAToDraw: Equation {
        reactantMoleculesToDraw(equation: equations.reactantA)
    }

    var gridMoleculesBToDraw: Equation {
        reactantMoleculesToDraw(equation: equations.reactantB)
    }

    var convergenceQuotient: CGFloat {
        quotientEquation.getY(at: AqueousReactionSettings.timeForConvergence)
    }

    func incrementAMolecules() {
        moleculesA = addingMolecules(to: moleculesA, avoiding: moleculesB)
        gridMoleculesA = addingGridMolecules(molecules: gridMoleculesA, concentration: initialConcentrationA, avoiding: gridMoleculesB)
    }

    func incrementBMolecules() {
        moleculesB = addingMolecules(to: moleculesB, avoiding: moleculesA)
        gridMoleculesB = addingGridMolecules(molecules: gridMoleculesB, concentration: initialConcentrationB, avoiding: gridMoleculesA)
    }

    func resetMolecules() {
        moleculesA.removeAll()
        moleculesB.removeAll()
        gridMoleculesA.removeAll()
        gridMoleculesB.removeAll()
        instructToAddMoreReactantCount = instructToAddMoreReactantCount.reset()
    }

    func next() {
        if inputState == .addReactants,
           let missingReactant = getMissingReactant() {
            informUserOfMissing(reactant: missingReactant)
        } else {
            navigation?.next()
        }
    }

    func back() {
        navigation?.back()
    }

    private func informUserOfMissing(reactant: AqueousMoleculeReactant) {
        let minConvergence = inputSettings.minInitial
        let minInput = equations.a0ForConvergence(of: inputSettings.minFinal)
        let minConcentration = max(minConvergence, minInput)
        instructToAddMoreReactantCount = instructToAddMoreReactantCount.increment(value: reactant)
        statement = AqueousStatements.addMore(
            reactant: reactant,
            count: instructToAddMoreReactantCount.count,
            minConcentration: minConcentration.str(decimals: 2)
        )
    }

    // Returns the first reactant which does not have enough molecules in the beaker
    private func getMissingReactant() -> AqueousMoleculeReactant? {
        let aTooLow = initialConcentrationA < inputSettings.minInitial
        let bTooLow = initialConcentrationB < inputSettings.minInitial

        if aTooLow {
            return .A
        } else if bTooLow {
            return .B
        }
        return equations.reactantToAddForMinConvergence(convergence: AqueousReactionSettings.ConcentrationInput.minFinal)
    }

    private func reactantMoleculesToDraw(
        equation: Equation
    ) -> Equation {
        ScaledEquation(
            targetY: 1,
            targetX: 0,
            underlying: equation
        )
    }

    private func initialConcentration(of molecules: [GridCoordinate]) -> CGFloat {
        CGFloat(molecules.count) / CGFloat(availableMolecules)
    }

    private func addingMolecules(to molecules: [GridCoordinate], avoiding: [GridCoordinate]) -> [GridCoordinate] {
        let cInput = AqueousReactionSettings.ConcentrationInput.self

        let availableAsFloat = CGFloat(availableMolecules)
        let numToAdd = Int(cInput.cToIncrement * availableAsFloat)
        let maxCount = Int(cInput.maxInitial * availableAsFloat)
        let maxToAdd = maxCount - molecules.count

        let toAdd = max(min(maxToAdd, numToAdd), 0)

        return GridCoordinateList.addingRandomElementsTo(
            grid: molecules,
            count: toAdd,
            cols: availableCols,
            rows: availableRows,
            avoiding: avoiding
        )
    }

    private func addingGridMolecules(
        molecules: [GridCoordinate],
        concentration: CGFloat,
        avoiding: [GridCoordinate]
    ) -> [GridCoordinate] {
        let totalNum = equilibriumGridCount(for: concentration)
        let toAdd = totalNum - molecules.count
        guard toAdd > 0 else {
            return molecules
        }

        return GridCoordinateList.addingRandomElementsTo(
            grid: molecules,
            count: toAdd,
            cols: EquilibriumGridSettings.cols,
            rows: EquilibriumGridSettings.rows,
            avoiding: avoiding
        )
    }

    private func equilibriumGridCount(for concentration: CGFloat) -> Int {
        Int(concentration.rounded(decimals: 2) * CGFloat(EquilibriumGridSettings.grid.count))
    }

    private var initialConcentrationA: CGFloat {
        initialConcentration(of: moleculesA)
    }

    private var initialConcentrationB: CGFloat {
        initialConcentration(of: moleculesB)
    }

    private var availableMolecules: Int {
        availableRows * availableCols
    }

    private(set) var instructToAddMoreReactantCount = EquatableCounter<AqueousMoleculeReactant>()

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

// MARK: Computed vars for input state
extension AqueousReactionViewModel {

    var canSetLiquidLevel: Bool {
        inputState == .setLiquidLevel
    }

    var canAddReactants: Bool {
        inputState == .addReactants
    }

    var canChooseReactants: Bool {
        inputState == .selectReactionType
    }
}
