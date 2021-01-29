//
// Reactions App
//
  

import CoreGraphics

struct ZeroOrderStatements {

    static let initial = [
        TextLineGenerator.makeLine(
            "This is a zero order reaction in which a reactant A turns into the product B. But what does it mean? Let's find out!"
        ),
        TextLineGenerator.makeLine(
            "*Set the initial concentration of A (c_1_) and the initial time at which it'll start (t_1_)*."
        )
    ]

    static func rateExplainer(k: CGFloat) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                """
                The order of a reaction has to do with the rate of it. *Rate* is the rate of \
                change in the concentration per unit time. The rate constant *k* is a value on \
                which the *rate* depends. For this reaction, $k=\(k.str(decimals: 3))M/s$.
                """
            )
        ]
    }

    static func halfLifeExplainer(halfLife: CGFloat) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                """
                *Half-life (t_1/2_)* is an expression to easily calculate the point in time at \
                which the concentration of the reactant, in this case *A*, is half of what the \
                initial concentration was. For this reaction, $*t_1/2_=\(halfLife.str(decimals: 2))s*$.
                """
            )
        ]
    }
    
    static let setFinalValues = [
        TextLineGenerator.makeLine(
            "Great! Now you can set the *concentration of A at the end of the reaction (c_2_)* and the *time the reaction will end (t_2_)*."
        )
    ]

    static func reactionInProgress(display: ReactionPairDisplay) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                """
                Let's watch how all the molecules are changing! As \(display.reactant.name) \
                disappears, \(display.product.name) is being produced.
                """
            ),
            TextLineGenerator.makeLine(
                "This happens at a constant *rate (in units of M/s),* which is dependent on *k*."
            )
        ]
    }

    static let endAnimation = [
        TextLineGenerator.makeLine("For this zero order reaction, *rate* is constant and it's equal to *k*, that's why a graph plotting \(Strings.aVsT) is a straight line."),
        TextLine(
            "[A]*(y)*=-kt*(mx)*+[A0]*(b)*",
            label: "Concentration of A (y), equals minus kt (mx) + A0 (b)"
        ),
        TextLine(
            "*Where -k is the slope*.",
            label: "where minus k is the slope"
        )
    ]

    static let showConcentrationTable = [
        TextLineGenerator.makeLine("You can click the button in the top right corner to see the initial and final concentration and time for this reaction."),
        TextLineGenerator.makeLine("*Try clicking the toggle to see your results*."),
    ]

    static let end = [
        TextLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        TextLineGenerator.makeLine("Try *dragging the time indicator* to scrub through the reaction time.")
    ]

}
