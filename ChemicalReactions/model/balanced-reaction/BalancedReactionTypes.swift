//
// Reactions App
//

import Foundation

extension BalancedReaction {

    static let availableReactions = [
        firstReaction,
        secondReaction,
        thirdReaction,
        fourthReaction,
        fifthReaction
    ]

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

    private static let secondReaction = BalancedReaction(
        reactants: .one(element: .init(molecule: .water, coefficient: 2)),
        products: .two(
            first: .init(molecule: .dihydrogen, coefficient: 2),
            second: .init(molecule: .dioxygen, coefficient: 1)
        )
    )

    private static let thirdReaction = BalancedReaction(
        reactants: .two(
            first: .init(molecule: .dinitrogen, coefficient: 1),
            second: .init(molecule: .dihydrogen, coefficient: 3)
        ),
        products: .one(element: .init(molecule: .ammonia, coefficient: 2)
        )
    )

    private static let fourthReaction = BalancedReaction(
        reactants: .two(
            first: .init(molecule: .dinitrogen, coefficient: 2),
            second: .init(molecule: .water, coefficient: 6)
        ),
        products: .two(
            first: .init(molecule: .ammonia, coefficient: 4),
            second: .init(molecule: .dioxygen, coefficient: 3)
        )
    )

    private static let fifthReaction = BalancedReaction(
        reactants: .two(
            first: .init(molecule: .ammonia, coefficient: 4),
            second: .init(molecule: .dioxygen, coefficient: 7)
        ),
        products: .two(
            first: .init(molecule: .nitriteIon, coefficient: 4),
            second: .init(molecule: .water, coefficient: 6)
        )
    )
}
