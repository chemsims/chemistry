//
// Reactions App
//


import Foundation

/// GridElementBalancer provides a balance between increasing and decreasing pairs of elements
///
/// In the simplest case, the decrease in elements is equal to the increase in elements, so the net change is zero, and the decreasing
/// elements transfer directly to the increasing elements.
///
/// It is also possible that there is a net increase or decrease in elements. For example, if the overall increase is greater than the decrease,
/// then additional grid coordinates are added to the increasing elements.
///
/// Similarly, if the overall reduction is greater than the increase, then the final fraction to be drawn of the decreasing elements will be
/// lower than would otherwise have been the case
public struct GridElementBalancer {

    public let initialIncreasingA: GridElementToBalance
    public let initialIncreasingB: GridElementToBalance
    public let initialReducingC: GridElementToBalance
    public let initialReducingD: GridElementToBalance
    public let grid: [GridCoordinate]

    /// Creates a new balancer
    /// - Parameters:
    ///     - increasingElements: The elements which are increasing
    ///     - decreasingElements: The elements which are decreasing
    ///     - grid: Available grid coordinates that new coordinates can be taken from if necessary. Note that these will be filtered to ensure
    ///             existing coordinates are not chosen. This grid will be consumed in the same order as provided.
    public init?(
        increasingElements: GridElementPair<GridElementToBalance>,
        decreasingElements: GridElementPair<GridElementToBalance>,
        grid: [GridCoordinate]
    ) {
        guard increasingElements.both.allSatisfy({$0.delta >= 0}) else { return nil }
        guard decreasingElements.both.allSatisfy({$0.delta <= 0}) else { return nil }

        self.initialIncreasingA = increasingElements.first
        self.initialIncreasingB = increasingElements.second
        self.initialReducingC = decreasingElements.first
        self.initialReducingD = decreasingElements.second

        let all = (increasingElements.both + decreasingElements.both).flatMap(\.initialCoords)
        self.grid = grid.filter { coord in
            !all.contains(coord)
        }
    }

    public var increasingBalanced: GridElementPair<BalancedGridElement> {
        GridElementPair(
            first: initialIncreasingA.increasingElement(with: aCoords),
            second: initialIncreasingB.increasingElement(with: bCoords)
        )
    }

    public var decreasingBalanced: GridElementPair<BalancedGridElement> {
        GridElementPair(
            first: initialReducingC.decreasingElement(with: cCoords, extraDrop: extraCToDrop),
            second: initialReducingC.decreasingElement(with: dCoords, extraDrop: extraDToDrop)
        )
    }

    private var aCoords: [GridCoordinate] {
        let fromC = initialReducingC.initialCoords.prefix(numAToTakeFromC)
        let fromD = initialReducingD.initialCoords.prefix(numAToTakeFromD)
        let extra = grid.prefix(extraA)

        return initialIncreasingA.initialCoords + Array(fromC) + Array(fromD) + Array(extra)
    }

    private var bCoords: [GridCoordinate] {
        let fromC = initialReducingC.initialCoords.dropFirst(numAToTakeFromC).prefix(numBToTakeFromC)
        let fromD = initialReducingD.initialCoords.dropFirst(numAToTakeFromD).prefix(numBToTakeFromD)
        let extra = grid.dropFirst(extraA).prefix(extraB)


        return initialIncreasingB.initialCoords + Array(fromC) + Array(fromD) + Array(extra)
    }

    private var cCoords: [GridCoordinate] {
        initialReducingC.initialCoords
    }

    private var dCoords: [GridCoordinate] {
        initialReducingD.initialCoords
    }
}

private extension GridElementBalancer {
    private var numAToTakeFromC: Int {
        (Double(aToTransfer) * cToD).roundedInt()
    }

    private var numAToTakeFromD: Int {
        aToTransfer - numAToTakeFromC
    }

    private var numBToTakeFromC: Int {
        cToTransfer - numAToTakeFromC
    }

    private var numBToTakeFromD: Int {
        bToTransfer - numBToTakeFromC
    }

    private var aToTransfer: Int {
        (Double(directTransfer) * aToB).roundedInt()
    }

    private var bToTransfer: Int {
        directTransfer - aToTransfer
    }

    private var cToTransfer: Int {
        (Double(directTransfer) * cToD).roundedInt()
    }

    private var dToTransfer: Int {
        directTransfer - cToTransfer
    }

    private var directTransfer: Int {
        let increase = initialIncreasingA.delta + initialIncreasingB.delta
        let decrease = abs(initialReducingC.delta) + abs(initialReducingD.delta)
        return min(increase, decrease)
    }

    private var aToB: Double {
        ratio(initialIncreasingA.delta, initialIncreasingB.delta)
    }

    private var cToD: Double {
        ratio(abs(initialReducingC.delta), abs(initialReducingD.delta))
    }

    private var extraA: Int {
        initialIncreasingA.delta - aToTransfer
    }

    private var extraB: Int {
        initialIncreasingB.delta - bToTransfer
    }

    private var extraCToDrop: Int {
        abs(initialReducingC.delta) - cToTransfer
    }

    private var extraDToDrop: Int {
        abs(initialReducingD.delta) - dToTransfer
    }

    private func ratio(_ l: Int, _ r: Int) -> Double {
        let sum = l + r
        return sum == 0 ? 0 : Double(l) / Double(sum)
    }
}

public struct GridElementPair<Value> {
    public let first: Value
    public let second: Value

    public init(first: Value, second: Value) {
        self.first = first
        self.second = second
    }

    fileprivate var both: [Value] {
        [first, second]
    }
}


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

    fileprivate var delta: Int {
        finalCount - initialCoords.count
    }

    fileprivate func increasingElement(
        with coords: [GridCoordinate]
    ) -> BalancedGridElement {
        balancedElement(coords: coords, finalNumerator: finalCount)
    }

    fileprivate func decreasingElement(
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

/// - Note: Any fraction to draw must be drawn from the start of the coordinates
///         For example, given 10 elements and a fraction to draw of 0.3, then the indices 0, 1 and 2 should be drawn
public struct BalancedGridElement {

    public let coords: [GridCoordinate]
    public let initialFraction: Double
    public let finalFraction: Double

    public init(
        coords: [GridCoordinate],
        initialFraction: Double,
        finalFraction: Double
    ) {
        self.coords = coords
        self.initialFraction = initialFraction
        self.finalFraction = finalFraction
    }
}
