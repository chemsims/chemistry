//
// Reactions App
//


import SwiftUI

/// A test tube container with flat sides and a sloped tip and rounded bottom
struct TestTubeContainer: Shape {

    /// Height of the tip
    let tipHeightFractionOfHeight: CGFloat

    /// Radius of the bottom of the tube
    let bottomRadiusFractionOfWidth: CGFloat

    /// Sets the corner radius where the sides curves into the tip
    let slopeEdgeRadiusFractionOfWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tipHeight = tipHeightFractionOfHeight * rect.height
        let topOfTipY = rect.height - tipHeight

        let bottomRadius = bottomRadiusFractionOfWidth * rect.width
        let edgeRadius = slopeEdgeRadiusFractionOfWidth * rect.width

        let circleCenter = CGPoint(x: rect.width / 2, y: rect.height - bottomRadius)

        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: topOfTipY - edgeRadius))

        // Position of the tangent between the left slope and bottom circle
        guard let leftTangent = ArcGeometry.tangentOfCircle(
            withRadius: bottomRadius,
            center: circleCenter,
            through: CGPoint(x: 0, y: topOfTipY)
        ).map({ tangents in
            tangents.0.x < tangents.1.x ? tangents.0 : tangents.1
        }) else {
            print("Could not find tangents to draw curved edge")
            path.addLines([
                CGPoint(x: 0, y: topOfTipY - edgeRadius),
                CGPoint(x: 0, y: topOfTipY),
                CGPoint(x: rect.width / 2, y: rect.height),
                CGPoint(x: rect.width, y: topOfTipY),
                CGPoint(x: rect.width, y: 0),
            ])
            return path
        }

        let slopeX = leftTangent.x
        let slopeY = leftTangent.y - topOfTipY
        let angleOfSlopeToVertical = atan(slopeX / slopeY)
        let angleOfSlopeToHorizontal = (Double.pi / 2) - Double(angleOfSlopeToVertical)

        // Arcs from the left edge to left slope
        // NB: See this link for a visualisation of how this works https://www.twistedape.me.uk/2013/09/23/what-arctopointdoes/
        // And the docs: https://developer.apple.com/documentation/coregraphics/cgcontext/2427122-addarc
        path.addArc(
            tangent1End: CGPoint(x: 0, y: topOfTipY),
            tangent2End: leftTangent,
            radius: edgeRadius
        )

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
        ZStack {
            TestTubeContainer(
                tipHeightFractionOfHeight: 0.3,
                bottomRadiusFractionOfWidth: 0.1,
                slopeEdgeRadiusFractionOfWidth: 0.3
            )
            .stroke()
            .foregroundColor(.red)

            // Check that it's perfectly symmetrical
            TestTubeContainer(
                tipHeightFractionOfHeight: 0.3,
                bottomRadiusFractionOfWidth: 0.1,
                slopeEdgeRadiusFractionOfWidth: 0.3
            )
            .stroke()
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .frame(width: 200, height: 400)
        .previewLayout(.fixed(width: 250, height: 440))
    }
}
