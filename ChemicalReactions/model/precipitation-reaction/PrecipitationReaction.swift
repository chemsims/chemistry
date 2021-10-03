//
// Reactions App
//

import Foundation
import ReactionsCore

struct PrecipitationReaction: Identifiable, Equatable {
    let knownReactant: Element
    let unknownReactant: UnknownPrecipitationReactant
    let product: Product

    var id: String {
        "\(knownReactant.id):\(unknownReactant.id):\(product.id)"
    }

    var displayWithoutUnknownMetal: TextLine {
        let reactants = unknownReactant.unknownDisplay + " + " + knownReactant.display
        let products = product.display
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


extension PrecipitationReaction {

    struct Element: Equatable {
        let name: TextLine
        let state: ElementState

        var id: String {
            display.asString
        }

        var display: TextLine {
            name + "_(\(state.symbol))_"
        }
    }

    struct Product: Equatable {
        let name: TextLine
        let state: ElementState
        let molarMass: Int

        var display: TextLine {
            name + "_(\(state.symbol))_"
        }

        var id: String {
            display.asString
        }
    }

    struct UnknownPrecipitationReactant: Equatable {
        let latterPart: TextLine
        let state: ElementState
        let latterPartMolarMass: Int

        let metal: PrecipitationReaction.Metal
        let metalAtomCount: Int
        let coeff: Int

        var id: String {
            knownDisplay.asString + state.symbol
        }

        var molarMass: Int {
            latterPartMolarMass + (metalAtomCount * metal.atomicWeight)
        }

        var unknownDisplay: TextLine {
            coeffTextLine + "M" + latterPartWithState
        }

        var knownDisplay: TextLine {
            coeffTextLine + metalTextLine + latterPartWithState
        }

        func replacingMetal(with newMetal: Metal) -> UnknownPrecipitationReactant {
            .init(
                latterPart: latterPart,
                state: state,
                latterPartMolarMass: latterPartMolarMass,
                metal: newMetal,
                metalAtomCount: metalAtomCount,
                coeff: coeff
            )
        }

        private var latterPartWithState: TextLine {
            latterPart + "_(\(state.symbol))_"
        }

        private var coeffTextLine: TextLine {
            coeff > 1 ? "\(coeff)" : ""
        }

        private var metalTextLine: TextLine {
            if metalAtomCount > 1 {
                return "*\(metal.rawValue)*_\(metalAtomCount)_"
            }
            return "*\(metal.rawValue)*"
        }
    }
}
