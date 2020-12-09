//
// Reactions App
//
  

import CoreGraphics

struct FirstOrderStatements {
    static let intro = [
        SpeechBubbleLineGenerator.makeLine("This is a First Order Reaction."),
        SpeechBubbleLineGenerator.makeLine("Why don't you set the *initial concentration of A [A_0_]*, the reactant?")
    ]

    static let setC2 = [
        SpeechBubbleLineGenerator.makeLine("Great! Now you can set the *concentration of A at the end of the reaction [A_t_]* and the *time the reaction will last (t)*."),
    ]

    static let explainRateConstant1 = [
        SpeechBubbleLineGenerator.makeLine(
            "The Rate Constant *k* is a value on which the Rate depends. This dependency is often represented with the Rate Law or the Rate Equation."
        ),
    ]

    static func explainRateConstant2(rate: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                """
                Rate Laws or Rate Equations are mathematical expressions that describe the relationship \
                between the Rate of a chemical reaction and the concentration of its reactants. For this reaction: *k=\(rate.str(decimals: 3))*.
                """
            )
        ]
    }

    static func explainHalflife(halfLife: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                """
                Half Life (t_1/2_) is an expression to easily calculate the point in time at which the concentration of the reactant, \
                in this case *A*, is half of what the initial concentration was. For this reaction:*
                """
            ),
            SpeechBubbleLineGenerator.makeLine(
                "*t_1/2_=ln(1)/k=\(halfLife.str(decimals: 2))s"
            )
        ]
    }

    fileprivate class ExplainRatePostReaction1: ReactionState {
        init() {
            super.init(statement: FirstOrderStatements.explainRatePostReaction1)
        }
    }

    static let explainRatePostReaction1 = [
        SpeechBubbleLineGenerator.makeLine(
            "For the previous Zero Order Reaction, Rate was constant because it was independent of *[A]*, since Rate=k[A]^0^ is equivelant to Rate=k, which is the Rate Constant."
        )
    ]

    static let explainRatePostReaction2 = [
        SpeechBubbleLineGenerator.makeLine(
            "For this First Order Reaction, *Rate=k[A]^1^*, that's why a graph plotting ([A] vs t) is a curve, given how the Rate is proportional to the concentration of A."
        )
    ]

    static let explainRatePostReaction3 = [
        SpeechBubbleLineGenerator.makeLine(
            "Notice how [A] drops faster at the beginning because there's more of *A* present, making the Rate higher"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "Towards the end of the reaction there's much less [A] present, so the Rate of the reaction is lower, making [A] drop slower."
        )
    ]

    static let explainIntegratedRateLaw1 = [
        SpeechBubbleLineGenerator.makeLine(
            "For simplification purposes, when integrating the Rate Law of the Rate Equation, we get the *Integrated Rate Law*."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "This is a form of the Rate Law that makes it simpler to make calculations and graphs from the original Rate Law Equation."
        )
    ]

    static let explainIntegratedRateLaw2 = [
        SpeechBubbleLineGenerator.makeLine(
            "For this First Order Reaction, the resultant Integrated Rate Law is *k=(ln[A_0_]-ln[A])/t*."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "That's why a graph plotting (ln[A] vs t) is a straight line."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "ln[A]*(y)*=-kt*(mx)*+ln[A0]*(b)*, with a slope of *-k*."
        )
    ]

    static let explainRate = [
        SpeechBubbleLineGenerator.makeLine(
            "For a reaction with one reactant it's usually written as: Rate=k[A]^Order^."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "For this reaction then, *Rate=k[A]^1^*"
        )
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        SpeechBubbleLineGenerator.makeLine("Try *dragging the time indicator* to scrub through the reaction time."),
        SpeechBubbleLineGenerator.makeLine("Then, let's see take a look at another integrated rate law.")
    ]

    static let inProgress = ReactionStatements.inProgress
    
}
