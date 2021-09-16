//
// Reactions App
//

import Foundation
import ReactionsCore

struct EnergyProfileFilingStatements {
    static func statement(
        catalyst: Catalyst,
        order: ReactionOrder,
        nextCatalyst: Catalyst?
    ) -> [TextLine] {
        var lines = [
            TextLineGenerator.makeLine(
                """
                This is the \(order.name.lowercased()) order reaction you completed earlier using *catalyst \
                \(catalyst.rawValue)*.
                """
            )
        ]

        if let next = nextCatalyst {
            lines.append(
                TextLineGenerator.makeLine(
                    "Swipe left or tap next to see the reaction using the catalyst \(next)."
                )
            )
        }

        return lines
    }
}
