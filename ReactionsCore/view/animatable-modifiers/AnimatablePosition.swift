//
// Reactions App
//

import SwiftUI

extension View {

    /// Sets the position of the view by evaluating the provided position equation at the equation input.
    public func animatablePosition(
        equation: PointEquation,
        input: CGFloat
    ) -> some View {
        self.modifier(
            AnimatablePositionModifier(equation: equation, equationInput: input)
        )
    }
}

public struct AnimatablePositionModifier: AnimatableModifier {

    let equation: PointEquation
    var equationInput: CGFloat

    public var animatableData: CGFloat {
        get { equationInput }
        set { equationInput = newValue }
    }

    public func body(content: Content) -> some View {
        content
            .position(equation.getPoint(at: equationInput))
    }
}
