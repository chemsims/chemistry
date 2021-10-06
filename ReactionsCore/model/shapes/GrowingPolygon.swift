//
// Reactions App
//

import CoreGraphics
import SwiftUI

/// A polygon which grows away from the center position, ensuring that points do not cross over
public struct GrowingPolygon {

    init(directedPoints: [DirectedPoint]) {
        self.directedPoints = directedPoints
    }

    let directedPoints: [DirectedPoint]

    public var points: [CGPoint] {
        directedPoints.map(\.point)
    }

    /// The fractional `CGRect` which encloses all points. This is in terms of the fractional points - i.e.,
    /// the bounds of the rect lie between 0 and 1
    public var boundingRect: CGRect {
        guard !directedPoints.isEmpty else {
            return .zero
        }
        var minX: CGFloat = directedPoints[0].point.x
        var maxX: CGFloat = directedPoints[0].point.x
        var minY: CGFloat = directedPoints[0].point.y
        var maxY: CGFloat = directedPoints[0].point.y
        for point in points {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }
        return CGRect(
            origin: CGPoint(x: minX, y: minY),
            size: CGSize(width: maxX - minX, height: maxY - minY)
        )
    }

    public func grow(by magnitude: Range<CGFloat>) -> GrowingPolygon {
        doGrow(magnitude: { CGFloat.random(in: magnitude) })
    }

    public func grow(exactly magnitude: CGFloat) -> GrowingPolygon {
        doGrow(magnitude: { magnitude })
    }

    private func doGrow(magnitude: () -> CGFloat) -> GrowingPolygon {
        let grownPoints = directedPoints.map { point in
            point.grow(by: magnitude())
        }
        return GrowingPolygon(directedPoints: grownPoints)
    }

    /// A point with an angle which this point should move along when growing. If you imagine drawing a line
    /// out from the center to the point, then `angle` would be the angle formed between that line and the
    /// horizontal. An angle of zero is the horizontal line, and turns clockwise. For example, an angle
    /// of 45 degrees would point to the bottom right. The cosine of the angle would produce a positive x, and the
    /// sine would produce a positive y.
    struct DirectedPoint {
        let point: CGPoint
        let angle: Angle

        func grow(by magnitude: CGFloat) -> DirectedPoint {
            let dx = cos(angle.radians) * magnitude
            let dy = sin(angle.radians) * magnitude
            let newPoint = point.offset(dx: dx, dy: dy).within(min: 0, max: 1)
            return DirectedPoint(
                point: newPoint,
                angle: angle
            )
        }
    }
}

extension GrowingPolygon {

    /// Creates a new polygon at the given `center`, using a default number of points, and a random growth
    /// trajectory for the points
    public init(
        center: CGPoint
    ) {
        let numPoints = 7
        let deltaAngle = 360 / Double(numPoints)
        let initialAngle = Double.random(in: 0..<(deltaAngle / 2))

        // we must ensure two angles don't overlap. If two adjacent points change their
        // starting angle by deltaAngle / 2, then they would be form the same line. So
        // we use deltaAngle / 3 to leave a little space between adjacent points
        let degreeRange = deltaAngle / 3

        func point(baseDegrees: Double) -> DirectedPoint {
            let minDegrees = baseDegrees - degreeRange
            let maxDegrees = baseDegrees + degreeRange
            let randomDegrees = Double.random(in: minDegrees...maxDegrees)
            return DirectedPoint(point: center, angle: .degrees(randomDegrees))
        }

        self.directedPoints = (0..<numPoints).map { i in
            let degrees = initialAngle + (Double(i) * deltaAngle)
            return point(baseDegrees: degrees)
        }
    }
}

private extension CGPoint {
    func within(min: CGFloat, max: CGFloat) -> CGPoint {
        CGPoint(
            x: self.x.within(min: min, max: max),
            y: self.y.within(min: min, max: max)
        )
    }
}
