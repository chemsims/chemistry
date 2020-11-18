//
// Reactions App
//
  

import Foundation

struct ReactionComparisonStatements {

    static let intro: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            "Can you identify the orders? Press next to find out!"
        )
    ]

    static let inProgress: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            "Compare one graph to another!"
        )
    ]

    static let end: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            "Took a while, didn't it? Let's see how we can *make things faster*."
        )
    ]

}
