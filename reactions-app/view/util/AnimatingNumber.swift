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
        content
            .modifier(
                AnimatingValueModifier(
                    x: x,
                    alignment: alignment,
                    format: { x in
                        formatter(equation.getY(at: x))
                    }
                )
            )
    }

}

struct AnimatingValueModifier: AnimatableModifier {

    var x: CGFloat
    let alignment: Alignment
    var format: (CGFloat) -> String

    var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    func body(content: Content) -> some View {
        let value = Text(format(x))
        return content
            .overlay(value, alignment: alignment)
            .accessibility(value: value)
            .accessibility(addTraits: .updatesFrequently)
    }

}

/// An animatable modifier which also hides the view, for example to use in accessibility values
struct AccessibleValueModifier: AnimatableModifier {
    var x: CGFloat
    let format: (CGFloat) -> String

    var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    func body(content: Content) -> some View {
        let value = Text(format(x))
        return content
            .overlay(value.opacity(0))
            .accessibility(value: value)
            .accessibility(addTraits: .updatesFrequently)
    }
}

extension View {
    func updatingAccessibilityValue(x: CGFloat, format: @escaping (CGFloat) -> String) -> some View {
        self.modifier(AccessibleValueModifier(x: x, format: format))
    }
}
