//
// Reactions App
//

import SwiftUI
import ReactionsCore

class GaseousReactionViewModel: ObservableObject {

    init() {
        let initialReaction = GaseousReactionType.A
        let initialRows = GaseousReactionSettings.initialRows
        self.rows = CGFloat(initialRows)
        self.selectedReaction = initialReaction
        self.componentWrapper = ReactionComponentsWrapper(
            coefficients: initialReaction.coefficients,
            equilibriumConstant: initialReaction.equilibriumConstant,
            beakerCols: MoleculeGridSettings.cols,
            beakerRows: initialRows,
            maxBeakerRows: GaseousReactionSettings.maxRows,
            dynamicGridCols: EquilibriumGridSettings.cols,
            dynamicGridRows: EquilibriumGridSettings.rows,
            startTime: 0,
            equilibriumTime: GaseousReactionSettings.forwardTiming.equilibrium,
            maxC: AqueousReactionSettings.ConcentrationInput.maxInitial,
            usePressureValues: true
        )
        self.pumpModel = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 5,
            onDownPump: onPump
        )
        self.navigation = GaseousNavigationModel.model(model: self)
    }

    @Published var statement = [TextLine]()
    @Published var inputState = GaseousReactionInputState.selectReactionType
    @Published var currentTime: CGFloat = 0
    @Published var componentWrapper: ReactionComponentsWrapper
    @Published var rows: CGFloat {
        didSet {
            objectWillChange.send()
            highlightedElements.clear()
            componentWrapper.beakerRows = GridUtil.availableRows(for: rows)
        }
    }

    @Published var highlightedElements = HighlightedElements<GaseousScreenElement>()
    @Published var selectedPumpReactant = AqueousMoleculeReactant.A

    @Published var chartOffset: CGFloat = 0
    @Published var canSetCurrentTime = false
    @Published var showConcentrationLines = false
    @Published var showQuotientLine = false

    @Published var selectedReaction: GaseousReactionType {
        didSet {
            componentWrapper.coefficients = selectedReaction.coefficients
            componentWrapper.equilibriumConstant = selectedReaction.equilibriumConstant
        }
    }
    @Published var reactionSelectionIsToggled = true

    @Published var reactionDefinitionDirection = ReactionDefinitionArrowDirection.none

    @Published var showEquationTerms = true

    @Published var showFlame = false
    @Published var extraHeatFactor: CGFloat = 0 {
        didSet {
            highlightedElements.clear()
            componentWrapper.equilibriumConstant = equilibriumQuotient
        }
    }
    @Published var timing: ReactionTiming = GaseousReactionSettings.forwardTiming

    var reactionPhase = GaseousReactionPhase.firstReaction

    private(set) var navigation: NavigationModel<GaseousScreenState>?
    private let incrementingLimits = ConcentrationIncrementingLimits()

    func next() {
        if validateInputs() {
            navigation?.next()
        }
    }

    func back() {
        navigation?.back()
    }

    func resetMolecules() {
        objectWillChange.send()
        componentWrapper.reset()
    }


    var components: ReactionComponents {
        componentWrapper.components
    }

    var maxQuotient: CGFloat {
        components.maxQuotient
    }

    var equilibriumQuotient: CGFloat {
        scaleQuotient(base: selectedReaction.equilibriumConstant)
    }

    var equilibriumQuotientForAxis: CGFloat {
        (2 - extraHeatFactor) * equilibriumQuotient
    }

    var equilibriumPressureQuotient: CGFloat {
        scaleQuotient(base: selectedReaction.pressureConstant)
    }

    var volumeHasDecreased: Bool {
        GridUtil.availableRows(for: rows) < GaseousReactionSettings.initialRows
    }

    private func scaleQuotient(base: CGFloat) -> CGFloat {
        if selectedReaction.energyTransfer == .endothermic {
            return base * (1 + (5 * extraHeatFactor))
        }
        return base / (1 + (3 * extraHeatFactor))
    }

    private func onPump() {
        incrementReactant(selectedPumpReactant, amount: 1)
        highlightedElements.clear()
    }

    func incrementReactant(_ reactant: AqueousMoleculeReactant, amount: Int) {
        guard inputState == .addReactants else {
            return
        }
        objectWillChange.send()
        let molecule = reactant.molecule
        componentWrapper.increment(molecule: molecule, count: amount)
        if !componentWrapper.canIncrement(molecule: molecule) {
            let saturatedStatement = StatementUtil.hasAddedEnough(
                of: molecule.rawValue,
                complement: molecule.complement.rawValue,
                canAddComplement: componentWrapper.canIncrement(molecule: molecule.complement)
            )
            statement = saturatedStatement
            UIAccessibility.post(notification: .announcement, argument: saturatedStatement.label)
        }
    }

    var scalesRotationFraction: Equation {
        EquilibriumReactionEquation(
            t1: componentWrapper.startTime,
            c1: initialAngle.fraction,
            t2: components.equilibriumTime,
            c2: 0
        )
    }

    private var initialAngle: InitialAngleValue {
        switch reactionPhase {
        case .firstReaction: return initialAngleForFirstReaction
        case .pressureReaction: return initialAngleForPressureReaction
        case .heatReaction: return initialAngleForHeatReaction
        }
    }

    private var initialAngleForFirstReaction: InitialAngleValue {
        InitialAngleValue(
            currentValue: components.equation.initialConcentrations.all.reduce(0) { $0 + $1 },
            valueAtZeroAngle: 0,
            valueAtMaxAngle: AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation,
            isNegative: true
        )
    }

    private var initialAngleForPressureReaction: InitialAngleValue {
        let settings = GaseousReactionSettings.self
        let minRows = CGFloat(settings.minRows)
        let maxRows = CGFloat(settings.maxRows)
        let isReducingVolume = rows < CGFloat(settings.initialRows)
        return InitialAngleValue(
            currentValue: rows,
            valueAtZeroAngle: CGFloat(settings.initialRows),
            valueAtMaxAngle: isReducingVolume ? minRows : maxRows,
            isNegative: isReducingVolume
        )
    }

    private var initialAngleForHeatReaction: InitialAngleValue {
        InitialAngleValue(
            currentValue: extraHeatFactor,
            valueAtZeroAngle: 0,
            valueAtMaxAngle: 1,
            isNegative: selectedReaction.energyTransfer == .endothermic
        )
    }

    private(set) var pumpModel: PumpViewModel<CGFloat>!
}

enum GaseousReactionPhase {
    case firstReaction, pressureReaction, heatReaction
}

// MARK: Helper functions for concentration, volume and heat input limits
private extension GaseousReactionViewModel {

    private func validateInputs() -> Bool {
        switch inputState {
        case .addReactants:
            if let missingReactant = getMissingReactant() {
                informUserOfMissing(reactant: missingReactant)
                return false
            }
            return true
        case .setBeakerVolume where !hasChangedVolumeEnough:
            informUserToChangeVolume()
            return false
        case .setTemperature where !hasAddedEnoughHeat:
            informUserToAddHeat()
            return false
        default: return true
        }
    }

    private func informUserOfMissing(reactant: AqueousMoleculeReactant) {
        incrementingLimits.increment(for: reactant)
        statement = StatementUtil.addMore(
            reactant: reactant,
            count: incrementingLimits.count,
            minProperty: minInitialP.str(decimals: 2),
            property: "pressure",
            action: "pump"
        )
    }

    // Returns the first reactant which does not have enough molecules in the beaker
    private func getMissingReactant() -> AqueousMoleculeReactant? {
        incrementingLimits.missingReactant(
            incremented: components.equation.initialConcentrations.map {
                $0 * GaseousReactionSettings.pressureToConcentration
            },
            minInitial: minInitialP
        )
    }

    private var minInitialP: CGFloat {
        AqueousReactionSettings.ConcentrationInput.minInitial * GaseousReactionSettings.pressureToConcentration
    }

    private var hasChangedVolumeEnough: Bool {
        let currentRows = GridUtil.availableRows(for: rows)
        let initialRows = GaseousReactionSettings.initialRows
        if currentRows == initialRows {
            return false
        } else if currentRows == componentWrapper.minBeakerRows {
            return true
        }
        return abs(currentRows - initialRows) >= GaseousReactionSettings.minRowDelta
    }

    private var hasAddedEnoughHeat: Bool {
        extraHeatFactor >= GaseousReactionSettings.minHeatDelta
    }

    private func informUserToAddHeat() {
        statement = GaseousStatements.addHeat
    }

    private func informUserToChangeVolume() {
        statement = GaseousStatements.adjustVolume
    }
}
