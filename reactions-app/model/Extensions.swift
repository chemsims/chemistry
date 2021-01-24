//
// Reactions App
//
  

import CoreGraphics

extension CGFloat {
    func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", self)
    }

    func rounded(decimals: Int) -> CGFloat {
        let power = pow(10, CGFloat(decimals))
        let multiplied = self * power
        let rounded = multiplied.rounded()
        return rounded / power
    }
}

extension BinaryFloatingPoint {
    func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", Double(self))
    }
}

extension Array where Self.Element : Equatable {

    func element(after element: Element) -> Element? {
        self.element(after: element, distance: 1)
    }

    func element(before element: Element) -> Element? {
        self.element(after: element, distance: -1)
    }

    private func element(after element: Element, distance: Int) -> Element? {
        let index = firstIndex(of: element)
        let nextIndex = index.map { $0 + distance }
        return nextIndex.flatMap { self[safe: $0] }
    }

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
