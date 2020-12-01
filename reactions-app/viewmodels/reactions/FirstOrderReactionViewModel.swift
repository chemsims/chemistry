//
// Reactions App
//
  

import SwiftUI

class FirstOrderReactionViewModel: ZeroOrderReactionViewModel {

    override var concentrationEquationA: ConcentrationEquation {
        if let rate = rate {
            return FirstOrderConcentration(
                initialConcentration: initialConcentration,
                rate: rate
            )
        }
        return ConstantConcentration(value: initialConcentration)
    }

    var logAEquation: ConcentrationEquation {
        LogEquation(underlying: concentrationEquationA)
    }

    override var rate: CGFloat? {
        if let finalConcentration = finalConcentration, let finalTime = finalTime, initialConcentration != 0, finalTime != 0 {
            return FirstOrderConcentration.getRate(
                c1: initialConcentration,
                c2: finalConcentration,
                time: finalTime
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
