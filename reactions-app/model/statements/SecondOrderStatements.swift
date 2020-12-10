//
// Reactions App
//
  

import CoreGraphics

struct SecondOrderStatements {
    static let intro = [
        SpeechBubbleLineGenerator.makeLine("This is a Second Order Reaction."),
        SpeechBubbleLineGenerator.makeLine("Why don't you set the *initial concentration of A (c_1_)*, the reactant?")
    ]

    static func explainRateConstant(rateConstant: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine("For this reaction, *k=\(rateConstant.str(decimals: 2))*")
        ]
    }

    static let explainChart = [
        SpeechBubbleLineGenerator.makeLine("For a reaction with one reactant, it's usually written as:"),
        SpeechBubbleLineGenerator.makeLine("*Rate=k[A]^order^*"),
        SpeechBubbleLineGenerator.makeLine("For this Second Order Reaction then:"),
        SpeechBubbleLineGenerator.makeLine("*Rate=k[A]^2^*"),
    ]

    static func explainHalfLife(halfLife: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine("Half Life (*t_1/2_*) is an expression to easily calculate the time at which the concentration of the reactant, in this case A, is half of what the initial concentration was."),
            SpeechBubbleLineGenerator.makeLine("For this reaction:"),
            SpeechBubbleLineGenerator.makeLine("*t_1/2_=1/k[A_0_]*")
        ]
    }

    static let postReactionExplain1 = [
        SpeechBubbleLineGenerator.makeLine(
            "For this Second Order Reaction, *Rate=k[A]^2^*, that's why a graph plotting ([A] vs t) is a steeper curve, given how the Rate is proportional to the concentration of A squared."
        )
    ]

    static let postReactionExplain2 = [
        SpeechBubbleLineGenerator.makeLine(
            "Notice how [A] drops a lot faster at the beginning of because there's more of A present, making the Rate much higher."
        )
    ]

    static let postReactionExplain3 = [
        SpeechBubbleLineGenerator.makeLine(
            "Subsequently, towards the end of the reaction, there's much less [A] present, so the Rate of the reaction is a lot lower, making [A] drop significantly slower at this point."
        )
    ]

    static let postReactionExplain4 = [
        SpeechBubbleLineGenerator.makeLine(
            "For example, if [A] is 0.9, then [A]^2^ is 0.81. If [A] is 0.8, then [A]^2^ is 0.64"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "You see that dropping [A] by 0.1 would make a First Order Reaction drop its Rate by 0.1, and a Second Order Reaction drop its Rate by 0.17."
        )
    ]

    static let postReactionExplain5 = [
        SpeechBubbleLineGenerator.makeLine(
            "Since 0.1 is less than 0.17, it's noticeable how for a Second Order Reaction the Rate would drop faster."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "In other words, the Rate of the reaction will drop *more drastically for a Second Order Reaction at first*, and slowly reduce to a point in which the Rate drops *slower than in a First Order Reaction towards the end*."
        )
    ]

    static let postReactionExplain6 = [
        SpeechBubbleLineGenerator.makeLine(
            "For this Second Order Reaction, the resultant Integrated Rate Law is:"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "k=(1/[A]-1/[A_0_]t"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "That's why a graph plotting \(Strings.withNoBreaks(str: "(1/[A] vs t)")) is a straight line:"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "1/[A]*(y)*=kt*(mx)*+1/[A_0_]*(b)*"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "with a slope of *k*."
        )
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        SpeechBubbleLineGenerator.makeLine("Now let's compare all the graphs we collected so far!"),
    ]
}
