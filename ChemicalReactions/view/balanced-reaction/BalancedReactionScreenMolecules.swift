//
// Reactions App
//

import SwiftUI

extension BalancedReactionScreen {

    struct BalancedReactionScreenMolecules: View {

        @ObservedObject var model: BalancedReactionScreenViewModel
        @ObservedObject var moleculeModel: BalancedReactionMoleculePositionViewModel
        let layout: BalancedReactionScreenLayout

        var body: some View {
            ZStack {
                ForEach(moleculeModel.molecules) { molecule in
                    BalancedReactionMoleculeView(
                        structure: molecule.moleculeType.structure,
                        atomSize: atomSize(of: molecule),
                        showSymbols: !molecule.isInBeaker,
                        dragEnabled: model.inputState == .dragMolecules,
                        onDragUpdate: {
                            moleculeDragUpdated(molecule: molecule, offset: $0)
                        },
                        onDragEnd: {
                            moleculeDragEnded(molecule: molecule, offset: $0)
                        }
                    )
                    .animation(.easeOut(duration: 0.35))
                    .position(position(of: molecule))
                }

                if model.showDragTutorial {
                    GhostMolecule(
                        moleculeType: moleculeModel.reaction.reactants.first.molecule,
                        originalPosition: moleculeGridLayout.firstReactantPosition,
                        layout: layout
                    )
                }
            }
        }

        private func moleculeDragUpdated(
            molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
            offset: CGSize
        ) {
            let overlappingBeaker = getOverlappingBeaker(molecule: molecule, offset: offset)
            if overlappingBeaker == .reactant {
                model.moleculesInFlightOverReactant.insert(molecule.id)
            } else if overlappingBeaker == .product {
                model.moleculesInFlightOverProduct.insert(molecule.id)
            } else {
                model.removeInFlightMolecule(id: molecule.id)
            }
        }

        private func moleculeDragEnded(
            molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
            offset: CGSize
        ) {
            model.removeInFlightMolecule(id: molecule.id)
            let beaker = getOverlappingBeaker(molecule: molecule, offset: offset)
            model.drop(molecule: molecule, on: beaker)
        }

        private func getOverlappingBeaker(
            molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule,
            offset: CGSize
        ) -> BalancedReaction.ElementType? {
            let originalPosition = position(of: molecule)
            let currentPosition = originalPosition.offset(offset)
            let boxSize = layout.moleculeBoundingBoxSizeForOverlapDetection
            let effectiveRect = CGRect(
                origin: currentPosition.offset(dx: -boxSize / 2, dy: -boxSize / 2),
                size: CGSize(width: boxSize, height: boxSize)
            )

            let overlappingLeftBeaker = layout.firstBeakerRect.intersects(effectiveRect)
            let overlappingRightBeaker = layout.secondBeakerRect.intersects(effectiveRect)

            if overlappingLeftBeaker {
                return .reactant
            } else if overlappingRightBeaker {
                return .product
            }
            return nil
        }

        private func atomSize(of molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule) -> CGFloat {
            if molecule.isInBeaker {
                return layout.beakerMoleculeAtomSize
            }
            return layout.moleculeTableAtomSize
        }

        private func position(
            of molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule
        ) -> CGPoint {
            optPosition(of: molecule) ?? .zero
        }

        private func optPosition(of molecule: BalancedReactionMoleculePositionViewModel.MovingMolecule) -> CGPoint? {
            switch molecule.position {
            case .grid:
                return moleculeGridLayout.position(
                    substanceType: molecule.elementType,
                    side: molecule.side
                )
            case let .beaker(index):
                return beakerLayout(elementType: molecule.elementType)
                    .position(of: molecule.moleculeType, index: index)
            }
        }

        private func beakerLayout(elementType: BalancedReaction.ElementType) -> BalancedReactionBeakerMoleculeLayout {
            let elements = model.reaction.elements(ofType: elementType)
            let rect = elementType == .reactant ? layout.firstBeakerRect : layout.secondBeakerRect
            return .init(
                firstMolecule: elements.first.molecule,
                secondMolecule: elements.second?.molecule,
                beakerRect: rect,
                beakerSettings: layout.beakerSettings
            )
        }

        private var moleculeGridLayout: BalancedReactionMoleculeGridLayout {
            BalancedReactionMoleculeGridLayout(
                rect: layout.moleculeTableRect,
                reactants: model.reaction.reactants.count,
                products: model.reaction.products.count
            )
        }
    }
}


private struct GhostMolecule: View {

    let moleculeType: BalancedReaction.Molecule
    let originalPosition: CGPoint
    let layout: BalancedReactionScreenLayout

    @State private var moleculeIsInBeaker = false

    var body: some View {
        ZStack {
            BalancedReactionMoleculeView(
                structure: moleculeType.structure,
                atomSize: layout.moleculeTableAtomSize,
                showSymbols: false
            )
            .compositingGroup()
            .opacity(0.5)

            Image(.core(.openHand))
                .resizable()
                .offset(y: layout.moleculeTableAtomSize / 2)
                .frame(size: layout.moleculeDragHandSize)
        }
        .position(position)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false)) {
                moleculeIsInBeaker = true
            }
        }
    }

    private var position: CGPoint {
        moleculeIsInBeaker ? positionInBeaker : originalPosition
    }

    private var positionInBeaker: CGPoint {
        layout.firstBeakerRect.center
    }
}
