//
// Reactions App
//
  

import SwiftUI

class FirstOrderReactionViewModel: ZeroOrderReactionViewModel {

    override var concentrationEquationA: ConcentrationEquation? {
        rate.map {
            FirstOrderConcentration(
               a0: initialConcentration,
               rateConstant: $0
           )
        }
    }

    var logAEquation: Equation? {
        concentrationEquationA.map { LogEquation(underlying: $0) }
    }

    override var rate: CGFloat? {
        if let finalConcentration = finalConcentration, let finalTime = finalTime, initialConcentration != 0, finalTime != 0 {
            let roundedC1 = initialConcentration.rounded(decimals: 2)
            let roundedC2 = finalConcentration.rounded(decimals: 2)
            let roundedTime = finalTime.rounded(decimals: 2)
            return FirstOrderConcentration.getRate(
                c1: roundedC1,
                c2: roundedC2,
                time: roundedTime
            )
        }
        return nil
    }

    override var halfTime: CGFloat? {
        rate.map { log(2) / $0 }
    }
}
