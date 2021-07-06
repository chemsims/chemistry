//
// Reactions App
//

import CoreGraphics
import ReactionsCore

private let hydrogen = AcidStatementUtil.hydrogen
private let hydroxide = AcidStatementUtil.hydroxide
private let water = "H_2_O"

struct TitrationStatements {
    private init() { }

    static let intro: [TextLine] = [
        """
        One big use of acid-base reactions is a technique called titration. Let's learn more \
        about it!
        """,
        "*Choose a strong acid!*"
    ]

    static let explainNeutralization: [TextLine] = [
        """
        The reaction between an acid and a base is called *neutralization*. An acid reacts with \
        a base to form a salt and water. We already know strong acids totally dissociate into \
        \(hydrogen) ions, while strong bases into \(hydroxide).
        """
    ]

    static let explainMolecularIonicEquations: [TextLine] = [
        """
        For *neutralization* reactions the importance resides on the fact the ions dissociated \
        more than the molecular compounds. So you can choose between the *molecule equation* or \
        *ionic equation* which only shows the ions of importance.
        """
    ]

    static let explainTitration: [TextLine] = [
        """
        So when \(hydrogen) and \(hydroxide) react, they form \(water). This is the *ionic equation* \
        of a neutralization reaction. A *titration* occurs when you slowly add an acid to a base \
        or vice versa, until reaching the *equivalence point* or beyond.
        """
    ]

    static let explainEquivalencePoint: [TextLine] = [
        """
        The *equivalence point* is the one at which the acid and the base have totally \
        neutralized each other. In the case of strong acids or bases, the *pH is 7* at this point.
        """
    ]

    static let explainTitrationCurveAndInstructToSetWaterLevel: [TextLine] = [
        """
        the plotted curve of pH vs titrant added is called a titration curve. Let's first see \
        the titration curve for a strong acid being titrated by a strong base. *Set the water \
        level. Note: feel free to use the pH meter whenever.*
        """
    ]

    static let instructToAddStrongAcid: [TextLine] = [
        """
        Now let's prepare the acidic solution that we're going to titrate.
        """,
        "*Shake the HCl into the beaker!*"
    ]

    static let midAddingStrongAcid: [TextLine] = [
        """
        Concentration of *[\(hydrogen)]* is getting higher! And the pH is also very low.
        """,
        "This is a very acidic solution.",
        """
        *Keep shaking until you're happy with the initial concentration of \(hydrogen).*
        """
    ]

    static let explainTitrationStages: [TextLine] = [
        """
        During a titration, there are stages: before the equivalence point (EP), at the EP and \
        finally after the EP. At this stage, before the EP, there's an excess of *\(hydrogen)* \
        moles in the solution, making it *acidic*. All moles of *\(hydroxide)* will react to \
        *neutralize moles of \(hydrogen).*
        """
    ]

    static let explainMolesOfHydrogen: [TextLine] = [
        """
        Moles of *\(hydrogen)* in the solution will be the moles that are already present, minus \
        the ones that will be neutralized by the addition of moles of *\(hydroxide)*. By dividing \
        this amount by the total volume, it's possible to determine the concentration of \
        *\(hydrogen)*.
        """
    ]

    static let explainIndicator: [TextLine] = [
        """
        Now let's add the *indicator*. This is a substance that makes the solution change its \
        color at a determined pH. It's very important to pick an indicator whose changing point \
        is very close to the *equivalence point, to identify it.*
        """
    ]

    static let instructToAddIndicator: [TextLine] = [
        """
        If you want to see the effect of the indicator, just set the view of the beaker to \
        macroscopic.
        """,
        """
        Tap on the dropper to let a few drops fall into the solution.
        """,
        "*Tap to add it!*"
    ]

    static let instructToSetMolarityOfStrongBaseTitrant =
        instructToSetMolarityOfSubstanceTitrant(substance: "strong base KOH")

    static let instructToAddStrongBaseTitrant: [TextLine] = [
        """
        Let's add the titrant now! The titration curve starts at a *very low pH*, as the \
        solution is purely acidic now. When KOH is added, it will neutralize the HCl to slowly \
        make it more basic. *Tap to add it.*
        """
    ]

    static let midAddingStrongBaseTitrant: [TextLine] = [
        """
        At this stage, \(hydrogen) ions are reacting with the \(hydroxide) ions added to form water.
        """,
        "The solution is slowly increasing its pH.",
        "*Keep adding by tapping the burette!*"
    ]

    static let reachedStrongAcidEquivalencePoint: [TextLine] = [
        """
        We've reached the *equivalence point*. As all \(hydrogen) ions have reacted with the \
        \(hydroxide) ions added, there's only water and salt remaining, making the solution *neutral.*
        """,
        "*That means, a pH of 7.*"
    ]

    static let instructToAddStrongBaseTitrantPostEP: [TextLine] = [
        """
        At this point, the macroscopic view of the solution turns pink, as pH is no longer acid. \
        Also, from this point on, all *\(hydroxide)* added will remain in the solution, making \
        it basic.
        """,
        "*Keep adding by tapping the burette!*"
    ]

    static let midAddingStrongBaseTitrantPostEP: [TextLine] = [
        """
        At this stage there is no more HCl in the solution to react with the KOH, so this \
        one is fully dissociating into \(hydroxide). The solution is rapidly increasing its \
        pH. *Keep adding by tapping the burette!*
        """
    ]

    static let endOfStrongAcidTitration: [TextLine] = [
        """
        Awesome! We ended the titration. Normally, in the laboratory, the titration ends at \
        the equivalence point, as the goal is usually to determine the concentration of any of \
        the species. *Let's titrate a strong base now!*
        """
    ]

    static let instructToChooseStrongBase: [TextLine] = [
        "Now, let's titrate a strong base!",
        "*Choose a strong base.*"
    ]

    static let instructToSetWaterLevelForStrongBaseTitration: [TextLine] = [
        """
        Let's first see the titration curve for a strong base being titrated by \
        a strong acid.
        """,
        "*Set the water level. Note: Feel free to use the pH meter whenever.*"
    ]

    static let instructToAddStrongBase: [TextLine] = [
        """
        Now, let's prepare the basic solution that we're going to titrate. Add the KOH.
        """,
        "*Shake it into it.*"
    ]

    static let midAddingStrongBase: [TextLine] = [
        """
        Concentration of *\(hydroxide)* is getting higher! And the pH is also \
        very high, so this is a very basic solution.
        """,
        """
        *Keep shaking until you're happy with the initial concentration of \
        \(hydroxide).*
        """
    ]

    static let postAddingStrongBaseExplanation1: [TextLine] = [
        """
        During a titration, there are stages: before the equivalence point (EP), at the EP \
        and finally after the EP. At this stage, before the EP, there's an excess of \
        *\(hydroxide)* in the solution, making it *basic*. All moles of *\(hydrogen)* added will \
        react to *neutralize moles of \(hydroxide).*
        """
    ]

    static let postAddingStrongBaseExplanation2: [TextLine] = [
        """
        Moles of *\(hydroxide)* in the solution will be the moles that are already present, \
        minus the ones that will be neutralized by the addition of moles of *\(hydrogen)*. By \
        dividing this amount by the total volume, it's possible to determine the concentration of \
        \(hydroxide).
        """
    ]

    static let instructToSetMolarityOfStrongAcidTitrant =
        instructToSetMolarityOfSubstanceTitrant(substance: "strong acid HCl")

    static let instructToAddStrongAcidTitrantPreEP: [TextLine] = [
        """
        Let's just add the titrant now! The titration curve starts at a *very high pH*, as \
        the solution is purely basic now. When HCl is added, it will neutralize the KOH to \
        slowly make it more acidic. *Tap to add it.*
        """
    ]

    static let midAddingStrongAcidTitrant: [TextLine] = [
        """
        At this stage, \(hydroxide) ions are reacting with the \(hydrogen) ions \
        added to form water. The solution is slowly decreasing its pH.
        """,
        """
        *Keep adding by tapping the burette!*
        """
    ]

    static let reachedStrongBaseEquivalencePoint: [TextLine] = [
        """
        We've reached the *equivalence point*. As all \(hydroxide) ions have reacted with the \
        \(hydrogen) ions added, there's only water and salt remaining, making the solution *neutral*.
        """,
        "*This means the pH is 7.*"
    ]

    static let instructToAddStrongAcidTitrantPostEP: [TextLine] = [
        """
        At this point, the macroscopic view of the solution turns blue, as the pH is no longer \
        basic. Also, from this point on, all *\(hydrogen)* moles added will remain in the \
        solution, making it acidic.
        """,
        "*Keep adding by tapping the burette!*"
    ]

    static let midAddingStrongAcidTitrantPostEP: [TextLine] = [
        """
        At this stage there is no more KOH in the solution to react with \
        the HCl, so this is fully dissociating into \(hydrogen). The solution is \
        rapidly decreasing its pH. *Keep adding by tapping the burette!*
        """
    ]

    static let endOfStrongBaseTitration: [TextLine] = [
        """
        Awesome! These types of reactions are very useful. But what if were to titrate weak \
        acids or bases?
        """,
        "*Let's titrate a weak acid now!*"
    ]

    static let instructToChooseWeakAcid: [TextLine] = [
        """
        We already know weak acids partially dissociate into *\(hydrogen)* ions, while strong \
        bases totally dissociate into *\(hydroxide)*.
        """,
        "*Choose a weak acid.*"
    ]

    static let instructToSetWeakAcidTitrationWaterLevel: [TextLine] = [
        """
        These equations sound familiar right? Well this is because we already got to learn about \
        them in the weak acids equilibrium.
        """
    ]

    static let explainWeakAcidTitrationReaction: [TextLine] = [
        """
        For this *neutralization* reaction, *K^+^* ions are spectator ions, meaning that they \
        don't actually take part in the reaction. So, let's just write KOH as *\(hydroxide)* and \
        HA as *A^-^*.
        """
    ]

    static let instructToAddWeakAcid: [TextLine] = [
        """
        Now let's prepare the acidic solution that we're going to titrate.
        """,
        "*Shake the HA into the beaker.*"
    ]

    static let runningWeakAcidReaction: [TextLine] = [
        """
        The reaction is now running, and the concentration of *\(hydrogen)* is increasing!
        """
    ]

    static func endOfWeakAcidReaction(
        kA: CGFloat,
        pH: CGFloat,
        substanceMoles: CGFloat
    ) -> [TextLine] {

        let kAString = TextLineUtil.scientific(value: kA).asMarkdown
        let pHString = pH.str(decimals: 2)
        let molesString = substanceMoles.str(decimals: 2)

        return [
            """
            The concentration of *\(hydrogen)* is now a little higher, and the solution is \
            acidic. Recall the the equations from the previous weak acid-base part. *Ka is \
            \(kAString), pH is \(pHString) and the initial moles of HA are \(molesString) moles*. \
            Let's remember those values!
            """
        ]
    }

    static let explainWeakAcidTitrationStages =
        explainWeakSubstanceTitrationStages(
            acidityType: "acids",
            substance: "HA",
            primaryIonBeingAdded: hydroxide
        )


    static let instructToSetMolarityOfTitrantOfWeakAcidSolution =
        instructToSetMolarityOfSubstanceTitrant(substance: "strong base KOH")

    static let explainWeakAcidBufferRegion: [TextLine] =
        explainWeakSubstanceBufferRegion(
            acidityType: "acid",
            firstMolecule: "HA",
            secondMolecule: "A^-^"
        )

    static let explainWeakAcidHasselbalch: [TextLine] = [
        """
        That's why the equation of *Henderson-Hasselbalch* can be used in this part.
        """,
        """
        Until the EP is reached, any mole of *\(hydroxide)* added will react with HA to produce \
        the same amount of *A^-^* moles, and to consume *HA* moles.
        """
    ]

    static let explainWeakAcidBufferMoles: [TextLine] = [
        """
        That's why at this stage, the moles of *\(hydroxide)* added will be the same as the \
        moles of HA in the solution. While the moles of A^-^ will be what's already present in \
        the solution, minus the ones consumed by the added  *\(hydroxide).*
        """
    ]

    static let instructToAddTitrantToWeakAcid: [TextLine] = [
        """
        Let's add the titrant now! The titration curve starts at a *very low pH*, as the \
        solution is purely acidic right now. When KOH is added, it will neutralize the HA \
        to slowly make it more basic. *Tap to add it.*
        """
    ]


    static func reachedWeakAcidEquivalencePoint(pH: CGFloat) -> [TextLine] {
        let pHString = pH.str(decimals: 2)
        return [
           """
           We've reached the *equivalence point.* Unlike strong titrations, in this case the pH isn't
           7 but \(pHString), being slightly basic. Right now, all of the added *\(hydroxide)* \
           has neutralized all of the HA, and there's no more of it in the solution.
           """
       ]
    }

    static let explainWeakAcidEP1: [TextLine] = [
        """
        As we saw in the previous parts, the A^-^ is the conjugate base of HA. Because there \
        are so many A^-^ ions in the solution, it produce little amounts of *\(hydroxide)*, making \
        the solution basic.
        """
    ]

    static func explainWeakAcidEP2(pH: CGFloat) -> [TextLine] {
        let pHString = pH.str(decimals: 2)
        return [
           """
           As little as it is, it's more than enough to make the solution slightly basic. From \
           this point on, all *\(hydroxide)* added will remain in the solution, making it basic. \
           At this point, the macroscopic view of the solution turns pink, as the *pH is now \
           \(pHString).*
           """
       ]
    }

    static let instructToAddTitrantToWeakAcidPostEP: [TextLine] = [
        """
        The concentration of *\(hydroxide)* will merely be the moles of *\(hydroxide)* added \
        from now on, divided by the total volume.
        """,
        "*Keep adding by tapping the burette!*"
    ]

    static let endOfWeakAcidTitration: [TextLine] = [
        """
        Awesome! We ended the titration. Normally, in the laboratory, the titration ends at the \
        equivalence point, as the goal is usually to determine the concentration of any of the \
        species. *Let's titrate a weak base now!*
        """
    ]

    static let instructToChooseWeakBase: [TextLine] = [
        """
        We already know weak bases partially produce *\(hydroxide)* ions, while strong acids \
        totally dissociate into *\(hydrogen)*.
        """,
        "*Choose a weak base.*"
    ]

    static let instructToSetWaterLevelOfWeakBaseTitration: [TextLine] = [
        """
        These equations sound familiar right? Well this is because we already got to learn about \
        them in the weak bases equilibrium unit. This is the *neutralization* of a weak base.
        """,
        "*Set the water level.*"
    ]

    static let instructToAddWeakBase: [TextLine] = [
        """
        Now, let's prepare the basic solution that we're going to titrate.
        """,
        "*Shake the A^-^ into the beaker*"
    ]

    static let runningWeakBaseReaction: [TextLine] = [
        """
        The reaction is now running, and the concentration of *\(hydroxide)* is increasing!
        """
    ]

    static func endOfWeakBaseReaction(
        kB: CGFloat,
        pOH: CGFloat,
        substanceMoles: CGFloat
    ) -> [TextLine] {
        let kBString = TextLineUtil.scientific(value: kB).asMarkdown
        let pOHString = pOH.str(decimals: 2)
        let molesString = substanceMoles.str(decimals: 2)

        return [
            """
            The concentration of *\(hydroxide)* is getting a little higher, so the solution is now \
            basic. Recall the equations from the previous weak acid-base part. *Kb is
            \(kBString)*, pOH is \(pOHString) and the initial moles of A^-^ are \(molesString). \
            Let's remember those values!
            """
        ]
    }

    static let explainWeakBaseTitrationStages =
        explainWeakSubstanceTitrationStages(
            acidityType: "bases",
            substance: "A^-^",
            primaryIonBeingAdded: hydrogen
        )

    static let instructToSetMolarityTitrantOfWeakBaseSolution =
        instructToSetMolarityOfSubstanceTitrant(substance: "strong acid \(hydrogen)")

    static let explainWeakBaseBufferRegion: [TextLine] =
        explainWeakSubstanceBufferRegion(
            acidityType: "base",
            firstMolecule: "HA",
            secondMolecule: "A^-^"
        )

    static let explainWeakBaseHasselbalch: [TextLine] = [
        """
        That's why the equation of *Henderson-Hasselbalch* can be used in this part.
        """,
        """
        Until the EP is reached, any mole of *\(hydrogen)* added will react with HA to produce \
        the same amount of *HA* moles, and to consume *A^-^* moles.
        """
    ]

    static let explainWeakBaseBufferMoles: [TextLine] = [
        """
        That's why at this stage, the moles of *\(hydrogen)* added will be the same as the \
        moles of HA in the solution. While the moles of A^-^ will be what's already present in \
        the solution, minus the ones consumed by the added  *\(hydrogen).*
        """
    ]

    static let instructToAddTitrantToWeakBase: [TextLine] = [
        """
        Let's add the titrant now! The titration curve starts at a *very high pH*, as the \
        solution is purely basic right now. When \(hydrogen) is added, it will neutralize the \
        A^-^ to slowly make it more basic. *Tap to add it.*
        """
    ]

    static func reachedWeakBaseEquivalencePoint(pH: CGFloat) -> [TextLine] {
        let pHString = pH.str(decimals: 2)
        return [
           """
           We've reached the *equivalence point.* Unlike strong titrations, in this case the pH isn't
           7 but \(pHString), being slightly acidic. Right now, all of the added *\(hydrogen)* \
           has neutralized all of the A^-^, and there's no more of it in the solution.
           """
       ]
    }

    static let explainWeakBaseEP1: [TextLine] = [
        """
        As we saw in the previous parts, the HA is the conjugate base of A^-^. Because there \
        are so many A^-^ ions in the solution, it produce little amounts of *\(hydroxide)*, making \
        the solution basic.
        """
    ]

    static func explainWeakBasedEP2(pH: CGFloat) -> [TextLine] {
        let pHString = pH.str(decimals: 2)
        return [
           """
           As little as it is, it's more than enough to make the solution slightly basic. From \
           this point on, all *\(hydrogen)* added will remain in the solution, making it basic. \
           At this point, the macroscopic view of the solution turns blue, as the *pH is now \
           \(pHString).*
           """
       ]
    }

    static let instructToAddTitrantToWeakBasePostEP: [TextLine] = [
        """
        The concentration of *\(hydrogen)* will merely be the moles of *\(hydrogen)* added \
        from now on, divided by the total volume.
        """,
        "*Keep adding by tapping the burette!*"
    ]

    static let endOfWeakBaseTitration: [TextLine] = [
        """
        Awesome! We ended the titration. Normally, in the laboratory, the titration ends at the \
        equivalence point, as the goal is usually to determine the concentration of any of the \
        species.
        """
    ]
}

// MARK: Common statement methods
extension TitrationStatements {
    private static func instructToSetMolarityOfSubstanceTitrant(substance: String) ->  [TextLine] {
        [
            """
            Now set the concentration of the \(substance). notice that the titrant is in a \
            burette. This tool allows us to slowly add small amounts of the substance into the solution \
            while easily measuring the volume added. *Use the slider.*
            """
        ]
    }

    private static func explainWeakSubstanceTitrationStages(
        acidityType: String,
        substance: String,
        primaryIonBeingAdded: String
    ) -> [TextLine] {
        [
            """
            For titrations of weak \(acidityType), there are more stages involved: buffer region \
            (before the EP), at the EP, and finally after the EP. Before the EP, there's plenty of \
            \(substance) in the solution, which will react with any moles of \
            *\(primaryIonBeingAdded)* added.
            """
        ]
    }

    private static func explainWeakSubstanceBufferRegion(
        acidityType: String,
        firstMolecule: String,
        secondMolecule: String
    ) -> [TextLine] {
        [
            """
            Before the equivalence point, in this case, this section is called the *buffer region*, \
            because the weak \(acidityType) solution will act as a buffer during this stage, due \
            to the relation between \(firstMolecule) and \(secondMolecule) present in the solution.
            """
        ]
    }
}
