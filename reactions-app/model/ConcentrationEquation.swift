//
// Reactions App
//
  

import CoreGraphics

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

struct TestEQ: ConcentrationEquation {
    func getConcentration(at time: CGFloat) -> CGFloat {
        if (time < 10) {
            return 0
        }
        return 1
    }


}

struct ConstantConcentration: ConcentrationEquation {
    let value: CGFloat

    func getConcentration(at time: CGFloat) -> CGFloat {
        return value
    }
}
