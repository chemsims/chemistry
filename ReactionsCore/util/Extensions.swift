//
// Reactions App
//

import SwiftUI
import CoreMotion

extension View {

    /// Adds `value` as a label of the view, after passing it through the labelling function
    /// to generate a nicer label.
    public func accessibilityParsedLabel(_ value: String) -> some View {
        self.accessibility(label: Text(Labelling.stringToLabel(value)))
    }
}

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

    /// Dissociation constant of water (Kw) at 25°C
    public static let waterDissociationConstant: CGFloat = 1e-14
}

extension BinaryFloatingPoint {
    public func str(decimals: Int) -> String {
        String(format: "%.\(decimals)f", Double(self))
    }

    /// Returns the value as a percentage where 1 corresponds to 100%
    public var percentage: String {
        "\((self * 100).str(decimals: 0))%"
    }

    public func roundedInt() -> Int {
        Int(rounded())
    }
}

extension Comparable {
    public func within(min: Self, max: Self) -> Self {
        precondition(max >= min, "Cannot check bounds when max is smaller than min")
        return Swift.min(max, Swift.max(min, self))
    }
}

extension Array {
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
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


}

extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}

extension CGPoint {
    public func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

extension CGSize {
    public func scaled(by factor: CGFloat) -> CGSize {
        CGSize(
            width: width * factor,
            height: height * factor
        )
    }
}

extension CGRect {
    public var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}


extension TextLine: CustomDebugStringConvertible {

    public var debugDescription: String {
        concat(\.debugDescription)
    }

    public var plainString: String {
        concat(\.content)
    }

    private func concat(_ getString: KeyPath<TextSegment, String>) -> String {
        content.reduce("") {
            $0 + $1[keyPath: getString]
        }
    }
}

extension TextSegment: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(em)\(sc)\(content)\(sc)\(em)"
    }

    private var em: String {
        emphasised ? "*" : ""
    }

    private var sc: String {
        switch scriptType {
        case .superScript: return "^"
        case .subScript: return "_"
        case nil: return ""
        }
    }
}
