//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AnimatingMoleculePile: Shape {

    let fractionToDraw: Equation
    var currentTime: CGFloat

    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func path(in rect: CGRect) -> Path {
        MoleculePile(
            molecules: Array(MoleculePileSettings.grid.prefix(numToTake))
        ).path(in: rect)
    }

    private var numToTake: Int {
        let numAsFloat = fractionToDraw.getY(at: currentTime) * CGFloat(MoleculePileSettings.grid.count)
        return Int(numAsFloat.rounded())
    }
}

struct MoleculePile: Shape {

    let molecules: [GridCoordinate]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width / CGFloat(MoleculePileSettings.cols)
        let height = rect.height / CGFloat(MoleculePileSettings.rows)

        func addEllipse(row: CGFloat, col: CGFloat) {
            var top = rect.height - (height * (row + 1))
            let delta = (height / 8) * row
            top += delta

            let leftForRow = (width / 2) * row
            let left = leftForRow + (width * col)
            path.addEllipse(in: CGRect(x: left, y: top, width: width, height: height))
        }

        molecules.forEach { molecule in
            addEllipse(row: CGFloat(molecule.row), col: CGFloat(molecule.col))
        }

        return path
    }

    /// Adds an ellipse to path `path`
    /// - Parameters:
    ///     - col: The col index, starting from 0 at the left hand side
    ///     - row: The row index, starting at 0 at the bottom
    private func addEllipse(
        path: inout Path,
        row: Int,
        col: Int
    ) {

    }
}

struct MoleculePileSettings {
    static let cols = 4
    static let rows = 4

    static var grid: [GridCoordinate] {
        (0..<rows).flatMap { row in
            (0..<(cols - row)).map { col in
                GridCoordinate(col: col, row: row)
            }
        }
    }
}

struct MoleculePile_Previews: PreviewProvider {
    static var previews: some View {
        AnimatingMoleculePile(
            fractionToDraw: ConstantEquation(value: 10),
            currentTime: 0
        )
        .fill()
        .border(Color.red)
        .frame(width: 250, height: 250)
    }
}
