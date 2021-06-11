//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct BufferSharedComponents {
    private init() { }

    static func pHEquation(
        pKa: CGFloat,
        substanceConcentration: Equation,
        secondaryConcentration: Equation
    ) -> Equation {
        pKa + Log10Equation(underlying: secondaryConcentration / substanceConcentration)
    }

    struct SubstanceFractionFromPh: Equation {
        let pK: CGFloat

        func getY(at x: CGFloat) -> CGFloat {
            let denom = 1 + pow(10, x - pK)
            return denom == 0 ? 0 : 1 / denom
        }
    }

    struct SecondaryIonFractionFromPh: Equation {
        let pK: CGFloat

        func getY(at x: CGFloat) -> CGFloat {
            let powerTerm = pow(10, x - pK)
            let denom = powerTerm + 1
            return denom == 0 ? 0 : powerTerm / denom
        }
    }
}
