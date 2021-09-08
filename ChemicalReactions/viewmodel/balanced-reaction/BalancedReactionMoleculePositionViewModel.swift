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
    }

    @Published var reaction: BalancedReaction
    let moleculePosition: BalancedReactionMoleculePositionViewModel

    @Published var statement = [TextLine]()
    @Published var canGoNext = true
}

// MARK: - Navigation
extension BalancedReactionScreenViewModel {
    func next() {
    }

    func back() {
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

    func dropped(molecule: MovingMolecule, on elementType: BalancedReaction.ElementType) {
        guard !molecule.isInBeaker && molecule.elementType == elementType else {
            return
        }
        add(molecule: molecule)
    }

    func add(molecule: MovingMolecule) {
        let countInBeaker = reactionBalancer.count(of: molecule.moleculeType)

        guard countInBeaker < BalancedReactionBeakerMoleculeLayout.maxCount else {
            return
        }

        let newMoleculeInGrid = MovingMolecule(
            moleculeType: molecule.moleculeType,
            elementType: molecule.elementType,
            side: molecule.side
        )

        reactionBalancer.add(molecule.moleculeType, to: molecule.elementType)

        for i in molecules.indices {
            if molecules[i].id == molecule.id {
                molecules[i].position = .beaker(index: countInBeaker)
            }
        }

        withAnimation(.addMolecule) {
            molecules.append(newMoleculeInGrid)
        }
    }

    func remove(molecule: MovingMolecule) {
        guard let moleculeBeakerIndex = molecule.beakerIndex else {
            return
        }

        reactionBalancer.remove(molecule.moleculeType, from: molecule.elementType)

        molecules.removeAll { $0.id == molecule.id }

        for moleculeIndex in molecules.indices {
            if molecules[moleculeIndex].moleculeType == molecule.moleculeType {
                molecules[moleculeIndex].decrementBeakerIndexIfGreaterThan(moleculeBeakerIndex)
            }
        }
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
