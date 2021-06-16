//
// Reactions App
//

import CoreGraphics
import ReactionsCore

private let hydrogen = "H^+^"
private let hydroxide = "OH^-^"
private let h3O = "H_3_O^+^"

struct BufferStatements {
    private init() { }



    static let intro: [TextLine] = [
        """
        As stated before, weak acids and bases don't go to completion, as they do not \
        dissociate entirely in water. In fact, they partially dissociate very little \
        into *[H^+^]* or *[OH^-^]* ions. These are reactions that go toward equilibrium.
        """
    ]

    static let explainEquilibriumConstant1: [TextLine] = [
        """
        In the equilibrium unit, we got to know about *reverse reactions*. A weak acid \
        or base that dissociates in water is a reversible reaction as it goes to \
        equilibrium. Do you remember *K*, the equilibrium constant?
        """
    ]

    static let explainEquilibriumConstant2: [TextLine] = [
        "Let's refresh our memory!",
        """
        *K* is the value that relates products and reactants at equilibrium.
        """,
        """
        K is called *Ka* for an acid dissociating, and *Kb* for a base. *Choose a weak \
        acid to learn more*.
        """
    ]

    static func explainWeakAcid(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let secondary = substance.secondary
        return [
            """
            You chose *\(symbol)*. When \(symbol) reacts with water, it dissociates into \
            *\(secondary)^-^* and *H_3_O^+^ (remember that H_3_O^+^ and H^+^ are \
            interchangeable)*. The double arrow indicates that this is a reversible reaction.
            """
        ]
    }

    static func explainKa(substance: AcidOrBase) -> [TextLine] {
        [
            """
            The equation for Ka is the same equation as *K = [products]/reactants]*. In \
            this case, the products are the ions: *[\(substance.secondary)^-^]* and \
            *[H^+^]*, while the reactant is just $[\(substance.symbol)]$, the acid, as water is a pure \
            liquid and it's not included in the equation.
            """
        ]
    }

    static let explainHighKa: [TextLine] = [
        """
        The larger K is, the larger the concentration of products at equilibrium is. This is \
        why, when comparing weak acids, the one with a *higher Ka* is the one that at \
        equilibrium will produce *more H^+^ ions*, making it more acidic.
        """
    ]

    static func explainConjugateBase(_ substance: AcidOrBase) -> [TextLine] {
        let secondary = "\(substance.secondary)^-^"
        return [
            """
            Notice how *\(secondary)* can react with *H^+^*. In other words, *\(secondary)* \
            has the ability to trap a proton *(H^+^)*, working as a base. These products \
            are called *conjugate base of the acid*. *\(secondary)* is the conjugate base \
            of *\(substance.symbol)*. \(substance.symbol) and \(secondary) are called \
            *conjugate acid-base pair*.
            """
        ]
    }

    static func explainKb(_ substance: AcidOrBase) -> [TextLine] {
        let secondary = "\(substance.secondary)^-^"
        return [
            """
            That's where *Kb* comes from. When *\(secondary)* traps *H^+^* from water, it \
            releases *OH^-^* ions, working as a base. The equation for Kb is: \
            *$Kb = [\(substance.symbol)][OH^-^]/[\(secondary)]$*. That'll be the Kb for the \
            conjugate base \(secondary). When *Ka* is large, *Kb* is small, and vice versa.
            """
        ]
    }

    static let explainKw: [TextLine] = [
        """
        But there's also a *Kw*, for water. This is because water also dissociates, but very \
        little H_2_O dissociates into H^+^ and OH^-^, making the equation for Kw: \
        *$Kw = [H^+^][OH^-^]$*. *Kw* is constant, and at 25°C its value is *10^-14^*.
        """
    ]

    static let explainP14: [TextLine] = [
        """
        And since OH^-^ and H^+^ dissociate equally from water, $[OH^-^] = [H^+^]$ and \
        they're *10^-7^*. That's exactly why pH and pOH are both *7 in water*. When applying \
        negative log to both sides of the equation *$Kw = [H^+^][OH^-^]$* we get that \
        *$14 = pH + pOH$*.
        """
    ]

    static let explainKaKbNaming: [TextLine] = [
        """
        For the purposes of this unit, *Ka* is usually called acid dissociation constant, \
        *Kb* is called base dissociation constant and *Kw* is the water dissociation constant. \
        Another way they relate to each other is by *$Kw = Ka \\* Kb$*.
        """
    ]

    static let explainPKaPKb: [TextLine] = [
        """
        As Ka and Kb are really small, they get the same treatment and logarithms are used \
        to better relate them:
        *pKa = -log(Ka)*
        *pKb = -log(Kb)*
        """
    ]

    static func explainHendersonHasselbalch(substance: AcidOrBase) -> [TextLine] {
        let secondary = substance.symbol(ofPart: .secondaryIon)
        let substance = substance.symbol
        return [
            """
            We can obtain a very useful equation for buffers: the *Henderson-Hasselbalch* equation. \
            This formula is derived algebraically from the equilibrium constant expression for Ka.
            *pH = pKa + log([\(secondary)^-^]/[\(substance)])*
            """
        ]

    }
    static let instructToSetWaterLevel1: [TextLine] = [
        """
        The *Henderson-Hasselbalch* equation has a very unique use that we are going to \
        learn later. First of all, let's set the water volume in the beaker.
        """,
        "*Use the water slider*."
    ]

    static func instructToAddWeakAcid(_ substance: AcidOrBase) -> [TextLine] {
        [
            """
            *Awesome!* Now add the weak acid *\(substance.symbol)* to see it dissociate \
            into *H^+^ and \(substance.secondary)^-^*.
            """,
            "*Shake it into it!*"
        ]
    }

    static func midAddingWeakAcid(_ substance: AcidOrBase) -> [TextLine] {
        [
            """
            *Great!* Keep adding until you're happy with the initial concentration of \
            \(substance.symbol).
            """,
            "*Keep shaking it!*"
        ]
    }

    static func runningWeakAcidReaction(_ substance: AcidOrBase) -> [TextLine] {
        [
            "Watch how it reacts and dissociates!",
            """
            *\(substance.symbol)* is now dissociating into *H^+^* and \
            *\(substance.secondary)^-^*, and the presence of H^+^ makes the solution acidic.
            """
        ]
    }

    static func weakAcidEquilibriumReached(
        substance: AcidOrBase,
        ka: CGFloat,
        pH: CGFloat
    ) -> [TextLine] {
        let kaText = scientificValueWithTextLineMarkdown(ka)
        
        return [
            """
            Equilibrium has been reached! That means that this is the maximum number of \
            ions that can be produced by this weak acid. *$Ka = \(kaText)$* and \
            *$pH = \(pH.str(decimals: 2))$* making the solution very acidic. Notice \
            there's plenty of \(substance.symbol) remaining.
            """
        ]
    }

    static let introduceBufferSolutions: [TextLine] = [
        """
        Now that we know Ka, let's use the *Henderson-Hasselbalch* equation for \
        something very useful:
        *Buffer solutions*
        """,
        "But what are they?"
    ]

    static let explainBufferSolutions: [TextLine] = [
        """
        Buffers are solutions that resist a change in pH when acid or base is added \
        to them. These are usually composed of a *weak acid* and its *conjugate base* or \
        a *weak base* and its *conjugate acid.*
        """
    ]

    static let explainBufferSolutions2: [TextLine] = [
        """
        Why is that? Well, when there's a weak acid in the solution, this would react \
        with any *OH^-^* added, while its conjugate base would react with any *H^+^*, \
        maintaining the *pH* relatively constant. The same thing happens with weak \
        base buffers.
        """
    ]

    static let explainBufferUses: [TextLine] = [
        """
        Buffers are very important and are present in *various systems*. For example, blood \
        has a buffer system of bicarbonate and carbonic acid. It helps maintain blood at \
        pH 7.4, and without it human life wouldn't be possible.
        """
    ]

    static func explainFractionChart(substance: AcidOrBase) -> [TextLine] {
        let secondary = "\(substance.secondary)^-^"
        let symbol = substance.symbol
        return [
            """
            Watch the graph in the bottom. The y axis is the fraction of proportions of \
            species *\(symbol)* and *\(secondary)*. When \(symbol) and \(secondary) are \
            equally present in the solution, both fractions are *0.50*. The x axis is \
            the pH of the solution.
            """
        ]
    }

    static func explainFractionChartCurrentPosition(substance: AcidOrBase) -> [TextLine] {
        [
            """
            As seen in the bottom graph, right now there's much more *\(substance.symbol)* \
            than *\(substance.secondary)^-^* in the solution. It's not yet considered a \
            buffer. When within the *buffer range* (center of the graph), the solution has \
            buffer properties.
            """
        ]
    }

    static func explainBufferRange(substance: AcidOrBase) -> [TextLine] {
        let symbol = substance.symbol
        let secondary = "\(substance.secondary)^-^"
        return [
            """
            The *Henderson-Hasselbalch* equation lets us calculate pH of the *buffer*. In \
            this case, variations on \(symbol) and \(secondary) ratio will make the pH \
            vary. When \(symbol) and \(secondary) are the same value, the *$pH = pKa$*. The \
            buffer range is ±1 from that point.
            """
        ]
    }

    static func explainBufferProportions(substance: AcidOrBase) -> [TextLine] {
        [
            """
            When proportions of \(substance.symbol) and \(substance.secondary)^-^ are \
            equal, that's when the buffer has a higher effectiveness, because at that point \
            it is able to buffer against equal amounts of acid *H^+^* or base *OH^-^* added.
            """
        ]
    }

    static func explainAddingAcidIonizingSalt(substance: AcidOrBase) -> [TextLine] {
        [
            """
            A very common way to add a conjugate base is by adding its *salt* (one that ionizes \
            completely in water to \(substance.secondary)^-^ ions).
            """
        ]
    }

    // TODO - read the salt name from somewhere
    static func instructToAddSalt(substance: AcidOrBase) -> [TextLine] {
        let secondary = substance.symbol(ofPart: .secondaryIon)
        return [
            """
            *M\(secondary)* is a salt that ionizes completely in water, \
            letting *\(secondary)^-^* ions free in the solution, the \
            conjugate base of *\(substance.symbol)*. In other \
            words, add *M\(secondary)* to increase the presence of *\(secondary)^-^* ions.
            """,
            "*Shake it into it!*"
        ]
    }

    static func bufferReached(substance: AcidOrBase) -> [TextLine] {
        let secondary = "\(substance.secondary)^-^"
        return [
            """
            Awesome! That's what I called a *buffer!* There's equal parts of \
            *\(substance.symbol)* and *\(secondary)* now. Notice that *pH went \
            up*, this is because \(secondary) ions trapped the \(hydrogen) ions that \
            were free in the solution, decreasing the concentration of *\(hydrogen)* \
            in the solution.
            """
        ]
    }

    // TODO - should use the substance added in part 1
    static let explainWaterPhLine: [TextLine] = [
        """
        Now that the buffer is prepared, we can test it. Remember that graph \
        at the top? That's right! It's from when we added *HCl* to pure water.
        """,
        """
        See how pH went down without much resistance.
        """
    ]

    static let showPreviousPhLine: [TextLine] = [
        """
        Now that the buffer is prepared, we can test it. Remember that graph at the top? That's \
        right! It's from when we added *HCl* to pure water.
        """,
        """
        See how pH went down without much resistance.
        """
    ]

    static let instructToAddStrongAcid: [TextLine] = [
        """
        But what will happen if we add *HCl* to this buffer? Let's find out!
        """,
        """
        Add HCl, which totally dissociates in water into *\(hydrogen)* ions.
        """,
        "*Shake it into it!*"
    ]

    static let acidBufferLimitReached: [TextLine] = [
        """
        Finally the *buffer* has reached its *limit!*. pH has gone down \
        significantly now, but our buffer did a great job maintaining pH \
        constant for that long! Let's try with weak bases now!
        """
    ]

    static let instructToChooseWeakBase: [TextLine] = [
        """
        Let's try now with a weak base and see if we can make a buffer out of it!
        """,
        "*Choose a weak base to learn more.*"
    ]

    static let explainKbOhRelation: [TextLine] = [
        """
        The larger K is, the larger the concentrations of products at equilibrium are. \
        This is why, when comparing weak bases, the one with a *higher Kb* is the one that at \
        equilibrium, will produce *more \(hydroxide) ions*, making it more basic.
        """
    ]

    static let instructToSetWaterLevelForBase: [TextLine] = [
        """
        The *Henderson-Hasselbalch* equation has a very unique use to determine pH or pOH for buffers. \
        First of all, let's set the water volume in the beaker.
        """,
        "*Use the water slider*."
    ]

    static let explainBasicHasselbalch: [TextLine] = [
        """
        Now that we know the Kb, let's use the *Henderson-Hasselbalch* equation for something \
        very useful:
        """,
        """
        *Buffer solutions*. This time, we'll make one from a weak base and its conjugate salt.
        """
    ]

    static let showBasePhWaterLine: [TextLine] = [
        """
        Now that the buffer is prepared, we can test it. Remember that graph at the top? That's right! \
        It's from when we added *KOH* to pure water.
        """,
        "See how pH went up without much resistance."
    ]

    static let instructToAddStrongBase: [TextLine] = [
        """
        But what will happen if we add *KOH* to this buffer? Let's find out!
        """,
        """
        Add KOH, which totally dissociates in water into *\(hydroxide)* ions.
        """,
        "*Shake it into it!*"
    ]

    static let baseBufferLimitReached: [TextLine] = [
        """
        Finally, the *buffer* has reached it's limit! pH has gone significantly up now, but out \
        buffer did a great job maintaining pH constant for that long!
        """,
        "That was awesome!"
    ]

    /// Returns `value` in scientific form as a String with markdown to pass to `TextLine`
    private static func scientificValueWithTextLineMarkdown(
        _ value: CGFloat
    ) -> String {
        if let (base, exponent) = TextLineUtil.scientificComponents(value: value) {
            return "\(base)x10^\(exponent)^"
        }
        return value.str(decimals: 2)
    }
}

struct BufferStatementsForSubstance {

    init(substance: AcidOrBase) {
        let substanceStr = substance.chargedSymbol(ofPart: .substance).text.asMarkdown
        let primary = substance.chargedSymbol(ofPart: .primaryIon).text.asMarkdown
        let secondary = substance.chargedSymbol(ofPart: .secondaryIon).text.asMarkdown
        self.substance = substanceStr
        self.primary = primary
        self.secondary = secondary

        self.substanceC = "[\(substanceStr)]"
        self.primaryC = "[\(primary)]"
        self.secondaryC = "[\(secondary)]"

        self.underlyingSubstance = substance
    }

    let underlyingSubstance: AcidOrBase
    let substance: String
    let primary: String
    let secondary: String

    let substanceC: String
    let primaryC: String
    let secondaryC: String

    var reachedAcidBuffer: [TextLine] {
        [
            """
            Awesome! That's what I call a *buffer!*. There's equal parts of *\(substance)* and *\(secondary)* \
            now. Notice that *pH went up*, this is because \(secondary) ions trapped the \(primary) ions \
            that were free in the solution, decreasing the concentration of *\(primary)* in the solution.
            """
        ]
    }

    var midAddingStrongAcid: [TextLine] {
        [
            """
            Watch how pH decreases. But wait! It doesn't go down immediately as before. The *\(secondary)* \
            ions in the *buffer* react with the \(primary) free ions to make more \(substance).
            """,
            """
            *Keep adding HCl to test the buffer!*
            """
        ]
    }

    var choseWeakBase: [TextLine] {
        [
            """
            You chose *\(substance)*. When \(substance) reacts with water, it dissociates \
            into \(secondary) and *\(primary)*. The double arrow indicates that this is a \
            reverse reaction.
            """
        ]
    }

    var explainKbEquation: [TextLine] {
        [
            """
            The equation for Kb is the same equation for *K = [products]/[reactants]*. In this case, \
            the products are: *\(secondaryC)* and *\(primaryC)*, while the reactant is just \
            *\(substanceC)*, the base, as water is a pure liquid and it's not included in the equation.
            """
        ]
    }

    var explainConjugateAcidPair: [TextLine] {
        [
            """
            Notice how *\(secondary)* can react with *\(primary)*. In other words, \(primary) \
            has the ability to donate a proton *(\(hydrogen))*, working as an acid. These products \
            are called *conjugate acid of the base. \(primary)* is the conjugate acid of *\(substance)*. \
            \(substance) and \(primary) are called *conjugate acid-base pair*.
            """
        ]
    }

    var explainKa: [TextLine] {
        [
            """
            That's where *Ka* comes from. When *\(primary)* donates \(hydrogen) to water, it releases \
            *\(h3O)* ions, working as an acid. The equation for Ka is: \
            $Ka = \(substanceC)[\(hydrogen)]/\(primaryC)$. That'll be the Ka for the conjugate acid \
            \(primary). When *Kb* is large, *Ka* is small and vice versa.
            """
        ]
    }

    var explainBasicHasselbalch: [TextLine] {
        [
            """
            When solving for [\(hydroxide)] in the Kb equation, and applying negative log to both \
            sides, we get the *Henderson-Hasselbalch* equation for bases:
            *pOH = pKa + log(\(primaryC)/\(substanceC))*.
            """
        ]
    }

    var instructToAddWeakBase: [TextLine] {
        [
            """
            *Awesome!* Now add the weak base *\(substance)* to see it dissociate into *\(secondary)* \
            and *\(primary)*.
            """,
            "*Shake it into it!*"
        ]
    }

    var midAddingWeakBase: [TextLine] {
        [
            """
            *Great!* Add until you're happy with the initial concentration of *\(substance)*.
            """,
            "*Keep shaking it!*"
        ]
    }

    var runningWeakBaseReaction: [TextLine] {
        [
            "Watch how it reacts and dissociates!",
            """
            *\(substance)* is now reacting with water and dissociating into *\(secondary)* and \
            *\(primary)*, and the presence of \(secondary) makes the solution basic.
            """
        ]
    }

    func reachedBaseEquilibrium(pH: CGFloat) -> [TextLine] {
        let kB = TextLineUtil.scientific(value: underlyingSubstance.kB).asMarkdown
        return [
            """
            Equilibrium has been reached! That means that this is the maximum amount of ions that \
            can be produced by this weak base. $*Kb = \(kB)*$, and $*pH = \(pH.str(decimals: 2))*$ \
            making the solution very basic. Notice that there's plenty of *\(substance)* remaining.
            """
        ]
    }

    var explainBufferRange: [TextLine] {
        [
            """
            As seen in the bottom graph, right now there's much more *\(substance)* than *\(secondary)* \
            in the solution. It's not yet considered a buffer. When within the *buffer range* \
            (the center of the graph) the solution has buffer properties.
            """
        ]
    }

    var calculateBufferRange: [TextLine] {
        [
            """
            *Henderson-Hasselbalch* let's us calculate pH of the *buffer*. In this case, variations \
            on the \(primary) and \(substance) ratio will make the pH vary. When \(primary) and \
            \(substance) are the same, then *pH = pKa*. The *buffer range is ±1 from that point*.
            """
        ]
    }

    var explainEqualProportions: [TextLine] {
        [
            """
            When proportions of \(secondary) and \(substance) are equal, that's when the buffer has \
            higher effectiveness. This is because at that point, it is able to buffer against \
            equal amounts of acid *\(hydrogen)* or base *\(hydroxide)* added.
            """
        ]
    }

    var explainSalt: [TextLine] {
        [
            """
            A very common way to add a conjugate acid is by adding its *salt* (one that ionizes \
            completely in water to *\(secondary)*).
            """
        ]
    }

    // TODO - read salt from somewhere
    var instructToAddSaltToBase: [TextLine] {
       [
        """
        *\(secondary)X* is a salt that ionizes completely in water, letting *\(secondary)* free in \
        the solution, the conjugate acid of *\(substance)*. In other words, add *\(secondary)X* to \
        increase the presence of *\(secondary)* in the solution
        """,
        "*Shake it into it!*"
       ]
    }

    var reachedBasicBuffer: [TextLine] {
        [
            """
            Awesome! That's what I call a *buffer*. There's equal parts of *\(secondary)* and \
            *\(substance)* now. Notice that *pOH went up*, this is because the *\(secondary)* \
            trapped the *\(hydroxide)* ions that were free in the solution, decreasing the \
            concentration of *\(hydroxide)* in the solution.
            """
        ]
    }

    var midAddingStrongBase: [TextLine] {
        [
            """
            Watch how pH increases. But wait! It doesn't go up immediately as before. The *\(secondary)* \
            ions in the *buffer* react with the *\(hydroxide)* free ions to make more *\(substance)*.
            """,
            """
            *Keep adding KOH to test the buffer!*
            """
        ]
    }
}
