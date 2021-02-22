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
        let firstLine = "This is the \(order.name.lowercased()) order reaction you created earlier\(msgSuffix)"

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

    static func pageNotEnabledMessage(order: ReactionOrder) -> String {
        """
        When you've completed the whole app, head back to the \(order.name) order reaction screen to try a
        different reaction type, which will then show up here.
        """
    }

    private static func rateConstant(reactionType: ReactionType) -> String? {
        switch reactionType {
        case .A: return nil
        case .B: return ReactionSettings.reactionBRateConstant.str(decimals: 2)
        case .C: return ReactionSettings.reactionCRateConstant.str(decimals: 2)
        }
    }

    // This message will be blurred, but it's worth writing something as it's still partially visible
    static let blankMessage: [TextLine] = [
        "This screen will become available when you've completed this part of the app!"
    ]

}
