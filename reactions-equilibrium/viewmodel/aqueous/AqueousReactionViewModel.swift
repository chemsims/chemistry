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
        self.componentsWrapper = ReactionComponentsWrapper(
            coefficients: initialType.coefficients,
            equilibriumConstant: initialType.equilibriumConstant,
            beakerCols: MoleculeGridSettings.cols,
            beakerRows: initialRows,
            maxBeakerRows: AqueousReactionSettings.maxRows,
            dynamicGridCols: EquilibriumGridSettings.cols,
            dynamicGridRows: EquilibriumGridSettings.rows,
            startTime: 0,
            equilibriumTime: AqueousReactionSettings.timeForConvergence,
            maxC: AqueousReactionSettings.ConcentrationInput.maxInitial
        )

        self.navigation = AqueousNavigationModel.model(model: self)
        self.addingMoleculesModel = AddingMoleculesViewModel(
            canAddMolecule: { self.componentsWrapper.canIncrement(molecule: $0) },
            addMolecules: { (molecule, num) in self.increment(molecule: molecule, count: num) }
        )
    }

    private(set) var addingMoleculesModel: AddingMoleculesViewModel! = nil

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat = CGFloat(AqueousReactionSettings.initialRows) {
        didSet {
            componentsWrapper.beakerRows = GridUtil.availableRows(for: rows)
            highlightedElements.clear()
        }
    }

    @Published var inputState = AqueousReactionInputState.selectReactionType

    @Published var canSetCurrentTime = false
    @Published var currentTime: CGFloat = 0

    @Published var reactionSelectionIsToggled = false
    @Published var selectedReaction: AqueousReactionType {
        didSet {
            componentsWrapper.coefficients = selectedReaction.coefficients
            componentsWrapper.equilibriumConstant = selectedReaction.equilibriumConstant
        }
    }

    @Published var showQuotientLine = false
    @Published var showConcentrationLines = false

    @Published var chartOffset: CGFloat = 0

    @Published var componentsWrapper: ReactionComponentsWrapper
    var components: ReactionComponents {
        componentsWrapper.components
    }

    @Published var showEquationTerms = false

    @Published var highlightReverseReactionArrow = false
    @Published var highlightForwardReactionArrow = false
    @Published var highlightedElements = HighlightedElements<AqueousScreenElement>()

    @Published var canSetChartIndex = false {
        didSet {
            if !canSetChartIndex {
                activeChartIndex = nil
            }
        }
    }
    @Published var activeChartIndex: Int?

    private let inputSettings = AqueousReactionSettings.ConcentrationInput.self

    var quotientEquation: Equation {
        components.quotientEquation
    }

    var maxQuotient: CGFloat {
        quotientEquation.getY(at: components.tForMaxQuotient)
    }

    var convergenceQuotient: CGFloat {
        quotientEquation.getY(at: AqueousReactionSettings.endOfReverseReaction)
    }

    func stopShaking() {
        addingMoleculesModel.stopAll()
    }

    func increment(molecule: AqueousMolecule, count: Int) {
        guard componentsWrapper.canIncrement(molecule: molecule) else {
            return
        }

        let canAddReactant = inputState == .addReactants && molecule.isReactant
        let canAddProduct = inputState == .addProducts && molecule.isProduct
        if canAddProduct || canAddReactant {
            objectWillChange.send()
            componentsWrapper.increment(molecule: molecule, count: count)
            handlePostIncrementSaturation(of: molecule)
        }
    }

    func resetMolecules() {
        instructToAddMoreReactantCount = instructToAddMoreReactantCount.reset()
    }

    func next() {
        if inputState == .addReactants,
           let missingReactant = getMissingReactant() {
            informUserOfMissing(reactant: missingReactant)
        } else if inputState == .addProducts && !hasAddedEnoughProduct {
            informUserOfMissingProduct()
        } else {
            navigation?.next()
        }
    }

    func back() {
        navigation?.back()
    }

    /// Informs the user if they've added the maximum allowed amount of `molecule`
    private func handlePostIncrementSaturation(of molecule: AqueousMolecule) {
        guard !componentsWrapper.canIncrement(molecule: molecule) && (inputState == .addProducts || inputState == .addReactants) else {
            return
        }
        let canAddComplement = componentsWrapper.canIncrement(molecule: molecule.complement)
        var msg: [TextLine] = ["That's plenty of \(molecule) for now!"]
        if canAddComplement {
            msg.append("Why don't you try adding some of \(molecule.complement)?")
        } else {
            msg.append("Why don't you press next to start the reaction?")
        }
        statement = msg
    }

    private var hasAddedEnoughProduct: Bool {
        let minIncrement = AqueousReactionSettings.ConcentrationInput.minProductIncrement
        func hasEnough(_ molecule: AqueousMolecule) -> Bool {
            let incremented = componentsWrapper.concentrationIncremented(of: molecule)
            let didIncrementEnough = incremented.rounded(decimals: 2) >= minIncrement
            return didIncrementEnough || !componentsWrapper.canIncrement(molecule: molecule)
        }

        return hasEnough(.C) || hasEnough(.D)
    }

    private func informUserOfMissingProduct() {
        statement = AqueousStatements.addMoreProduct
    }

    private func informUserOfMissing(reactant: AqueousMoleculeReactant) {
        instructToAddMoreReactantCount = instructToAddMoreReactantCount.increment(value: reactant)
        statement = AqueousStatements.addMore(
            reactant: reactant,
            count: instructToAddMoreReactantCount.count,
            minConcentration: inputSettings.minInitial.str(decimals: 2)
        )
    }

    // Returns the first reactant which does not have enough molecules in the beaker
    private func getMissingReactant() -> AqueousMoleculeReactant? {
        let aTooLow = components.equation.initialConcentrations.reactantA.rounded(decimals: 2) < inputSettings.minInitial
        let bTooLow = components.equation.initialConcentrations.reactantB.rounded(decimals: 2) < inputSettings.minInitial

        if aTooLow {
            return .A
        } else if bTooLow {
            return .B
        }
        return nil
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
