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

    var inverse: LinearConcentration {
        LinearConcentration(t1: t1, c1: c2, t2: t2, c2: c1)
    }

}
