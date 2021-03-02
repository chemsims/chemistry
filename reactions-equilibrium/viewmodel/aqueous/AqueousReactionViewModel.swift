//
// Reactions App
//

import SwiftUI
import ReactionsCore

class AqueousReactionViewModel: ObservableObject {

    private var navigation: NavigationModel<AqueousScreenState>?

    init() {
        let initialType = AqueousReactionType.A
        let initialRows = AqueousReactionSettings.initialRows

        self.selectedReaction = initialType
        self.rows = CGFloat(initialRows)
        self.components = ForwardAqueousReactionComponents(
            coefficients: initialType.coefficients,
            availableCols: MoleculeGridSettings.cols,
            availableRows: initialRows
        )

        self.navigation = AqueousNavigationModel.model(model: self)
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat = CGFloat(AqueousReactionSettings.initialRows) {
        didSet {
            components.availableRows = availableRows
        }
    }

    @Published var inputState = AqueousReactionInputState.none

    @Published var canSetCurrentTime = false
    @Published var currentTime: CGFloat = 0

    @Published var reactionSelectionIsToggled = false
    @Published var selectedReaction: AqueousReactionType {
        didSet {
            components.coefficients = selectedReaction.coefficients
        }
    }

    @Published var showQuotientLine = false
    @Published var showConcentrationLines = false

    @Published var chartOffset: CGFloat = 0

    @Published var components: AqueousReactionComponents

    private let inputSettings = AqueousReactionSettings.ConcentrationInput.self

    var equations: BalancedReactionEquations {
        components.equations
    }

    var quotientEquation: Equation {
        ReactionQuotientEquation(equations: components.equations)
    }

    var convergenceQuotient: CGFloat {
        quotientEquation.getY(at: AqueousReactionSettings.timeForConvergence)
    }

    func incrementAMolecules() {
        guard inputState == .addReactants else {
            return
        }
        components.increment(molecule: .A)
    }

    func incrementBMolecules() {
        guard inputState == .addReactants else {
            return
        }
        components.increment(molecule: .B)
    }

    func incrementCMolecules() {
        components.increment(molecule: .C)
    }

    func resetMolecules() {
        components.reset()
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
        let aTooLow = components.equations.a0 < inputSettings.minInitial
        let bTooLow = components.equations.b0 < inputSettings.minInitial

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
