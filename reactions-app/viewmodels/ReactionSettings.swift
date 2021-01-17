//
// Reactions App
//


import CoreGraphics

struct ReactionSettings {

    struct Axis {
        static let minC: CGFloat = 0
        static let maxC: CGFloat = 1
        static let minT: CGFloat = 0
        static let maxT: CGFloat = 20

        static let minLogC: CGFloat = -4
        static let maxLogC: CGFloat = 0

        static let minInverseC: CGFloat = 0
        static let maxInverseC: CGFloat = 10
    }

    struct Input {
        static let minC: CGFloat = 0.1
        static let maxC: CGFloat = 1
        static let minC2Input: CGFloat = 0.15

        static let minT1: CGFloat = 0
        static let minT2: CGFloat = 3
        static let maxT: CGFloat = 20
        static let minT2Input: CGFloat = 16
    }

    static let initialC: CGFloat = 0.7
    static let initialT: CGFloat = 10


    /// Fixed rate constant for B reactions (i.e., the second reaction type which can be chosen on parts 1-3)
    static let reactionBRateConstant: CGFloat = 0.04

    /// Fixed rate constant for C reactions (i.e., the third reaction type which can be chosen on parts 1-3)
    static let reactionCRateConstant: CGFloat = 0.07
}
