//
// Reactions App
//


import Foundation

public struct GridElementToBalance {
    let initialCoords: [GridCoordinate]
    let finalCount: Int

    public init(
        initialCoords: [GridCoordinate],
        finalCount: Int
    ) {
        self.initialCoords = initialCoords
        self.finalCount = finalCount
    }

    var delta: Int {
        finalCount - initialCoords.count
    }

    func increasingElement(
        with coords: [GridCoordinate]
    ) -> BalancedGridElement {
        balancedElement(coords: coords, finalNumerator: finalCount)
    }

    func decreasingElement(
        with coords: [GridCoordinate],
        extraDrop: Int
    ) -> BalancedGridElement {
        balancedElement(coords: coords, finalNumerator: initialCoords.count - extraDrop)
    }

    private func balancedElement(
        coords: [GridCoordinate],
        finalNumerator: Int
    ) -> BalancedGridElement {
        guard !coords.isEmpty else {
            return BalancedGridElement(coords: [], initialFraction: 0, finalFraction: 0)
        }
        return BalancedGridElement(
            coords: coords,
            initialFraction: Double(initialCoords.count) / Double(coords.count),
            finalFraction: Double(finalNumerator) / Double(coords.count)
        )
    }
}
