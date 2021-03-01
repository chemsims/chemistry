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
                settings: MoleculeScaleBasketGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
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

    private func fractionToDraw(concentration: Equation) -> Equation {
        let factor = 1 / AqueousReactionSettings.Scales.concentrationForMaxBasketPile
        let constantEquation: Equation = ConstantEquation(value: factor)
        return concentration * constantEquation
    }

    private var moleculePiles: some View {
        HStack(spacing: 0) {
            moleculeView(moleculeLeft)
            moleculeView(moleculeRight)
        }
    }

    private func moleculeView(_ molecule: MoleculeConcentration) -> some View {
        AnimatingMoleculePile(
            fractionToDraw: fractionToDraw(concentration: molecule.concentration),
            currentTime: currentTime
        )
        .frame(width: settings.width / 2, height: settings.width / 2)
        .padding(.bottom, settings.moleculesBottomPadding)
        .foregroundColor(molecule.color)
    }

    private var image: some View {
        ZStack(alignment: .bottom) {
            Image("single-scale-basket")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: settings.width)

            basketHolder(isLeft: true)
            basketHolder(isLeft: false)
        }
        .frame(width: settings.width)
    }

    private func basketHolder(isLeft: Bool) -> some View {
        Path { p in
            p.move(to: CGPoint(x: settings.width / 2, y: 0))
            p.addLine(
                to: CGPoint(
                    x: isLeft ? 0 : settings.width,
                    y: settings.height - settings.basketHeight
                )
            )
        }
        .stroke(lineWidth: MoleculeScalesGeometry.lineWidth)
        .foregroundColor(Styling.scalesBody)
    }
}

struct MoleculeScaleBasketGeometry {

    static let heightToWidth: CGFloat = 1.11

    fileprivate let width: CGFloat
    fileprivate let height: CGFloat

    fileprivate static let basketHeightToTotalWidth: CGFloat = 0.21

    fileprivate var moleculesBottomPadding: CGFloat {
        0.9 * basketHeight
    }

    fileprivate var basketHeight: CGFloat {
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
