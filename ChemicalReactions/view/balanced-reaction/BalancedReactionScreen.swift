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
            Rectangle()
                .foregroundColor(.purple)
                .frame(size: layout.moleculeTableRect.size)
                .position(layout.moleculeTableRect.center)

            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.firstBeakerPosition)

            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.secondBeakerPosition)

            ForEach(model.molecules) { molecule in
                BalancedReactionMoleculeView(
                    structure: molecule.moleculeType.structure,
                    atomSize: atomSize(of: molecule)
                )
                .position(position(of: molecule))
                .onTapGesture {
                    if molecule.isInBeaker {
                        model.remove(molecule: molecule)
                    } else {
                        model.add(molecule: molecule)
                    }
                }
            }
        }
        .border(Color.red)
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
            return moleculeLayout.position(
                substanceType: molecule.substanceType,
                side: molecule.side
            )
        case let .beaker(index):
            return beakerLayout.position(of: molecule.moleculeType, index: index)
        }
    }

    private var beakerLayout: BalancedReactionBeakerMoleculeLayout {
        .init(
            firstMolecule: .ammonia,
            secondMolecule: .carbonDioxide,
            beakerRect: layout.firstBeakerRect,
            beakerSettings: layout.beakerSettings
        )
    }

    private var moleculeLayout: BalancedReactionMoleculeGridLayout {
        BalancedReactionMoleculeGridLayout(
            rect: layout.moleculeTableRect,
            reactants: .double,
            products: .double
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
