//
// Reactions App
//
  

import CoreGraphics

struct ZeroOrderStatements {

    static let initial = [
        SpeechBubbleLineGenerator.makeLine(
            "This is a Zero Order Reaction in which a reactant A turns into the produt B. But what does it mean? Let's find out!"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "*Set the initial concentration of A (c_1_) and the initial time at which it'll start (t_1_)*."
        )
    ]

    static func rateExplainer(k: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                "The Order of a reaction has to do with the Rate of it. *Rate* is the rate of change in the concentration per unit time. The Rate Constant *k* is a value on which the Rate depends. For this reaction: *k=\(k.str(decimals: 3))M/s*"
            )
        ]
    }

    static func halfLifeExplainer(halfLife: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                "*Half Life (t_1/2_)* is an expression to easily calculate the point in time at which the concentration of the reactant, in this case *A*, is half of what the initial concentration was. For this reaction: *t_1/2_=\(halfLife.str(decimals: 2))s*"
            )
        ]
    }
    
    static let setFinalValues = [
        SpeechBubbleLineGenerator.makeLine(
            "Great! Now you can set the *concentration of A at the end of the reaction (c_2_)* and the *time the reaction will last (t_2_)*."
        )
    ]

    static let reactionInProgress = [
        SpeechBubbleLineGenerator.makeLine(
            "Let's watch how all the molecules are changing! As A disappears, B is being produced."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "This happens at a constant *Rate (in units of M/s),* which is dependant on *k*."
        )
    ]

    static let endAnimation = [
        SpeechBubbleLineGenerator.makeLine("For this Zero Order Reaction, *Rate* is constant and it's equal to *k*, that's why a graph plotting *([A] vs t)* is a straight line:"),
        SpeechBubbleLineGenerator.makeLine("[A]*(y)*=-kt*(mx)*+[A0]*(b)*"),
        SpeechBubbleLineGenerator.makeLine("*Where -k is the slope*.")
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        SpeechBubbleLineGenerator.makeLine("Try *dragging the time indicator* to scrub through the reaction time."),
        SpeechBubbleLineGenerator.makeLine("Then, let's see how Integrated Rate Law works.")
    ]

}
