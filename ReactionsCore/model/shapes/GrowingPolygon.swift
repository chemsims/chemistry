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

struct GrowingPolygon3 {

    /// Constructs a growing polygon using a random growth amount for each point, and each step.
    ///
    /// For each step, each point will grow by a random amount. The sum of growth for any point over
    /// every step will fall within the provided `pointGrowth`.
    ///
    /// Each point will start at a random angle (i.e., the points trajectory away from the center). Their
    /// angles will vary by some random amount during each step, but two points will never cross over.
    init(center: CGPoint, steps: Int, points: Int, pointGrowth: Range<CGFloat>) {
        let deltaAngle = 360 / Double(points)
        let firstPointAngle = Angle.degrees(Double.random(in: 0..<(deltaAngle / 2)))

        let maxAngleVariation = deltaAngle / 3

        self.points = (0..<points).map { point in
            Self.growingPointWithGrowthRange(
                initialPosition: center,
                steps: steps,
                totalGrowth: pointGrowth,
                initialAngle: firstPointAngle + Angle.degrees(Double(point) * deltaAngle),
                maxAngleVariation: maxAngleVariation
            )
        }
    }

    /// Constructs a growing polygon using a fixed growth amount for every point. The angle (i.e. the trajectory away from
    /// the center) of the first point can be provided, otherwise a random value is used.
    init(
        center: CGPoint,
        points: Int,
        pointGrowth: CGFloat,
        firstPointAngle: Angle?
    ) {
        let deltaAngle = 360 / Double(points)

        self.points = (0..<points).map { point in
            let first = firstPointAngle ?? Angle.degrees(Double.random(in: 0..<(deltaAngle / 2)))
            return Self.growingPointWithExactGrowth(
                initialPosition: center,
                totalGrowth: pointGrowth,
                initialAngle: first + Angle.degrees(Double(point) * deltaAngle)
            )
        }
    }

    let points: [PointEquation]

    func boundingRect(at progress: CGFloat) -> CGRect {
        guard !points.isEmpty else {
            return .zero
        }
        let resolvedPoints = points.map {
            $0.getPoint(at: progress)
        }
        var minX = resolvedPoints[0].x
        var maxX = resolvedPoints[0].x
        var minY = resolvedPoints[0].y
        var maxY = resolvedPoints[0].y
        for point in resolvedPoints {
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

    private static func growingPointWithGrowthRange(
        initialPosition: CGPoint,
        steps: Int,
        totalGrowth: Range<CGFloat>,
        initialAngle: Angle,
        maxAngleVariation: CGFloat
    ) -> PointEquation {
        let stepGrowthLowerBound = totalGrowth.lowerBound / CGFloat(steps)
        let stepGrowthUpperBound = totalGrowth.upperBound / CGFloat(steps)

        let stepGrowthRange = stepGrowthLowerBound..<stepGrowthUpperBound
        let stepMaxAngleVariation = maxAngleVariation / CGFloat(steps)

        let angleVariationRange = -stepMaxAngleVariation..<stepMaxAngleVariation

        return growingPoint(
            steps: steps,
            stepGrowth: { CGFloat.random(in: stepGrowthRange) },
            angleVariation: {
                Angle.degrees(CGFloat.random(in: angleVariationRange))
            },
            initialAngle: initialAngle,
            initialPosition: initialPosition
        )
    }

    private static func growingPointWithExactGrowth(
        initialPosition: CGPoint,
        totalGrowth: CGFloat,
        initialAngle: Angle
    ) -> PointEquation {
        growingPoint(
            steps: 1,
            stepGrowth: { totalGrowth },
            angleVariation: { .zero },
            initialAngle: initialAngle,
            initialPosition: initialPosition
        )
    }

    private static func growingPoint(
        steps: Int,
        stepGrowth: () -> CGFloat,
        angleVariation: () -> Angle,
        initialAngle: Angle,
        initialPosition: CGPoint
    ) -> PointEquation {
        var result: PointEquation = ConstantPointEquation(initialPosition)
        var lastPoint = GrowingPolygon.DirectedPoint(point: initialPosition, angle: initialAngle)

        let deltaProgress = 1 / CGFloat(steps)

        for stepIndex in 1...steps {
            let growth = stepGrowth()
            let nextAngle =  lastPoint.angle + angleVariation()

            let nextPosition = lastPoint.grow(by: growth).point
            let nextPoint = GrowingPolygon.DirectedPoint(point: nextPosition, angle: nextAngle)

            let prevProgress = CGFloat(stepIndex - 1) * deltaProgress

            result = SwitchingPointEquation(
                left: result,
                right: LinearPointEquation(
                    initial: lastPoint.point,
                    final: nextPosition,
                    initialProgress: prevProgress,
                    finalProgress: CGFloat(stepIndex) * deltaProgress
                ),
                thresholdProgress: prevProgress
            )
            lastPoint = nextPoint
        }

        return result
    }
}


extension GrowingPolygon {

    /// Creates a new polygon at the given `center`, using a default number of points, and a random growth
    /// trajectory for the points
    public init(
        center: CGPoint
    ) {
        let numPoints = 10
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
