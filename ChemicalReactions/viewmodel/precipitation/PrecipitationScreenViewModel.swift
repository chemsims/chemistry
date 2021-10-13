//
// Reactions App
//

import CoreGraphics
import ReactionsCore

class PrecipitationScreenViewModel: ObservableObject {

    init() {
        let availableReactions = PrecipitationReaction.availableReactionsWithRandomMetals()
        let chosenReaction = availableReactions.first!
        let initialRows = ChemicalReactionsSettings.initialRows
        let initialVolume = ChemicalReactionsSettings.rowsToVolume.getY(at: CGFloat(initialRows))

        self.rows = CGFloat(initialRows)
        self.availableReactions = availableReactions
        self.chosenReaction = chosenReaction
        self.components = PrecipitationComponents(
            reaction: chosenReaction,
            rows: initialRows,
            volume: initialVolume
        )
        self.shakeModel = .init(
            canAddMolecule: self.canAdd,
            addMolecules: self.add,
            useBufferWhenAddingMolecules: false // TODO perf test
        )
        self.navigation = PrecipitationNavigationModel.model(
            using: self
        )
    }

    let availableReactions: [PrecipitationReaction]
    @Published var statement = [TextLine]()
    @Published var input: Input? = .selectReaction
    @Published var equationState = EquationState.blank
    @Published var rows: CGFloat {
        didSet {
            setComponents()
            if !highlights.elements.isEmpty {
                highlights.clear()
            }
        }
    }
    @Published var chosenReaction: PrecipitationReaction {
        didSet {
            setComponents()
        }
    }
    @Published var showUnknownMetal = false
    @Published var beakerView = BeakerView.microscopic
    @Published var precipitatePosition = PrecipitatePosition.beaker
    @Published var showMovingHand = false
    @Published var highlights = HighlightedElements<ScreenElement>()
    @Published var emphasiseUnknownMetalSymbol = false

    private(set) var navigation: NavigationModel<PrecipitationScreenState>!
    private(set) var components: PrecipitationComponents
    private(set) var shakeModel: MultiContainerShakeViewModel<PrecipitationComponents.Reactant>!

    private func setComponents() {
        self.components = PrecipitationComponents(
            reaction: chosenReaction,
            rows: GridCoordinateList.availableRows(for: rows),
            volume: ChemicalReactionsSettings.rowsToVolume.getY(at: rows)
        )
    }
}

// MARK: - Navigation
extension PrecipitationScreenViewModel {
    func next() {
        doGoNext(force: false)
    }

    func back() {
        navigation.back()
    }

    func didWeighProduct() {
        doGoNext(force: true)
    }

    private func doGoNext(force: Bool) {
        if force || !nextIsDisabled {
            navigation.next()
        }
    }

    var nextIsDisabled : Bool {
        switch input {
        case let .addReactant(type):
            return !components.hasAddedEnough(of: type)
        case .weighProduct:
            return precipitatePosition == .beaker
        default:
            return false
        }
    }
}

// MARK: - Adding molecules
extension PrecipitationScreenViewModel {
    private func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
        input == .addReactant(type: reactant) && components.canAdd(reactant: reactant)
    }

    private func add(reactant: PrecipitationComponents.Reactant, count: Int) {
        if canAdd(reactant: reactant) {
            components.add(reactant: reactant, count: count)
        }
    }
}

// MARK: - Equation data
extension PrecipitationScreenViewModel {
    var equationData: PrecipitationEquationView.EquationData {
        .init(
            beakerVolume: ChemicalReactionsSettings.rowsToVolume.getY(at: rows),
            knownReactant: chosenReaction.knownReactant.name.asString,
            product: chosenReaction.product.name.asString,
            unknownReactant: chosenReaction.unknownReactant.name(
                showMetal: showUnknownMetal,
                emphasiseMetal: showUnknownMetal
            ),
            unknownReactantCoefficient: chosenReaction.unknownReactant.coeff,
            knownReactantMolarity: components.knownReactantInitialMolarity,
            knownReactantMoles: components.knownReactantInitialMoles,
            productMolarMass: chosenReaction.product.molarMass,
            productMoles: components.productMolesProduced,
            productMass: components.productMassProduced,
            unknownReactantMolarMass: chosenReaction.unknownReactant.molarMass,
            unknownReactantMoles: components.reactingUnknownReactantMoles,
            unknownReactantMass: components.reactingUnknownReactantMass
        )
    }
}

// MARK: - UI states
extension PrecipitationScreenViewModel {
    enum Input: Equatable {
        case selectReaction
        case setWaterLevel
        case addReactant(type: PrecipitationComponents.Reactant)
        case weighProduct
    }

    enum EquationState: Int, Comparable {

        case blank,
            showKnownReactantMolarity,
             showAll

        static func < (
            lhs: PrecipitationScreenViewModel.EquationState,
            rhs: PrecipitationScreenViewModel.EquationState
        ) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum BeakerView {
        case microscopic, macroscopic
    }

    enum PrecipitatePosition {
        case beaker, scales
    }

    enum ScreenElement {
        case reactionToggle,
             reactionDefinition,
             waterSlider,
             knownReactantContainer,
             unknownReactantContainer,
             productMoles,
             unknownReactantMoles,
             unknownReactantMolarMass,
             correctMetalRow
    }
}
