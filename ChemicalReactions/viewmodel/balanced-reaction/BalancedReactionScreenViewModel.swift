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

    func drop(
        molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
        on elementType: BalancedReaction.ElementType
    ) {
        guard inputState == .dragMolecules else {
            return
        }
        let didDrop = moleculePosition.drop(molecule: molecule, on: elementType)
        if didDrop {
            updateStatementPostMoleculeInteraction(molecule: molecule.moleculeType)
            if showDragTutorial {
                showDragTutorial = false
            }
            if moleculePosition.reactionBalancer.isBalanced {
                doGoNext()
            }
        }
    }

    func remove(molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule) {
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


