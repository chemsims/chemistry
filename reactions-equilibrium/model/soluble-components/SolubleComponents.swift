//
// Reactions App
//

import SwiftUI
import ReactionsCore

class SolubilityComponentsWrapper {

    var startTime: CGFloat {
        didSet {
            setComponents()
        }
    }
    var equilibriumTime: CGFloat {
        didSet {
            setComponents()
        }
    }

    init(equilibriumConstant: CGFloat, startTime: CGFloat, equilibriumTime: CGFloat) {
        self.equilibriumConstant = equilibriumConstant
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.components = SolubilityComponents(
            equilibriumConstant: equilibriumConstant,
            initialConcentration: SoluteValues.constant(0),
            startTime: startTime,
            equilibriumTime: equilibriumTime
        )
    }

    var equilibriumConstant: CGFloat {
        didSet {
            setComponents()
        }
    }

    private(set) var components: SolubilityComponents

    private func setComponents() {
        components = SolubilityComponents(
            equilibriumConstant: equilibriumConstant,
            initialConcentration: components.initialConcentration,
            startTime: startTime,
            equilibriumTime: equilibriumTime
        )
    }
}

class SolubilityComponents {

    let equilibriumConstant: CGFloat
    let initialConcentration: SoluteValues<CGFloat>
    let startTime: CGFloat
    let equilibriumTime: CGFloat

    init(
        equilibriumConstant: CGFloat,
        initialConcentration: SoluteValues<CGFloat>,
        startTime: CGFloat,
        equilibriumTime: CGFloat
    ) {
        self.equilibriumConstant = equilibriumConstant
        self.initialConcentration = initialConcentration
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
    }

    lazy var equation = SolubleReactionEquation(
        initialConcentration: initialConcentration,
        equilibriumConstant: equilibriumConstant,
        startTime: startTime,
        equilibriumTime: equilibriumTime
    )

    var quotient: SolubilityQuotientEquation {
        SolubilityQuotientEquation(concentration: equation.concentration)
    }
}

class SolubleReactionEquation {

    let concentration: SoluteValues<Equation>
    let initialConcentration: SoluteValues<CGFloat>
    let finalConcentration: SoluteValues<CGFloat>

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

        let concentration = initialConcentration.map(makeEquation)
        self.concentration = concentration
        self.initialConcentration = initialConcentration
        self.finalConcentration = concentration.map {
            $0.getY(at: equilibriumTime)
        }
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

struct SolubilityQuotientEquation: Equation {

    let concentration: SoluteValues<Equation>

    func getY(at x: CGFloat) -> CGFloat {
        let values = concentration.map { $0.getY(at: x) }
        return values.productA * values.productB
    }

}

struct SoluteValues<Value> {
    let productA: Value
    let productB: Value

    init(productA: Value, productB: Value) {
        self.productA = productA
        self.productB = productB
    }

    init(builder: (SoluteProductType) -> Value) {
        self.init(productA: builder(.A), productB: builder(.B))
    }

    static func constant(_ value: Value) -> SoluteValues {
        SoluteValues(builder: { _ in value })
    }

    func map<MappedValue>(_ f: (Value) -> MappedValue) -> SoluteValues<MappedValue> {
        SoluteValues<MappedValue>(productA: f(productA), productB: f(productB))
    }

    func value(for element: SoluteProductType) -> Value {
        switch element {
        case .A: return productA
        case .B: return productB
        }
    }

    var all: [Value] {
        [productA, productB]
    }
    
}

enum SoluteProductType: String {
    case A, B

    var color: Color {
        switch self {
        case .A: return Color.from(RGB.aqMoleculeA)
        case .B: return Color.from(RGB.aqMoleculeB)
        }
    }
}
