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
        Q is. The smaller the products, then the smaller Q will be.
        """
    ]

    static func instructToAddReactants(reaction: GaseousReactionType) -> [TextLine] {
        let moles = reaction.coefficients.molesDisplay.map { "\($0)*(g)*"}
        return [
            """
            The forward reaction is \(moles.reactantA) and \(moles.reactantB) transform \
            into \(moles.productC) and \(moles.productD).
            """,
            "Add reactants to make it start.",
            "*Use the pump.*"
        ]
    }

    static func reactionRunning(direction: ReactionDirection) -> [TextLine] {
        let reactant = direction == .forward ? "reactants" : "products"
        let product = direction == .forward ? "products" : "reactants"
        let lower = direction == .forward ? "lower" : "higher"
        return [
            """
            Watch how \(reactant) are being transformed into \(product). This will continue until \
            the equilibrium state is reached, meaning, *until Q=Kp, as the products to reactants \
            ratio is still \(lower) than it would be at equilibrium.*
            """
        ]
    }

    static func midReaction(direction: ReactionDirection) -> [TextLine] {
        let lower = direction == .forward ? "lower" : "higher"
        let sign = direction == .forward ? "<" : ">"
        return [
            """
            Reactants are being converted into products because Q is still \(lower) than Kp (*Q \(sign) Kp)*.
            """,
            "But you can see in the graphs we're almost there!"
        ]
    }

    static let forwardEquilibriumReached: [TextLine] = [
        """
        Great! Partial pressures of all species will be constant now that we have reached *equilibrium*
        """,
        """
        Notice that right now both the forward and reverse reactions are taking place at \
        the *same rate*.
        """
    ]

    static let instructToSetTime: [TextLine] = [
        """
        Try *dragging either of the charts* to scrub through the reaction time!
        """
    ]

    static let chatelier: [TextLine] = [
        """
        Another way to test the *Le Chatelier's principle* is by making a change on the pressure \
        of the system. The reaction will counteract by consuming more moles of gas, or producing \
        fewer moles of gas.
        """
    ]

    static func instructToChangeVolume(selected: GaseousReactionType) -> [TextLine] {
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

    static func explainReducedVolume(productsHaveHigherExponents: Bool) -> [TextLine] {
        let higherE = productsHaveHigherExponents ? "products" : "reactants"
        let increases = productsHaveHigherExponents ? "increases" : "decreases"
        return [
            """
            *Increased pressure*, decreases volume of the container, making the concentration of \
            the species higher. Since \(higherE) have higher exponents, Q \(increases). *The \
            system will consume moles to relieve pressure.*
            """
        ]
    }

    static func explainIncreasedVolume(productsHaveHigherExponents: Bool) -> [TextLine] {
        let higherE = productsHaveHigherExponents ? "products" : "reactants"
        let increase = productsHaveHigherExponents ? "decreases" : "increases"
        return [
            """
            *Decreased pressure*, increases volume of the container, making the concentration of \
            the species lower. Since \(higherE) have higher exponents, Q \(increase). *The \
            system will consume moles to relieve pressure.*
            """
        ]
    }

    static func prePressureReaction(
        selected: GaseousReactionType,
        pressureIncreased: Bool,
        direction: ReactionDirection
    ) -> [TextLine] {
        let moles = selected.coefficients.molesDisplay
        let raised = pressureIncreased ? "raised" : "reduced"
        let directionStr = direction == .forward ? "forward" : "reverse"

        var description: String
        if direction == .forward {
            description = "\(moles.reactantA) and \(moles.reactantB) transform into \(moles.productC) and \(moles.productD)"
        } else {
            description = "\(moles.productC) and \(moles.productD) transform into \(moles.reactantA) and \(moles.reactantB)"
        }

        return [
            """
            The \(directionStr) reaction is \(description). As you \(raised) the pressure, the \
            system will *favor* this reaction, to be able to reach equilibrium.
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

    static let preHeatReaction: [TextLine] = [
        """
        You raised the temperature! Now, the system needs to consume heat. The endothermic \
        reaction will take place now!
        """,
        """
        It is said that the *forward* reaction is being *favored*.
        """
    ]

    static let end: [TextLine] = [
        """
        There are some other reactions in which equilibrium has a big roll in.
        """,
        "*Let's learn about them now!*"
    ]

}

// MARK: Statements for user to adjust input
extension GaseousStatements {
    static let adjustVolume: [TextLine] = [
        "Try changing the pressure in the beaker more before moving on!",
        "*Use the slider to adjust the beaker pressure.*"
    ]

    static let addHeat: [TextLine] = [
        "Try increasing the temperature of the reaction before moving on!",
        "*Use the slider to increase the beaker temperature*."
    ]
}
