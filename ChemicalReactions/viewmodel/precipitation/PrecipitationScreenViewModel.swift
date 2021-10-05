//
// Reactions App
//

import CoreGraphics
import ReactionsCore
import AcidsBases

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
    @Published var rows: CGFloat
    @Published var chosenReaction: PrecipitationReaction

    private(set) var navigation: NavigationModel<PrecipitationScreenState>!

    let components: PrecipitationComponents
    private(set) var shakeModel: MultiContainerShakeViewModel<PrecipitationComponents.Reactant>!
}

// MARK: - Navigation
extension PrecipitationScreenViewModel {
    func next() {
        if !nextIsDisabled {
            navigation.next()
        }
    }

    func back() {
        navigation.back()
    }

    var nextIsDisabled : Bool {
        switch input {
        case let .addReactant(type):
            return !components.hasAddedEnough(of: type)
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
            unknownReactant: chosenReaction.unknownReactant.name(showMetal: false).asString,
            highlightUnknownReactantFirstTerm: false,
            knownReactantMolarity: components.knownReactantMolarity,
            knownReactantMoles: components.knownReactantMoles,
            productMolarMass: chosenReaction.product.molarMass,
            productMoles: ConstantEquation(value: 0.23),
            productMass: ConstantEquation(value: 0.23),
            unknownReactantMolarMass: chosenReaction.unknownReactant.molarMass,
            unknownReactantMoles: ConstantEquation(value: components.unknownReactantMoles),
            unknownReactantMass: ConstantEquation(value: components.unknownReactantMass)
        )
    }
}

// MARK: - Input & equation state
extension PrecipitationScreenViewModel {
    enum Input: Equatable {
        case selectReaction
        case setWaterLevel
        case addReactant(type: PrecipitationComponents.Reactant)
    }

    enum EquationState: Int, Comparable {

        case blank,
            showKnownReactantMolarity

        static func < (
            lhs: PrecipitationScreenViewModel.EquationState,
            rhs: PrecipitationScreenViewModel.EquationState
        ) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
