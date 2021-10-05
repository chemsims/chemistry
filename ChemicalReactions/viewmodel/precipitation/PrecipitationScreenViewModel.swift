//
// Reactions App
//

import CoreGraphics
import ReactionsCore

class PrecipitationScreenViewModel: ObservableObject {

    init() {
        let availableReactions = PrecipitationReaction.availableReactionsWithRandomMetals()
        let chosenReaction = availableReactions.first!
        self.availableReactions = availableReactions
        self.chosenReaction = chosenReaction
        self.components = PrecipitationComponents(reaction: chosenReaction)
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
    @Published var rows: CGFloat = CGFloat(ChemicalReactionsSettings.initialRows)
    @Published var chosenReaction: PrecipitationReaction
    @Published var equationState = EquationState.blank

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
        false
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
            knownReactantMolarity: 0.3,
            knownReactantMoles: 0.5,
            productMolarMass: 123,
            productMoles: ConstantEquation(value: 0.23),
            productMass: ConstantEquation(value: 0.23),
            unknownReactantMolarMass: 180,
            unknownReactantMoles: ConstantEquation(value: 0.23),
            unknownReactantMass: ConstantEquation(value: 0.23)
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
