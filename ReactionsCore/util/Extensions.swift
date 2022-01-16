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
    /// Dissociation constant of water (Kw) at 25°C
    public static let waterDissociationConstant: CGFloat = 1e-14
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

extension Array where Self.Element: Numeric {
    public func sum() -> Self.Element {
        self.reduce(Self.Element.zero) { $0 + $1 }
    }
}

extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
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
