//
// Reactions App
//


import SwiftUI

struct AnimatingNumber: View {

    let x: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String
    let alignment: Alignment

    init(
        x: CGFloat,
        equation: Equation,
        formatter: @escaping (CGFloat) -> String,
        alignment: Alignment = .center
    ) {
        self.x = x
        self.equation = equation
        self.formatter = formatter
        self.alignment = alignment
    }

    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .modifier(
                AnimatingNumberModifier(
                    x: x,
                    equation: equation,
                    formatter: formatter,
                    alignment: alignment
                )
            )
    }
}


struct AnimatingNumberModifier: AnimatableModifier {

    var x: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String
    let alignment: Alignment

    var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    func body(content: Content) -> some View {
        let value = Text(formatter(equation.getY(at: x)))
        return content
            .overlay(value, alignment: alignment)
            .accessibility(value: value)
            .accessibility(addTraits: .updatesFrequently)
    }

}
