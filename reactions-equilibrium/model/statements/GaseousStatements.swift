//
// Reactions App
//


import ReactionsCore

struct GaseousStatements {
    static let intro: [TextLine] = [
        """
        We already saw how the concentration can affect equilibrium. But there are other ways to \
        accomplish that.
        """,
        "This time, we'll check a gaseous reaction.",
        "*Choose a reaction.*"
    ]

    static let explainQEquation: [TextLine] = [
        """
        Does this *Q equation* look familiar? That's right! It's the same one, the only difference \
        is that, as a matter of convenience, in the gaseous reaction, *partial pressures* of \
        compounds are used instead of the concentrations.
        """
    ]

    static let explainK: [TextLine] = [
        """
        Similarly, in this case we talk about *Kp* (p stands for pressure). Everything \
        else works the same, the larger the partial pressures of the products, the larger \
        is Q. The smaller the products, then the smaller Q will be.
        """
    ]

    static func instructToAddReactants(reaction: AqueousReactionType) -> [TextLine] {
        let moles = reaction.coefficients.molesDisplay.map { "\($0)*(g)*"}
        return [
            """
            The forward reaction is \(moles.reactantA) and \(moles.reactantB) transform \
            into \(moles.productC) and \(moles.productD).
            """,
            "Add reactants to make it start.",
            "*Use the pump*"
        ]
    }

    static let forwardReactionIsRunning: [TextLine] = [
        """
        Watch how reactants are being transformed into products. This will continue until \
        the equilibrium state is reached, meaning, *until Q=Kp, as the products to reactants \
        ratio is still lower than it would be at equilibrium.*
        """
    ]

    static let midForwardReaction: [TextLine] = [
        """
        Reactants are being converted into products because Q is still lower than Kp (*Q < Kp)*.
        """,
        "But you can see in the graphs we're almost there!"
    ]

    static let forwardEquilibriumReached: [TextLine] = [
        """
        Great! Partial pressures of all species will be constant now that we have reached *equilibrium*
        """,
        """
        Notice that right now both the forward and reverse reactions are taking place at \
        the *same rate*.
        """
    ]

    static let chatelier: [TextLine] = [
        """
        Another way to test the *Le Chatelier's principle* is by making a change on the pressure \
        of the system. The reaction will counteract by consuming more moles of gas, or producing \
        fewer moles of gas.
        """
    ]

    static func instructToChangeVolume(selected: AqueousReactionType) -> [TextLine] {
        let coeffs = selected.coefficients
        let reactantSum = coeffs.reactantA + coeffs.reactantB
        let productSum = coeffs.productC + coeffs.productD
        return [
            """
            Change the pressure using the piston of the tank. There are \(reactantSum) in the \
            reactants' side, and \(productSum) moles of gas in the products' side.
            """,
            "*Use the slider and see what happens!*"
        ]
    }

    static let explainReducedVolume: [TextLine] = [
        """
        *Decreasing volume of container *increases pressure*, making the concentrations of \
        the species higher. Since products have higher exponents, Q increases. *The system will \
        consume moles to relieve pressure*.
        """
    ]

    static func describeReverseReaction(selected: AqueousReactionType) -> [TextLine] {
        let moles = selected.coefficients.molesDisplay
        return [
            """
            The reverse reaction is \(moles.productD) and \(moles.productC) transform into \
            \(moles.reactantA) and \(moles.reactantB). As you raised the pressure, the system \
            will *favor* this reaction, to be able to reach equilibrium.
            """
        ]
    }

    static var reverseReactionRunning: [TextLine] {
        [
            """
            Watch how products are being transformed into reactants. This will continue the \
            equilibrium state is reached, meaning, *until Q=K, as the products to reactants \
            ratio is still higher that it would be at equilibrium.*
            """
        ]
    }

    static var midReverseReaction: [TextLine] {
        [
            """
            Products are being converted into reactants because Q is still higher than K \
            *(Q > Kp).*
            """,
            "But you can see in the graphs we're almost there!"
        ]
    }

    static let endOfPressureReaction: [TextLine] = [
        """
        That's how variations in pressure on the system involved in a reverse reaction in \
        chemical equilibrium can disturb it.
        """,
        "*Let's see how else equilibrium can be disturbed.*"
    ]

    static let explainChangeOfTemp: [TextLine] = [
        """
        For reversible reactions when one reaction is endothermic, the other one is \
        the opposite, exothermic.
        """,
        """
        Changing temperature is another way that *equilibrium* can be disturbed.
        """
    ]

    static let chatelier2: [TextLine] = [
        """
        Another way to test *Le Chatelier's principle* is by changing the temperature. \
        Raising the temperature makes the system try to consume heat. In which case, \
        the reaction favored will be the endothermic one.
        """
    ]

    static let instructToSetTemp: [TextLine] = [
        """
        In this reaction, the forward reaction is exothermic, while the reverse \
        is exothermic.
        """,
        "Change temperature of the system to see what happens!",
        "*Use the flame slider.*"
    ]

}
