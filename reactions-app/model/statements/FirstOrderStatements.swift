//
// Reactions App
//
  

import CoreGraphics

struct FirstOrderStatements {
    static let intro = [
        TextLineGenerator.makeLine("This is a First Order Reaction."),
        TextLineGenerator.makeLine("Why don't you set the *initial concentration of A [A_0_]*, the reactant?")
    ]

    static let setC2 = [
        TextLineGenerator.makeLine("Great! Now you can set the *concentration of A at the end of the reaction [A_t_]* and the *time the reaction will last (t)*."),
    ]

    static let explainRateConstant1 = [
        TextLineGenerator.makeLine(
            "The Rate Constant *k* is a value on which the *Rate* depends. This dependency is often represented with the Rate Law or the Rate Equation."
        ),
    ]

    static func explainRateConstant2(rate: CGFloat) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                """
                Rate Laws or Rate Equations are mathematical expressions that describe the relationship \
                between the *Rate* of a chemical reaction and the concentration of its reactants. For this reaction, \(Strings.withNoBreaks(str: "*k=\(rate.str(decimals: 3))*")).
                """
            )
        ]
    }

    static let explainRate = [
        TextLineGenerator.makeLine(
            "For a reaction with one reactant it's usually written as \(Strings.withNoBreaks(str: "*Rate=k[A]^Order^*"))."
        ),
        TextLineGenerator.makeLine(
            "For this reaction then, \(Strings.withNoBreaks(str: "*Rate=k[A]^1^*"))."
        )
    ]

    static func explainHalfLife(halfLife: CGFloat) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                """
                *Half Life (t_1/2_)* is an expression to easily calculate the point in time at which the concentration of the reactant, \
                in this case *A*, is half of what the initial concentration was. For this reaction,
                """
            ),
            TextLineGenerator.makeLine(
                "*t_1/2_=ln(1)/k=\(halfLife.str(decimals: 2))s*."
            )
        ]
    }

    static let inProgress = ReactionStatements.inProgress

    static let explainRatePostReaction1 = [
        TextLineGenerator.makeLine(
            "For the previous Zero Order Reaction, *Rate* was constant because it was independent of *[A]*, since \(Strings.withNoBreaks(str: "*Rate=k[A]^0^*")) is equivalent to \(Strings.withNoBreaks(str: "*Rate=k*")), which is the Rate Constant."
        )
    ]

    static let explainRatePostReaction2 = [
        TextLineGenerator.makeLine(
            "For this First Order Reaction, \(Strings.withNoBreaks(str: "*Rate=k[A]^1^*")). That's why a graph plotting \(Strings.aVsT) is a curve, given how the *Rate* is proportional to the concentration of *A*."
        )
    ]

    static let explainChangeInRate = [
        TextLineGenerator.makeLine(
            "Notice how *[A]* drops faster at the beginning because there's more of *A* present, making the *Rate* higher."
        ),
        TextLineGenerator.makeLine(
            "Towards the end of the reaction there's much less *[A]* present, so the *Rate* of the reaction is lower, making *[A]* drop slower."
        )
    ]

    static let explainIntegratedRateLaw1 = [
        TextLineGenerator.makeLine(
            "For simplification purposes, when integrating the Rate Law or the Rate Equation, we get the *Integrated Rate Law*."
        ),
        TextLineGenerator.makeLine(
            "This is a form of the Rate Law that makes it simpler to make calculations and graphs from the original Rate Law Equation."
        )
    ]

    static let explainIntegratedRateLaw2 = [
        TextLineGenerator.makeLine(
            "For this First Order Reaction, the resultant Integrated Rate Law is \(Strings.withNoBreaks(str: "*k=(ln[A_0_]-ln[A])/t*"))."
        ),
        TextLineGenerator.makeLine(
            "That's why a graph plotting \(Strings.withNoBreaks(str: "(ln[A] vs t)")) is a straight line."
        ),
        TextLineGenerator.makeLine(
            "ln[A]*(y)*=-kt*(mx)*+ln[A0]*(b)*"
        ),
        TextLineGenerator.makeLine(
            "Where the slope is *-k*."
        )
    ]

    static let end = [
        TextLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        TextLineGenerator.makeLine("Try *dragging the time indicator* to scrub through the reaction time."),
        TextLineGenerator.makeLine("Then, let's take a quiz before having a look at a Second Order Reaction.")
    ]
}
