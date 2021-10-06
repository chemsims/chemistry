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

    public func grow(by magnitude: Range<CGFloat>) -> GrowingPolygon {
        doGrow(magnitude: { CGFloat.random(in: magnitude) })
    }

    func grow(exactly magnitude: CGFloat) -> GrowingPolygon {
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
    public init(
        center: CGPoint
    ) {
        func point(baseDegrees: Double) -> DirectedPoint {
            let degreeRange: Double = 10
            let minDegrees = baseDegrees - degreeRange
            let maxDegrees = baseDegrees + degreeRange
            let randomDegrees = Double.random(in: minDegrees...maxDegrees)
            return DirectedPoint(point: center, angle: .degrees(randomDegrees))
        }

        self.directedPoints = [
            point(baseDegrees: 45), // bottom right
            point(baseDegrees: 135), // bottom left
            point(baseDegrees: 225), // top right
            point(baseDegrees: 270), // top middle
            point(baseDegrees: 315) // top right
        ]
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
