//
// Reactions App
//

import SwiftUI

/// A polygon with support for animating the points.
///
/// - Note: When animating points, the number of points passed in should not be changed.
/// If you need to remove a point for example, you should animate it moving to the same position
/// as an existing point, so that it does not affect the shape, but remains in the array of points.
public struct Polygon: Shape {

    /// - Parameter points:
    /// The points of the polygon, which are drawn as fractions of the frame size.
    /// For example, a point of (1, 1) would be at the bottom right of the frame, and
    /// any coordinates exceeding 1 would be outside of the frame.
    public init(points: [CGPoint]) {
        self.points = points
    }

    private var points: [CGPoint]

    public func path(in rect: CGRect) -> Path {
        var p = Path()

        let scaledPoints = points.map { point in
            CGPoint(x: point.x * rect.width, y: point.y * rect.height)
        }

        p.addLines(scaledPoints)

        return p
    }

    public var animatableData: AnimatablePoints {
        get { AnimatablePoints(points: points) }
        set { points = newValue.points }
    }
}

/// Vector arithmetic for an array of `CGPoint`
public struct AnimatablePoints: VectorArithmetic {

    public static func + (lhs: AnimatablePoints, rhs: AnimatablePoints) -> AnimatablePoints {
        let zipped = zip(lhs.points, rhs.points)
        let newPoints = zipped.map { l, r in
            l + r
        }
        return AnimatablePoints(points: newPoints)
    }

    public static func - (lhs: AnimatablePoints, rhs: AnimatablePoints) -> AnimatablePoints {
        let zipped = zip(lhs.points, rhs.points)
        let newPoints = zipped.map { l, r in
            l - r
        }
        return AnimatablePoints(points: newPoints)
    }

    var points: [CGPoint]

    mutating public func scale(by rhs: Double) {
        points = points.map { $0.scale(by: rhs) }
    }

    public var magnitudeSquared: Double {
        points.reduce(0) { acc, next in
            acc + next.magnitudeSquared
        }
    }

    public static var zero = AnimatablePoints(points: [])
}

private extension CGPoint {
    func scale(by rhs: Double) -> CGPoint {
        CGPoint(x: x * rhs, y: y * rhs)
    }

    var magnitudeSquared: Double {
        (x * x) + (y * y)
    }

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
