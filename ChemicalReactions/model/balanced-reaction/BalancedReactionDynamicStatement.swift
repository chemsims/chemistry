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
    ) -> [TextLine] {
        if reactionBalancer.isBalanced {
            return statementForBalancedReaction()
        }
        if reactionBalancer.isMultipleOfBalanced {
            return statementForMultipleOfBalanced()
        }

        return statementForUnbalancedReaction(
            afterAdding: molecule,
            reactionBalancer: reactionBalancer
        )
    }

    private static func statementForBalancedReaction() -> [TextLine] {
        [
            """
            *The equation is balanced!* This is what the real equation for this reaction looks \
            like. There are the same number of atoms on both sides of the equation.
            """,
            "*Choose another one.*"
        ]
    }

    private static func statementForMultipleOfBalanced() -> [TextLine] {
        [
            """
            There are now the same number of atoms on both sides of the equation, but each \
            coefficient could be smaller. *Try to remove molecules*.
            """
        ]
    }

    private static func statementForUnbalancedReaction(
        afterAdding molecule: BalancedReaction.Molecule,
        reactionBalancer: ReactionBalancer
    ) -> [TextLine] {
        let symbol = molecule.textLine
        let coeff = reactionBalancer.count(of: molecule)

        let moleculeString = coeff == 1 ? "molecule" : "molecules"
        let moleculeDisplay = "\(coeff) \(moleculeString) of \(symbol)"
        let atomDisplays = molecule.atoms.map { $0.displayCount(coeff: coeff) }

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

private extension BalancedReaction.AtomCount {
    func displayCount(coeff: Int) -> String {
        let resultingCount = coeff * count
        let atomString = resultingCount == 1 ? "atom" : "atoms"
        return "\(resultingCount) \(atomString) of \(atom.name)"
    }
}
