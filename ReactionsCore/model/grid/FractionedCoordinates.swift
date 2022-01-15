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

    /// Maps between the initial and final coordinates linearly, using the
    /// provided reaction limits. The fraction is bounded, such that for inputs before
    /// `startOfReaction`, the `initial` coordinates are returned,
    /// and for inputs larger than `endOfReaction`, the `final` coordinates are
    /// returned.
    ///
    /// - Note: This constructor simply takes the larger array of the provided coordinates,
    /// and uses the size of the other array to determine its fraction to draw. This means
    /// one of `initial` or `final` should contain the other in the same
    /// order. For example, if `final` is larger than `initial`, then `final` should
    /// start with the `initial` coordinates. If `final` is smaller than `initial`,
    /// then `initial` should end with the same elements as `initial`.
    public init(
        initial: [GridCoordinate],
        final: [GridCoordinate],
        startOfReaction: CGFloat,
        endOfReaction: CGFloat
    ) {
        let biggerGrid = initial.count > final.count ? initial : final

        func fraction(_ coords: [GridCoordinate]) -> CGFloat {
            CGFloat(coords.count) / CGFloat(biggerGrid.count)
        }

        let initialFraction = fraction(initial)
        let finalFraction = fraction(final)

        let minFraction = min(initialFraction, finalFraction)
        let maxFraction = max(initialFraction, finalFraction)

        let equation = LinearEquation(
            x1: startOfReaction,
            y1: initialFraction,
            x2: endOfReaction,
            y2: finalFraction
        )
        .within(min: minFraction, max: maxFraction)

        self.init(
            coordinates: biggerGrid,
            fractionToDraw: equation
        )
    }
}

extension FractionedCoordinates {
    public func coords(at x: CGFloat) -> [GridCoordinate] {
        let fraction = fractionToDraw.getValue(at: x).within(min: 0, max: 1)
        let num = (fraction * CGFloat(coordinates.count)).roundedInt()
        return Array(coordinates.prefix(num))
    }
}
