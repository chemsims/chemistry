//
// Reactions App
//
  

import CoreGraphics
import Darwin

protocol ConcentrationEquation: Equation {

    /// The concentration at t=0
    var a0: CGFloat { get }

    var rateConstant: CGFloat { get }

    var order: Int { get }
    var halfLife: CGFloat { get }

    /// Returns concentration at time `time`
    func getConcentration(at time: CGFloat) -> CGFloat

    /// Returns the time at which the concentration is `concentration`
    func time(for concentration: CGFloat) -> CGFloat?
}

extension ConcentrationEquation {
    func getY(at x: CGFloat) -> CGFloat {
        getConcentration(at: x)
    }

    /// Returns the rate at time `time`
    func getRate(at time: CGFloat) -> CGFloat {
        rateConstant * pow(getConcentration(at: time), CGFloat(order))
    }

    var rateEquation: Equation {
        RateEquation(concentration: self)
    }
}

struct ZeroOrderConcentration: ConcentrationEquation {

    let a0: CGFloat
    let rateConstant: CGFloat
    let order = 0

    init(a0: CGFloat, rateConstant: CGFloat) {
        assert(rateConstant != 0)
        self.a0 = a0
        self.rateConstant = rateConstant
    }

    init(c1: CGFloat, t1: CGFloat, rateConstant: CGFloat) {
        let a0 = c1 + (rateConstant * t1)
        self.init(a0: a0, rateConstant: rateConstant)
    }

    init(t1: CGFloat, c1: CGFloat, t2: CGFloat, c2: CGFloat) {
        self.rateConstant = ZeroOrderConcentration.getRate(t1: t1, c1: c1, t2: t2, c2: c2)
        let a0Numerator = (t1 * c2) - (t2 * c1)
        self.a0 = a0Numerator / (t1 - t2)
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        a0 - (rateConstant * time)
    }

    func time(for concentration: CGFloat) -> CGFloat? {
        (a0 - concentration) / rateConstant
    }

    var halfLife: CGFloat {
        a0 / (2 * rateConstant)
    }

    static func getRate(t1: CGFloat, c1: CGFloat, t2: CGFloat, c2: CGFloat) -> CGFloat {
        assert(t1 != t2)
        let deltaT = t2 - t1
        let deltaC = c2 - c1
        return -deltaC/deltaT
    }

}

struct FirstOrderConcentration: ConcentrationEquation {

    let a0: CGFloat
    let rateConstant: CGFloat
    let order = 1

    init(a0: CGFloat, rateConstant: CGFloat) {
        assert(rateConstant != 0)
        self.a0 = a0
        self.rateConstant = rateConstant
    }

    init(c1: CGFloat, c2: CGFloat, time: CGFloat) {
        self.init(
            a0: c1,
            rateConstant: FirstOrderConcentration.getRate(c1: c1, c2: c2, time: time)
        )
    }

    init(c1: CGFloat, t1: CGFloat, rateConstant: CGFloat) {
        let a0 = c1 / CGFloat(pow(Darwin.M_E, -Double(rateConstant * t1)))
        self.init(a0: a0, rateConstant: rateConstant)
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        a0 * CGFloat(pow(Darwin.M_E, -Double(rateConstant * time)))
    }

    func time(for concentration: CGFloat) -> CGFloat? {
        guard concentration > 0 else {
            return nil
        }
        return -(1 / rateConstant) * log(concentration / a0)
    }

    var halfLife: CGFloat {
        log(2) / rateConstant
    }

    static func getRate(c1: CGFloat, c2: CGFloat, time: CGFloat) -> CGFloat {
        assert(c1 != 0)
        assert(time != 0)
        let logC = log(c2 / c1)
        return -1 * (logC / time)
    }
}

struct ConcentrationBEquation: Equation {
    let concentrationA: ConcentrationEquation
    let initialAConcentration: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        initialAConcentration - concentrationA.getConcentration(at: x)
    }

}



struct SecondOrderConcentration: ConcentrationEquation {

    let a0: CGFloat
    let rateConstant: CGFloat
    let order = 2

    init(a0: CGFloat, rateConstant: CGFloat) {
        assert(a0 != 0)
        self.a0 = a0
        self.rateConstant = rateConstant
    }

    init(c1: CGFloat, c2: CGFloat, time: CGFloat) {
        self.init(
            a0: c1,
            rateConstant: SecondOrderConcentration.getRate(c1: c1, c2: c2, time: time)
        )
    }

    init(c1: CGFloat, t1: CGFloat, rateConstant: CGFloat) {
        assert(c1 != 0)
        let invC1 = 1 / c1
        let denominator = invC1 - (rateConstant * t1)
        assert(denominator != 0)
        let a0 = 1 / denominator
        self.init(a0: a0, rateConstant: rateConstant)
    }

    var halfLife: CGFloat {
        1 / (rateConstant * a0)
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        assert(a0 != 0)
        let invA1 = 1 / a0
        let kt = rateConstant * time
        return 1 / (invA1 + kt)
    }

    func time(for concentration: CGFloat) -> CGFloat? {
        guard concentration > 0 else {
            return nil
        }
        return (1 / (concentration  * rateConstant)) - (1 / (a0 * rateConstant))
    }

    static func getRate(c1: CGFloat, c2: CGFloat, time: CGFloat) -> CGFloat {
        assert(c1 != 0)
        assert(c2 != 0)
        let invC1 = 1 / c1
        let invC2 = 1 / c2
        return (invC2 - invC1) / time
    }
}

struct InverseEquation: Equation {
    let underlying: ConcentrationEquation

    func getY(at x: CGFloat) -> CGFloat {
        let value = underlying.getConcentration(at: x)
        assert(value != 0)
        return 1 / value
    }
}
