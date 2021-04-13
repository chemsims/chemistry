//
// Reactions App
//

import ReactionsCore

struct SolubilityStatements {
    private init() { }

    static let intro: [TextLine] = [
        "There are some other reactions in which equilibrium has a big role",
        "*Let's learn about them now!*"
    ]

    static let explainPrecipitationReactions: [TextLine] = [
        """
        Some reactions can produce solids as their products, these are called *precipitation \
        reactions*. But as they are reversible, the opposite can happen and the solid can even \
        dissolve. *Choose one*.
        """
    ]

    static let explainSolubility1: [TextLine] = [
        """
        Many compounds can actually dissolve in water with no problem, but some others are \
        partially soluble.
        """,
        """
        The measurement on how much a salt can dissolve in water is called *solubility*.
        """
    ]

    static let explainSolubility2: [TextLine] = [
        """
        A salt is being dissolved when it turns into ions when reacting with water. In this type of \
        reaction we work with the *net-ionic equation*.
        """
    ]

    static let explainRecapEquation: [TextLine] = [
        """
        Let's quickly remember all versions of Q equation with you so far.
        """
    ]

    static func explainQEquation1(solute: String) -> [TextLine] {
        [
            """
            The equation of Q in these types of reaction is the same as always, but this time *\(solute)(s)* \
            is not included. This is because *pure solids and liquids are not included* as they don't \
            affect the amounts at equilibrium.
            """
        ]
    }

    static let explainQEquation2: [TextLine] = [
        """
        That's also why K is referred to as *Ksp*. They are the same values, constant of \
        equilibrium, but in these reactions it serves as an indicator on how soluble a salt is. \
        *Ksp stands for solubility product.*
        """
    ]

    static let explainKspRatio1: [TextLine] = [
        """
        The higher the *Ksp*, then the higher the amount of ions the reaction produces at the \
        equilibrium state will be. Once the quotient *Q* reaches *Ksp*, the reverse reaction and \
        forward reaction will be taking place at the same rate, meaning that no more solid can be \
        turned into ions.
        """
    ]

    static let explainKspRatio2: [TextLine] = [
        """
        A way to see it, is as *Ksp* being the maximum amount of ions that can be in a solution. \
        Once *Ksp* is reached, no more solids can be dissolved. *Let's get it started!*
        """
    ]

    static let instructToSetWaterLevel: [TextLine] = [
        """
        You chose a reversible precipitation reaction. So, first of all, why don't you set the \
        amount of water?
        """,
        "*Use the slider.*"
    ]

    static func instructToAddSolute(product: SolubleProductPair) -> [TextLine] {
        [
            """
            The forward reaction is *1* mole of *\(product.concatenated)(s) (the salt)*, transforms \
            into *1* mole of mole of *\(product.first)+ (cation)* and *1* mole of \
            *\(product.second)- (anion)*.
            """,
            "Add reactant to make it start",
            "*Shake it into it*."
        ]
    }

    static let primaryReactionStarted: [TextLine] = [
        """
        *Awesome!* Now the forward reaction will take place it is said that forward reaction is
        being *favored* this is because in order for the reaction to reach the equilibrium state \
        products must be produced.
        """
    ]

    static let firstThirdPrimaryReaction: [TextLine] = [
        """
        Watch how the reactant is being transformed into products (ions). This will continue until \
        the equilibrium state is reached, meaning, *until $Q = Ksp$*.
        """,
        "*Keep shaking!*"
    ]

    static let lastThirdPrimaryReaction: [TextLine] = [
        """
        Products (ions) keep being produced because Q is still lower than Ksp *$(Q < Ksp)$*.
        """,
        "But you can see in the graphs we're almost there!"
    ]

    static func primaryEquilibriumReached(amount: Int, solute: String) -> [TextLine] {
        [
            """
            Great! No more salt can be dissolved in water now that we reached *equilibrium*.
            """,
            """
            Notice that you could only dissolve \(amount)mg of \(solute)(s).
            """
        ]
    }

    static func instructToAddSaturatedSolute(solute: String) -> [TextLine] {
        [
            """
            Now, try shaking a bit more of *\(solute)(s)* into the beaker and see what happens.
            """
        ]
    }

    static let explainSuperSaturated: [TextLine] = [
        """
        Wow! Now the salt doesn't dissolve anymore. The extra solid added doesn't affect Q, as it \
        is still *$Q = Ksp$*. More ions cannot be produced as the solution has now reached its \
        capacity to dissolve the salt.
        """
    ]

    static func explainSaturatedEquilibrium1(product: SolubleProductPair) -> [TextLine] {
        [
            """
            Forward and reverse reactions are taking place at the same rate at equilibrium. So as \
            ions \(product.first)+ and \(product.second)- become \(product.concatenated)(s), \
            \(product.concatenated)(s) becomes \(product.first)+ and \(product.second)-. Remember, \
            the amount of *\(product.concatenated)(s) doesn't affect Q or Ksp*.
            """
        ]
    }

    static let explainSaturatedEquilibrium2: [TextLine] = [
        """
        So, even if more of the salt is added, it will not be dissolved, as the forward and the \
        reverse reactions will be taking place at the *same rate*, independently of the amount \
        of salt there is. Let's now try something different.
        """
    ]

    static func explainCommonIonEffect(product: SolubleProductPair) -> [TextLine] {
        [
            """
            When an ion is already within the solution in which the reaction will take place, the salt \
            won't be as soluble. This is called the *common-ion effect*, and the "common ion" in this \
            situation is *\(product.second)-*.
            """
        ]
    }

    static func instructToAddCommonIon(product: SolubleProductPair) -> [TextLine] {
        [
            """
            Once you add *\(product.commonSalt)(s)*, it will dissolve into ions \
            *\(product.third)+* and *\(product.second)-*. In this case, *\(product.third)+* \
            doesn't affect the solubility of *\(product.concatenated)(s), it only affects \
            \(product.first)+ and \(product.second)-(aq)*.
            """,
            "*Shake it into it to see what happens!*"
        ]
    }

    static func instructToAddPrimarySolutePostCommonIon(product: SolubleProductPair) -> [TextLine] {
        [
            """
            Notice how the amount of *\(product.second)-* goes up. Now, let's add \
            *\(product.concatenated)(s)* the same as before and spot the difference.
            """,
            """
            Shake *\(product.concatenated)(s)* into it and see what happens!
            """
        ]
    }

    static func commonIonEquilibriumReached(amount: Int, product: SolubleProductPair) -> [TextLine] {
        [
            """
            Great! No more salt can be dissolved in water now that we reached *equilibrium*.
            """,
            """
            Notice that you could only dissolve \(amount)mg of \(product.concatenated)(s), which is \
            less than before.
            """
        ]
    }

    static let explainPh1: [TextLine] = [
        """
        *pH* can affect the solubility of some salts. When pH is high or low, it means that there \
        are more *H+ (low pH)* or *OH- (high pH)* ions free that can react with the ions produced \
        by the salt, trapping them, and reducing their concentration.
        """
    ]

    static func explainPh2(product: SolubleProductPair) -> [TextLine] {
        [
            """
            Another factor that can affect the solubility of a salt is *pH*. Lower pH values mean \
            higher presence of *H+ ions*. In some cases, H+ could react with ions in the solution. In \
            this case, H+ reacts with *\(product.second)-* to form *H\(product.second)(aq)*.
            """
        ]
    }

    static func instructToAddH(product: SolubleProductPair) -> [TextLine] {
        [
            """
            In other words, if you add H+ ions, they will react and therefore reduce the presence of \
            \(product.second))- ions in the solution, *reducing Q*, allowing \
            *\(product.concatenated)(s) to turn into more \(product.first)+ and \(product.second)- ions*.
            """,
            "Shake *H+* ions into the beaker!"
        ]
    }

    static func acidReactionRunning(product: SolubleProductPair) -> [TextLine] {
        [
            """
            *H+* ions reacted with *\(product.second)-* ions and reduced its concentration! Now, \
            the solution is no longer saturated and the extra solid (*precipitate*) can turn into \
            ions and dissolve. This makes the *forward reaction* to be favored, until *equilibrium*.
            """
        ]
    }

    static func acidEquilibriumReached(product: SolubleProductPair) -> [TextLine] {
        [
            """
            Awesome! Now the precipitate has totally dissolved. We made the solution have a larger \
            capacity to dissolve the *\(product.concatenated)(s)* salt by making its *pH lower*. This can apply to various \
            other salts.
            """
        ]
    }

    static let end: [TextLine] = [
        "It's done!",
        """
        Now you're free to explore the *chemical equilibrium* and the ways to disturb it.
        """
    ]
}
