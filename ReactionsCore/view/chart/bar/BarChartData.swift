//
// Reactions App
//

import SwiftUI

public struct BarChartData {

    public init(
        label: String,
        equation: Equation,
        color: Color,
        accessibilityLabel: String,
        initialValue: InitialValue? = nil
    ) {
        self.init(
            label: label,
            equation: equation,
            color: color,
            accessibilityLabel: accessibilityLabel,
            initialValue: initialValue,
            accessibilityValue: { equation.getY(at: $0).str(decimals: 2) }
        )
    }

    public init(
        label: String,
        equation: Equation,
        color: Color,
        accessibilityLabel: String,
        initialValue: InitialValue?,
        accessibilityValue: @escaping (CGFloat) -> String
    ) {
        self.label = label
        self.equation = equation
        self.color = color
        self.initialValue = initialValue
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
    }

    public let label: String
    public let equation: Equation
    public let color: Color

    public let initialValue: InitialValue?

    public let accessibilityLabel: String
    public let accessibilityValue: (CGFloat) -> String

    public struct InitialValue {
        let value: CGFloat
        let color: Color

        public init(value: CGFloat, color: Color) {
            self.value = value
            self.color = color
        }
    }
}
