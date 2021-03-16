//
// Reactions App
//

import ReactionsCore
import CoreGraphics

protocol AqueousReactionComponents {

    var nonAnimatingMolecules: [BeakerMolecules] { get }
    var animatingMolecules: [AnimatingBeakerMolecules] { get }

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

    var quotientChartDiscontinuity: CGPoint? { get }
    var moleculeChartDiscontinuities: MoleculeValue<CGPoint>? { get }

    var iceData: MoleculeValue<ICETableElement> { get }

    mutating func increment(molecule: AqueousMolecule, count: Int)

    func canIncrement(molecule: AqueousMolecule) -> Bool

    func concentrationIncremented(of molecule: AqueousMolecule) -> CGFloat

    mutating func reset()
}

extension AqueousReactionComponents {

    fileprivate func addingMolecules(
        to existing: [GridCoordinate],
        avoiding: [GridCoordinate],
        maxConcentration: CGFloat,
        count: Int
    ) -> [GridCoordinate] {
        let maxToAdd = maximumToAdd(to: existing, maxConcentration: maxConcentration)

        let toAdd = max(min(maxToAdd, count), 0)
        return GridCoordinateList.addingRandomElementsTo(
            grid: existing,
            count: toAdd,
            cols: availableCols,
            rows: availableRows,
            avoiding: avoiding
        )
    }

    fileprivate func maximumToAdd(to existing: [GridCoordinate], maxConcentration: CGFloat) -> Int {
        let available = CGFloat(availableMolecules)
        let maxCount = (maxConcentration * available).roundedInt()
        return maxCount - existing.count
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
    let quotientChartDiscontinuity: CGPoint? = nil
    let moleculeChartDiscontinuities: MoleculeValue<CGPoint>? = nil

    private let shuffledEquilibriumGrid = EquilibriumGridSettings.grid.shuffled()
    private let shuffledMoleculeGrid: [GridCoordinate]

    private(set) var grid = ForwardGridMolecules()

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        availableCols: Int,
        availableRows: Int,
        maxRows: Int
    ) {
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.availableCols = availableCols
        self.availableRows = availableRows
        self.shuffledMoleculeGrid = GridCoordinate.grid(cols: availableCols, rows: maxRows).shuffled()
    }

    mutating func reset() {
        underlyingAMolecules.removeAll()
        underlyingBMolecules.removeAll()
        grid = ForwardGridMolecules()
    }

    func concentrationIncremented(of molecule: AqueousMolecule) -> CGFloat {
        switch molecule {
        case .A: return initialConcentration(of: underlyingAMolecules)
        case .B: return initialConcentration(of: underlyingBMolecules)
        default: return 0
        }
    }

    let nonAnimatingMolecules: [BeakerMolecules] = []

    var animatingMolecules: [AnimatingBeakerMolecules] {
        [
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(
                    coords: productMoleculeSetter.moleculesA.coordinates,
                    color: .from(.aqMoleculeA)
                ),
                fractionToDraw: productMoleculeSetter.moleculesA.fractionToDraw
            ),
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(
                    coords: productMoleculeSetter.moleculesB.coordinates,
                    color: .from(.aqMoleculeB)
                ),
                fractionToDraw: productMoleculeSetter.moleculesB.fractionToDraw
            ),
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(coords: cMolecules, color: .from(.aqMoleculeC)),
                fractionToDraw: productMoleculeSetter.moleculesC.fractionToDraw
            ),
            AnimatingBeakerMolecules(
                molecules: BeakerMolecules(coords: dMolecules, color: .from(.aqMoleculeD)),
                fractionToDraw: productMoleculeSetter.moleculesD.fractionToDraw
            )
        ]
    }

    private var underlyingAMolecules = [GridCoordinate]()
    private var underlyingBMolecules = [GridCoordinate]()

    var aMolecules: FractionedCoordinates {
        productMoleculeSetter.moleculesA
    }

    var bMolecules: FractionedCoordinates {
        productMoleculeSetter.moleculesB
    }

    var cMolecules: [GridCoordinate] {
        productMoleculeSetter.moleculesC.coordinates
    }
    var dMolecules: [GridCoordinate] {
        productMoleculeSetter.moleculesD.coordinates
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

    mutating func increment(molecule: AqueousMolecule, count: Int) {
        if molecule == .A {
            incrementA(count: count)
        } else if molecule == .B {
            incrementB(count: count)
        }
    }

    mutating func incrementA(count: Int) {
        underlyingAMolecules = addingMolecules(
            to: underlyingAMolecules,
            avoiding: underlyingBMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial,
            count: count
        )
        grid.setConcentration(of: .A, concentration: initialA)
    }

    mutating func incrementB(count: Int) {
        underlyingBMolecules = addingMolecules(
            to: underlyingBMolecules,
            avoiding: underlyingAMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial,
            count: count
        )
        grid.setConcentration(of: .B, concentration: initialB)
    }

    func canIncrement(molecule: AqueousMolecule) -> Bool {
        let maxC = AqueousReactionSettings.ConcentrationInput.maxInitial
        switch molecule {
        case .A: return maximumToAdd(to: underlyingAMolecules, maxConcentration: maxC) > 0
        case .B: return maximumToAdd(to: underlyingBMolecules, maxConcentration: maxC) > 0
        default: return false
        }
    }

    private var initialA: CGFloat {
        initialConcentration(of: underlyingAMolecules)
    }

    private var initialB: CGFloat {
        initialConcentration(of: underlyingBMolecules)
    }

    var productMoleculeSetter: ForwardEquilibriumBeakerGridBalancer {
        ForwardEquilibriumBeakerGridBalancer(
            shuffledCoords: availableShuffledGrid,
            moleculesA: underlyingAMolecules,
            moleculesB: underlyingBMolecules,
            reactionEquation: equations
        )
    }

    var iceData: MoleculeValue<ICETableElement> {
        func element(_ c0: CGFloat, _ equation: Equation) -> ICETableElement {
            ICETableElement(initial: c0, final: equation.getY(at: equations.convergenceTime))
        }
        return MoleculeValue(
            reactantA: element(equations.a0, equations.reactantA),
            reactantB: element(equations.b0, equations.reactantB),
            productC: element(0, equations.productC),
            productD: element(0, equations.productD)
        )
    }

    private var availableShuffledGrid: [GridCoordinate] {
        shuffledMoleculeGrid.filter {
            $0.row < availableRows
        }
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
    var quotientChartDiscontinuity: CGPoint? {
        CGPoint(
            x: AqueousReactionSettings.timeToAddProduct,
            y: ReactionQuotientEquation(equations: forwardReaction.equations).getY(at: AqueousReactionSettings.timeToAddProduct)
        )
    }

    var moleculeChartDiscontinuities: MoleculeValue<CGPoint>? {
        let x = AqueousReactionSettings.timeToAddProduct
        return MoleculeValue(
            reactantA: CGPoint(x: x, y: forwardReaction.equations.reactantA.getY(at: x)),
            reactantB: CGPoint(x: x, y: forwardReaction.equations.reactantB.getY(at: x)),
            productC: CGPoint(x: x, y: forwardReaction.equations.productC.getY(at: x)),
            productD: CGPoint(x: x, y: forwardReaction.equations.productD.getY(at: x))
        )
    }

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

    mutating func increment(molecule: AqueousMolecule, count: Int) {
        if molecule == .C {
            incrementC(count: count)
        } else if molecule == .D {
            incrementD(count: count)
        }
    }

    func canIncrement(molecule: AqueousMolecule) -> Bool {
        let maxC = AqueousReactionSettings.ConcentrationInput.maxInitial
        switch molecule {
        case .C: return maximumToAdd(to: cMolecules, maxConcentration: maxC) > 0
        case .D: return maximumToAdd(to: dMolecules, maxConcentration: maxC) > 0
        default: return false
        }
    }

    private mutating func incrementC(count: Int) {
        cMolecules = addingMolecules(
            to: cMolecules,
            avoiding: beakerSetter.originalAMolecules + beakerSetter.originalBMolecules + dMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial,
            count: count
        )
        grid.setConcentration(of: .C, concentration: initialConcentration(of: cMolecules))
    }

    private mutating func incrementD(count: Int) {
        dMolecules = addingMolecules(
            to: dMolecules,
            avoiding: beakerSetter.originalAMolecules + beakerSetter.originalBMolecules + cMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial,
            count: count
        )
        grid.setConcentration(of: .D, concentration: initialConcentration(of: dMolecules))
    }

    var productConcentrationIncremented: CGFloat {
        let initC = forwardReaction.equations.productC.getY(at: forwardReaction.equations.convergenceTime)
        let initD = forwardReaction.equations.productD.getY(at: forwardReaction.equations.convergenceTime)
        let incC = initialConcentration(of: cMolecules) - initC
        let incD = initialConcentration(of: dMolecules) - initD
        return incC + incD
    }

    func concentrationIncremented(of molecule: AqueousMolecule) -> CGFloat {
        func getProduct(_ molecules: [GridCoordinate], _ equation: Equation) -> CGFloat {
            initialConcentration(of: molecules) - equation.getY(at: forwardReaction.equations.convergenceTime)
        }

        switch molecule {
        case .C: return getProduct(cMolecules, forwardReaction.equations.productC)
        case .D: return getProduct(dMolecules, forwardReaction.equations.productD)
        default: return 0
        }
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

    var iceData: MoleculeValue<ICETableElement> {
        func element(_ equation: Equation) -> ICETableElement {
            let initial = equation.getY(at: AqueousReactionSettings.timeToAddProduct)
            let final = equation.getY(at: equations.convergenceTime)
            return ICETableElement(initial: initial, final: final)
        }

        return MoleculeValue(
            reactantA: element(equations.reactantA),
            reactantB: element(equations.reactantB),
            productC: element(equations.productC),
            productD: element(equations.productD)
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

    private var beakerSetter: ReverseEquilibriumBeakerGridBalancer {
        ReverseEquilibriumBeakerGridBalancer(
            reverseReaction: equations,
            startTime: AqueousReactionSettings.timeToAddProduct,
            forwardBeaker: forwardReaction.productMoleculeSetter,
            cMolecules: cMolecules,
            dMolecules: dMolecules
        )
    }
}
