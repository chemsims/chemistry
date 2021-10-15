//
// Reactions App
//

import SwiftUI

struct MoleculeScaleBasket: View {

    let molecules: MoleculeScales.Molecules
    let equationInput: CGFloat
    let cols: Int
    let rows: Int

    var body: some View {
        GeometryReader { geo in
            SizedMoleculeScaleBasket(
                molecules: molecules,
                equationInput: equationInput,
                cols: cols,
                rows: rows,
                settings: MoleculeScaleBasketGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }
}

extension MoleculeScaleBasket {

    static func coordsToDraw(
        fractionToDraw: Equation,
        equationInput: CGFloat,
        cols: Int,
        rows: Int
    ) -> Int {
        let gridSize = MoleculeScales.gridCoords(cols: cols, rows: rows).count
        let currentFraction = fractionToDraw.getY(at: equationInput)
        let numAsFloat = currentFraction * CGFloat(gridSize)

        // NB: SwiftUI may pass in a negative value for currentTime
        return max(0, Int(numAsFloat.rounded()))
    }
    
}

private struct SizedMoleculeScaleBasket: View {

    let molecules: MoleculeScales.Molecules
    let equationInput: CGFloat
    let cols: Int
    let rows: Int
    let settings: MoleculeScaleBasketGeometry

    var body: some View {
        ZStack(alignment: .bottom) {
            moleculePiles
            image
        }
        .accessibility(removeTraits: .isImage)
        .updatingAccessibilityValue(x: equationInput, format: getAccessibilityLabel)
    }

    private var moleculePiles: some View {
        HStack(spacing: 0) {
            switch molecules {
            case let .single(molecules):
                Spacer(minLength: 0)
                moleculeView(molecules)
                    .frame(square: settings.singleMoleculePileSize)
                Spacer(minLength: 0)

            case let .double(left, right):
                let size = settings.width / 2
                moleculeView(left)
                    .frame(square: size)

                moleculeView(right)
                    .frame(square: size)
            }
        }
        .padding(.bottom, settings.moleculesBottomPadding)
    }

    private func moleculeView(
        _ molecule: MoleculeScales.MoleculeEquation
    ) -> some View {
        AnimatingMoleculePile(
            fractionToDraw: molecule.fractionToDraw,
            equationInput: equationInput,
            cols: cols,
            rows: rows
        )

        .foregroundColor(molecule.color)
    }

    private var image: some View {
        ZStack(alignment: .bottom) {
            Image("single-scale-basket", bundle: .reactionsCore)
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

// MARK: Accessibility value
extension SizedMoleculeScaleBasket {
    private func getAccessibilityLabel(atInput input: CGFloat) -> String {
        switch molecules {
        case let .single(concentration):
            return "\(getCount(of: concentration, at: input))"
        case let .double(left, right):
            let leftLabel = moleculeLabel(left, at: input)
            let rightLabel = moleculeLabel(right, at: input)
            return "\(leftLabel), \(rightLabel)"
        }
    }

    private func moleculeLabel(
        _ molecule: MoleculeScales.MoleculeEquation,
        at input: CGFloat
    ) -> String {
        let count = getCount(of: molecule, at: input)
        return "\(count) of \(molecule.label)"
    }

    private func getCount(
        of molecule: MoleculeScales.MoleculeEquation,
        at input: CGFloat
    ) -> Int {
        MoleculeScaleBasket.coordsToDraw(
            fractionToDraw: molecule.fractionToDraw,
            equationInput: input,
            cols: cols,
            rows: rows
        )
    }
}

struct MoleculeScaleBasket_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MoleculeScaleBasket(
                molecules: .single(
                    concentration: .init(
                        fractionToDraw: ConstantEquation(value: 1),
                        color: .red,
                        label: "A"
                    )
                ),
                equationInput: 0,
                cols: 5,
                rows: 5
            )
            .frame(square: 300)
            .border(Color.black)

            MoleculeScaleBasket(
                molecules: .double(
                    left: .init(
                        fractionToDraw: ConstantEquation(value: 1),
                        color: .red,
                        label: "A"
                    ),
                    right: .init(
                        fractionToDraw: ConstantEquation(value: 1),
                        color: .purple,
                        label: "B"
                    )
                ),
                equationInput: 0,
                cols: 5,
                rows: 5
            )
            .frame(square: 300)
            .border(Color.black)
        }
    }
}
