//
// Reactions App
//
  

import SwiftUI

/// Base shape of a beaker
struct BeakerShape: Shape {

    /// Height of the lip. This is also used for the radius of the lip curve at either edge
    let lipHeight: CGFloat

    /// The width of the lip on the left of the beaker. This is added after the lip curve, and can be zero.
    let lipWidthLeft: CGFloat

    /// The width of the lip on the right of the beaker. This is added after the lip curve, and can be zero.
    let lipWidthRight: CGFloat

    // Corner radius of the bottom of the beaker
    let bottomCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Left lip curve
        path.addArc(
            center: CGPoint(x: lipHeight, y: lipHeight),
            radius: lipHeight,
            startAngle: .degrees(270),
            endAngle: .degrees(90),
            clockwise: true
        )

        // Left lip
        path.addLine(to: CGPoint(x: lipHeight + lipWidthLeft, y: lipHeight * 2))

        // Left edge
        path.addLine(to: CGPoint(x: lipHeight + lipWidthLeft, y: rect.height - bottomCornerRadius))

        // Bottom left curve
        path.addQuadCurve(
            to: CGPoint(x: lipHeight + lipWidthLeft + bottomCornerRadius, y: rect.height),
            control: CGPoint(x: lipHeight + lipWidthLeft, y: rect.height)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.width - lipHeight - lipWidthRight - bottomCornerRadius, y: rect.height))

        // Bottom right curve
        path.addQuadCurve(to: CGPoint(x: rect.width - lipHeight - lipWidthRight, y: rect.height - bottomCornerRadius), control: CGPoint(x: rect.width - lipHeight - lipWidthRight, y: rect.height))

        // Right edge
        path.addLine(to: CGPoint(x: rect.width - lipHeight - lipWidthRight, y: lipHeight * 2))

        // Right lip
        path.addLine(to: CGPoint(x: rect.width - lipHeight, y: lipHeight * 2))


        // Right lip curve
        path.addArc(
            center: CGPoint(x: rect.width - lipHeight, y: lipHeight), radius: lipHeight, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)

        path.closeSubpath()

        return path
    }

}

struct BeakerShape_Previews: PreviewProvider {
    static var previews: some View {
        BeakerShape(
            lipHeight: 20,
            lipWidthLeft: 10,
            lipWidthRight: 20,
            bottomCornerRadius: 80
        ).stroke()
    }
}

