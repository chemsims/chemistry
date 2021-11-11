//
// Reactions App
//

import ReactionsCore
import Foundation

extension PrecipitationReaction {

    /// Returns a list of available reactions, using a random metal as the unknown element
    static func availableReactionsWithRandomMetals() -> [PrecipitationReaction] {
        [
            firstReaction(metal: Metal.allCases.randomElement()!),
            secondReaction(metal: Metal.allCases.randomElement()!)
        ]
    }

    static func fromId(_ id: String, metal: Metal) -> PrecipitationReaction? {
        switch id {
        case firstReaction(metal: metal).id: return firstReaction(metal: metal)
        case secondReaction(metal: metal).id: return secondReaction(metal: metal)
        default: return nil
        }
    }

    private static func firstReaction(metal: Metal) -> PrecipitationReaction {
        PrecipitationReaction(
            knownReactant: .init(
                name: "CaCl_2_",
                state: .aqueous,
                color: Styling.Precipitation.knownReactant1
            ),
            unknownReactant: .init(
                latterPart: "CO_3_",
                state: .aqueous,
                latterPartMolarMass: 60,
                metal: metal,
                metalAtomCount: 2,
                coeff: 1,
                color: Styling.Precipitation.unknownReactant1
            ),
            product: .init(
                name: "CaCO_3_",
                state: .solid,
                molarMass: 100,
                color: Styling.Precipitation.product1
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
            knownReactant: .init(
                name: "Pb(NO_3_)_2_",
                state: .aqueous,
                color: Styling.Precipitation.knownReactant2
            ),
            unknownReactant: .init(
                latterPart: "I",
                state: .aqueous,
                latterPartMolarMass: 127,
                metal: metal,
                metalAtomCount: 1,
                coeff: 2,
                color: Styling.Precipitation.unknownReactant2
            ),
            product: .init(
                name: "PbI_2_",
                state: .solid,
                molarMass: 334,
                color: Styling.Precipitation.product2
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
