//
// Reactions App
//
  

import Foundation

struct SecondOrderStatements {
    static let intro = [
        SpeechBubbleLineGenerator.makeLine("This is a Second Order Reaction."),
        SpeechBubbleLineGenerator.makeLine("Why don't you set the *initial concentration of A (c_1_)*, the reactant?")
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing! Let's take a snapshot!"),
        SpeechBubbleLineGenerator.makeLine("Now let's compare all the graphs we collected so far!"),
    ]
}
