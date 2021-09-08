//
// Reactions App
//

import Foundation

extension BalancedReaction {

    static let firstReaction = BalancedReaction(
        reactants: .two(
            first: .init(molecule: .methane, coefficient: 1),
            second: .init(molecule: .dioxygen, coefficient: 2)
        ),
        products: .two(
            first: .init(molecule: .carbonDioxide, coefficient: 1),
            second: .init(molecule: .water, coefficient: 2)
        )
    )
}
