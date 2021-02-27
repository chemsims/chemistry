//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EquilibriumGrid: View {

    let reactants: [AnimatingBeakerMolecules]
    let products: [AnimatingBeakerMolecules]

    var body: some View {
        GeometryReader { geo in
            makeView(
                settings: EquilibriumGridGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
        .border(Color.black, width: 1)
    }

    private func makeView(settings: EquilibriumGridGeometry) -> some View {
        HStack(spacing: 2) {
            Spacer()
            SizedEquilibriumGrid(
                molecules: reactants,
                settings: settings
            )
            Spacer()
            Rectangle()
                .frame(width: 1)
            Spacer()
            SizedEquilibriumGrid(
                molecules: products,
                settings: settings
            )
            Spacer()
        }
    }
}

private struct SizedEquilibriumGrid: View {

    let molecules: [AnimatingBeakerMolecules]
    let settings: EquilibriumGridGeometry

    var body: some View {
        ZStack {
            backgroundGrid
            ForEach(0..<molecules.count, id: \.self) { i in
                animatingGrid(
                    coords: molecules[i].molecules.coords,
                    equation: molecules[i].fractionToDraw
                )
                .foregroundColor(molecules[i].molecules.color)
            }
        }
        .frame(width: settings.gridWidth, height: settings.gridHeight)
    }

    private var backgroundGrid: some View {
        MoleculeGridShape(
            cellSize: settings.cellSize,
            cellPadding: settings.cellPadding,
            coords: EquilibriumGridGeometry.fullGrid
        )
        .foregroundColor(Styling.timeAxisCompleteBar)
    }

    private func animatingGrid(coords: [GridCoordinate], equation: Equation) -> some Shape {
        AnimatingMoleculeGridShape(
            cellSize: settings.cellSize,
            cellPadding: settings.cellPadding,
            coords: coords,
            fractionOfCoordsToDraw: equation,
            currentTime: 0
        )
    }
}

private struct EquilibriumGridGeometry {
    let width: CGFloat
    let height: CGFloat
    private static let rows: Int = 5
    private static let cols: Int = 6

    static var fullGrid: [GridCoordinate] {
        GridCoordinate.grid(cols: Self.cols, rows: Self.rows)
    }

    var cellSize: CGFloat {
        let maxForHeight = maxGridHeight / CGFloat(Self.rows)
        let maxForWidth = maxGridWidth / CGFloat(Self.cols)
        return min(maxForHeight, maxForWidth)
    }

    var cellPadding: CGFloat {
        0.2 * cellSize
    }

    var gridHeight: CGFloat {
        cellSize * CGFloat(Self.rows)
    }

    var gridWidth: CGFloat {
        cellSize * CGFloat(Self.cols)
    }

    var maxGridHeight: CGFloat {
        0.9 * height
    }

    var maxGridWidth: CGFloat {
        0.4 * width
    }
}

struct EquilibriumGrid_Previews: PreviewProvider {
    static var previews: some View {
        EquilibriumGrid(
            reactants: [
                AnimatingBeakerMolecules(
                    molecules: BeakerMolecules(
                        coords: [
                            GridCoordinate(col: 0, row: 0),
                            GridCoordinate(col: 1, row: 1),
                        ],
                        color: .red
                    ),
                    fractionToDraw: ConstantEquation(value: 1)
                )
            ],
            products: []
        )
            .frame(width: 320, height: 150)
            .previewLayout(.iPhoneSELandscape)
    }
}
