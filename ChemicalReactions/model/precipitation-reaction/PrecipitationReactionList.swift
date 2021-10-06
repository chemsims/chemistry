//
// Reactions App
//

import Foundation

extension PrecipitationReaction {

    /// Returns a list of available reactions, using a random metal as the unknown element
    static func availableReactionsWithRandomMetals() -> [PrecipitationReaction] {
        [
            firstReaction(metal: Metal.allCases.randomElement()!),
            secondReaction(metal: Metal.allCases.randomElement()!)
        ]
    }

    private static func firstReaction(metal: Metal) -> PrecipitationReaction {
        PrecipitationReaction(
            knownReactant: .init(name: "CaCl_2_", state: .aqueous),
            unknownReactant: .init(
                latterPart: "CO_3_",
                state: .aqueous,
                latterPartMolarMass: 60,
                metal: metal,
                metalAtomCount: 2,
                coeff: 1
            ),
            product: .init(
                name: "CaCO_3_",
                state: .solid,
                molarMass: 100
            ),
            secondaryProduct: .init(
                latterPart: "Cl",
                coeff: 2,
                metal: metal,
                metalAtomCount: 1,
                state: .aqueous
            )
        )
    }

    private static func secondReaction(metal: Metal) -> PrecipitationReaction {
        .init(
            knownReactant: .init(name: "Pb(NO_3_)_2_", state: .aqueous),
            unknownReactant: .init(
                latterPart: "I",
                state: .aqueous,
                latterPartMolarMass: 127,
                metal: metal,
                metalAtomCount: 1,
                coeff: 2
            ),
            product: .init(
                name: "PbI_2_",
                state: .solid,
                molarMass: 334
            ),
            secondaryProduct: .init(
                latterPart: "NO_3_",
                coeff: 2,
                metal: metal,
                metalAtomCount: 1,
                state: .aqueous
            )
        )
    }
}
