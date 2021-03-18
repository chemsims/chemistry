//
// Reactions App
//

import Foundation
import ReactionsCore
import CoreGraphics

typealias BalancedReactionCoefficients = MoleculeValue<Int>
typealias BalancedReactionInitialConcentrations = MoleculeValue<CGFloat>

struct BalancedReactionEquations {

    let reactions: MoleculeValue<Equation>
    let coefficients: BalancedReactionCoefficients
    let convergenceTime: CGFloat

    var reactantA: Equation { reactions.reactantA }
    var reactantB: Equation { reactions.reactantB }
    var productC: Equation { reactions.productC }
    var productD: Equation { reactions.productD }

    let initialConcentrations: MoleculeValue<CGFloat>

    let direction: ReactionDirection

    let equilibriumConstant: CGFloat


    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        a0: CGFloat,
        b0: CGFloat,
        convergenceTime: CGFloat
    ) {
        let initialConcentrations = MoleculeValue(reactantA: a0, reactantB: b0, productC: 0, productD: 0)
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: equilibriumConstant,
            coeffs: coefficients,
            initialConcentrations: initialConcentrations,
            isForward: true
        )
        self.initialConcentrations = initialConcentrations
        self.reactions = BalancedEquationBuilder.getEquations(
            terms: MoleculeValue(
                reactantA: MoleculeTerms(initC: a0, coeff: coefficients.reactantA, increases: false),
                reactantB: MoleculeTerms(initC: b0, coeff: coefficients.reactantB, increases: false),
                productC: MoleculeTerms(initC: 0, coeff: coefficients.productC, increases: true),
                productD: MoleculeTerms(initC: 0, coeff: coefficients.productD, increases: true)
            ),
            startTime: 0,
            convergenceTime: convergenceTime,
            unitChange: unitChange ?? 0
        )

        self.coefficients = coefficients
        self.convergenceTime = convergenceTime
        self.equilibriumConstant = equilibriumConstant
        self.direction = .forward
    }

    /// Creates a new reverse reaction
    init(
        forwardReaction: BalancedReactionEquations,
        reverseInput: ReverseReactionInput
    ) {
        let initA = forwardReaction.reactantA.getY(at: forwardReaction.convergenceTime)
        let initB = forwardReaction.reactantB.getY(at: forwardReaction.convergenceTime)

        let initialConcentrations = MoleculeValue(
            reactantA: initA,
            reactantB: initB,
            productC: reverseInput.c0,
            productD: reverseInput.d0
        )
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: forwardReaction.equilibriumConstant,
            coeffs: forwardReaction.coefficients,
            initialConcentrations: initialConcentrations,
            isForward: false
        )

        let reverseReaction = BalancedEquationBuilder.getEquations(
            terms: MoleculeValue(
                reactantA: MoleculeTerms(initC: initA, coeff: forwardReaction.coefficients.reactantA, increases: true),
                reactantB: MoleculeTerms(initC: initB, coeff: forwardReaction.coefficients.reactantB, increases: true),
                productC: MoleculeTerms(initC: reverseInput.c0, coeff: forwardReaction.coefficients.productC, increases: false),
                productD: MoleculeTerms(initC: reverseInput.d0, coeff: forwardReaction.coefficients.productD, increases: false)
            ),
            startTime: reverseInput.startTime,
            convergenceTime: reverseInput.convergenceTime,
            unitChange: unitChange ?? 0
        )

        func getEquation(lhs: Equation, rhs: Equation) -> Equation {
            SwitchingEquation(
                thresholdX: reverseInput.startTime,
                underlyingLeft: lhs,
                underlyingRight: rhs
            )
        }

        self.reactions = forwardReaction.reactions.combine(
            with: reverseReaction,
            using: { getEquation(lhs: $0, rhs: $1) }
        )

        self.initialConcentrations = initialConcentrations
        self.equilibriumConstant = forwardReaction.equilibriumConstant
        self.coefficients = forwardReaction.coefficients
        self.direction = .reverse

        self.convergenceTime = reverseInput.convergenceTime
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

struct ReverseReactionInput {
    let c0: CGFloat
    let d0: CGFloat
    let startTime: CGFloat
    let convergenceTime: CGFloat
}
