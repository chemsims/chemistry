//
// Reactions App
//

import Foundation
import SwiftUI

public struct HighlightedElements<Value: Equatable>: Equatable {

    public var elements: [Value]

    public init() {
        self.elements = []
    }

    public init(elements: [Value]) {
        self.elements = elements
    }

    public func highlight(_ element: Value?) -> Bool {
        if let element = element, elements.contains(element) {
            return true
        }
        return false
    }

    public func colorMultiply(for element: Value?) -> Color {
        if elements.isEmpty || highlight(element) {
            return highlightColor
        }
        return inactiveColor
    }

    public func colorMultiply(anyOf elements: Value...) -> Color {
        colorMultiply(anyOf: elements)
    }

    public func colorMultiply(anyOf matchingElements: [Value]) -> Color {
        let anyAreHighlighted = matchingElements.contains { highlight($0) }
        if elements.isEmpty || anyAreHighlighted {
            return highlightColor
        }
        return inactiveColor
    }

    private let highlightColor = Color.white
    private let inactiveColor = Styling.inactiveScreenElement

    public mutating func clear() {
        elements = []
    }
}
