//
// ReactionsCore
//

import CoreGraphics

public protocol Equation {
    func getY(at x: CGFloat) -> CGFloat
}

public func * (lhs: Equation, rhs: Equation) -> Equation {
    OperatorEquation(lhs: lhs, rhs: rhs, op: *)
}

public func * (lhs: CGFloat, rhs: Equation) -> Equation {
    ConstantEquation(value: lhs) * rhs
}

public func / (lhs: Equation, rhs: Equation) -> Equation {
    OperatorEquation(lhs: lhs, rhs: rhs) { (l, r) in
        r == 0 ? 0 : l / r
    }
}

public func / (lhs: CGFloat, rhs: Equation) -> Equation {
    ConstantEquation(value: lhs) / rhs
}

public func + (lhs: Equation, rhs: Equation) -> Equation {
    OperatorEquation(lhs: lhs, rhs: rhs, op: +)
}

public func + (lhs: CGFloat, rhs: Equation) -> Equation {
    ConstantEquation(value: lhs) + rhs
}

public func - (lhs: Equation, rhs: Equation) -> Equation {
    OperatorEquation(lhs: lhs, rhs: rhs, op: -)
}

public func - (lhs: Equation, rhs: CGFloat) -> Equation {
    lhs - ConstantEquation(value: rhs)
}

public func - (lhs: CGFloat, rhs: Equation) -> Equation {
    ConstantEquation(value: lhs) - rhs
}

public func pow(_ base: Equation, _ exponent: CGFloat) -> Equation {
    pow(base, ConstantEquation(value: exponent))
}

public func pow(_ base: CGFloat, _ exponent: Equation) -> Equation {
    pow(ConstantEquation(value: base), exponent)
}

public func pow(_ base: Equation, _ exponent: Equation) -> Equation {
    OperatorEquation(lhs: base, rhs: exponent) { pow($0, $1) }
}

public struct LinearEquation: Equation {
    public let m: CGFloat
    public let c: CGFloat

    public init(m: CGFloat, x1: CGFloat, y1: CGFloat) {
        self.m = m
        self.c = y1 - (m * x1)
    }

    /// Creates a new instance which passes through the points (`x1`, `y1`) and (`x2`, `y2`).
    ///
    /// - Note: When `x1 == x2`, the resulting equation will have a constant value of `y1`.
    public init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        let denom = x2 - x1
        let m = denom == 0 ? 0 : (y2 - y1) / denom
        self.init(m: m, x1: x1, y1: y1)
    }

    public func getY(at x: CGFloat) -> CGFloat {
        (m * x) + c
    }

    public func getX(at y: CGFloat) -> CGFloat {
        m == 0 ? 0 : (y - c) / m
    }
}

public struct IdentityEquation: Equation {

    public init() { }

    public func getY(at x: CGFloat) -> CGFloat {
        x
    }
}

public struct ConstantEquation: Equation {
    public let value: CGFloat

    public init(value: CGFloat) {
        self.value = value
    }

    public func getY(at x: CGFloat) -> CGFloat {
        value
    }
}

public struct ScaledEquation: Equation {

    public let scaleFactor: CGFloat
    public let underlying: Equation

    public init(targetY: CGFloat, targetX: CGFloat, underlying: Equation) {
        let currentY = underlying.getY(at: targetX)
        self.scaleFactor = currentY == 0 ? 1 : targetY / currentY
        self.underlying = underlying
    }

    public func getY(at x: CGFloat) -> CGFloat {
        scaleFactor * underlying.getY(at: x)
    }
}

/// An equation which evaluates two equations for the same input, and returns the result of
/// the provided operator which combines them.
public struct OperatorEquation: Equation {
    public let lhs: Equation
    public let rhs: Equation
    public let op: (CGFloat, CGFloat) -> CGFloat

    public init(lhs: Equation, rhs: Equation, op: @escaping (CGFloat, CGFloat) -> CGFloat) {
        self.lhs = lhs
        self.rhs = rhs
        self.op = op
    }

    public func getY(at x: CGFloat) -> CGFloat {
        op(lhs.getY(at: x), rhs.getY(at: x))
    }
}

public struct BoundEquation: Equation {
    let underlying: Equation
    let lowerBound: CGFloat?
    let upperBound: CGFloat?

    public init(
        underlying: Equation,
        lowerBound: CGFloat?,
        upperBound: CGFloat?
    ) {
        precondition(
            lowerBound.flatMap { lb in upperBound.map { ub in ub >= lb }} ?? true,
            "Cannot create bounded equation when upper bound is smaller than lower bound"
        )
        self.underlying = underlying
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    public func getY(at x: CGFloat) -> CGFloat {
        let value = underlying.getY(at: x)
        let withLowerBound = lowerBound.map { max($0, value) } ?? value
        return upperBound.map { min($0, withLowerBound) } ?? withLowerBound
    }
}

/// Returns the natural logarithm of `underlying`
/// Returns 0 for inputs of 0
public struct LogEquation: Equation {
    let underlying: Equation

    public init(underlying: Equation) {
        self.underlying = underlying
    }

    public func getY(at x: CGFloat) -> CGFloat {
        let value = underlying.getY(at: x)
        return value == 0 ? 0 : log(value)
    }
}

/// Returns log base 10 of either the input `x`, or wraps an `underlying` equation
/// Returns 0 for inputs of 0
public struct Log10Equation: Equation {
    let underlying: Equation

    public init() {
        self.init(underlying: IdentityEquation())
    }

    public init(underlying: Equation) {
        self.underlying = underlying
    }

    public func getY(at x: CGFloat) -> CGFloat {
        let value = underlying.getY(at: x)
        return value <= 0 ? 0 : log10(value)
    }
}

/// A linear equation which enforces that the `y` value has a minimum value at a given `x` value.
///
/// If the provided linear equation would be lower than the `minIntersection` point, then a switching
/// equation is instead used with a linear line on the left of the intersection from `x1`, `y1` up to the intersection, and
/// another linear line on the right of the intersection to `x2`, `y2`.
public struct LinearEquationWithMinIntersection: Equation {
    public init(
        x1: CGFloat,
        y1: CGFloat,
        x2: CGFloat,
        y2: CGFloat,
        minIntersection: CGPoint
    ) {
        let idealEquation = LinearEquation(x1: x1, y1: y1, x2: x2, y2: y2)
        let yValueAtIntersection = idealEquation.getY(at: minIntersection.x)

        if yValueAtIntersection > minIntersection.y {
            self.underlying = idealEquation
        } else {
            self.underlying = SwitchingEquation(
                thresholdX: minIntersection.x,
                underlyingLeft: LinearEquation(x1: x1, y1: y1, x2: minIntersection.x, y2: minIntersection.y),
                underlyingRight: LinearEquation(x1: minIntersection.x, y1: minIntersection.y, x2: x2, y2: y2)
            )
        }
    }

    let underlying: Equation

    public func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x)
    }
}

/// An equation which passes the result of the `inner` equation as input to the `outer`
/// equation.
///
/// This equation can be considered as `y(x) = g(f(x))`, where `f` is the inner equation
/// and `g` is the outer equation.
public struct ComposedEquation: Equation {

    public init(outer: Equation, inner: Equation) {
        self.outer = outer
        self.inner = inner
    }

    let outer: Equation
    let inner: Equation

    public func getY(at x: CGFloat) -> CGFloat {
        outer.getY(at: inner.getY(at: x))
    }
}

private struct AnonymousEquation: Equation {
    let transform: (CGFloat) -> CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        transform(x)
    }
}

extension Equation {
    public func within(min: CGFloat, max: CGFloat) -> Equation {
        BoundEquation(underlying: self, lowerBound: min, upperBound: max)
    }

    public func upTo(_ max: CGFloat) -> Equation {
        BoundEquation(underlying: self, lowerBound: nil, upperBound: max)
    }

    public func atLeast(_ min: CGFloat) -> Equation {
        BoundEquation(underlying: self, lowerBound: min, upperBound: nil)
    }

    public func map(_ transform: @escaping (CGFloat) -> CGFloat) -> Equation {
        ComposedEquation(
            outer: AnonymousEquation(transform: transform),
            inner: self
        )
    }
}
