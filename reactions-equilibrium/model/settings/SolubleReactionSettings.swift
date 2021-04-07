//
// Reactions App
//

import CoreGraphics

struct SolubleReactionSettings {
    static let minWaterHeight: CGFloat = 0.4
    static let maxWaterHeight: CGFloat = 0.7

    static let saturatedSoluteParticlesToAdd = 5
    static let commonIonSoluteParticlesToAdd = 5
    static let acidSoluteParticlesToAdd = 5

    static let maxInitialBConcentration: CGFloat = 0.15

    static let firstReactionTiming = ReactionTiming.standard(reactionIndex: 0)
    static let secondReactionTiming = ReactionTiming.standard(reactionIndex: 1)


    struct PhCurve {
        static let curve = SolubilityChartEquation(
            zeroPhSolubility: 1,
            maxPhSolubility: 0.9,
            minSolubility: 0.3,
            phAtMinSolubility: 0.6
        )
    }

    static let startingPh: CGFloat = 0.88
    static let saturatedSolubility: CGFloat = PhCurve.curve.getY(at: startingPh)
    static let superSaturatedSolubility: CGFloat = 1.25 * saturatedSolubility
    static let phForAcidSaturation: CGFloat = PhCurve.curve.getLeftHandPh(for: superSaturatedSolubility)!
}
