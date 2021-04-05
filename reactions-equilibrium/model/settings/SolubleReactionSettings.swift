//
// Reactions App
//

import CoreGraphics

struct SolubleReactionSettings {
    static let minWaterHeight: CGFloat = 0.4
    static let maxWaterHeight: CGFloat = 0.7

    static let saturatedSoluteParticlesToAdd = 5
    static let commonIonSoluteParticlesToAdd = 5

    static let maxInitialBConcentration: CGFloat = 0.15

    static let firstReactionTiming = ReactionTiming.standard(reactionIndex: 0)
    static let secondReactionTiming = ReactionTiming.standard(reactionIndex: 1)
}
