//
// Reactions App
//

import ReactionsCore
import SwiftUI

extension PrecipitationComponents {
    enum Phase {
        case addKnownReactant,
             addUnknownReactant,
             runReaction,
             addExtraUnknownReactant,
             runFinalReaction
    }
}

extension PrecipitationComponents {
    struct Settings {
        init(
            minConcentrationOfKnownReactantPostFirstReaction: CGFloat = 0.1,
            minConcentrationOfUnknownReactantToReact: CGFloat = 0.1
        ) {
            self.minConcentrationOfKnownReactantPostFirstReaction = minConcentrationOfKnownReactantPostFirstReaction
            self.minConcentrationOfUnknownReactantToReact = minConcentrationOfUnknownReactantToReact
        }
        let minConcentrationOfKnownReactantPostFirstReaction: CGFloat
        let minConcentrationOfUnknownReactantToReact: CGFloat

        let precipitateGrowthMagnitude: Range<CGFloat> = 0.15..<0.25
    }
}

extension PrecipitationComponents {
    enum Reactant: Int, Identifiable, CaseIterable {
        case known, unknown

        var id: Int {
            rawValue
        }

        var molecule: Molecule {
            switch self {
            case .known: return .knownReactant
            case .unknown: return .unknownReactant
            }
        }
    }

    enum Molecule: Int, CaseIterable {
        case knownReactant, unknownReactant, product

        func name(reaction: PrecipitationReaction) -> TextLine {
            switch self {
            case .knownReactant: return reaction.knownReactant.name
            case .unknownReactant: return reaction.unknownReactant.name(showMetal: false)
            case .product: return reaction.product.name
            }
        }

        // TODO, store color on the reaction definition
        func color(reaction: PrecipitationReaction) -> Color {
            switch self {
            case .knownReactant: return .red
            case .unknownReactant: return .blue
            case .product: return .orange
            }
        }
    }
}

