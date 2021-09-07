//
// Reactions App
//

import SwiftUI

struct AnimatingMoleculePile: Shape {

    let fractionToDraw: Equation
    var equationInput: CGFloat
    let cols: Int
    let rows: Int

    var animatableData: CGFloat {
        get { equationInput }
        set { equationInput = newValue }
    }

    func path(in rect: CGRect) -> Path {
        MoleculePile(
            molecules: moleculesToDraw,
            cols: cols,
            rows: rows
        ).path(in: rect)
    }

    private var moleculesToDraw: [GridCoordinate] {
        Array(grid.prefix(numToTake))
    }

    private var grid: [GridCoordinate] {
        MoleculeScales.gridCoords(cols: cols, rows: rows)
    }

    private var numToTake: Int {
        MoleculeScaleBasket.coordsToDraw(
            fractionToDraw: fractionToDraw,
            equationInput: equationInput,
            cols: cols,
            rows: rows
        )
    }
}

struct MoleculePile: Shape {

    let molecules: [GridCoordinate]
    let cols: Int
    let rows: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width / CGFloat(cols)
        let height = rect.height / CGFloat(rows)
        let size = min(width, height)

        func addEllipse(row: CGFloat, col: CGFloat) {
            var top = rect.height - (size * (row + 1))
            let delta = (size / 8) * row
            top += delta

            let leftForRow = (size / 2) * row
            let left = leftForRow + (size * col)
            path.addEllipse(
                in: CGRect(
                    x: left,
                    y: top,
                    width: size,
                    height: size
                )
            )
        }

        molecules.forEach { molecule in
            addEllipse(row: CGFloat(molecule.row), col: CGFloat(molecule.col))
        }

        return path
    }

}

struct AnimatingMoleculePile_Previews: PreviewProvider {
    static var previews: some View {
        AnimatingMoleculePile(
            fractionToDraw: ConstantEquation(value: 1),
            equationInput: 1,
            cols: 5,
            rows: 5
        )
        .fill()
        .border(Color.red)
        .frame(square: 200)
    }
}
