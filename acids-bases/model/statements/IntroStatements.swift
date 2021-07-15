//
// Reactions App
//

import ReactionsCore

struct IntroStatements {
    static let intro: [TextLine] = [
        """
        *Acids and bases* are extremely common, as are the reactions \
        between acids and bases. The driving force is often the \
        hydronium ion reacting with the hydroxide to form water.
        """
    ]

    static let explainTexture: [TextLine] = [
        """
        At the macroscopic level, *acids* taste sour, may be damaging to \
        the skin, and react with bases to yield salts. *Bases* tase bitter,
        feel slippery, and react with acids to form salts. But on a microscopic \
        level there are various definitions by authors.
        """
    ]

    static let explainArrhenius: [TextLine] = [
        """
        An *Arrhenius acid* is a substance that dissociates in water into \
        hydrogen ions *(H^+^)* increasing the concentration of H^+^ ions in \
        the solution. An *Arrhenius base* is a substance that dissociates in \
        water into hydroxide *(OH^-^)* ions; increasing the concentration of \
        OH^-^ ions in an aqueous solution (aq).
        """
    ]

    static let explainBronstedLowry: [TextLine] = [
        """
        *The Bronsted-Lowry* definition states that acids are those with the \
        ability to "donate" hydrogen ions *(H^+^)*, otherwise known as *protons*,
        and bases are those that "accept" them.
        """
    ]

    static let explainLewis: [TextLine] = [
        """
        *The Lewis* definition defines a base (referred to as a Lewis base) to be \
        a compound that can donate an *electron pair*, and an acid (a Lewis acid) to \
        be a compound that can receive this electron pair.
        """
    ]

    static let explainSimpleDefinition: [TextLine] = [
        """
        To put it simply, the presence of *H^+^* ions in a solution makes it acidic, \
        while the presence of *OH^-^* makes it basic. Acids and bases are classified \
        in strong and weak. This will depend on how much they can *dissociate* into \
        H^+^ or OH^-^.
        """
    ]

    static let chooseStrongAcid: [TextLine] = [
        """
        Strong acids are those that dissociate entirely into H^+^ ions. The reaction \
        of these acids with water goes to completion.
        """,
        "*Choose a strong acid.*"
    ]

    static let showPhScale: [TextLine] = [
        """
        That awesome colorful scale is a *pH scale!* You can see that [H^+^] and [OH^-^] are \
        related to each other. When both are the same, they're both at *10^-7^ concentration*. \
        At which point, *pH* is said to be neutral: 7. But what is pH?
        """
    ]

    static let explainPHConcept: [TextLine] = [
        """
        *[H^+^]* presence in a solution can be very small, that's why the concept of *pH* \
        exists. pH is defined as $*pH=-log[H^+^]*$ and is used as a measurement of acidity \
        of a solution. The same thing happens to $[OH^-^]$.
        """
    ]

    static let explainPOHConcept: [TextLine] = [
        """
        *[OH^-^]* presence in a solution can be very small, that's the concept of *pOH* \
        exists. pOH is defined as $*pOH=-log[OH^-^]*$. pOH is related with pH, as in every \
        solution within water: $*pH + pOH = 14*$.
        """
    ]

    static let explainPRelation: [TextLine] = [
        """
        The relation between pH and pOH can be easily seen in the pH scale. This relationship \
        between *pH and pOH* will be better explained later. Just know that the lower the \
        pH is, the more acidic the solution is. But why?
        """
    ]

    static let explainPConcentrationRelation1: [TextLine] = [
        """
        If you take a look at the pH equation: $*pH=-log[H^+^]*$, the $[H^+^]$ concentration \
        is really small (10 to some negative exponent). The higher the exponent is, the \
        smaller the value, making a high pH one that represents a low $[H^+^]$.
        """
    ]

    static let explainPConcentrationRelation2: [TextLine] = [
        """
        In other words, you can notice that the higher the concentration of *$[H^+^]$, \
        then the lower pH is and the more acidic is the solution.* The same thing goes \
        for pOH and $[OH^-^]$. The higher pH is, the lower pOH is and vice versa.
        """
    ]

    static func setWaterLevel(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let primary = substance.primary.rawValue
        let secondary = substance.primary.rawValue
        return [
            """
            You chose *\(symbol)*. When in water, \(symbol) dissociates completely \
            into *\(primary)* and *\(secondary)* ions.
            """,
            """
            *Set the amount of water first of all to get started.*
            """
        ]
    }

    static func addSubstance(_ type: AcidOrBaseType) -> [TextLine] {
        let typeName = type.isAcid ? "acid" : "base"
        return [
            """
            Great! Now add the \(typeName) to the solution to watch the pH scale change. \
            *Shake it into it!*
            """,
            """
            Note: feel free to use the pH meter anytime to measure pH in the solution.
            """
        ]
    }

    static func midAddingStrongAcid(substance: AcidOrBase) -> [TextLine] {
        midAddingStrongSubstance(substance: substance, pHDirection: "decreases")
    }

    static func showPhVsMolesGraph(namePersistence: NamePersistence) -> [TextLine] {
        [
            """
            *Awesome\(namePersistence.nameWithComma)!* Now, this is how it looks when you plot a \
            line for pH vs the moles of strong acid you added. Let's take a snapshot of that \
            graph, it will help us later.
            """
        ]
    }

    static let chooseStrongBase: [TextLine] = [
        """
        Strong bases are those that dissociate entirely into OH^-^ ions. The reaction of \
        these bases with water goes to completion.
        """,
        "*Choose a strong base.*"
    ]

    static func midAddingStrongBase(substance: AcidOrBase) -> [TextLine] {
        midAddingStrongSubstance(substance: substance, pHDirection: "increases")
    }

    static let chooseWeakAcid: [TextLine] = chooseWeakSubstance(type: .weakAcid)

    static func explainWeakAcid(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let primary = substance.primary.rawValue
        let secondary = substance.secondary.rawValue

        return [
            """
            You chose *\(symbol)*. When in water, \(symbol) dissociates partially into \
            *\(primary)* and *\(secondary)* ions. Notice how in this case, *H_2_O* is written in the \
            reaction equation as a reactant. This is due to stoichiometric reasons.
            """
        ]
    }

    static let explainHEquivalence: [TextLine] = [
        """
        *H_2_O^+^ and H^+^* ions are used interchangeably, they are the same thing, but one or \
        the other is used for balancing convenience. In this case, for weak acids and bases, \
        H_2_O is written as a reactant in the equations.
        """
    ]

    static func explainDoubleArrow(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let primary = substance.primary.rawValue
        let secondary = substance.secondary.rawValue
        return [
            """
            It's also important to notice in the equation the *double arrow* we encountered \
            in the equilibrium unit. This is why *\(symbol)* does not go to completion, and \
            only dissociates into a few *\(primary)* and *\(secondary)* ions.
            """
        ]
    }

    static let explainEquilibrium: [TextLine] = [
        """
        As we already know now, equilibrium reactions will go towards the equilibrium state \
        in which the concentrations of all species remain macroscopically constant. More of \
        the acids-base equilibria will be explained later.
        """
    ]

    static func midAddingWeakAcid(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let primary = substance.primary.rawValue
        let secondary = substance.secondary.rawValue
        return [
            """
            It changed a bit! pH decreases when *\(symbol)* is added. Notice how \(symbol) \
            is partially ionized into \(primary) and \(secondary), and there's still much of \
            \(symbol) present in the solution.
            """,
            "*Keep shaking as much as you like.*"
        ]
    }

    static let chooseWeakBase: [TextLine] = chooseWeakSubstance(type: .weakBase)

    static func setWeakBaseWaterLevel(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let secondary = substance.secondary.rawValue
        return [
            """
            You chose *\(symbol)*. When in water, \(symbol) reacts with water to yield \
            *\(secondary). \(symbol) acts as a proton acceptor.*
            """,
            """
            *Set the amount of water first of all to get started.*
            """
        ]
    }

    static func midAddingWeakBase(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        return [
            """
            It changed a bit! pH increases when \(symbol) is added. Notice how \(symbol) \
            partially produces *OH^-^*, and there's still much of \(symbol) present in the \
            solution.
            """,
            """
            *Keep shaking as much as you like.*
            """
        ]
    }

    static func end(namePersistence: NamePersistence) -> [TextLine] {
        [
            """
            *That was great\(namePersistence.nameWithComma)!*  Now, let's get more into this \
            acid-bases equilibria and see how it works, and what is good for.
            """
        ]
    }

    private static func midAddingStrongSubstance(
        substance: AcidOrBase,
        pHDirection: String
    ) -> [TextLine] {
        let symbol = substance.symbol
        let primary = substance.primary.rawValue
        let secondary = substance.secondary.rawValue

        return [
            """
            What a change! pH \(pHDirection) a lot when *\(symbol)* is added. Notice how \
            \(symbol) is totally ionized into \(primary) and \(secondary).
            """,
            """
            *Keep shaking as much as you like.*
            """
        ]
    }

    private static func chooseWeakSubstance(type: AcidOrBaseType) -> [TextLine] {
        let typeName = type.isAcid ? "acid" : "base"
        let ion = type.isAcid ? "H^+^" : "OH^-^"
        return [
            """
            Weak \(typeName) are those that dissociate partially into \(ion) ions. The \
            reaction of these \(typeName)s with water goes to equilibrium.
            """,
            "*Choose a weak \(typeName).*"
        ]
    }
}
