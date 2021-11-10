//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct LimitingReagentReaction: Equatable {

    let yield: CGFloat

    let limitingReactant: LimitingReactant
    let excessReactant: ExcessReactant
    let product: Product

    let firstExtraProduct: NonReactingProduct?
    let secondExtraProduct: NonReactingProduct?
}

extension LimitingReagentReaction: Identifiable {
    var id: String {
        label
    }
}

extension LimitingReagentReaction {
    var displayString: TextLine {
        reactionLine(getName: \.nameWithCoeff)
    }

    var reactionDisplayWithElementState: TextLine {
        reactionLine(getName: \.nameWithCoeffAndState)
    }

    var reactionDisplayWithEmphasisedElementState: TextLine {
        reactionLine(getName: \.nameWithCoeffAndEmphasisedState)
    }

    private func reactionLine(
        getName: KeyPath<ElementDisplay, TextLine>
    ) -> TextLine {
        let reactants = reactantLine(getName: getName)
        let products = productsLine(getName: getName)
        return TextLine(
            reactants.asMarkdown + " ➝ " + products.asMarkdown,
            label: reactants.asString + " yields " + products.asString
        )
    }

    private func reactantLine(
        getName: KeyPath<ElementDisplay, TextLine>
    ) -> TextLine {
        let reactant1 = excessReactant[keyPath: getName]
        let reactant2 = limitingReactant[keyPath: getName]
        return reactant1 + " + " + reactant2
    }

    private func productsLine(
        getName: KeyPath<ElementDisplay, TextLine>
    ) -> TextLine {
        var builder: TextLine = ""
        if let first = firstExtraProduct {
            builder = builder + first[keyPath: getName] + " + "
        }
        builder = builder + product[keyPath: getName]
        if let second = secondExtraProduct {
            builder = builder + " + " + second[keyPath: getName]
        }
        return builder
    }

    var label: String {
        displayString.label
    }
}

extension LimitingReagentReaction {

    struct NonReactingProduct: Equatable {
        let name: TextLine
        let state: ElementState
        let coefficient: Int

        var nameWithCoeff: TextLine {
            coefficient == 1 ? name : "\(coefficient)" + name
        }
    }

    struct LimitingReactant: Equatable {
        let name: TextLine
        let state: ElementState
        let color: Color
    }

    struct ExcessReactant: Equatable {
        let name: TextLine
        let state: ElementState
        let color: Color
        let coefficient: Int
        let molarMass: Int

        var nameWithCoeff: TextLine {
            coefficient == 1 ? name : "\(coefficient)" + name
        }
    }

    struct Product: Equatable {
        let name: TextLine
        let state: ElementState
        let color: Color
        let molarMass: Int
    }
}


private protocol ElementDisplay {
    var name: TextLine { get }
    var coefficient: Int { get }
    var state: ElementState { get }
}

extension ElementDisplay {
    var nameWithCoeff: TextLine {
        coefficient == 1 ? name : "\(coefficient)" + name
    }

    var nameWithCoeffAndState: TextLine {
        nameWithCoeff + "_(\(state.symbol))_"
    }

    var nameWithCoeffAndEmphasisedState: TextLine {
        nameWithCoeff + "_*(\(state.symbol))*_"
    }
}

extension LimitingReagentReaction.LimitingReactant: ElementDisplay {
    fileprivate var coefficient: Int {
        1
    }
}

extension LimitingReagentReaction.ExcessReactant: ElementDisplay { }

extension LimitingReagentReaction.Product: ElementDisplay {
    fileprivate var coefficient: Int {
        1
    }
}

extension LimitingReagentReaction.NonReactingProduct: ElementDisplay { }

extension LimitingReagentReaction {

    static let availableReactions = [
        firstReaction,
        secondReaction
    ]

    static func fromId(_ id: String) -> LimitingReagentReaction? {
        switch id {
        case firstReaction.id: return firstReaction
        case secondReaction.id: return secondReaction
        default: return nil
        }
    }

    private static let firstReaction = LimitingReagentReaction(
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
            molarMass: 84
        ),
        product: .init(
            name: "Na_2_C_2_O_4_",
            state: .aqueous,
            color: .blue,
            molarMass: 134
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

    private static let secondReaction = LimitingReagentReaction(
        yield: 0.96,
        limitingReactant: .init(
            name: "HNO_3_",
            state: .aqueous,
            color: .red
        ),
        excessReactant: .init(
            name: "NaOH",
            state: .aqueous,
            color: .purple,
            coefficient: 1,
            molarMass: 40
        ),
        product: .init(
            name: "NaNO_3_",
            state: .aqueous,
            color: .black,
            molarMass: 85
        ),
        firstExtraProduct: nil,
        secondExtraProduct: .init(
            name: "H_2_O",
            state: .liquid,
            coefficient: 1
        )
    )
}
