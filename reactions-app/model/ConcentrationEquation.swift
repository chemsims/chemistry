//
// Reactions App
//
  

import Foundation

protocol ConcentrationEquation {
    func getConcentration(at time: Double) -> Double
}


/// Linear concentration which is c1 at t1, and c2 at t2.
struct LinearConcentration: ConcentrationEquation {

    let t1: Double
    let c1: Double
    let t2: Double
    let c2: Double


    func getConcentration(at time: Double) -> Double {
        (m * time) + c
    }

    private var m: Double {
        (c2 - c1) / (t2 - t1)
    }

    private var c: Double {
        c1 - (m * t1)
    }


}
