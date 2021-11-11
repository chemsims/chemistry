//
// Reactions App
//

import CoreGraphics
import ReactionsCore
import UIKit

class PrecipitationScreenViewModel: ObservableObject {

    init(persistence: PrecipitationInputPersistence) {
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
            useBufferWhenAddingMolecules: false
        )
        self.navigation = PrecipitationNavigationModel.model(
            using: self,
            persistence: persistence
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

    var navigation: NavigationModel<PrecipitationScreenState>!
    @Published var components: PrecipitationComponents
    private(set) var shakeModel: MultiContainerShakeViewModel<PrecipitationComponents.Reactant>!

    private func setComponents() {
        self.components = PrecipitationComponents(
            reaction: chosenReaction,
            rows: GridCoordinateList.availableRows(for: rows),
            volume: ChemicalReactionsSettings.rowsToVolume.getY(at: rows)
        )
    }

    var beakerToggleIsDisabled: Bool {
        input == .weighProduct
    }

    var nextIsDisabled : Bool {
        switch input {
        case .selectReaction:
            return true
        case let .addReactant(type):
            return !components.hasAddedEnough(of: type)
        case .weighProduct:
            return precipitatePosition == .beaker
        default:
            return false
        }
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

    func accessibilityWeighProductAction() {
        guard input == .weighProduct else {
            return
        }
        precipitatePosition = .scales
        didWeighProduct()
    }

    func didWeighProduct() {
        doGoNext(force: true)
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    func didSelectReaction() {
        doGoNext(force: true)
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    private func doGoNext(force: Bool) {
        if force || !nextIsDisabled {
            navigation.next()
        }
    }
}

// MARK: - Adding molecules
extension PrecipitationScreenViewModel {
    private func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
        input == .addReactant(type: reactant) && components.canAdd(reactant: reactant)
    }

    func add(reactant: PrecipitationComponents.Reactant, count: Int) {
        if canAdd(reactant: reactant) {
            components.add(reactant: reactant, count: count)
            if !components.canAdd(reactant: reactant) {
                doGoNext(force: true)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
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

    enum BeakerView: Codable {
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
             correctMetalRow,
             metalTable
    }
}
