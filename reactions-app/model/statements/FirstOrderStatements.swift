//
// Reactions App
//
  

import Foundation

struct FirstOrderStatements {
    static let intro = [
        SpeechBubbleLineGenerator.makeLine("This is a First Order Reaction."),
        SpeechBubbleLineGenerator.makeLine("Why don't you set the *initial concentration of A [A0]*, the reactant?")
    ]

    static let setC2 = [
        SpeechBubbleLineGenerator.makeLine("Great! Now you can set the *concentration of A at the end of the reaction [At]* and the *time the reaction will last (t)*."),
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Amazing!"),
        SpeechBubbleLineGenerator.makeLine("Let's take a snapshot! Now, let's try another."),
        SpeechBubbleLineGenerator.makeLine("*Choose a 2nd Order Reaction*."),
    ]

    static let inProgress = ReactionStatements.inProgress
    
}
