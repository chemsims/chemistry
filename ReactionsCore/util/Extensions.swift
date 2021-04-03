//
// Reactions App
//

import CoreGraphics
import CoreMotion

extension CGFloat {
    public func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", self)
    }

    public func rounded(decimals: Int) -> CGFloat {
        let power = pow(10, CGFloat(decimals))
        let multiplied = self * power
        let rounded = multiplied.rounded()
        return rounded / power
    }
}

extension BinaryFloatingPoint {
    public func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", Double(self))
    }

    public func roundedInt() -> Int {
        Int(rounded())
    }
}

extension Comparable {
    public func within(min: Self, max: Self) -> Self {
        Swift.min(max, Swift.max(min, self))
    }
}

extension Array where Self.Element: Equatable {

    public func element(after element: Element) -> Element? {
        self.element(after: element, distance: 1)
    }

    public func element(before element: Element) -> Element? {
        self.element(after: element, distance: -1)
    }

    private func element(after element: Element, distance: Int) -> Element? {
        let index = firstIndex(of: element)
        let nextIndex = index.map { $0 + distance }
        return nextIndex.flatMap { self[safe: $0] }
    }

    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}
