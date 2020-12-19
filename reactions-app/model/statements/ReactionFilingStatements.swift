//
// Reactions App
//
  

import Foundation

struct ReactionFilingStatements {

    static func message(
        order: ReactionOrder,
        next: ReactionOrder?
    ) -> [SpeechBubbleLine] {
        var msg = [
            SpeechBubbleLineGenerator.makeLine("This is the \(order.string) Order Reaction you completed earlier."),
            SpeechBubbleLineGenerator.makeLine("*Drag the chart to scrub through the reaction time.*")
        ]

        if let next = next {
            msg.append(
                SpeechBubbleLineGenerator.makeLine("Swipe left or press next to see your \(next.string) Order Reaction.")
            )
        }

        return msg
    }

    // This message is blurred, but it's worth writing something as it's still partially visible
    static let blankMessage = [
        SpeechBubbleLineGenerator.makeLine("This screen will become available when you've completed this part of the app!")
    ]
}

fileprivate extension ReactionOrder {
    var string: String {
        switch (self) {
        case .Zero: return "Zero"
        case .First: return "First"
        case .Second: return "Second"
        }
    }
}
