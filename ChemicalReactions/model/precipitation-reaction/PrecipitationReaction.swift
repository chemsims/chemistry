//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PrecipitationReaction: Identifiable, Equatable {
    let knownReactant: KnownReactant
    let unknownReactant: UnknownPrecipitationReactant
    let product: Product
    let secondaryProduct: SecondaryProduct

    var id: String {
        "\(knownReactant.id):\(unknownReactant.id):\(product.id):\(secondaryProduct.id)"
    }

    func name(showMetal: Bool) -> TextLine {
        getName(
            elementName: \.name,
            elementWithMetalName: { $0.name(showMetal: showMetal) }
        )
    }

    func nameWithState(showMetal: Bool) -> TextLine {
        getName(
            elementName: \.nameWithState,
            elementWithMetalName: { $0.nameWithState(showMetal: showMetal) }
        )
    }

    private func getName(
        elementName: KeyPath<PrecipitationElement, TextLine>,
        elementWithMetalName: (PrecipitationElementWithUnknownMetal) -> TextLine
    ) -> TextLine {
        let r1 = elementWithMetalName(unknownReactant)
        let r2 = knownReactant[keyPath: elementName]
        let p1 = product[keyPath: elementName]
        let p2 = elementWithMetalName(secondaryProduct)
        let reactants = r1 + " + " + r2
        let products = p1 + " + " + p2
        return reactants + " ➝ " + products
    }
}

extension PrecipitationReaction {
    enum Metal: String, CaseIterable {
        case Na
        case Li
        case K

        var atomicWeight: Int {
            switch self {
            case .Na: return 23
            case .Li: return 7
            case .K: return 39
            }
        }
    }
}

protocol PrecipitationElement {
    var name: TextLine { get }
    var state: ElementState { get }
}

extension PrecipitationElement {

    var id: String {
        nameWithState.asString
    }

    var nameWithState: TextLine {
        name + "_(\(state.symbol))_"
    }
}

protocol PrecipitationElementWithUnknownMetal {
    var latterPart: TextLine { get }
    var coeff: Int { get }
    var metal: PrecipitationReaction.Metal { get }
    var metalAtomCount: Int { get }
    var state: ElementState { get }
}

extension PrecipitationElementWithUnknownMetal {

    var id: String {
        nameWithState(showMetal: true).asString
    }

    /// - Parameter emphasiseMetal: Whether to emphasise the metal element, when the metal is shown.
    func nameWithState(showMetal: Bool, emphasiseMetal: Bool = false) -> TextLine {
        name(showMetal: showMetal, emphasiseMetal: emphasiseMetal) + "_(\(state.symbol))_"
    }

    /// - Parameter emphasiseMetal: Whether to emphasise the metal element, when the metal is shown.
    func name(showMetal: Bool, emphasiseMetal: Bool = false) -> TextLine {
        let coeffNum = coeff == 1 ? "" : "\(coeff)"
        let metal = metalStr(showMetal: showMetal, emphasise: emphasiseMetal)
        return "\(coeffNum)\(metal)" + latterPart
    }

    private func metalStr(showMetal: Bool, emphasise: Bool) -> String {
        let metalValue = showMetal ? metal.rawValue : "M"
        return metalStr(metalValue: metalValue, emphasise: emphasise)
    }

    private func metalStr(metalValue: String, emphasise: Bool) -> String {
        let countSuffix = metalAtomCount == 1 ? "" : "_\(metalAtomCount)_"
        let emphasis = emphasise ? "*" : ""
        return "\(emphasis)\(metalValue)\(emphasis)\(countSuffix)"
    }
}

extension PrecipitationReaction {

    struct KnownReactant: Equatable, PrecipitationElement {
        let name: TextLine
        let state: ElementState
        let color: Color
    }

    struct Product: Equatable, PrecipitationElement {
        let name: TextLine
        let state: ElementState
        let molarMass: Int
        let color: Color
    }

    struct UnknownPrecipitationReactant: Equatable, PrecipitationElementWithUnknownMetal {
        let latterPart: TextLine
        let state: ElementState
        let latterPartMolarMass: Int

        let metal: PrecipitationReaction.Metal
        let metalAtomCount: Int
        let coeff: Int
        let color: Color

        var molarMass: Int {
            latterPartMolarMass + (metalAtomCount * metal.atomicWeight)
        }

        func replacingMetal(with newMetal: Metal) -> UnknownPrecipitationReactant {
            .init(
                latterPart: latterPart,
                state: state,
                latterPartMolarMass: latterPartMolarMass,
                metal: newMetal,
                metalAtomCount: metalAtomCount,
                coeff: coeff,
                color: color
            )
        }
    }

    struct SecondaryProduct: Equatable, PrecipitationElementWithUnknownMetal {
        let latterPart: TextLine
        let coeff: Int
        let metal: Metal
        let metalAtomCount: Int
        let state: ElementState
    }
}
