//
// Reactions App
//
  

import SwiftUI

class FirstOrderReactionViewModel: ZeroOrderReactionViewModel {

    override var concentrationEquationA: ConcentrationEquation {
        if let rate = rate {
            return FirstOrderConcentration(
                a0: initialConcentration,
                rateConstant: rate
            )
        }
        return ConstantConcentration(value: initialConcentration)
    }

    var logAEquation: Equation {
        LogEquation(underlying: concentrationEquationA)
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
        if let rate = rate {
            return log(2) / rate
        }
        return nil
    }
}
