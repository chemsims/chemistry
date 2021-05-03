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
        let fraction = fractionToDraw.getY(at: x).within(min: 0, max: 1)
        let num = (fraction * CGFloat(coordinates.count)).roundedInt()
        return Array(coordinates.prefix(num))
    }
}
