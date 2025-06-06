//
// Reactions App
//

import Foundation
import ReactionsCore

struct BalancedReactionDynamicStatement {

    private init() { }

    static func getStatement(
        afterAdjusting molecule: BalancedReaction.Molecule,
        reactionBalancer: ReactionBalancer
    ) -> [TextLine]? {
        if reactionBalancer.isBalanced {
            return nil
        }
        if reactionBalancer.isMultipleOfBalanced {
            return statementForMultipleOfBalanced
        }

        return statementForUnbalancedReaction(
            afterAdding: molecule,
            reactionBalancer: reactionBalancer
        )
    }


    private static let statementForMultipleOfBalanced: [TextLine] = [
        """
        There are now the same number of atoms on both sides of the equation, but each \
        coefficient could be smaller. *Try to remove molecules*.
        """
    ]


    private static func statementForUnbalancedReaction(
        afterAdding molecule: BalancedReaction.Molecule,
        reactionBalancer: ReactionBalancer
    ) -> [TextLine] {
        let symbol = molecule.textLine
        let coeff = reactionBalancer.count(of: molecule)

        let moleculeString = coeff == 1 ? "molecule" : "molecules"
        let moleculeDisplay = "\(coeff) \(moleculeString) of \(symbol)"
        let atomDisplays = molecule.atoms.map {
            $0.effectiveDisplayCount(moleculeCoefficient: coeff)
        }

        let displayComponents = [moleculeDisplay] + atomDisplays

        let concatenatedComponents = StringUtil.combineStringsWithFinalAnd(displayComponents)

        let areOrIs = coeff == 1 ? "is" : "are"

        return [
            """
        Equation is unbalanced. The stoichiometric coefficient for \(symbol) is \(coeff), which \
        means there \(areOrIs) \(concatenatedComponents). *Keep dragging the molecules to \
        balance the reaction.*
        """
        ]
    }
}
