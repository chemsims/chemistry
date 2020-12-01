//
// Reactions App
//
  

import SwiftUI
import CoreText

struct AnimatingNumberView: View {

    let number: CGFloat
    let formatter: (CGFloat) -> String

    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .modifier(AnimatingNumberModifier(number: number, formatter: formatter))
    }
}


struct AnimatingNumberModifier: AnimatableModifier {

    var number: CGFloat
    let formatter: (CGFloat) -> String

    var animatableData: CGFloat {
        get { number }
        set { number = newValue }
    }

    func body(content: Content) -> some View {
        content
            .overlay(Text(formatter(number)))
    }

}
