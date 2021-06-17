//
// Reactions App
//


import SwiftUI

/// A test tube container with flat sides and a sloped tip and rounded bottom
struct TestTubeContainer: Shape {

    let tipHeightFractionOfHeight: CGFloat
    let bottomRadiusFractionOfWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tipHeight = tipHeightFractionOfHeight * rect.height
        let topOfTipY = rect.height - tipHeight

        let bottomRadius = bottomRadiusFractionOfWidth * rect.width

        let angleOfSlopeToVertical = atan((rect.width / 2) / tipHeight)
        let circleCenter = CGPoint(x: rect.width / 2, y: rect.height - bottomRadius)

        let circleCenterToTangentX = bottomRadius * cos(angleOfSlopeToVertical)
        let circleCenterToTangentY = bottomRadius * sin(angleOfSlopeToVertical)

        // Position of the tangent between the left slope and bottom circle
        let leftTangent = CGPoint(
            x: circleCenter.x - circleCenterToTangentX,
            y: circleCenter.y + circleCenterToTangentY
        )

        let edgeRadius = 0.3 * rect.width
        path.move(to: .zero)

        path.addLine(to: CGPoint(x: 0, y: topOfTipY - edgeRadius))

        // Arcs from the left edge to left slope
        // NB: See this link for a visualisation of how this works https://www.twistedape.me.uk/2013/09/23/what-arctopointdoes/
        // And the docs: https://developer.apple.com/documentation/coregraphics/cgcontext/2427122-addarc
        path.addArc(
            tangent1End: CGPoint(x: 0, y: topOfTipY),
            tangent2End: leftTangent,
            radius: edgeRadius
        )

        let angleOfSlopeToHorizontal = (Double.pi / 2) - Double(angleOfSlopeToVertical)
        path.addArc(
            center: circleCenter,
            radius: bottomRadius,
            startAngle: .radians((Double.pi / 2) + angleOfSlopeToHorizontal),
            endAngle: .radians(Double(angleOfSlopeToVertical)),
            clockwise: true
        )

        // Arcs from the bottom slope to the right edge
        path.addArc(
            tangent1End: CGPoint(x: rect.width, y: topOfTipY),
            tangent2End: CGPoint(x: rect.width, y: topOfTipY - edgeRadius),
            radius: edgeRadius
        )

        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct TestTubeContainer_Previews: PreviewProvider {
    static var previews: some View {
        container
            .stroke()
        .frame(width: 200, height: 400)
        .previewLayout(.fixed(width: 250, height: 440))
    }

    private static var container: some Shape {
        TestTubeContainer(
            tipHeightFractionOfHeight: 0.3,
            bottomRadiusFractionOfWidth: 0.2
        )
    }
}
