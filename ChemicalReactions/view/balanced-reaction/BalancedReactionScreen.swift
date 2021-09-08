//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BalancedReactionScreen: View {

    @ObservedObject var model: BalancedReactionViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            SizedBalancedReactionScreen(
                model: model,
                layout: BalancedReactionScreenLayout(
                    common: ChemicalReactionsScreenLayout(
                        geometry: geo,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            )
        }
    }
}

private struct SizedBalancedReactionScreen: View {
    @ObservedObject var model: BalancedReactionViewModel
    let layout: BalancedReactionScreenLayout

    var body: some View {
        ZStack {
            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.firstBeakerPosition)

            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.secondBeakerPosition)

            BalancedReactionTopStack(
                model: model,
                layout: layout
            )

            ForEach(model.molecules) { molecule in
                BalancedReactionMoleculeView(
                    structure: molecule.moleculeType.structure,
                    atomSize: atomSize(of: molecule),
                    showSymbols: !molecule.isInBeaker,
                    dragEnabled: !molecule.isInBeaker,
                    onDragEnd: {
                        moleculeDragEnded(molecule: molecule, offset: $0)
                    }
                )
                .animation(.easeOut(duration: 0.35))
                .position(position(of: molecule))
                .onTapGesture {
                    if molecule.isInBeaker {
                        model.remove(molecule: molecule)
                    }
                }
            }
        }
    }

    private func moleculeDragEnded(
        molecule: BalancedReactionViewModel.MovingMolecule,
        offset: CGSize
    ) {
        guard !molecule.isInBeaker else {
            return
        }

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
            model.dropped(molecule: molecule, on: .reactant)
        } else if overlappingRightBeaker {
            model.dropped(molecule: molecule, on: .product)
        }
    }

    private func atomSize(of molecule: BalancedReactionViewModel.MovingMolecule) -> CGFloat {
        if molecule.isInBeaker {
            return layout.beakerMoleculeAtomSize
        }
        return layout.moleculeTableAtomSize
    }

    private func position(
        of molecule: BalancedReactionViewModel.MovingMolecule
    ) -> CGPoint {
        optPosition(of: molecule) ?? .zero
    }

    private func optPosition(of molecule: BalancedReactionViewModel.MovingMolecule) -> CGPoint? {
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

private struct BalancedReactionTopStack: View {

    @ObservedObject var model: BalancedReactionViewModel
    let layout: BalancedReactionScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                BalancedReactionDefinition(
                    model: model.reactionBalancer,
                    layout: layout
                )

                scales

                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
    }

    private var scales: some View {
        BalancedReactionScales(
            model: .init(balancer: model.reactionBalancer),
            layout: layout
        )
    }
}

struct BalancedReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BalancedReactionScreen(
                model: BalancedReactionViewModel()
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
