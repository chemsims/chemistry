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
        return ConstantConcentration(value: 0.5)
    }

    var logAEquation: ConcentrationEquation {
        LogEquation(underlying: concentrationEquationA)
    }

    override var rate: CGFloat? {
        if let finalConcentration = finalConcentration, let finalTime = finalTime, initialConcentration != 0, finalTime != 0 {
            let logC = log(finalConcentration / initialConcentration)
            return -1 * (logC / finalTime)
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
