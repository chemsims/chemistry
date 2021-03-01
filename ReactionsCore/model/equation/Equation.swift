//
// ReactionsCore
//

import CoreGraphics

public protocol Equation {
    func getY(at x: CGFloat) -> CGFloat
}

public func *(lhs: Equation, rhs: Equation) -> Equation {
    OperatorEquation(lhs: lhs, rhs: rhs, op: { $0 * $1 })
}

public struct LinearEquation: Equation {
    public let m: CGFloat
    public let c: CGFloat

    public init(m: CGFloat, x1: CGFloat, y1: CGFloat) {
        self.m = m
        self.c = y1 - (m * x1)
    }

    public init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        assert(x2 != x1)
        let m = (y2 - y1) / (x2 - x1)
        self.init(m: m, x1: x1, y1: y1)
    }

    public func getY(at x: CGFloat) -> CGFloat {
        (m * x) + c
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
