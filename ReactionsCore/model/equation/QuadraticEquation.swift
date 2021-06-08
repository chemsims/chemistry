//
// Reactions App
//

import CoreGraphics

/// An equation which switches between two underlying equations at some cutoff
public struct SwitchingEquation: Equation {

    public let thresholdX: CGFloat
    public let underlyingLeft: Equation
    public let underlyingRight: Equation

    /// Creates a new equation which switches between two underlying equations at the given X threshold
    ///
    /// - Parameters:
    ///     - thresholdX: The X value at which to switch to the right equation
    ///     - underlyingLeft: Equation to use for values less than `thresholdX`
    ///     - underlyingRight: Equation to use for values greater than or equal to `thresholdX`
    ///     -
    public init(
        thresholdX: CGFloat,
        underlyingLeft: Equation,
        underlyingRight: Equation
    ) {
        self.thresholdX = thresholdX
        self.underlyingLeft = underlyingLeft
        self.underlyingRight = underlyingRight
    }

    public func getY(at x: CGFloat) -> CGFloat {
        if x < thresholdX {
            return underlyingLeft.getY(at: x)
        }
        return underlyingRight.getY(at: x)
    }
}

public struct QuadraticEquation: Equation {

    // coefficient for x^2
    private let a: CGFloat

    // coefficient for x
    private let b: CGFloat

    // constant term
    private let c: CGFloat

    // TODO - add tests for this
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

    public init(
        gradient: CGFloat,
        at p1: CGPoint,
        through p2: CGPoint
    ) {
        let aDenom = pow(p2.x, 2) + pow(p1.x, 2) - (2 * p1.x * p2.x)
        let aNumer = p2.y - p1.y - (gradient * p2.x) + (gradient * p1.x)

        let a = aDenom == 0 ? 0 : aNumer / aDenom
        let b = gradient - (2 * a * p1.x)
        let c = p1.y + (a * pow(p1.x, 2)) - (gradient * p1.x)

        self.a = a
        self.b = b
        self.c = c
    }

    public func getY(at x: CGFloat) -> CGFloat {
        (a * pow(x, 2)) + (b * x) + c
    }

    public func getX(for y: CGFloat) -> (CGFloat, CGFloat)? {
        let termToSquareRoot = pow(b, 2) - (4 * a * (c - y))
        let denom = 2 * a
        guard termToSquareRoot > 0, denom != 0 else {
            return nil
        }
        let sqrtTerm = sqrt(termToSquareRoot)
        let term1 = (-b + sqrtTerm) / denom
        let term2 = (-b - sqrtTerm) / denom
        return (term1, term2)
    }

    /// Returns roots for the quadratic equation of the form `ax^2 + bx + c = 0`.
    ///
    /// Nil is returned in the case no roots exist.
    ///
    /// - Note: Both roots may be equal, and are returned in no guaranteed order.
    public static func roots(
        a: CGFloat,
        b: CGFloat,
        c: CGFloat
    ) -> (CGFloat, CGFloat)? {
        let termToSqrt = pow(b, 2) - (4 * a * c)
        let denom = 2 * a
        guard termToSqrt > 0, denom != 0 else {
            return nil
        }
        let sqrtTerm = sqrt(termToSqrt)

        let numer1 = -b + sqrtTerm
        let numer2 = -b - sqrtTerm

        return (numer1 / denom, numer2 / denom)
    }
}
