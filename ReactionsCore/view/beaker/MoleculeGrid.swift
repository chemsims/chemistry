//
// ReactionsCore
//

import SwiftUI

struct AnimatingMoleculeGrid: View {
    let settings: MoleculeGridSettings
    let coords: [GridCoordinate]
    let color: Color
    let drawFromTop: Bool
    let fractionOfCoordsToDraw: Equation
    let currentTime: CGFloat

    var body: some View {
        AnimatingMoleculeGridShape(
            cellSize: settings.cellSize,
            cellPadding: settings.cellPadding,
            drawFromTop: drawFromTop,
            coords: coords,
            fractionOfCoordsToDraw: fractionOfCoordsToDraw,
            currentTime: currentTime
        ).fill(color)
    }
}

struct MoleculeGrid: View {

    let settings: MoleculeGridSettings
    let coords: [GridCoordinate]
    let color: Color
    let drawFromTop: Bool

    var body: some View {
        MoleculeGridShape(
            cellSize: settings.cellSize,
            cellPadding: settings.cellPadding,
            drawFromTop: drawFromTop,
            coords: coords
        ).fill(color)
    }
}

struct MoleculeGrid_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GeometryReader { geometry in
                MoleculeGrid(
                    settings: MoleculeGridSettings(totalWidth: geometry.size.width),
                    coords: MoleculeGridSettings.fullGrid,
                    color: Color.black,
                    drawFromTop: true
                )
            }
            .border(Color.red)
            GeometryReader { geometry in
                MoleculeGrid(
                    settings: MoleculeGridSettings(totalWidth: geometry.size.width),
                    coords: [
                        GridCoordinate(col: 0, row: 0),
                        GridCoordinate(col: 0, row: 1)
                    ],
                    color: Color.black,
                    drawFromTop: false
                )
            }
            .border(Color.red)
        }
    }
}
