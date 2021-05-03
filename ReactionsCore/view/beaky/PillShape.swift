//
// Reactions App
//


import SwiftUI

struct PillShape: InsettableShape {

    private let insetAmount: CGFloat

    init() {
        self.init(insetAmount: 0)
    }

    private init(insetAmount: CGFloat) {
        self.insetAmount = insetAmount
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let insetRect = rect.inset(
            by: UIEdgeInsets(
                top: insetAmount,
                left: insetAmount,
                bottom: insetAmount,
                right: insetAmount
            )
        )

        let radius = insetRect.height / 2
        path.addArc(
            center: CGPoint(
                x: insetAmount + radius,
                y: insetAmount + radius
            ),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(90),
            clockwise: true
        )
        path.addLine(
            to: CGPoint(
                x: insetAmount + insetRect.width - radius,
                y: insetAmount + insetRect.height
            )
        )
        path.addArc(
            center: CGPoint(
                x: insetAmount + insetRect.width - radius,
                y: insetAmount + radius
            ),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(270),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        PillShape(insetAmount: insetAmount + amount)
    }

}

struct PillShape_Previews: PreviewProvider {
    static var previews: some View {
        PillShape()
            .frame(width: 300, height: 100)
    }
}
