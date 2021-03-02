//
// Reactions App
//

import ReactionsCore
import CoreGraphics

protocol AqueousReactionComponents {

    var aMolecules: [GridCoordinate] { get }
    var bMolecules: [GridCoordinate] { get }
    var cMolecules: [GridCoordinate] { get }
    var dMolecules: [GridCoordinate] { get }

    var aBeakerFractionToDraw: Equation { get }
    var bBeakerFractionToDraw: Equation { get }
    var cBeakerFractionToDraw: Equation { get }
    var dBeakerFractionToDraw: Equation { get }

    var equations: BalancedReactionEquations { get }

    var availableCols: Int { get }
    var availableRows: Int { get }
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

    let coefficients: BalancedReactionCoefficients
    let availableCols: Int
    let availableRows: Int

    init(
        coefficients: BalancedReactionCoefficients,
        availableCols: Int,
        availableRows: Int
    ) {
        self.coefficients = coefficients
        self.availableCols = availableCols
        self.availableRows = availableRows
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
            a0: initialA,
            b0: initialB,
            finalTime: AqueousReactionSettings.timeForConvergence
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

    mutating func incrementA() {
        aMolecules = addingMolecules(
            to: aMolecules,
            avoiding: bMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
    }

    mutating func incrementB() {
        bMolecules = addingMolecules(
            to: bMolecules,
            avoiding: aMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
    }

    private var initialA: CGFloat {
        initialConcentration(of: aMolecules)
    }

    private var initialB: CGFloat {
        initialConcentration(of: bMolecules)
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
}

struct ReverseAqueousReactionComponents: AqueousReactionComponents {

    private let forwardReaction: ForwardAqueousReactionComponents
    let availableCols: Int
    let availableRows: Int


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

    mutating func incrementC() {
        cMolecules = addingMolecules(
            to: cMolecules,
            avoiding: aMolecules + bMolecules + dMolecules,
            maxConcentration: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
    }

    var equations: BalancedReactionEquations {
        BalancedReactionEquations(
            coefficients: forwardReaction.coefficients,
            a0: 0.2,
            b0: 0.4,
            finalTime: AqueousReactionSettings.timeForConvergence
        )
    }
}
