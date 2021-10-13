//
// Reactions App
//

import ReactionsCore
import SwiftUI

extension PrecipitationComponents {
    enum Phase: Int, Comparable, CaseIterable {
        case addKnownReactant,
             addUnknownReactant,
             runReaction,
             addExtraUnknownReactant,
             runFinalReaction

        static func <(_ lhs: Phase, _ rhs: Phase) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension PrecipitationComponents {
    struct Settings {
        init(
            minConcentrationOfKnownReactantPostFirstReaction: CGFloat = 0.15,
            minConcentrationOfUnknownReactantToReact: CGFloat = 0.15
        ) {
            self.minConcentrationOfKnownReactantPostFirstReaction = minConcentrationOfKnownReactantPostFirstReaction
            self.minConcentrationOfUnknownReactantToReact = minConcentrationOfUnknownReactantToReact
        }
        let minConcentrationOfKnownReactantPostFirstReaction: CGFloat
        let minConcentrationOfUnknownReactantToReact: CGFloat

        let addMoleculeReactionProgressDuration: TimeInterval = 0.5

        let precipitateGrowthSteps = 4
        let precipitatePoints = 7
        let precipitateCenter = CGPoint(x: 0.5, y: 0.75)
        let precipitateGrowthMagnitude: Range<CGFloat> = 0.23..<0.48
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

        func color(reaction: PrecipitationReaction) -> Color {
            switch self {
            case .knownReactant: return reaction.knownReactant.color
            case .unknownReactant: return reaction.unknownReactant.color
            case .product: return reaction.product.color
            }
        }
    }
}

