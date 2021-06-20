//
// Reactions App
//

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
        Now let's prepare the acidic solution that we're going to titrate. Add the HCl.
        """,
        "*Shake it into it!*"
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
        finally after the EP. AT this stage, before the EP, there's an excess of *\(hydrogen)* \
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

    static let instructToAddIndicatorToStrongAcid: [TextLine] = [
        """
        If you want to see the effect of the indicator, just set the view of the beaker to \
        macroscopic.
        """,
        """
        Tap on the dropper to let a few drops fall into the solution.
        """,
        "*Tap to add it!*"
    ]

    static let instructToSetMolarityOfStrongBaseTitrant: [TextLine] = [
        """
        Now set the concentration of the strong base KOH. notice that the titrant is in a \
        burette. This tool allows us to slowly add small amounts of the substance into the solution \
        while easily measuring the volume added. *Use the slider.*
        """
    ]

    static let instructToAddStrongBaseTitrant: [TextLine] = [
        """
        Let's just add the titrant now! The titration curve starts at a *very low pH*, as the \
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

}
