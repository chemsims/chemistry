//
// Reactions App
//


import Foundation

public struct GridElementBalancer {

    let initialIncreasingA: GridElementToBalance
    let initialIncreasingB: GridElementToBalance
    let initialReducingC: GridElementToBalance
    let initialReducingD: GridElementToBalance
    let grid: [GridCoordinate]

    public init(
        initialIncreasingA: GridElementToBalance,
        initialIncreasingB: GridElementToBalance,
        initialReducingC: GridElementToBalance,
        initialReducingD: GridElementToBalance,
        grid: [GridCoordinate]
    ) {
        assert(initialIncreasingA.delta >= 0)
        assert(initialIncreasingB.delta >= 0)
        assert(initialReducingC.delta <= 0)
        assert(initialReducingD.delta <= 0)
        self.initialIncreasingA = initialIncreasingA
        self.initialIncreasingB = initialIncreasingB
        self.initialReducingC = initialReducingC
        self.initialReducingD = initialReducingD

        let all = initialIncreasingA.initialCoords + initialIncreasingB.initialCoords + initialReducingC.initialCoords + initialReducingD.initialCoords
        self.grid = grid.filter { coord in
            !all.contains(coord)
        }
    }

    var balancedA: BalancedGridElement {
        initialIncreasingA.balancedElement(with: aCoords)
    }

    var balancedB: BalancedGridElement {
        initialIncreasingB.balancedElement(with: bCoords)
    }

    var balancedC: BalancedGridElement {
        initialReducingC.balancedElement(with: cCoords)
    }

    var balancedD: BalancedGridElement {
        initialReducingD.balancedElement(with: dCoords)
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

    private func ratio(_ l: Int, _ r: Int) -> Double {
        let sum = l + r
        return sum == 0 ? 0 : Double(l) / Double(sum)
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

    fileprivate func balancedElement(
        with coords: [GridCoordinate]
    ) -> BalancedGridElement {
        guard !coords.isEmpty else {
            return BalancedGridElement(coords: [], initialFraction: 0, finalFraction: 0)
        }
        return BalancedGridElement(
            coords: coords,
            initialFraction: Double(initialCoords.count) / Double(coords.count),
            finalFraction: Double(finalCount) / Double(coords.count)
        )
    }
}

/// - Note: Any fraction to draw must be drawn from the start of the coordinates
///         For example, given 10 elements and a fraction to draw of 0.3, then the indices 0, 1 and 2 should be drawn
struct BalancedGridElement {
    let coords: [GridCoordinate]
    let initialFraction: Double
    let finalFraction: Double
}
