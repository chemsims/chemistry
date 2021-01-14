//
// Reactions App
//


import CoreGraphics

struct ReactionSettings {

    // TODO rename axis settings variables
    // Axis settings
    static let minConcentration: CGFloat = 0
    static let maxConcentration: CGFloat = 1
    static let minTime: CGFloat = 0
    static let maxTime: CGFloat = 20

    // Input settings

    /// Minimum allowed C input on the slider
    static let minCInput: CGFloat = 0.1
    static let maxCInput: CGFloat = 1
    static let minT1Input: CGFloat = 0
    static let minT2Input: CGFloat = 3
    static let maxTInput: CGFloat = 20
    static let initialC: CGFloat = 0.7
    static let initialT: CGFloat = 10
    
    static let minLogConcentration: CGFloat = -4
    static let maxLogConcentration: CGFloat = 0

    static let minInverseConcentration: CGFloat = 0
    static let maxInverseConcentration: CGFloat = 10

    /// The minimum range of the C2 input
    static let minC2InputRange: CGFloat = 0.05

    /// The minimum value that time 2 may be. Time 1 is limited to ensure there is sufficient space
    static let minFinalTime: CGFloat = 15

    /// Fixed rate constant for B reactions (i.e., the second reaction type which can be chosen on parts 1-3)
    static let reactionBRateConstant: CGFloat = 0.04

    /// Fixed rate constant for C reactions (i.e., the third reaction type which can be chosen on parts 1-3)
    static let reactionCRateConstant: CGFloat = 0.07
}
