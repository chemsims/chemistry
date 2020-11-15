//
// Reactions App
//
  

import Foundation

struct ZeroOrderStatements {

    static let initial: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            "This is a zero Order Reaction."
        ),
        SpeechBubbleLineGenerator.makeLine(
            "Why don't you set the *initial time (t1)* and *initial concentration of A (c1)*, the reactant?"
        )
    ]

    static let setFinalValues: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            "Great! Now you can set the *concentration of A at the end of the reaction (c2)* and the *time the reaction will last (t2)*"
        )
    ]

    static let reactionInProgress: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            "Let's watch all the molecules changing"
        ),
        SpeechBubbleLineGenerator.makeLine(
            "As A disappears, B is being produced."
        )
    ]


    static var endStatement: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("Amazing!"),
        SpeechBubbleLineGenerator.makeLine("Let's take a snapshot! Now, let's try another."),
        SpeechBubbleLineGenerator.makeLine("*Choose a 2nd Order Reaction*.")
    ]
}
