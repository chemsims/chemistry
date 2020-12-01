//
// Reactions App
//
  

import SwiftUI
import CoreText

struct AnimatingNumberView: View {

    let x: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String

    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .modifier(AnimatingNumberModifier(x: x, equation: equation, formatter: formatter))
    }
}


struct AnimatingNumberModifier: AnimatableModifier {

    var x: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String

    var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    func body(content: Content) -> some View {
        content
            .overlay(Text(formatter(equation.getY(at: x))))
    }

}
