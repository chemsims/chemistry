//
// Reactions App
//

import Foundation
import ReactionsCore
import CoreGraphics

typealias BalancedReactionCoefficients = MoleculeValue<Int>
typealias BalancedReactionInitialConcentrations = MoleculeValue<CGFloat>

struct BalancedReactionEquation {

    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let concentration: MoleculeValue<Equation>
    let direction: ReactionDirection
    let coefficients: MoleculeValue<Int>

    let initialConcentrations: MoleculeValue<CGFloat>
    let equilibriumConstant: CGFloat

    var isForward: Bool {
        direction == .forward
    }

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        initialConcentrations: MoleculeValue<CGFloat>,
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        previous: BalancedReactionEquation?
    ) {
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.equilibriumConstant = equilibriumConstant
        self.initialConcentrations = initialConcentrations
        self.coefficients = coefficients

        let direction = Self.getDirection(
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            initialConcentrations: initialConcentrations
        )
        self.direction = direction
        let isForward = direction == .forward

        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: equilibriumConstant,
            coeffs: coefficients,
            initialConcentrations: initialConcentrations,
            isForward: direction == .forward
        )

        func getTerm(_ molecule: AqueousMolecule) -> MoleculeTerms {
            MoleculeTerms(
                initC: initialConcentrations.value(for: molecule),
                coeff: coefficients.value(for: molecule),
                increases: molecule.isReactant ? !isForward : isForward
            )
        }

        let equations = BalancedEquationBuilder.getEquations(
            terms: MoleculeValue(builder: getTerm),
            startTime: startTime,
            convergenceTime: equilibriumTime,
            unitChange: unitChange ?? 0
        )

        let combinedWithPrevious: MoleculeValue<Equation>? = previous.map { previous in
            previous.concentration.combine(
                with: equations,
                using: {
                    SwitchingEquation(
                        thresholdX: startTime,
                        underlyingLeft: $0,
                        underlyingRight: $1
                    )
                }
            )
        }

        let concentration = combinedWithPrevious ?? equations
        self.concentration = concentration
        self.equilibriumConcentrations = concentration.map {
            $0.getY(at: equilibriumTime)
        }
    }

    let equilibriumConcentrations: MoleculeValue<CGFloat>

    private static func getDirection(
        coefficients: MoleculeValue<Int>,
        equilibriumConstant: CGFloat,
        initialConcentrations: MoleculeValue<CGFloat>
    ) -> ReactionDirection {
        let initialQuotient = ReactionQuotientEquation(
            coefficients: coefficients,
            equations: initialConcentrations.map {
                ConstantEquation(value: $0)
            }
        ).getY(at: 0)
        return initialQuotient < equilibriumConstant ? .forward : .reverse
    }
}


struct BalancedEquationBuilder {

    static func getEquations(
        terms: MoleculeValue<MoleculeTerms>,
        startTime: CGFloat,
        convergenceTime: CGFloat,
        unitChange: CGFloat
    ) -> MoleculeValue<Equation> {
        
        func getEquation(for terms: MoleculeTerms) -> Equation {
            elementEquation(
                terms: terms,
                unitChange: unitChange,
                startTime: startTime,
                convergenceTime: convergenceTime
            )
        }

        return terms.map(getEquation)
    }

    private static func elementEquation(
        terms: MoleculeTerms,
        unitChange: CGFloat,
        startTime: CGFloat,
        convergenceTime: CGFloat
    ) -> Equation {
        let unitChangeDirection = terms.increases ? unitChange : -unitChange
        let finalConcentration = terms.initC + (CGFloat(terms.coeff) * unitChangeDirection)
        return EquilibriumReactionEquation(
            t1: startTime,
            c1: terms.initC,
            t2: convergenceTime,
            c2: finalConcentration
        )
    }
}

struct MoleculeTerms {
    let initC: CGFloat
    let coeff: Int
    let increases: Bool

    var denomTerm: CGFloat {
        CGFloat(increases ? coeff : -coeff)
    }
}
