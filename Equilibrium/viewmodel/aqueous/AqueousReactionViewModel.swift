//
// Reactions App
//

import SwiftUI
import ReactionsCore


class AqueousReactionViewModel: AqueousOrIntegrationReactionViewModel<AqueousScreenState> {
    override init() {
        super.init()
        self.navigation = AqueousNavigationModel.model(model: self)
    }
}

class IntegrationViewModel: AqueousOrIntegrationReactionViewModel<IntegrationScreenState> {

    override init() {
        super.init()
        navigation = IntegrationNavigationModel.model(model: self)
    }

    var forwardRate: ReactionRateDefinition {
        ReactionRateDefinition(
            firstMolecule: makeReactionRatePart(.A),
            secondMolecule: makeReactionRatePart(.B),
            k: selectedReaction.forwardRateConstant
        )
    }

    var reverseRate: ReactionRateDefinition {
        ReactionRateDefinition(
            firstMolecule: makeReactionRatePart(.C),
            secondMolecule: makeReactionRatePart(.D),
            k: selectedReaction.reverseRateConstant
        )
    }

    private func makeReactionRatePart(_ molecule: AqueousMolecule) -> ReactionRateDefinition.Part {
        ReactionRateDefinition.Part(
            molecule: molecule,
            concentration: components.equation.concentration.value(for: molecule),
            coefficient: components.coefficients.value(for: molecule)
        )
    }
}

struct ReactionRateDefinition {
    let firstMolecule: Part
    let secondMolecule: Part
    let k: CGFloat

    var rate: Equation {
        RateEquation(firstMolecule: firstMolecule, secondMolecule: secondMolecule, k: k)
    }

    struct Part {
        let molecule: AqueousMolecule
        let concentration: Equation
        let coefficient: Int
    }
}

struct RateEquation: Equation {
    let firstMolecule: ReactionRateDefinition.Part
    let secondMolecule: ReactionRateDefinition.Part
    let k: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        func getTerm(_ term: ReactionRateDefinition.Part) -> CGFloat {
            pow(term.concentration.getY(at: x), CGFloat(term.coefficient))
        }

        return k * getTerm(firstMolecule) * getTerm(secondMolecule)
    }
}

class AqueousOrIntegrationReactionViewModel<NavigationState: ScreenState>: ObservableObject {

    var navigation: NavigationModel<NavigationState>?

    fileprivate init() {
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

        self.addingMoleculesModel = MultiContainerShakeViewModel(
            canAddMolecule: { self.componentsWrapper.canIncrement(molecule: $0) },
            addMolecules: { (molecule, num) in self.increment(molecule: molecule, count: num) }
        )
    }

    private(set) var addingMoleculesModel: MultiContainerShakeViewModel<AqueousMolecule>! = nil

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

    @Published var reactionSelectionIsToggled = true
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

    @Published var highlightedElements = HighlightedElements<AqueousScreenElement>()
    @Published var reactionDefinitionDirection = ReactionDefinitionArrowDirection.none
    @Published private(set) var showShakeText = false
    @Published var timing: ReactionTiming = AqueousReactionSettings.firstReactionTiming

    var reactionPhase = AqueousReactionPhase.first

    private let incrementingLimits = ConcentrationIncrementingLimits()

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
        showShakeText = false

        let canAddReactant = inputState == .addReactants && molecule.isReactant
        let canAddProduct = inputState == .addProducts && molecule.isProduct
        if canAddProduct || canAddReactant {
            objectWillChange.send()
            componentsWrapper.increment(molecule: molecule, count: count)
            handlePostIncrementSaturation(of: molecule)
        }
    }

    func resetMolecules() {
        componentsWrapper.reset()
        instructToAddMoreReactantCount.reset()
    }

    func next() {
        if inputState == .addReactants,
           let missingReactant = getMissingReactant() {
            informUserOfMissing(reactant: missingReactant)
        } else if inputState == .addProducts && !hasAddedEnoughProduct {
            informUserOfMissingProduct()
        } else {
            hasShownShakeTextOnCurrentState = false
            showShakeText = false
            navigation?.next()
        }
    }

    func back() {
        hasShownShakeTextOnCurrentState = false
        showShakeText = false
        navigation?.back()
    }


    func showShakeTextIfNeeded() {
        guard !hasShownShakeTextOnCurrentState else {
            return
        }
        showShakeText = true
        hasShownShakeTextOnCurrentState = true
    }

    func hideShakeText() {
        showShakeText = false
    }

    private var hasShownShakeTextOnCurrentState = false

    /// Informs the user if they've added the maximum allowed amount of `molecule`
    private func handlePostIncrementSaturation(of molecule: AqueousMolecule) {
        guard !componentsWrapper.canIncrement(molecule: molecule) && (inputState == .addProducts || inputState == .addReactants) else {
            return
        }
        let canAddComplement = componentsWrapper.canIncrement(molecule: molecule.complement)


        let enoughStatement = StatementUtil.hasAddedEnough(
            of: molecule.rawValue,
            complement: molecule.complement.rawValue,
            canAddComplement: canAddComplement
        )
        statement = enoughStatement
        UIAccessibility.post(notification: .announcement, argument: statement.label)
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
        incrementingLimits.increment(for: reactant)
        statement = StatementUtil.addMore(
            reactant: reactant,
            count: incrementingLimits.count,
            minProperty: inputSettings.minInitial.str(decimals: 2),
            property: "concentration",
            action: "shake"
        )
    }

    // Returns the first reactant which does not have enough molecules in the beaker
    private func getMissingReactant() -> AqueousMoleculeReactant? {
        incrementingLimits.missingReactant(
            incremented: components.equation.initialConcentrations,
            minInitial: inputSettings.minInitial
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

    private(set) var instructToAddMoreReactantCount = EquatableCounter<AqueousMoleculeReactant>()

    /// Returns the number of cols available for molecules
    private var availableCols: Int {
        MoleculeGridSettings.cols
    }

    var scalesRotationFraction: Equation {
        EquilibriumReactionEquation(
            t1: components.startTime,
            c1: initialAngle.fraction,
            t2: components.equilibriumTime,
            c2: 0
        )
    }

    private var initialAngle: InitialAngleValue {
        reactionPhase == .first ? initialReactionScalesRotation : secondReactionScalesRotation
    }

    private var initialReactionScalesRotation: InitialAngleValue {
        InitialAngleValue(
            currentValue: components.equation.initialConcentrations.all.reduce(0) { $0 + $1 },
            valueAtZeroAngle: 0,
            valueAtMaxAngle: AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation,
            isNegative: true
        )
    }

    private var secondReactionScalesRotation: InitialAngleValue {
        let currentMoleculeCounts = componentsWrapper.molecules.map { $0.count }
        let currentCAndD = currentMoleculeCounts.productC + currentMoleculeCounts.productD

        let prevCAndD = componentsWrapper.previous?.components.beakerMolecules.filter {
            $0.molecule == .C || $0.molecule == .D
        }.map { molecule in
            molecule.fractioned.coords(at: components.startTime).count
        }.reduce(0) { $0 + $1 } ?? 0

        let maxConcentration = AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation
        let gridCount = GridUtil.availableRows(for: rows) * availableCols

        return InitialAngleValue(
            currentValue: CGFloat(currentCAndD),
            valueAtZeroAngle: CGFloat(prevCAndD),
            valueAtMaxAngle: CGFloat(gridCount) * maxConcentration
        )
    }
}

enum AqueousReactionPhase {
    case first, second
}

// MARK: Computed vars for input state
extension AqueousOrIntegrationReactionViewModel {

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

class ConcentrationIncrementingLimits {

    private var counter = EquatableCounter<AqueousMoleculeReactant>()

    func missingReactant(
        incremented: MoleculeValue<CGFloat>,
        minInitial: CGFloat
    ) -> AqueousMoleculeReactant? {
        func tooLow(_ molecule: AqueousMolecule) -> Bool {
            incremented.value(for: molecule) < minInitial
        }

        if tooLow(.A) {
            return .A
        } else if tooLow(.B) {
            return .B
        }
        return nil
    }

    var count: Int {
        counter.count
    }

    func increment(for reactant: AqueousMoleculeReactant) {
        counter.increment(value: reactant)
    }

    func resetCounter() {
        counter.reset()
    }
}
