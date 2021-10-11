//
// Reactions App
//

import CoreGraphics
import SwiftUI

public struct GrowingPolygon {

    /// Constructs a growing polygon using a random growth amount for each point, and each step.
    ///
    /// For each step, each point will grow by a random amount. The sum of growth for any point over
    /// every step will fall within the provided `pointGrowth`.
    ///
    /// Each point will start at a random angle (i.e., the points trajectory away from the center). Their
    /// angles will vary by some random amount during each step, but two points will never cross over.
    public init(center: CGPoint, steps: Int, points: Int, pointGrowth: Range<CGFloat>) {
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
    public init(
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

    public let points: [PointEquation]

    public func boundingRect(at progress: CGFloat) -> CGRect {
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
        var lastPoint = DirectedPoint(point: initialPosition, angle: initialAngle)

        let deltaProgress = 1 / CGFloat(steps)

        for stepIndex in 1...steps {
            let growth = stepGrowth()
            let nextAngle =  lastPoint.angle + angleVariation()

            let nextPosition = lastPoint.grow(by: growth).point
            let nextPoint = DirectedPoint(point: nextPosition, angle: nextAngle)

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

private extension CGPoint {
    func within(min: CGFloat, max: CGFloat) -> CGPoint {
        CGPoint(
            x: self.x.within(min: min, max: max),
            y: self.y.within(min: min, max: max)
        )
    }
}
