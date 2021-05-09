//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct IntegrationStatements {
    private init() { }

    static let instructToChooseReaction: [TextLine] = [
        """
        The equilibrium constant *K* is actually deeply related to the rate constant *k*.
        """,
        "*Choose a reaction*."
    ]

    static let instructToSetWaterLevel: [TextLine] = [
        """
        Let's find out exactly how, so first of all, why don't you set the amount of water?
        """,
        "*Use the slider*."
    ]

    static let showPreviousEquations: [TextLine] = [
        "Remember these equations?",
        """
        These are rate law equations, one for the forward reaction, with a rate of rate_f_ and a \
        rate constant of k_f_. And one for the reverse reaction, with a rate of rate_r_ and a rate \
        constant of k_r_.
        """
    ]

    static func showRateConstantParts(
        reaction: AqueousReactionType
    ) -> [TextLine] {
        [
            """
            For the reaction you previously chose, the forward reaction has k_f_ of *\(reaction.forwardRateConstant.str(decimals: 2))* and \
            the reverse reaction has a k_r_ of *\(reaction.reverseRateConstant.str(decimals: 2))*. (As a side note, take into account that \
            for these equations to be true the reaction has to be elementary, which means that it's \
            only that reaction instead of a mechanism of various reactions).
            """
        ]
    }

    static let compareRates: [TextLine] = [
        """
        By comparing both rates, we can know which reaction is going faster, which in other words \
        would mean that it is the reaction being favored. On the other hand, the equilibrium \
        constant K can also be written as $*K=k_f_/k_r_*$, which is how these concepts relate to each other.
        """
    ]

    static func instructToAddReactant(selected: AqueousReactionType) -> [TextLine] {
        let moles = selected.coefficients.molesDisplay
        return [
            """
            The forward reaction is \(moles.reactantA) and \(moles.reactantB) transform into \
            \(moles.productC) and \(moles.productD).
            """,
            "Add the reactants to make it start.",
            "*Shake them into it*."
        ]
    }

    static let preForwardReaction: [TextLine] = [
        """
        Awesome! Now the forward reaction will take place. Notice how at this point the rate \
        of this reaction is higher than the reverse reaction, which means that the products are \
        being produced at a higher rate than the reactants. This will continue until the \
        equilibrium state is reached.
        """
    ]

    static let equilibriumReached: [TextLine] = [
        """
        Great! Concentrations of all species will be constant now that we have reached equilibrium. \
        Not because the reaction stopped, but because both forward and reverse reactions are going \
        at the same rate.
        """
    ]


    static let preReverseReaction: [TextLine] = [
        """
        Awesome! Now the reverse reaction will take place. Notice how at this point the rate \
        of this reaction is higher than the forward reaction, which means that the reactants are \
        being produced at a higher rate than the products. This will continue until the \
        equilibrium state is reached.
        """
    ]

    static let reverseEquilibrium: [TextLine] = [
        """
        *Awesome!* The equilibrium has been reestablished once again. Equilibrium is restored \
        when the rate of the forward reaction is equal to the rate of the reverse reaction, which \
        makes it seem like the whole reaction has stopped at that point.
        """
    ]
}
