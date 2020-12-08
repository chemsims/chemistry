//
// Reactions App
//
  

import Foundation

struct FirstOrderStatements {
    static let intro = [
        SpeechBubbleLineGenerator.makeLine("This is a First Order Reaction."),
        SpeechBubbleLineGenerator.makeLine("Why don't you set the *initial concentration of A [A_0_]*, the reactant?")
    ]

    static let setC2 = [
        SpeechBubbleLineGenerator.makeLine("Great! Now you can set the *concentration of A at the end of the reaction [A_t_]* and the *time the reaction will last (t)*."),
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing!"),
        SpeechBubbleLineGenerator.makeLine("Let's take a snapshot! Now, let's try another."),
        SpeechBubbleLineGenerator.makeLine("*Choose a 2nd Order Reaction*."),
    ]

    static let inProgress = ReactionStatements.inProgress
    
}
