//
// Reactions App
//


import SwiftUI

public struct AnimatableRotation: AnimatableModifier {

    let degreesRotation: Equation
    var currentTime: CGFloat

    public init(
        degreesRotation: Equation,
        currentTime: CGFloat
    ) {
        self.degreesRotation = degreesRotation
        self.currentTime = currentTime
    }

    public var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    public func body(content: Content) -> some View {
        content.rotationEffect(
            .degrees(Double(degreesRotation.getY(at: currentTime)))
        )
    }
}

extension View {
    public func animatableRotation(
        degreesRotation: Equation,
        currentTime: CGFloat
    ) -> some View {
        self.modifier(
            AnimatableRotation(
                degreesRotation: degreesRotation,
                currentTime: currentTime
            )
        )
    }
}
