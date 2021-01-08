//
// Reactions App
//
  

import Foundation

struct ReactionFilingStatements {

    static func message(
        order: ReactionOrder,
        reactionType: ReactionType
    ) -> [TextLine] {

        let rateConstantMsg = rateConstant(reactionType: reactionType).map { k in
            ", which has a fixed rate constant of \(k)."
        }
        let msgSuffix = rateConstantMsg ?? "."
        let firstLine = "This is the \(order.string) Order Reaction you created earlier\(msgSuffix)"

        let hasNext = reactionType != .C

        var msg = [
            TextLineGenerator.makeLine(firstLine),
            TextLineGenerator.makeLine("*Drag the chart to scrub through the reaction time.*")
        ]

        if hasNext {
            msg.append(
                TextLineGenerator.makeLine("Swipe left or press next to see another reaction type.")
            )
        }

        return msg
    }

    private static func rateConstant(reactionType: ReactionType) -> String? {
        switch (reactionType) {
        case .A: return nil
        case .B: return ReactionSettings.reactionBRateConstant.str(decimals: 2)
        case .C: return ReactionSettings.reactionCRateConstant.str(decimals: 2)
        }
    }

    // This message is blurred, but it's worth writing something as it's still partially visible
    static func blankMessage(order: ReactionOrder, reactionType: ReactionType) -> [TextLine] {
        assert(reactionType != .A)
        return [
            TextLineGenerator.makeLine("""
            When you've completed the whole app, head back to the \(order.string) screen to try a
            different reaction, which will then show up here
            """)
        ]
    }
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
