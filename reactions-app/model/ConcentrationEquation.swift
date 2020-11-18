//
// Reactions App
//
  

import CoreGraphics
import Darwin

protocol ConcentrationEquation {
    func getConcentration(at time: CGFloat) -> CGFloat
}


/// Linear concentration which is c1 at t1, and c2 at t2.
struct LinearConcentration: ConcentrationEquation {

    let t1: CGFloat
    let c1: CGFloat
    let t2: CGFloat
    let c2: CGFloat

    func getConcentration(at time: CGFloat) -> CGFloat {
        (m * time) + c
    }

    private var m: CGFloat {
        (c2 - c1) / (t2 - t1)
    }

    private var c: CGFloat {
        c1 - (m * t1)
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

struct SecondOrderReactionEquation: ConcentrationEquation {

    let initialConcentration: CGFloat
    let rate: CGFloat

    init(initialConcentration: CGFloat, rate: CGFloat) {
        self.initialConcentration = initialConcentration
        self.rate = rate
    }

    init(c1: CGFloat, c2: CGFloat, time: CGFloat) {
        self.init(
            initialConcentration: c1,
            rate: SecondOrderReactionEquation.getRate(c1: c1, c2: c2, time: time)
        )
    }

    func getConcentration(at time: CGFloat) -> CGFloat {
        assert(initialConcentration != 0)
        let invA1 = 1 / initialConcentration
        let kt = rate * time
        return 1 / (invA1 + kt)
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
