//
// Reactions App
//

import ReactionsCore

struct AqueousStatements {
    static let intro: [TextLine] = [
        """
        Some reactions don't go to completion, but as they are *reversible*, they move towards \
        *equilibrium*. Reversible means there's a forward reaction that makes the products, \
        and a reverse that makes reactants. *Choose a reaction*.
        """
    ]

    static let explainEquilibrium: [TextLine] = [
        """
        *Chemical equilibrium* means that both the reactants and the products are being produced \
        at the same rate. Both forward and reverse reactions have the *same rate* at this state of \
        equilibrium.
        """
    ]

    static let explainQuotient1: [TextLine] = [
        """
        When this happens, concentrations of all species involved remain at a constant value that \
        represents the *ratio [product]/[reactant]*. The equation of *Q, the quotient* and the \
        *equilibrium constant K* form part of this concept.
        """
    ]

    static let explainQuotient2: [TextLine] = [
        """
        *Q, the reaction quotient*, is the product concentration divided by the reactant \
        concentration. Where each of the product concentrations are raised to their \
        stoichiometric coefficients and then multiplied within the numerator.
        """
    ]

    static let explainQuotient3: [TextLine] = [
        """
        Then, the same is done within the denominator for reactants. If the reaction is currently \
        in equilibrium, the value of *Q and K* will be the same.
        """
    ]

    static let explainQuotient4: [TextLine] = [
        """
        In essence then, Q is a value that represents the *relation between the products and the \
        the reactants at a given time*. The larger the products, then the larger Q. The smaller \
        the products, then the smaller Q will be.
        """
    ]

    static let explainQuotient5: [TextLine] = [
        """
        *Q is a ratio*. When the numerator is large, Q is bigger. When the denominator is large, Q \
        is smaller. But in this case, the numerator is the product, while the denominator is the \
        reactant.
        """
    ]

    static let explainK: [TextLine] = [
        """
        In this equation, when using concentrations, *K* can often be referred to as *K_c_*, where \
        *c* stands for concentration.
        """,
        """
        There are also other ways to refer to K in other situations we will touch upon later.
        """
    ]

    static let instructToSetWaterLevel: [TextLine] = [
        "You chose a reversible reaction.",
        """
        This time, we'll check an aqueous reaction. So, first of all, why don't you set the amount \
        of water?
        """,
        "*Use the slider*."
    ]

    static func instructToAddReactant(selected: AqueousReactionType) -> [TextLine] {
        let moles = selected.coefficients.molesDisplay
        return [
            """
            The forward reaction is \(moles.reactantA) and \(moles.reactantB) transform into \
            \(moles.productC)and \(moles.productD).
            """,
            "Add reactant to make it start.",
            "*Shake them into it*."
        ]
    }

    static let preAnimation: [TextLine] = [
        """
            *Awesome!* Now the forward reaction will take place. It is said that forward reaction \
            is being *favored*, this is because in order for the reaction to reach the equilibrium \
            state, products must be produced.
            """
    ]

    static let runAnimation: [TextLine] = [
        """
        What how reactants are being transformed into products. This will continue until the \
        equilibrium state is reached
        """
    ]

    static let midAnimation: [TextLine] = [
        """
        Reactants are being converted into products because Q is still lower than K *(Q < K)*.
        """,
        """
        But you can see in the graphs we're almost there!
        """
    ]

    static let reachedEquilibrium: [TextLine] = [
        """
        Great! Concentrations of all species will be constant now that we have reached *equilibrium*.
        """,
        """
        Notice that right now both the forward and reverse reactions are taking place at the *same rate*.
        """
    ]

    static let instructToChangeCurrentTime: [TextLine] = [
        "Try to *drag* either of the charts to *scrub through the reaction*."
    ]

    static let leChatelier: [TextLine] = [
        """
        Le Chatelier made an observation that within chemical reactions, any variation done to a \
        system in equilibrium, would make the system counteract.
        """,
        """
        This is called the *Le Chatelier's principle*.
        """
    ]

    static let introToReverse: [TextLine] = [
        "Let's see how that applies in this reaction.",
        """
        Equilibrium is fine and all, but let's disturb the system by adding any product \
        *(C or D)*. This will increase their concentration.
        """
    ]

    static func instructToAddProduct(selected: AqueousReactionType) -> [TextLine] {
        let moles = selected.coefficients.molesDisplay
        return [
            """
            The reverse reaction is \(moles.productD) and \(moles.productC) transform into \
            \(moles.reactantA) and \(moles.reactantB).
            """,
            "*Shake it into it.*"
        ]
    }

    static let preReverseReaction: [TextLine] = [
            """
            *Awesome!* Now the reverse reaction will take place. It is said that the reverse \
            reaction is being *favored*, this is because in order for the reaction to reach the \
            equilibrium state, reactants must be produced.
            """
        ]

    static let reverseReactionStarted: [TextLine] = [
        """
        Watch how products are being transformed into reactants. This will continue until the \
        equilibrium state is reached, meaning, *until $Q=K$, as the products to reactants ratio \
        is still higher than it would be at equilibrium*.
        """
    ]

    static let midReverseReaction: [TextLine] = [
        """
        Products are being converted to reactants, because Q is still higher than K *(Q > K)*.
        """,
        "But you can see in the graphs we're almost there!"
    ]


    static let reverseEquilibriumReached: [TextLine] = [
        """
        Great! Concentrations of all species will be constant now that we've reached *equilibrium*.
        """,
        """
        Notice that this doesn't mean necessarily that their concentrations are equal. In fact, \
        they are not equal, just *constant*.
        """
    ]


    static let endStatement: [TextLine] = [
        """
        That's how variations in concentration of a species involved in a reversible reaction in \
        *chemical equilibrium* can disturb it.
        """,
        "*Let's see how else equilibrium can be disturbed.*"
    ]

    static let addMoreProduct: [TextLine] = [
        "Try to add some more of C or D before continuing!",
        "*Shake them into the beaker*."
    ]
}

// MARK: Statements to instruct to add more A/B molecules
extension AqueousStatements {
    static func addMore(
        reactant: AqueousMoleculeReactant,
        count: Int,
        minConcentration: String
    ) -> [TextLine] {
        switch count {
        case 1: return addMore1(reactant.rawValue)
        case 2: return addMore2(reactant.rawValue)
        default: return addMore3(reactant.rawValue, minConcentration: minConcentration)
        }
    }

    private static func addMore1(_ name: String) -> [TextLine] {
        [
            "Add a bit more of *\(name)* to the beaker.",
            "*Shake \(name) into the beaker*."
        ]
    }

    private static func addMore2(_ name: String) -> [TextLine] {
        [
            "Try adding a bit more of *\(name)* to the beaker. There isn't enough yet!"
        ]
    }

    private static func addMore3(_ name: String, minConcentration: String) -> [TextLine] {
        [
            """
            Add more of *\(name)* to the beaker. Make sure it's concentration is at least \(minConcentration).
            """,
            "Shake *\(name)* into the beaker."
        ]
    }
}

extension BalancedReactionCoefficients {
    var molesDisplay: MoleculeValue<String> {
        MoleculeValue<String>(builder: { molecule in
            let coeff = value(for: molecule)
            let suffix = coeff > 1 ? "s" : ""
            return "*\(coeff)* moles\(suffix) of *\(molecule.rawValue)*"
        })
    }
}
