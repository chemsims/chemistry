//
// Reactions App
//

import SwiftUI

class BalancedReactionViewModel: ObservableObject {

    let reaction: BalancedReaction
    @Published var molecules = [MovingMolecule]()
    @Published var reactionBalancer: ReactionBalancer

    init() {
        let reaction = BalancedReaction(
            reactants: .two(
                first: .init(molecule: .methane, coefficient: 2),
                second: .init(molecule: .ammonia, coefficient: 1)
            ),
            products: .two(
                first: .init(molecule: .dioxygen, coefficient: 3),
                second: .init(molecule: .nitriteIon, coefficient: 4)
            )
        )

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

        withAnimation(.addMolecule) {
            molecules.append(newMoleculeInGrid)
            for i in molecules.indices {
                if molecules[i].id == molecule.id {
                    molecules[i].position = .beaker(index: countInBeaker)
                }
            }
        }
    }

    func remove(molecule: MovingMolecule) {
        guard let moleculeBeakerIndex = molecule.beakerIndex else {
            return
        }

        reactionBalancer.remove(molecule.moleculeType, from: molecule.elementType)

        withAnimation(.removeMolecule) {
            molecules.removeAll { $0.id == molecule.id }

            for moleculeIndex in molecules.indices {
                if molecules[moleculeIndex].moleculeType == molecule.moleculeType {
                    molecules[moleculeIndex].decrementBeakerIndexIfGreaterThan(moleculeBeakerIndex)
                }
            }
        }
    }
}

private extension Animation {
    static let addMolecule = Animation.easeOut(duration: 0.5)
    static let removeMolecule = Animation.easeOut(duration: 0.35)
}

extension BalancedReactionViewModel {

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
