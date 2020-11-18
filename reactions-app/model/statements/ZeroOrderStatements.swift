//
// Reactions App
//
  

import Foundation

struct ZeroOrderStatements {

    static let initial = ReactionStatements.orderIntro(order: "first")
    static let setFinalValues = ReactionStatements.orderSetFinalState
    static let inProgress = ReactionStatements.inProgress

    static var endStatement: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("Amazing!"),
        SpeechBubbleLineGenerator.makeLine("Let's take a snapshot! Now, let's try another."),
        SpeechBubbleLineGenerator.makeLine("*Choose a 2nd Order Reaction*.")
    ]
}
