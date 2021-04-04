//
// Reactions App
//

import CoreGraphics
import ReactionsCore


class SolubleReactionEquation {

    let concentration: SoluteValues<Equation>

    init(
        initialConcentration: SoluteValues<CGFloat>,
        equilibriumConstant: CGFloat,
        startTime: CGFloat,
        equilibriumTime: CGFloat
    ) {
        let unitChange = Self.getUnitChange(initialConcentration: initialConcentration, equilibriumConstant: equilibriumConstant) ?? 0
        func makeEquation(_ initC: CGFloat) -> Equation {
            EquilibriumReactionEquation(t1: startTime, c1: initC, t2: equilibriumTime, c2: initC + unitChange)
        }

        self.concentration = initialConcentration.map(makeEquation)
    }

    // Unit change for forward reaction
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

struct SoluteValues<Value> {
    let productA: Value
    let productB: Value

    init(productA: Value, productB: Value) {
        self.productA = productA
        self.productB = productB
    }

    func map<MappedValue>(_ f: (Value) -> MappedValue) -> SoluteValues<MappedValue> {
        SoluteValues<MappedValue>(productA: f(productA), productB: f(productB))
    }
}
