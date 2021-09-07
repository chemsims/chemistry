//
// Reactions App
//

import Foundation

struct SizeAdjuster {
    /// Returns a new array where each element is at each `minElementSize`, and the sum is
    /// less than or equal to `maximumSum`
    static func adjust<T: BinaryFloatingPoint>(
        sizes: [T],
        minElementSize: T,
        maximumSum: T
    ) -> [T] {
        sizes
            .withMinElementSize(minElementSize)
            .withSumBelow(limit: maximumSum, minSize: minElementSize)
    }
}

fileprivate extension Array where Element: BinaryFloatingPoint {

    func withMinElementSize(_ minSize: Element) -> [Element] {
        self.map { size in
            size < minSize ? minSize : size
        }
    }

    func withSumBelow(
        limit: Element,
        minSize: Element
    ) -> [Element] {
        let surplus = sum() - limit
        if surplus <= 0 {
            return self
        }

        let sortedElements = self.enumerated().sorted(by: {(a, b) in a.element < b.element })

        var result = self
        sortedElements.forEach { entry in
            let remainingElements = sortedElements[entry.offset...]
            let remainingSum = remainingElements.reduce(0) { $0 + $1.element }

            let previousElements = (0..<entry.offset).map { i in
                result[i]
            }
            let previousSum = previousElements.sum()

            let desiredScale = (limit - previousSum) / remainingSum
            let idealDelta = (1 - desiredScale) * entry.element
            let maxDelta = entry.element - minSize
            result[entry.offset] = entry.element - Swift.min(maxDelta, idealDelta)
        }
        return result
    }
}
