//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidReactionDefinition: Equatable {
    let leftTerms: [Term]
    let rightTerms: [Term]

    struct Term: Equatable {
        let name: TextLine
        let color: Color
    }

    /// Accessibility label
    var label: String {
        let lhs = labelOfTerms(leftTerms)
        let rhs = labelOfTerms(rightTerms)
        return "\(lhs), double sided arrow, \(rhs)"
    }

    private func labelOfTerms(_ terms: [Term]) -> String {
        let labels = terms.map { $0.name.label }
        if let first = labels.first {
            return labels.dropFirst().reduce(first) { (acc, next) in
                "\(acc) + \(next)"
            }
        }

        return ""
    }
}
