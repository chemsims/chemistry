//
// Reactions App
//
  

import CoreGraphics
import Darwin

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

protocol ConcentrationEquation: Equation {
    func getConcentration(at time: CGFloat) -> CGFloat
}

extension ConcentrationEquation {
    func getY(at x: CGFloat) -> CGFloat {
        getConcentration(at: x)
    }
}


struct ConcentrationEquationWrapper: ConcentrationEquation {

    let underlying: Equation

    func getConcentration(at time: CGFloat) -> CGFloat {
        underlying.getY(at: time)
    }

}

/// Linear concentration which is c1 at t1, and c2 at t2.
struct LinearConcentration: ConcentrationEquation {

    let a0: CGFloat
    let rate: CGFloat

    init(a0: CGFloat, rate: CGFloat) {
        self.a0 = a0
        self.rate = rate
    }

    init(t1: CGFloat, c1: CGFloat, t2: CGFloat, c2: CGFloat) {
        self.rate = LinearConcentration.getRate(t1: t1, c1: c1, t2: t2, c2: c2)
        let a0Numerator = (t1 * c2) - (t2 * c1)
        self.a0 = a0Numerator / (t1 - t2)
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        a0 - (rate * time)
    }

    func time(for concentration: CGFloat) -> CGFloat? {
        (a0 - concentration) / rate
    }

    static func getRate(t1: CGFloat, c1: CGFloat, t2: CGFloat, c2: CGFloat) -> CGFloat {
        assert(t1 != t2)
        let deltaT = t2 - t1
        let deltaC = c2 - c1
        return -deltaC/deltaT
    }

}

struct ConstantConcentration: ConcentrationEquation {
    let value: CGFloat

    func getConcentration(at time: CGFloat) -> CGFloat {
        return value
    }
}


struct FirstOrderConcentration: ConcentrationEquation {

    let initialConcentration: CGFloat
    let rate: CGFloat

    init(initialConcentration: CGFloat, rate: CGFloat) {
        self.initialConcentration = initialConcentration
        self.rate = rate
    }

    init(c1: CGFloat, c2: CGFloat, time: CGFloat) {
        self.init(
            initialConcentration: c1,
            rate: FirstOrderConcentration.getRate(c1: c1, c2: c2, time: time)
        )
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        initialConcentration * CGFloat(pow(Darwin.M_E, -Double(rate * time)))
    }

    func time(for concentration: CGFloat) -> CGFloat? {
        guard concentration > 0 else {
            return nil
        }
        return -(1 / rate) * log(concentration / initialConcentration)
    }

    static func getRate(c1: CGFloat, c2: CGFloat, time: CGFloat) -> CGFloat {
        assert(c1 != 0)
        assert(time != 0)
        let logC = log(c2 / c1)
        return -1 * (logC / time)
    }
}



struct ConcentrationBEquation: ConcentrationEquation {
    let concentrationA: ConcentrationEquation
    let initialAConcentration: CGFloat

    func getConcentration(at time: CGFloat) -> CGFloat {
        initialAConcentration - concentrationA.getConcentration(at: time)
    }
}

struct LogEquation: ConcentrationEquation {
    let underlying: ConcentrationEquation

    func getConcentration(at time: CGFloat) -> CGFloat {
        let value = underlying.getConcentration(at: time)
        if (value == 0) {
            return 0
        }
        return log(value)
    }
}

struct SecondOrderConcentration: ConcentrationEquation {

    let initialConcentration: CGFloat
    let rate: CGFloat

    init(initialConcentration: CGFloat, rate: CGFloat) {
        self.initialConcentration = initialConcentration
        self.rate = rate
    }

    init(c1: CGFloat, c2: CGFloat, time: CGFloat) {
        self.init(
            initialConcentration: c1,
            rate: SecondOrderConcentration.getRate(c1: c1, c2: c2, time: time)
        )
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        assert(initialConcentration != 0)
        let invA1 = 1 / initialConcentration
        let kt = rate * time
        return 1 / (invA1 + kt)
    }

    func time(for concentration: CGFloat) -> CGFloat? {
        guard concentration > 0 else {
            return nil
        }
        return (1 / (concentration  * rate)) - (1 / (initialConcentration * rate))
    }


    static func getRate(c1: CGFloat, c2: CGFloat, time: CGFloat) -> CGFloat {
        assert(c1 != 0)
        assert(c2 != 0)
        let invC1 = 1 / c1
        let invC2 = 1 / c2
        return (invC2 - invC1) / time
    }
}

struct InverseEquation: ConcentrationEquation {
    let underlying: ConcentrationEquation

    func getConcentration(at time: CGFloat) -> CGFloat {
        let value = underlying.getConcentration(at: time)
        assert(value != 0)
        return 1 / value
    }
}
