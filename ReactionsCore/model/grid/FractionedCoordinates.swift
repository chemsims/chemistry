//
// Reactions App
//

import CoreGraphics

public struct FractionedCoordinates {

    public let coordinates: [GridCoordinate]
    public let fractionToDraw: Equation

    public init(coordinates: [GridCoordinate], fractionToDraw: Equation) {
        self.coordinates = coordinates
        self.fractionToDraw = fractionToDraw
    }
}

extension FractionedCoordinates {
    public func coords(at x: CGFloat) -> [GridCoordinate] {
        let num = (fractionToDraw.getY(at: x) * CGFloat(coordinates.count)).roundedInt()
        return Array(coordinates.prefix(num))
    }
}
