//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BalancedReactionScreenViewModel: ObservableObject {

    init() {
        let initialReaction = BalancedReaction.firstReaction
        self.reaction = initialReaction
        self.moleculePosition = .init(reaction: initialReaction)
        self.navigation = BalancedReactionNavigationModel.model(using: self)
    }

    @Published var reaction: BalancedReaction
    private(set) var moleculePosition: BalancedReactionMoleculePositionViewModel

    @Published var statement = [TextLine]()
    @Published var showDragTutorial = false
    @Published var inputState: InputState? = nil

    @Published var emphasiseReactionCoefficients = true

    // tracks in-flight molecules, i.e. those currently being dragged
    @Published var moleculesInFlightOverReactant = Set<UUID>()
    @Published var moleculesInFlightOverProduct = Set<UUID>()

    @Published var moleculesInFlight = Set<UUID>()

    var elementTypesInFlight: Set<BalancedReaction.ElementType> {
        let elems = moleculesInFlight.compactMap { id -> BalancedReaction.ElementType? in
            if let molecule = moleculePosition.molecules.first(where: { $0.id == id}) {
                return molecule.elementType
            }
            return nil
        }
        return Set(elems)
    }

    var hasSelectedFirstReaction = false

    var unavailableReactions: [BalancedReaction] {
        // When there's nothing in history, then we should not block the current reaction
        // from being chosen, as it is initial reaction on the screen
        if !hasSelectedFirstReaction {
            return []
        }
        return [reaction] + moleculePositionHistory.map(\.reaction)
    }

    private(set) var navigation: NavigationModel<BalancedReactionScreenState>!

    private var moleculePositionHistory = [BalancedReactionMoleculePositionViewModel]()

    func moleculeWasMoved(id: UUID, overlapping: BalancedReaction.ElementType?) {
        moleculesInFlight.insert(id)
        if overlapping == .reactant {
            moleculesInFlightOverReactant.insert(id)
        } else if overlapping == .product {
            moleculesInFlightOverProduct.insert(id)
        } else {
            moleculesInFlightOverReactant.remove(id)
            moleculesInFlightOverProduct.remove(id)
        }
    }

    func moleculeDragEnded(
        molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
        overlapping: BalancedReaction.ElementType?
    ) {
        removeInFlightMolecule(id: molecule.id)
        drop(molecule: molecule, on: overlapping)
    }

    private func removeInFlightMolecule(id: UUID) {
        moleculesInFlight.remove(id)
        moleculesInFlightOverReactant.remove(id)
        moleculesInFlightOverProduct.remove(id)
    }
}

extension BalancedReactionScreenViewModel {
    enum InputState {
        case dragMolecules, selectReaction
    }

    var canGoNext: Bool {
        switch inputState {
        case .dragMolecules: return moleculePosition.reactionBalancer.isBalanced
        case .selectReaction: return false
        case nil: return true
        }
    }
}

// MARK: - Navigation
extension BalancedReactionScreenViewModel {
    func next() {
        if canGoNext {
            doGoNext()
        }
    }

    private func doGoNext() {
        navigation.next()
    }

    func back() {
        navigation.back()
    }
}

// MARK: - Selecting reaction
extension BalancedReactionScreenViewModel {

    func didSelectReaction() {
        if hasSelectedFirstReaction {
            moleculePositionHistory.append(moleculePosition)
        } else {
            hasSelectedFirstReaction = true
        }
        moleculePosition = .init(reaction: reaction)
        doGoNext()
    }

    func restorePreviousMolecules() {
        if let previousMolecules = moleculePositionHistory.last {
            reaction = previousMolecules.reaction
            moleculePosition = previousMolecules
            moleculePositionHistory.removeLast()
        }
    }
}

// MARK: - Adding molecule
extension BalancedReactionScreenViewModel {

    func resetMolecules() {
        moleculePosition = .init(reaction: reaction)
    }

    private func drop(
        molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
        on elementType: BalancedReaction.ElementType?
    ) {
        guard inputState == .dragMolecules else {
            return
        }
        if molecule.isInBeaker {
            if elementType == nil {
                remove(molecule: molecule)
            }
        } else {
            if let elementType = elementType {
                add(molecule: molecule, on: elementType)
            }
        }
    }

    private func add(
        molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
        on elementType: BalancedReaction.ElementType
    ) {
        guard inputState == .dragMolecules else {
            return
        }
        let didAdd = moleculePosition.drop(molecule: molecule, on: elementType)
        if didAdd {
            updateStatementPostMoleculeInteraction(molecule: molecule.moleculeType)
            if showDragTutorial {
                showDragTutorial = false
            }
            if moleculePosition.reactionBalancer.isBalanced {
                doGoNext()
            }
        }
    }

    private func remove(molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule) {
        let didRemove = moleculePosition.remove(molecule: molecule)
        if didRemove {
            updateStatementPostMoleculeInteraction(molecule: molecule.moleculeType)
            if moleculePosition.reactionBalancer.isBalanced {
                doGoNext()
            }
        }
    }

    private func updateStatementPostMoleculeInteraction(
        molecule: BalancedReaction.Molecule
    ) {
        if let newStatement = BalancedReactionDynamicStatement.getStatement(
            afterAdjusting: molecule,
            reactionBalancer: moleculePosition.reactionBalancer
        ) {
            self.statement = newStatement
        }
    }
}

extension Animation {
    static let addMolecule = Animation.easeOut(duration: 0.5)
}
