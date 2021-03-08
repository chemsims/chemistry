//
// Reactions App
//

import ReactionsCore
import CoreGraphics

protocol AqueousReactionComponents {

    var nonAnimatingMolecules: [BeakerMolecules] { get }
    var animatingMolecules: [AnimatingBeakerMolecules] { get }

//    var aMolecules: [GridCoordinate] { get }
//    var bMolecules: [GridCoordinate] { get }
//    var cMolecules: [GridCoordinate] { get }
//    var dMolecules: [GridCoordinate] { get }

//    var aBeakerFractionToDraw: Equation { get }
//    var bBeakerFractionToDraw: Equation { get }
//    var cBeakerFractionToDraw: Equation { get }
//    var dBeakerFractionToDraw: Equation { get }

    var aGridMolecules: FractionedCoordinates { get }
    var bGridMolecules: FractionedCoordinates { get }
    var cGridMolecules: FractionedCoordinates { get }
    var dGridMolecules: FractionedCoordinates { get }

    var coefficients: BalancedReactionCoefficients { get set }
    var equilibriumConstant: CGFloat { get set }
    var equations: BalancedReactionEquations { get }

    var availableCols: Int { get }
    var availableRows: Int { get set }

    var tForMaxQuotient: CGFloat { get }

    var chartDiscontinuity: CGFloat? { get }

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

}

struct ForwardAqueousReactionComponents: AqueousReactionComponents {

    var coefficients: BalancedReactionCoefficients
    var equilibriumConstant: CGFloat
    let availableCols: Int
    var availableRows: Int

    let tForMaxQuotient: CGFloat = AqueousReactionSettings.timeForConvergence
    let chartDiscontinuity: CGFloat? = nil
    private let shuffledEquilibriumGrid = EquilibriumGridSettings.grid.shuffled()

    private(set) var grid = ForwardGridMolecules()

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        availableCols: Int,
        availableRows: Int
    ) {
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.availableCols = availableCols
        self.availableRows = availableRows
    }

    mutating func reset() {
        aMolecules.removeAll()
        bMolecules.removeAll()
        grid = ForwardGridMolecules()
    }

    var nonAnimatingMolecules: [BeakerMolecules] {
        [
            BeakerMolecules(coords: aMolecules, color: .from(.aqMoleculeA)),
            BeakerMolecules(coords: bMolecules, color: .from(.aqMoleculeB))
        ]

    }

    var animatingMolecules: [AnimatingBeakerMolecules] {
        [
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(coords: cMolecules, color: .from(.aqMoleculeC)),
                fractionToDraw: productMoleculeSetter.cFractionToDraw
            ),
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(coords: dMolecules, color: .from(.aqMoleculeD)),
                fractionToDraw: productMoleculeSetter.dFractionToDraw
            )
        ]
    }

    private(set) var aMolecules = [GridCoordinate]()
    private(set) var bMolecules = [GridCoordinate]()

    var cMolecules: [GridCoordinate] {
        productMoleculeSetter.cMolecules
    }
    var dMolecules: [GridCoordinate] {
        productMoleculeSetter.dMolecules
    }

    var equations: BalancedReactionEquations {
        BalancedReactionEquations(
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            a0: initialA,
            b0: initialB,
            convergenceTime: AqueousReactionSettings.timeForConvergence
        )
    }

    var aGridMolecules: FractionedCoordinates {
        grid.aGrid(reaction: equations)
    }

    var bGridMolecules: FractionedCoordinates {
        grid.bGrid(reaction: equations)
    }

    var cGridMolecules: FractionedCoordinates {
        grid.cGrid(reaction: equations)
    }

    var dGridMolecules: FractionedCoordinates {
        grid.dGrid(reaction: equations)
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
        grid.setConcentration(of: .A, concentration: initialA)
    }

    mutating func incrementB() {
        bMolecules = addingMolecules(
            to: bMolecules,
            avoiding: aMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
        grid.setConcentration(of: .B, concentration: initialB)
    }

    private var initialA: CGFloat {
        initialConcentration(of: aMolecules)
    }

    private var initialB: CGFloat {
        initialConcentration(of: bMolecules)
    }

    fileprivate var productMoleculeSetter: BeakerMoleculesSetter {
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

    private(set) var forwardReaction: ForwardAqueousReactionComponents
    let availableCols: Int
    var availableRows: Int

    let tForMaxQuotient: CGFloat = AqueousReactionSettings.timeToAddProduct
    let chartDiscontinuity: CGFloat? = AqueousReactionSettings.timeToAddProduct

    var coefficients: BalancedReactionCoefficients {
        get {
            forwardReaction.coefficients
        }
        set {
            forwardReaction.coefficients = newValue
        }
    }

    var equilibriumConstant: CGFloat {
        get {
            forwardReaction.equilibriumConstant
        }
        set {
            forwardReaction.equilibriumConstant = newValue
        }
    }

    private var grid: ReverseGridMolecules

    init(forwardReaction: ForwardAqueousReactionComponents) {
        self.forwardReaction = forwardReaction
        self.cMolecules = forwardReaction.cMolecules
        self.dMolecules = forwardReaction.dMolecules
        self.availableCols = forwardReaction.availableCols
        self.availableRows = forwardReaction.availableRows


        self.grid = ReverseGridMolecules(forwardGrid: forwardReaction.grid, forwardReaction: forwardReaction.equations)
    }

    var nonAnimatingMolecules: [BeakerMolecules] {
        [
            BeakerMolecules(coords: cMolecules, color: .from(.aqMoleculeC)),
            BeakerMolecules(coords: dMolecules, color: .from(.aqMoleculeD))
        ]
    }

    var animatingMolecules: [AnimatingBeakerMolecules] {
        [
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(coords: aMolecules, color: .from(.aqMoleculeA)),
                fractionToDraw: beakerSetter.aMolecules.fractionToDraw
            ),
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(coords: bMolecules, color: .from(.aqMoleculeB)),
                fractionToDraw: beakerSetter.bMolecules.fractionToDraw
            )
        ]
    }

    var aMolecules: [GridCoordinate] {
        beakerSetter.aMolecules.coordinates
    }
    var bMolecules: [GridCoordinate] {
        beakerSetter.bMolecules.coordinates
    }
    private(set) var cMolecules = [GridCoordinate]()
    private(set) var dMolecules = [GridCoordinate]()

    private let convergenceTime = AqueousReactionSettings.timeForReverseConvergence

    var aGridMolecules: FractionedCoordinates {
        grid.aGrid(reaction: equations)
    }

    var bGridMolecules: FractionedCoordinates {
        grid.bGrid(reaction: equations)
    }

    var cGridMolecules: FractionedCoordinates {
        grid.cGrid(reaction: equations)
    }

    var dGridMolecules: FractionedCoordinates {
        grid.dGrid(reaction: equations)
    }

    mutating func reset() {
        cMolecules = forwardReaction.cMolecules
        dMolecules = forwardReaction.dMolecules
        grid = ReverseGridMolecules(forwardGrid: forwardReaction.grid, forwardReaction: forwardReaction.equations)
    }

    mutating func increment(molecule: AqueousMolecule) {
        if molecule == .C {
            incrementC()
        } else if molecule == .D {
            incrementD()
        }
    }

    private mutating func incrementC() {
        cMolecules = addingMolecules(
            to: cMolecules,
            avoiding: beakerSetter.originalAMolecules + beakerSetter.originalBMolecules + dMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
        grid.setConcentration(of: .C, concentration: initialConcentration(of: cMolecules))
    }

    private mutating func incrementD() {
        dMolecules = addingMolecules(
            to: dMolecules,
            avoiding: beakerSetter.originalAMolecules + beakerSetter.originalBMolecules + cMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
        grid.setConcentration(of: .D, concentration: initialConcentration(of: dMolecules))
    }

    var equations: BalancedReactionEquations {
        BalancedReactionEquations(
            forwardReaction: forwardReaction.equations,
            reverseInput: ReverseReactionInput(
                c0: initialProductConcentration(
                    forwardConvergedCount: forwardReaction.cMolecules.count,
                    forwardConvergedConcentration: forwardReaction.equations.productC.getY(at: AqueousReactionSettings.timeForConvergence),
                    currentMolecules: cMolecules
                ),
                d0: initialProductConcentration(
                    forwardConvergedCount: forwardReaction.dMolecules.count,
                    forwardConvergedConcentration: forwardReaction.equations.productD.getY(at: AqueousReactionSettings.timeForConvergence),
                    currentMolecules: dMolecules
                ),
                startTime: AqueousReactionSettings.timeToAddProduct,
                convergenceTime: AqueousReactionSettings.timeForReverseConvergence
            )
        )
    }

    /// Finding concentration based on molecule count will differ from the previously converged value
    ///
    /// So, if no molecules added, use the previously converged value instead
    private func initialProductConcentration(
        forwardConvergedCount: Int,
        forwardConvergedConcentration: CGFloat,
        currentMolecules: [GridCoordinate]
    ) -> CGFloat {
        if currentMolecules.count == forwardConvergedCount {
            return forwardConvergedConcentration
        }

        return initialConcentration(of: currentMolecules)
    }

    private var beakerSetter: ReverseBeakerMoleculeSetter {
        ReverseBeakerMoleculeSetter(
            reverseReaction: equations,
            startTime: AqueousReactionSettings.timeToAddProduct,
            forwardBeaker: forwardReaction.productMoleculeSetter,
            cMolecules: cMolecules,
            dMolecules: dMolecules
        )
    }
}
