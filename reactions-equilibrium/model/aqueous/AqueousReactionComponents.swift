//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct FractionedCoordinates {
    let coordinates: [GridCoordinate]
    let fractionToDraw: Equation
}

protocol AqueousReactionComponents {

    var aMolecules: [GridCoordinate] { get }
    var bMolecules: [GridCoordinate] { get }
    var cMolecules: [GridCoordinate] { get }
    var dMolecules: [GridCoordinate] { get }

    var aBeakerFractionToDraw: Equation { get }
    var bBeakerFractionToDraw: Equation { get }
    var cBeakerFractionToDraw: Equation { get }
    var dBeakerFractionToDraw: Equation { get }

    var aGridMolecules: FractionedCoordinates { get }
    var bGridMolecules: FractionedCoordinates { get }
    var cGridMolecules: FractionedCoordinates { get }
    var dGridMolecules: FractionedCoordinates { get }

    var coefficients: BalancedReactionCoefficients { get set }
    var equations: BalancedReactionEquations { get }

    var availableCols: Int { get }
    var availableRows: Int { get set }

    mutating func increment(molecule: AqueousMolecule)

    mutating func reset()
}

extension AqueousReactionComponents {

    fileprivate func addingMolecules(
        to existing: [GridCoordinate],
        avoiding: [GridCoordinate],
        maxConcentration: CGFloat
    ) -> [GridCoordinate] {
        let settings = AqueousReactionSettings.ConcentrationInput.self
        let available = CGFloat(availableCols * availableRows)

        let numToIncrement = (settings.cToIncrement * available).roundedInt()
        let maxCount = (maxConcentration * available).roundedInt()
        let maxToAdd = maxCount - existing.count

        let toAdd = max(min(maxToAdd, numToIncrement), 0)
        return GridCoordinateList.addingRandomElementsTo(
            grid: existing,
            count: toAdd,
            cols: availableCols,
            rows: availableRows,
            avoiding: avoiding
        )
    }

    fileprivate func initialConcentration(
        of molecules: [GridCoordinate]
    ) -> CGFloat {
        CGFloat(molecules.count) / CGFloat(availableMolecules)
    }

    fileprivate var availableMolecules: Int {
        availableCols * availableRows
    }

    fileprivate func addingGridMolecules(
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

    fileprivate func equilibriumGridCount(for concentration: CGFloat) -> Int {
        (concentration * CGFloat(EquilibriumGridSettings.grid.count)).roundedInt()
    }

}


struct ForwardAqueousReactionComponents: AqueousReactionComponents {

    var coefficients: BalancedReactionCoefficients
    let availableCols: Int
    var availableRows: Int

    let shuffledEquilibriumGrid = EquilibriumGridSettings.grid.shuffled()

    init(
        coefficients: BalancedReactionCoefficients,
        availableCols: Int,
        availableRows: Int
    ) {
        self.coefficients = coefficients
        self.availableCols = availableCols
        self.availableRows = availableRows
    }

    mutating func reset() {
        aMolecules.removeAll()
        bMolecules.removeAll()
        underlyingAGrid.removeAll()
        underlyingBGrid.removeAll()
    }

    private(set) var aMolecules = [GridCoordinate]()
    private(set) var bMolecules = [GridCoordinate]()
    private var underlyingAGrid = [GridCoordinate]()
    private var underlyingBGrid = [GridCoordinate]()

    var cMolecules: [GridCoordinate] {
        productMoleculeSetter.cMolecules
    }
    var dMolecules: [GridCoordinate] {
        productMoleculeSetter.dMolecules
    }

    var equations: BalancedReactionEquations {
        BalancedReactionEquations(
            coefficients: coefficients,
            a0: initialA,
            b0: initialB,
            convergenceTime: AqueousReactionSettings.timeForConvergence
        )
    }

    var aBeakerFractionToDraw: Equation {
         ConstantEquation(value: 1)
    }

    var bBeakerFractionToDraw: Equation {
        ConstantEquation(value: 1)
    }

    var cBeakerFractionToDraw: Equation {
        productMoleculeSetter.cFractionToDraw
    }

    var dBeakerFractionToDraw: Equation {
        productMoleculeSetter.dFractionToDraw
    }

    var aGridMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingAGrid,
            fractionToDraw: reactantMoleculesToDraw(equation: equations.reactantA)
        )
    }

    var bGridMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingBGrid,
            fractionToDraw: reactantMoleculesToDraw(equation: equations.reactantB
            )
        )
    }

    var cGridMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingCGrid,
            fractionToDraw: productMoleculeSetter.cFractionToDraw
        )
    }

    var dGridMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingDGrid,
            fractionToDraw: productMoleculeSetter.dFractionToDraw
        )
    }

    mutating func increment(molecule: AqueousMolecule) {
        if molecule == .A {
            incrementA()
        } else if molecule == .B {
            incrementB()
        }
    }

    mutating func incrementA() {
        aMolecules = addingMolecules(
            to: aMolecules,
            avoiding: bMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
        underlyingAGrid = addingGridMolecules(
            molecules: underlyingAGrid,
            concentration: initialA,
            avoiding: underlyingBGrid
        )
    }

    mutating func incrementB() {
        bMolecules = addingMolecules(
            to: bMolecules,
            avoiding: aMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
        underlyingBGrid = addingGridMolecules(
            molecules: underlyingBGrid,
            concentration: initialB,
            avoiding: underlyingAGrid
        )
    }

    private var initialA: CGFloat {
        initialConcentration(of: aMolecules)
    }

    private var initialB: CGFloat {
        initialConcentration(of: bMolecules)
    }

    private var underlyingCGrid: [GridCoordinate] {
        let concentration = equations.productC.getY(at: AqueousReactionSettings.timeForConvergence)
        let num = equilibriumGridCount(for: concentration)
        return Array(shuffledEquilibriumGrid.prefix(num))
    }

    private var underlyingDGrid: [GridCoordinate] {
        let concentration = equations.productD.getY(at: AqueousReactionSettings.timeForConvergence)
        let num = equilibriumGridCount(for: concentration)
        let suffixedCoords = shuffledEquilibriumGrid.dropFirst(underlyingCGrid.count)
        return Array(suffixedCoords.prefix(num))
    }

    private var productMoleculeSetter: BeakerMoleculesSetter {
        BeakerMoleculesSetter(
            totalMolecules: availableMolecules,
            endOfReactionTime: AqueousReactionSettings.timeForConvergence,
            moleculesA: aMolecules,
            moleculesB: bMolecules,
            reactionEquation: equations
        )
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
}

struct ReverseAqueousReactionComponents: AqueousReactionComponents {

    private var forwardReaction: ForwardAqueousReactionComponents
    let availableCols: Int
    var availableRows: Int

    var coefficients: BalancedReactionCoefficients {
        get {
            forwardReaction.coefficients
        }
        set {
            forwardReaction.coefficients = newValue
        }
    }

    init(forwardReaction: ForwardAqueousReactionComponents) {
        self.forwardReaction = forwardReaction
        self.aMolecules = forwardReaction.aMolecules
        self.bMolecules = forwardReaction.bMolecules
        self.cMolecules = forwardReaction.cMolecules
        self.dMolecules = forwardReaction.dMolecules
        self.availableCols = forwardReaction.availableCols
        self.availableRows = forwardReaction.availableRows
    }

    private(set) var aMolecules = [GridCoordinate]()
    private(set) var bMolecules = [GridCoordinate]()
    private(set) var cMolecules = [GridCoordinate]()
    private(set) var dMolecules = [GridCoordinate]()

    var aBeakerFractionToDraw: Equation {
        ConstantEquation(value: 1)
    }

    var bBeakerFractionToDraw: Equation {
        ConstantEquation(value: 1)
    }

    var cBeakerFractionToDraw: Equation {
        ConstantEquation(value: 1)
    }

    var dBeakerFractionToDraw: Equation {
        ConstantEquation(value: 1)
    }

    var aGridMolecules: FractionedCoordinates {
        FractionedCoordinates(coordinates: [], fractionToDraw: ConstantEquation(value: 0))
    }

    var bGridMolecules: FractionedCoordinates {
        FractionedCoordinates(coordinates: [], fractionToDraw: ConstantEquation(value: 0))
    }

    var cGridMolecules: FractionedCoordinates {
        FractionedCoordinates(coordinates: [], fractionToDraw: ConstantEquation(value: 0))
    }

    var dGridMolecules: FractionedCoordinates {
        FractionedCoordinates(coordinates: [], fractionToDraw: ConstantEquation(value: 0))
    }

    mutating func reset() {
        aMolecules.removeAll()
        bMolecules.removeAll()
    }

    mutating func increment(molecule: AqueousMolecule) {
        if molecule == .C {
            incrementC()
        } else if molecule == .D {
            incrementD()
        }
    }

    mutating func incrementC() {
        cMolecules = addingMolecules(
            to: cMolecules,
            avoiding: aMolecules + bMolecules + dMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
    }

    mutating func incrementD() {
        dMolecules = addingMolecules(
            to: dMolecules,
            avoiding: aMolecules + bMolecules + cMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
    }

    var equations: BalancedReactionEquations {
        BalancedReactionEquations(
            forwardReaction: forwardReaction.equations,
            reverseInput: ReverseReactionInput(
                c0: initialConcentration(of: cMolecules),
                d0: initialConcentration(of: dMolecules),
                startTime: AqueousReactionSettings.timeToAddProduct,
                convergenceTime: AqueousReactionSettings.endOfReverseReaction
            )
        )
    }
}
