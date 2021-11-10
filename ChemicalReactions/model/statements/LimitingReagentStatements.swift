//
// Reactions App
//

import ReactionsCore

struct LimitingReagentStatements {

    static let filingCabinet: [TextLine] = ["Check out the reaction you ran earlier!"]

    static let intro: [TextLine] = [
        """
        Now that we know how reactions have their own equation, we should learn how to use \
        them to determine desired data.
        """,
        "*Choose a reaction.*"
    ]

    static let explainStoichiometry: [TextLine] = [
        """
        The section of chemistry that uses relations between compounds in a reaction to \
        determine data is called stoichiometry. Let's analyze the chosen equation.
        """
    ]

    static let introducePhysicalStates: [TextLine] = [
        """
        We already know about the stoichiometric coefficients, but what are those sub indexes \
        at the right of each compound? Well, those indicate the physical state of the molecule.
        """
    ]

    static let explainEachPhysicalState: [TextLine] = [
        """
        So, lets see. *(aq)* stands for aqueous, which means the compound is dissolved in water. \
        *(l)* means liquid, *(s)* is solid and *(g)* is gaseous. But could we use molecules \
        in real life?
        """
    ]

    static let explainMoles: [TextLine] = [
        """
        Well, we usually can't. Remember that the stoichiometric coefficients represent the \
        molecules, but at the same time, for practical reasons, we talk about *moles.*
        """
    ]

    static let explainAvogadroNumber: [TextLine] = [
        """
        1 mol = $6.02214076x10^26^$ (the Avogadro number). When we talk about particles (say \
        molecules, atoms, ions), it's a very convenient unit to use in stoichiometry.
        """
    ]

    static let instructToSetVolume: [TextLine] = [
        """
        This reaction takes place in water as we already know, so let's first set the volume \
        of water (in liters) in the beaker. Volume is often represented by the letter *V*. \
        *Use the slider to set the volume.*
        """
    ]

    static let explainYieldPercentage: [TextLine] = [
        """
        Well, this is because in real life, the ideal values of the products are not obtained. \
        An important concept is *yield percentage*. This percentage represents how close or \
        far from theory is the real mass obtained of the product.
        """
    ]
}

struct LimitingReagentReactionStatements {

    init(components: LimitingReagentComponents) {
        self.components = components
        self.excessReactant = components.reaction.excessReactant.name.asMarkdown
        self.limitingReactant = components.reaction.limitingReactant.name.asMarkdown
        self.product = components.reaction.product.name.asMarkdown
    }

    let components: LimitingReagentComponents
    var reaction: LimitingReagentReaction {
        components.reaction
    }

    private let excessReactant: String
    private let limitingReactant: String
    private let product: String

    var instructToAddLimitingReactant: [TextLine] {
        let optionalProducts = [reaction.firstExtraProduct?.name, reaction.product.name, reaction.secondExtraProduct?.name]
        let allProducts = optionalProducts.compactMap { $0 }.map(\.asMarkdown)
        let productsString = StringUtil.combineStringsWithFinalAnd(allProducts)
        return [
            """
            Perfect! Now, the reactants of this reaction are *\(limitingReactant) and \
            \(excessReactant)*. When these two interact, they produce *\(productsString)*. \
            In this particular case, we have the liquid \(limitingReactant), so *shake it into the beaker.*
            """
        ]
    }

    var explainMolarity: [TextLine] {
        [
            """
            Awesome! So you are preparing a *solution* of \(limitingReactant) now. An important \
            concept related to this is *Molarity (M). Molarity* is a way to express the \
            concentration of a substance in the solution, in units of $*mol/L.*$
            """
        ]
    }

    var showLimitingReactantMolarity: [TextLine] {
        let molarity = components.limitingReactantMolarity.str(decimals: 2)
        return [
            """
            So right now, the molarity of *\(limitingReactant)* in this solution is \
            *\(molarity)M or \(molarity) moles/L*. This means that for each liter of substance, \
            there are *\(molarity) moles of \(limitingReactant)*. But we already know how many \
            liters there are right?
            """
        ]
    }

    var showLimitingReactantMoles: [TextLine] {
        let moles = components.equationData.limitingReactantMoles.str(decimals: 2)
        let volume = components.volume.str(decimals: 2)
        return [
            """
            Since there are *\(volume) liters* of water in the beaker, there are *\(moles) moles* \
            of *\(limitingReactant)* present in the solution *($moles = V x M$)*. But what \
            else can we determine by knowing the moles of this reactant? Let's see...
            """
        ]
    }

    var showNeededReactantMoles: [TextLine] {
        let coeff = reaction.excessReactant.coefficient
        let singleMoleNeeded = coeff == 1
        let moleCount = singleMoleNeeded ? "mole" : "moles"
        let neededMoles = components.equationData.neededExcessReactantMoles.str(decimals: 2)
        return [
            """
            So we know that for this reactant to be consumed completely, each *1 mol of \
            \(limitingReactant)* has to react with *\(coeff) \(moleCount) of \(excessReactant)*. \
            So we would need *\(neededMoles) of \(excessReactant)*. Let's call it \
            *\(excessReactant) needed.*
            """
        ]
    }

    var showTheoreticalProductMoles: [TextLine] {
        let reactantMoles = components.equationData.limitingReactantMoles.str(decimals: 2)
        let productMoles = components.equationData.theoreticalProductMoles.str(decimals: 2)
        return [
            """
            Let's look at the stoichiometric relation in the reaction. By each *1 mol of \
            \(limitingReactant)* that reacts, if in theory it reacts in its entirety, then \
            *\(reactantMoles) of \(limitingReactant)* should produce *\(productMoles) of \
            \(product).*
            """
        ]
    }

    var showTheoreticalProductMass: [TextLine] {
        let mass = components.equationData.theoreticalProductMass.str(decimals: 2)
        return [
            """
            And by knowing the *molar mass (MM, sometimes referred to as M, in g/mol)* of the \
            compound, we can calculate the mass produced. Theoretically, *\(mass) grams* of \
            *\(product)* should be produced if all the *\(limitingReactant)* reacts.
            """
        ]
    }

    var instructToAddExcessReactant: [TextLine] {
        [
            """
            Let's call that *\(excessReactant) theoretical*. Now let's add the other reactant, \
            \(excessReactant), and see the reaction going.
            """,
            "*Shake \(excessReactant) into the beaker.*"
        ]
    }

    var reactionInProgress: [TextLine] {
        [
            """
            Awesome! Now let's watch as *\(limitingReactant)* and *\(excessReactant)* react to produce \
            *\(product)*! We can use the molar mass of *\(product)* to know how many grams \
            are actually being produced. Let's call that the *actual \(product)*
            """
        ]
    }

    var endOfReaction: [TextLine] {
        let actualMass = components.equationData.actualProductMass.getY(at: 1).str(decimals: 2)
        let theoreticalMass = components.equationData.theoreticalProductMass.str(decimals: 2)
        return [
            """
            Done! You added the amount needed of *\(excessReactant)*. But wait a minute, the \
            actual mass of *\(product)* is *\(actualMass)g*, which is lower than the theoretical \
            mass we expected, which was *\(theoreticalMass)g.*
            """
        ]
    }

    var showYield: [TextLine] {
        [
            """
            Yield percentage is determined as the ratio of the actual yield (actual mass \
            obtained of *\(product)*) and theoretical yield (the expected mass of *\(product)*). \
            In this case, the yield percentage is *\(reaction.yield.percentage)*.
            """
        ]
    }

    var instructToAddExtraReactant: [TextLine] {
        [
            """
            Do you think we could improve that percentage by adding even more *\(product)*?
            """,
            "*Let's see, shake \(product) into the beaker.*"
        ]
    }

    var explainExtraReactantNotReacting: [TextLine] {
        [
            """
            Wow! *\(excessReactant)* is accumulating, but the reaction is not taking place.
            """,
            "Why is this?"
        ]
    }

    var explainLimitingReagent: [TextLine] {
        let moles = components.equationData.limitingReactantMoles.str(decimals: 2)
        return [
            """
            Very simple! There is not enough *\(product)*, as we only added so much of it \
            *(\(moles) moles)*. In stoichiometry, this is called the *limiting reagent*, as \
            *\(limitingReactant)* is the compound that limits the reaction as there is a \
            shortage of it.
            """
        ]
    }

    var explainExcessReactant: [TextLine] {
        [
            """
            When this happens, the other reactant would be the excess reactant, which in this \
            case is *\(excessReactant)*. There's an excess of *\(excessReactant)*, making it \
            accumulate instead of react. Awesome right? Let's learn more about stoichiometry.
            """
        ]
    }
}
