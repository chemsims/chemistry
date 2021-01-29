//
// Reactions App
//
  

import CoreGraphics

struct FirstOrderStatements {
    static let intro = [
        TextLineGenerator.makeLine("This is a first order reaction."),
        SpeechLabelling.labelledLine("Why don't you set the *initial concentration of A [A_0_]*, the reactant?")
    ]

    static let setC2 = [
        SpeechLabelling.labelledLine("Great! Now you can set the *concentration of A at the end of the reaction [A_t_]* and the *time the reaction will last (t)*."),
    ]

    static let explainRateConstant1: [TextLine] = [
        "The rate constant *k* is a value on which the *rate* depends. This dependency is often represented with the rate law or the rate equation."
    ]

    static func explainRateConstant2(rate: CGFloat) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                """
                Rate laws or rate equations are mathematical expressions that describe the relationship \
                between the *rate* of a chemical reaction and the concentration of its reactants. For this reaction, \(Strings.withNoBreaks(str: "*k=\(rate.str(decimals: 3))*")).
                """
            )
        ]
    }

    static let explainRate = [
        SpeechLabelling.labelledLine(
            "For a reaction with one reactant it's usually written as $*rate=k[A]^order^*$."
        ),
        SpeechLabelling.labelledLine(
            "For this reaction then, $*rate=k[A]^1^*$."
        )
    ]

    static func explainHalfLife(halfLife: CGFloat) -> [TextLine] {
        [
            SpeechLabelling.labelledLine(
                """
                *Half-life (t_1/2_)* is an expression to easily calculate the point in time at which the concentration of the reactant, \
                in this case *A*, is half of what the initial concentration was. For this reaction,
                """
            ),
            SpeechLabelling.labelledLine(
                "*t_1/2_=ln(1)/k=\(halfLife.str(decimals: 2))s*."
            )
        ]
    }

    static let inProgress = ReactionStatements.inProgress

    static let explainRatePostReaction1 = [
        SpeechLabelling.labelledLine(
            """
            For the previous zero order reaction, *rate* was constant because it was independent \
            of *[A]*, since $*rate=k[A]^0^*$ is equivalent to $*rate=k*$, which is the rate constant.
            """
        )
    ]

    static let explainRatePostReaction2 = [
        SpeechLabelling.labelledLine(
            """
            For this first order reaction, $*rate=k[A]^1^*$. That's why a graph plotting \
            \(Strings.aVsT) is a curve, given how the *rate* is proportional to the concentration \
            of *A*.
            """
        )
    ]

    static let explainChangeInRate: [TextLine] = [
        """
        Notice how *[A]* drops faster at the beginning because there's more of *A* present, making \
        the *rate* higher.
        """,
        """
        Towards the end of the reaction there's much less *[A]* present, so the *rate* of the \
        reaction is lower, making *[A]* drop slower.
        """
    ]

    static let explainIntegratedRateLaw1: [TextLine] = [
        """
        For simplification purposes, when integrating the rate law or the rate equation, we get \
        the *integrated rate law*.
        """,
        """
        This is a form of the rate law that makes it simpler to make calculations and graphs from \
        the original rate law equation.
        """
    ]

    static let explainIntegratedRateLaw2: [TextLine] = [
        """
        For this first order reaction, the resultant integrated rate law is \
        $*k=(ln[A_0_]-ln[A])/t*$.
        """,
        "That's why a graph plotting $(ln[A] vs t)$ is a straight line.",
        "ln[A]*(y)*=-kt*(mx)*+ln[A_0_]*(b)*",
        "Where the slope is *-k*."
    ]

    static let end: [TextLine] = [
        "Amazing! Let's take a snapshot!",
        "Try *dragging the time indicator* to scrub through the reaction time."
    ]
}
