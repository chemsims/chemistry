//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct SolubleReactionEquation {

    let concentration: SoluteValues<Equation>
    let initialConcentration: SoluteValues<CGFloat>
    let finalConcentration: SoluteValues<CGFloat>

    init(
        initialConcentration: SoluteValues<CGFloat>,
        equilibriumConstant: CGFloat,
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        previousEquation: SolubleReactionEquation?
    ) {
        let unitChange = Self.getUnitChange(initialConcentration: initialConcentration, equilibriumConstant: equilibriumConstant) ?? 0
        func makeEquation(_ initC: CGFloat) -> Equation {
            EquilibriumReactionEquation(t1: startTime, c1: initC, t2: equilibriumTime, c2: initC + unitChange)
        }

        let concentration = initialConcentration.map(makeEquation)
        let combined = previousEquation.map { previous in
            SoluteValues(builder: { element in
                SwitchingEquation(
                    thresholdX: startTime,
                    underlyingLeft: previous.concentration.value(for: element),
                    underlyingRight: concentration.value(for: element)
                )
            })
        } ?? concentration

        self.concentration = combined
        self.initialConcentration = initialConcentration
        self.finalConcentration = combined.map {
            $0.getValue(at: equilibriumTime)
        }
    }

    // Unit change for forward reaction
    // TODO - change this to use quadratic equation solver
    private static func getUnitChange(
        initialConcentration: SoluteValues<CGFloat>,
        equilibriumConstant: CGFloat
    ) -> CGFloat? {
        let a0 = initialConcentration.productA
        let b0 = initialConcentration.productB
        let bTerm = a0 + b0
        let cTerm = (a0 * b0) - equilibriumConstant
        let termToRoot = pow(bTerm, 2) - (4 * cTerm)

        guard termToRoot > 0 else {
            return nil
        }

        let rootTerm = sqrt(termToRoot)

        // NB, the solution is always +ve rootTerm, as using -ve would always produce a negative value
        // and we want a positive unit change
        return (-bTerm + rootTerm) / 2
    }

}
