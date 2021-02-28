//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct MoleculeScaleBasket: View {

    let moleculeLeft: MoleculeConcentration
    let moleculeRight: MoleculeConcentration
    let currentTime: CGFloat

    var body: some View {
        GeometryReader { geo in
            SizedMoleculeScaleBasket(
                moleculeLeft: moleculeLeft,
                moleculeRight: moleculeRight,
                currentTime: currentTime,
                settings: MoleculeScaleBasketGeometry(width: geo.size.width)
            )
        }
    }
}

private struct SizedMoleculeScaleBasket: View {

    let moleculeLeft: MoleculeConcentration
    let moleculeRight: MoleculeConcentration
    let currentTime: CGFloat
    let settings: MoleculeScaleBasketGeometry

    var body: some View {
        ZStack(alignment: .bottom) {
            moleculePiles
            image
        }
    }

    private var moleculePiles: some View {
        HStack(spacing: 0) {
            moleculeView(moleculeLeft)
            moleculeView(moleculeRight)
        }
    }

    private func moleculeView(_ molecule: MoleculeConcentration) -> some View {
        AnimatingMoleculePile(
            fractionToDraw: molecule.concentration,
            currentTime: currentTime
        )
        .frame(width: settings.width / 2, height: settings.width / 2)
        .padding(.bottom, settings.moleculesBottomPadding)
        .foregroundColor(molecule.color)
    }

    private var image: some View {
        Image("single-scale")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct MoleculeScaleBasketGeometry {

    static let heightToWidth: CGFloat = 1.11

    fileprivate let width: CGFloat
    fileprivate static let basketHeightToTotalWidth: CGFloat = 0.21

    fileprivate var moleculesBottomPadding: CGFloat {
        0.9 * basketHeight
    }

    private var basketHeight: CGFloat {
        Self.basketHeightToTotalWidth * width
    }
}

struct MoleculeScaleBasket_Previews: PreviewProvider {
    static var previews: some View {
        MoleculeScaleBasket(
            moleculeLeft: MoleculeConcentration(
                concentration: ConstantEquation(value: 0.5),
                color: .red
            ),
            moleculeRight: MoleculeConcentration(
                concentration: ConstantEquation(value: 1),
                color: .blue
            ),
            currentTime: 0
        )
    }
}
