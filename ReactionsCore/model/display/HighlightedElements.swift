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
            return .white
        }
        return Styling.inactiveScreenElement
    }

    public mutating func clear() {
        elements = []
    }
}
