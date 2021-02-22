//
// ReactionsCore
//

import SwiftUI

public struct BeakerBottomShape: Shape {

    /// Radius of the bottom corners
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(
            to: CGPoint(x: 0, y: rect.height - cornerRadius)
        )

        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: rect.height),
            control: CGPoint(x: 0, y: rect.height)
        )

        path.addLine(
            to: CGPoint(x: rect.width - cornerRadius, y: rect.height)
        )

        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height - cornerRadius),
            control: CGPoint(x: rect.width, y: rect.height)
        )

        path.addLine(to: CGPoint(x: rect.width, y: 0))

        return path
    }

}

struct BeakerBottomShape_Previews: PreviewProvider {
    static var previews: some View {
        BeakerBottomShape(
            cornerRadius: 50
        )
    }
}
