//
// Reactions App
//
  

import CoreGraphics

class SecondOrderReactionViewModel: ZeroOrderReactionViewModel {

    override var concentrationEquationA: ConcentrationEquation {
        if let rate = rate {
            return SecondOrderReactionEquation(
                initialConcentration: initialConcentration,
                rate: rate
            )
        }
        return ConstantConcentration(value: initialConcentration)
    }

    override var concentrationEquationB: ConcentrationEquation {
        ConcentrationBEquation(
            concentrationA: concentrationEquationA,
            initialAConcentration: initialConcentration
        )
    }

    override var rate: CGFloat? {
        if let c2 = finalConcentration, let t2 = finalTime, initialConcentration != 0, c2 != 0 {
            let invC1 = 1 / initialConcentration
            let invC2 = 1 / c2
            return (invC2 - invC1) / t2
        }
        return nil
    }

    var inverseAEquation: ConcentrationEquation {
        InverseEquation(underlying: concentrationEquationA)
    }

}
