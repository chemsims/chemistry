//
// Reactions App
//

import CoreGraphics

protocol Equation {
    func getY(at x: CGFloat) -> CGFloat
}

struct LinearEquation: Equation {
    let m: CGFloat
    let c: CGFloat

    init(m: CGFloat, x1: CGFloat, y1: CGFloat) {
        self.m = m
        self.c = y1 - (m * x1)
    }

    init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        assert(x2 != x1)
        let m = (y2 - y1) / (x2 - x1)
        self.init(m: m, x1: x1, y1: y1)
    }

    func getY(at x: CGFloat) -> CGFloat {
        (m * x) + c
    }
}

struct IdentityEquation: Equation {
    func getY(at x: CGFloat) -> CGFloat {
        x
    }
}

struct ConstantEquation: Equation {
    let value: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        value
    }
}

struct LogEquation: Equation {
    let underlying: ConcentrationEquation

    func getY(at x: CGFloat) -> CGFloat {
        let value = underlying.getConcentration(at: x)
        if value == 0 {
            return 0
        }
        return log(value)
    }
}

struct RateEquation: Equation {
    let concentration: ConcentrationEquation

    func getY(at x: CGFloat) -> CGFloat {
        let k = concentration.rateConstant
        let order = CGFloat(concentration.order)
        let value = concentration.getConcentration(at: x)
        return k * pow(value, order)
    }
}
