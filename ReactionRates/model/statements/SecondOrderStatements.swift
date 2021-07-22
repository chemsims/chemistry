//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct SecondOrderStatements {
    static let intro: [TextLine] = [
        "This is a second order reaction.",
        "Why don't you set the *initial concentration of A (A_0_)*, the reactant?"
    ]

    static func explainRateConstant(rateConstant: CGFloat) -> [TextLine] {
        [
            "For this reaction, $*k=\(rateConstant.str(decimals: 3))*$."
        ]
    }

    static let explainRate: [TextLine] = [
        "For a reaction with one reactant it's usually written as $*rate=k[A]^order^*$.",
        "For this reaction then, $*rate=k[A]^2^*$."
    ]

    static func explainHalfLife(halfLife: CGFloat) -> [TextLine] {
        [
            "*Half-life (t_1/2_)* is an expression to easily calculate the time at which the concentration of the reactant, in this case *A*, is half of what the initial concentration was.",
            "For this reaction,",
            TextLine(
                "*t_1/2_=1/k[A_0_]=\(halfLife.str(decimals: 2))s*.",
                label: Labelling.stringToLabel("t_1/2_ = 1 /, k times [A_0_], =\(halfLife.str(decimals: 2)) s.")
            )
        ]
    }

    static let postReactionExplain1: [TextLine] = [
        """
        For this second order reaction, $*rate=k[A]^2^*$, that's why a graph plotting \
        \(Strings.aVsT) is a steeper curve, given how the *rate* is proportional to the \
        concentration of *A* squared.
        """
    ]

    static let postReactionExplainFastRate: [TextLine] = [
        "Notice how *[A]* drops a lot faster at the beginning of the reaction because there's more of *A* present, making the *rate* much higher."
    ]

    static let postReactionExplainSlowRate: [TextLine] = [
        "Subsequently, towards the end of the reaction, there's much less *[A]* present, so the *rate* of the reaction is a lot lower, making *[A]* drop significantly slower at this point."
    ]

    static let postReactionExplain4: [TextLine] = [
        """
        For example, if $*[A]=0.9*$, then $*[A]^2^=0.81*$. And if $*[A]=0.8*$, then $*[A]^2^=0.64*$.
        """,
        "You see that dropping *[A]* by 0.1 would make a first order reaction drop its *rate* by 0.1, and a second order reaction drop its *rate* by 0.17."
    ]

    static let postReactionExplain5: [TextLine] = [
        "Since 0.1 is less than 0.17, it's noticeable how for a second order reaction the *rate* would drop faster.",
        "In other words, the rate of the reaction will drop *more drastically for a second order reaction at first*, and slowly reduce to a point at which the rate drops *slower than in a first order reaction towards the end*."
    ]

    static let postReactionExplain6: [TextLine] = [
        TextLine(
            """
            For this second order reaction, the resultant integrated rate law is  $*k=(1/[A]-1/[A_0_])/t*$. \
            That's why a graph plotting \(Strings.aVsT) is a straight line.
            """,
            label: Labelling.stringToLabel("""
            For this second order reaction, the resultant integrated rate law is \
            k = (inverse A - inverse A0), /t. \
            That's why a graph plotting \(Strings.aVsT) is a straight line.
            """
            )
        ),
        "1/[A]*(y)*=kt*(mx)*+1/[A_0_]*(b)*",
        "Where the slope is *k*."
    ]

    static let end: [TextLine] = [
        "Amazing! Let's take a snapshot!",
        "Try *dragging the time indicator* to scrub through the reaction time."
    ]
}
