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

            BalancedReactionMoleculeView(
                structure: BalancedReaction.Molecule.water.structure,
                atomSize: layout.moleculeTableAtomSize
            )
            .position(
                moleculeLayout.firstReactantPosition
            )

            BalancedReactionMoleculeView(
                structure: BalancedReaction.Molecule.methane.structure,
                atomSize: layout.moleculeTableAtomSize
            )
            .position(
                moleculeLayout.secondReactantPosition ?? .zero
            )

            BalancedReactionMoleculeView(
                structure: BalancedReaction.Molecule.carbonDioxide.structure,
                atomSize: layout.moleculeTableAtomSize
            )
            .position(
                moleculeLayout.firstProductPosition
            )

            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.firstBeakerPosition)

            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.secondBeakerPosition)
        }
        .border(Color.red)
    }

    private var moleculeLayout: BalancedReactionMoleculeGridLayout {
        BalancedReactionMoleculeGridLayout(
            rect: layout.moleculeTableRect,
            reactants: .double,
            products: .single
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
