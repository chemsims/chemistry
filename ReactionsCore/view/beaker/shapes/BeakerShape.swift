//
// ReactionsCore
//

import SwiftUI

/// Base shape of a beaker
public struct BeakerShape: Shape {

    /// Height of the lip. This is also used for the radius of the lip curve at either edge
    public let lipHeight: CGFloat

    /// The width of the lip on the left of the beaker. This is added after the lip curve, and can be zero.
    public let lipWidthLeft: CGFloat

    /// The width of the lip on the right of the beaker. This is added after the lip curve, and can be zero.
    public let lipWidthRight: CGFloat

    /// Bottom left corner radius
    public let leftCornerRadius: CGFloat

    /// Bottom right corner radius
    public let rightCornerRadius: CGFloat

    /// Gap at the bottom of the beaker
    public let bottomGap: CGFloat

    /// Gap at the right of the beaker
    public let rightGap: CGFloat

    /// Initialises a beaker shape object
    ///
    /// - Parameters:
    ///     - lipHeight: Height of the lip. This is also used for the radius of the lip curve at either edge
    ///     - lipWidthLeft: The width of the lip on the left of the beaker. This is added after the lip curve, and can be zero.
    ///     - lipWidthRight: The width of the lip on the right of the beaker. This is added after the lip curve, and can be zero.
    ///     - leftCornerRadius: Bottom left corner radius
    ///     - rightCornerRadius: Bottom right corner radius
    ///     - bottomGap: Gap at the bottom of the beaker
    ///     - rightGap: Gap at the right of the beaker
    public init(
        lipHeight: CGFloat,
        lipWidthLeft: CGFloat,
        lipWidthRight: CGFloat,
        leftCornerRadius: CGFloat,
        rightCornerRadius: CGFloat,
        bottomGap: CGFloat,
        rightGap: CGFloat
    ) {
        self.lipHeight = lipHeight
        self.lipWidthLeft = lipWidthLeft
        self.lipWidthRight = lipWidthRight
        self.leftCornerRadius = leftCornerRadius
        self.rightCornerRadius = rightCornerRadius
        self.bottomGap = bottomGap
        self.rightGap = rightGap
    }

    public func path(in rect: CGRect) -> Path {
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
