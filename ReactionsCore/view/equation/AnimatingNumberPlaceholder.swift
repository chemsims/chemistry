//
// Reactions App
//

import SwiftUI

public struct AnimatingNumberPlaceholder: View {

    public init(
        showTerm: Bool,
        progress: CGFloat,
        equation: Equation,
        formatter: @escaping (CGFloat) -> String = { $0.str(decimals: 2) }
    ) {
        self.showTerm = showTerm
        self.progress = progress
        self.equation = equation
        self.formatter = formatter
    }

    let showTerm: Bool
    let progress: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String

    public var body: some View {
        if showTerm {
            AnimatingNumber(
                x: progress,
                equation: equation,
                formatter: formatter
            )
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundColor(.orangeAccent)
        } else {
            PlaceholderTerm(value: nil)
        }
    }
}
