//
// Reactions App
//
  

import CoreGraphics

class SecondOrderReactionViewModel: ZeroOrderReactionViewModel {

    override var concentrationEquationA: ConcentrationEquation {
        if let rate = rate {
            return SecondOrderConcentration(
                a0: initialConcentration,
                rateConstant: rate
            )
        }
        return ConstantConcentration(value: initialConcentration)
    }

    override var concentrationEquationB: Equation {
        ConcentrationBEquation(
            concentrationA: concentrationEquationA,
            initialAConcentration: initialConcentration
        )
    }

    override var rate: CGFloat? {
        if let c2 = finalConcentration, let t2 = finalTime, initialConcentration != 0, c2 != 0 {
            let roundedC2 = c2.rounded(decimals: 2)
            let roundedC1 = initialConcentration.rounded(decimals: 2)
            let roundedT = t2.rounded(decimals: 2)
            return SecondOrderConcentration.getRate(c1: roundedC1, c2: roundedC2, time: roundedT)
        }
        return nil
    }

    override var halfTime: CGFloat? {
        if let rate = rate {
            return 1 / (rate * initialConcentration.rounded(decimals: 2))
        }
        return nil
    }

    var inverseAEquation: Equation {
        InverseEquation(underlying: concentrationEquationA)
    }

}
