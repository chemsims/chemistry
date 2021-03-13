//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct FractionedCoordinates {
    let coordinates: [GridCoordinate]
    let fractionToDraw: Equation
}

extension FractionedCoordinates {
    func coords(at x: CGFloat) -> [GridCoordinate] {
        let num = (fractionToDraw.getY(at: x) * CGFloat(coordinates.count)).roundedInt()
        return Array(coordinates.prefix(num))
    }
}
