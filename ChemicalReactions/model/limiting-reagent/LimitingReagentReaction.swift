//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct LimitingReagentReaction {

    let yield: CGFloat

    let limitingReactant: LimitingReactant
    let excessReactant: ExcessReactant
    let product: Product

    let firstExtraProduct: NonReactingProduct
    let secondExtraProduct: NonReactingProduct
}

extension LimitingReagentReaction {
    static let firstReaction = LimitingReagentReaction(
        yield: 0.98,
        limitingReactant: .init(
            name: "H_2_C_2_O_4_",
            state: .aqueous,
            color: .red
        ),
        excessReactant: .init(
            name: "NaHCO_3_",
            state: .solid,
            color: .purple,
            coefficient: 2,
            molecularMass: 84
        ),
        product: .init(
            name: "Na_2_C_2_O_4_",
            state: .aqueous,
            color: .blue,
            molecularMass: 134
        ),
        firstExtraProduct: .init(
            name: "H_2_O",
            state: .liquid,
            coefficient: 2
        ),
        secondExtraProduct: .init(
            name: "CO_2_",
            state: .gaseous,
            coefficient: 2
        )
    )
}

extension LimitingReagentReaction {

    struct NonReactingProduct {
        let name: TextLine
        let state: ElementState
        let coefficient: Int
    }

    struct LimitingReactant {
        let name: TextLine
        let state: ElementState
        let color: Color
    }

    struct ExcessReactant {
        let name: TextLine
        let state: ElementState
        let color: Color
        let coefficient: Int
        let molecularMass: Int
    }

    struct Product {
        let name: TextLine
        let state: ElementState
        let color: Color
        let molecularMass: Int
    }

    enum ElementState {
        case aqueous, liquid, solid, gaseous
    }
}
