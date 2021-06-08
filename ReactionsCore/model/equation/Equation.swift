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

/// Returns log base 10 of `underlying`.
/// Returns 0 for inputs of 0
public struct Log10Equation: Equation {
    let underlying: Equation

    public init(underlying: Equation) {
        self.underlying = underlying
    }

    public func getY(at x: CGFloat) -> CGFloat {
        let value = underlying.getY(at: x)
        return value == 0 ? 0 : log10(value)
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

}
