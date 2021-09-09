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
    @Published var canGoNext = true
    @Published var showReactionToggle = false

    @Published var showDragTutorial = false

    private(set) var navigation: NavigationModel<BalancedReactionScreenState>!
}

// MARK: - Navigation
extension BalancedReactionScreenViewModel {
    func next() {
        navigation.next()
    }

    func back() {
        navigation.back()
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
        let didDrop = moleculePosition.drop(molecule: molecule, on: elementType)
        if didDrop {
            updateStatementPostMoleculeInteraction(molecule: molecule.moleculeType)
            if showDragTutorial {
                showDragTutorial = false
            }
        }
    }

    func remove(molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule) {
        let didRemove = moleculePosition.remove(molecule: molecule)
        if didRemove {
            updateStatementPostMoleculeInteraction(molecule: molecule.moleculeType)
        }
    }

    private func updateStatementPostMoleculeInteraction(
        molecule: BalancedReaction.Molecule
    ) {
        let newStatement = BalancedReactionDynamicStatement.getStatement(
            afterAdjusting: molecule,
            reactionBalancer: moleculePosition.reactionBalancer
        )
        self.statement = newStatement
    }
}

class BalancedReactionMoleculePositionViewModel: ObservableObject {

    let reaction: BalancedReaction
    @Published var molecules = [MovingMolecule]()
    @Published var reactionBalancer: ReactionBalancer

    init(reaction: BalancedReaction) {
        self.reaction = reaction
        self.reactionBalancer = ReactionBalancer(reaction: reaction)

        func addInitialMolecules(_ type: BalancedReaction.ElementType) {
            let elements = reaction.elements(ofType: type)
            molecules.append(
                MovingMolecule(
                    moleculeType: elements.first.molecule,
                    elementType: type,
                    side: .first
                )
            )
            if let secondElement = elements.second {
                molecules.append(
                    MovingMolecule(
                        moleculeType: secondElement.molecule,
                        elementType: type,
                        side: .second
                    )
                )
            }
        }

        addInitialMolecules(.reactant)
        addInitialMolecules(.product)
    }

    /// Attempts to drop the molecule on the beaker, returning true if the molecule was added
    fileprivate func drop(
        molecule: MovingMolecule,
        on elementType: BalancedReaction.ElementType
    ) -> Bool {
        let countInBeaker = reactionBalancer.count(of: molecule.moleculeType)
        guard countInBeaker < BalancedReactionBeakerMoleculeLayout.maxCount else {
            return false
        }

        guard !molecule.isInBeaker && molecule.elementType == elementType else {
            return false
        }
        add(molecule: molecule, withIndex: countInBeaker)
        return true
    }

    /// Attempts to add the molecule on the beaker, returning true if the molecule was added
    private func add(
        molecule: MovingMolecule,
        withIndex index: Int
    ) {
        let newMoleculeInGrid = MovingMolecule(
            moleculeType: molecule.moleculeType,
            elementType: molecule.elementType,
            side: molecule.side
        )

        reactionBalancer.add(molecule.moleculeType, to: molecule.elementType)

        for i in molecules.indices {
            if molecules[i].id == molecule.id {
                molecules[i].position = .beaker(index: index)
            }
        }

        withAnimation(.addMolecule) {
            molecules.append(newMoleculeInGrid)
        }

    }

    /// Attempts to remove `molecule` from the beaker, returning true iff it was removed
    fileprivate func remove(molecule: MovingMolecule) -> Bool {
        guard let moleculeBeakerIndex = molecule.beakerIndex else {
            return false
        }

        reactionBalancer.remove(molecule.moleculeType, from: molecule.elementType)

        molecules.removeAll { $0.id == molecule.id }

        for moleculeIndex in molecules.indices {
            if molecules[moleculeIndex].moleculeType == molecule.moleculeType {
                molecules[moleculeIndex].decrementBeakerIndexIfGreaterThan(moleculeBeakerIndex)
            }
        }

        return true
    }
}

private extension Animation {
    static let addMolecule = Animation.easeOut(duration: 0.5)
}

extension BalancedReactionMoleculePositionViewModel {

    struct MovingMolecule: Identifiable {
        let id = UUID()
        let moleculeType: BalancedReaction.Molecule
        let elementType: BalancedReaction.ElementType
        let side: BalancedReaction.ElementOrder
        var position: MoleculePosition = .grid

        var isInBeaker: Bool {
            beakerIndex != nil
        }

        fileprivate mutating func decrementBeakerIndexIfGreaterThan(_ other: Int) {
            if let beakerIndex = beakerIndex, beakerIndex > other {
                self.position = .beaker(index: beakerIndex - 1)
            }
        }

        fileprivate var beakerIndex: Int? {
            if case let .beaker(index) = position {
                return index
            }
            return nil
        }
    }

    enum MoleculePosition {
        case grid
        case beaker(index: Int)
    }
}
