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

    /// Bottom left corner radius
    let leftCornerRadius: CGFloat

    /// Bottom right corner radius
    let rightCornerRadius: CGFloat

    /// Gap at the bottom of the beaker
    let bottomGap: CGFloat

    /// Gap at the right of the beaker
    let rightGap: CGFloat

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
        path.addLine(
            to: CGPoint(
                x: lipHeight + lipWidthLeft,
                y: rect.height - leftCornerRadius - bottomGap
            )
        )

        // Bottom left curve
        path.addQuadCurve(
            to: CGPoint(
                x: lipHeight + lipWidthLeft + leftCornerRadius,
                y: rect.height - bottomGap
            ),
            control: CGPoint(x: lipHeight + lipWidthLeft, y: rect.height - bottomGap)
        )

        // Bottom edge
        path.addLine(
            to: CGPoint(
                x: rect.width - lipHeight - lipWidthRight - rightCornerRadius - rightGap,
                y: rect.height - bottomGap
            )
        )

        // Bottom right curve
        path.addQuadCurve(
            to: CGPoint(
                x: rect.width - lipHeight - lipWidthRight - rightGap,
                y: rect.height - rightCornerRadius - bottomGap
            ),
            control: CGPoint(
                x: rect.width - lipHeight - lipWidthRight - rightGap,
                y: rect.height - bottomGap
            )
        )

        // Right edge
        path.addLine(
            to: CGPoint(
                x: rect.width - lipHeight - lipWidthRight - rightGap,
                y: lipHeight * 2
            )
        )

        // Right lip
        path.addLine(to: CGPoint(x: rect.width - lipHeight - rightGap, y: lipHeight * 2))


        // Right lip curve
        path.addArc(
            center: CGPoint(
                x: rect.width - lipHeight - rightGap,
                y: lipHeight
            ),
            radius: lipHeight,
            startAngle: .degrees(90),
            endAngle: .degrees(270),
            clockwise: true
        )

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
            leftCornerRadius: 80,
            rightCornerRadius: 160,
            bottomGap: 60,
            rightGap: 50
        ).stroke()
    }
}

