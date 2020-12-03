//
// Reactions App
//
  

import Foundation

struct ZeroOrderStatements {

    static let initial = [
        SpeechBubbleLineGenerator.makeLine(
            "This is a zero Order Reaction."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "Why don't you set the *initial time (t1)* and *initial concentration of A (c1)*, the reactant?"
        )
    ]
    
    static let setFinalValues = [
        SpeechBubbleLineGenerator.makeLine(
            "Great! Now you can set the *concentration of A at the end of the reaction (c2)* and the *time the reaction will last (t2)*."
        )
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        SpeechBubbleLineGenerator.makeLine("Now, let's see how Integrated Rate Law works. *Choose a 1st Order Reaction*.")
    ]

}
