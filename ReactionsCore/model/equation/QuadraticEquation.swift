//
// Reactions App
//

import CoreGraphics

public struct QuadraticEquation: Equation {

    // coefficient for x^2
    private let a: CGFloat

    // coefficient for x
    private let b: CGFloat

    // constant term
    private let c: CGFloat

    /// Creates a quadratic equation with a given parabola, and point which the curve passes through
    /// - Parameters:
    ///     - parabola: Coordinate of the curves parabola
    ///     - through: An additional point the curve should pass through
    public init(
        parabola: CGPoint,
        through point: CGPoint
    ) {
        let xParabola = parabola.x
        let yParabola = parabola.y
        let x1 = point.x
        let y1 = point.y

        let xPSquared = xParabola * xParabola
        let aNumer = (y1 - yParabola)
        let aDenom = (x1 * x1) - (2 * xParabola * x1) + (xPSquared)
        assert(aDenom != 0)

        let a = aNumer / aDenom
        let b = -2 * a * xParabola
        let c = yParabola + (a * xPSquared)

        self.a = a
        self.b = b
        self.c = c
    }

    public func getY(at x: CGFloat) -> CGFloat {
        (a * pow(x, 2)) + (b * x) + c
    }

}

