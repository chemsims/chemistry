//
// Reactions App
//

import Foundation
import ReactionsCore

struct ChemicalReactionStatements {
    private init() { }

    static let intro: [TextLine] = [
        """
        Chemical reactions are represented as an equation. *Click next and let's find out \
        more!*
        """
    ]

    static let explainEmpiricalFormula: [TextLine] = [
        """
        A reaction is separated in two parts: the left part where the reactants are, and the \
        right part where the products are. The compounds are represented as *empirical formulas*, \
        which indicates the atoms ratio within the molecule.
        """
    ]

    static let empiricalFormulaExample: [TextLine] = [
        """
        For example, this this *CH_4_* is methane, and the molecule of methane has 4 atoms of \
        *hydrogen (H)* and 1 atom of *carbon (C)*. *H_2_O* is water, and the molecule of water has \
        1 atom of *oxygen (O)* and 2 atoms of *hydrogen (H).*
        """
    ]

    static let explainStoichiometricCoeffs: [TextLine] = [
        """
        But this is not the only numbers that are involved in the equation. *Stoichiometric \
        coefficients* are values that are written on the left of the compound to determine how \
        many molecules there are.
        """
    ]

    static let explainBalancedReaction: [TextLine] = [
        """
        These values allow the reaction to be *balanced*. All chemical reactions, as the equation \
        they are, have to be *balanced*, meaning that there has to be the *same amount of atoms on \
        each side of the equation.*
        """
    ]

    static let instructToDragMoleculeForFirstReaction: [TextLine] = [
        """
        Let's learn how to do that right now with this equation. At the moment, there aren't any \
        compounds on either side. *Drag the molecules to the corresponding side to balance the \
        equation.*
        """
    ]

    static let instructToChooseReactionPostBalancing: [TextLine] = [
        equationIsBalanced,
        "*Choose another one.*"
    ]

    static let instructToDragMoleculesForSubsequentReaction: [TextLine] = [
        "Let's balance this reaction now.",
        "*Drag the molecules to the corresponding side to balance the equation.*"
    ]

    static let finalStatement: [TextLine] = [
        equationIsBalanced,
        "*Perfect! Now you know how to balance equations.*"
    ]

    private static let equationIsBalanced: TextLine = """
    *The equation is balanced!* This is what the real equation for this reaction looks \
    like. There are the same number of atoms on both sides of the equation.
    """
}
