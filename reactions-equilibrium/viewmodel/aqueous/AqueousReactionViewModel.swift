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

    @Published var rows: CGFloat = CGFloat(AqueousReactionSettings.initialRows)

    @Published var moleculesA = [GridCoordinate]()
    @Published var moleculesB = [GridCoordinate]()

    @Published var canSetLiquidLevel = true
    @Published var canAddReactants = false

    @Published var currentTime: CGFloat = 0

    @Published var reactionState = TriProcessState.notStarted

    @Published var canSetCurrentTime = false

    let finalTime: CGFloat = 15

    var equations: BalancedReactionEquations {
        let coeffs = BalancedReactionCoefficients(
            reactantACoefficient: 2,
            reactantBCoefficient: 2,
            productCCoefficient: 1,
            productDCoefficient: 4
        )
        return BalancedReactionEquations(
            coefficients: coeffs,
            a0: initialConcentrationA,
            b0: initialConcentrationB,
            finalTime: finalTime
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

    func productMoleculeFractionToDraw(underlying: Equation) -> Equation {
        ScaledEquation(
            targetY: 1,
            targetX: AqueousReactionSettings.timeForConvergence,
            underlying: underlying
        )
    }

    func incrementAMolecules() {
        moleculesA = addingMolecules(to: moleculesA, avoiding: moleculesB)
    }

    func incrementBMolecules() {
        moleculesB = addingMolecules(to: moleculesB, avoiding: moleculesA)
    }

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    private func initialConcentration(of molecules: [GridCoordinate]) -> CGFloat {
        CGFloat(molecules.count) / CGFloat(availableMolecules)
    }

    private func addingMolecules(to molecules: [GridCoordinate], avoiding: [GridCoordinate]) -> [GridCoordinate] {
        GridCoordinateList.addingRandomElementsTo(
            grid: molecules,
            count: AqueousReactionSettings.moleculesToIncrement,
            cols: availableCols,
            rows: availableRows,
            avoiding: avoiding
        )
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
