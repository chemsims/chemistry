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

        /// The minimum C for second order reaction B
        static let minCForSecondOrderReactionB: CGFloat = 0.4

        /// The smallest input range the user should be given to adjust C by.
        /// This in turn will impact limits of other coupled limits (such as the other concentration value being set), to ensure
        /// this range is provided
        static let minCRange: CGFloat = 0.05

        /// The smallest C2 input the user can be given. i.e., the range of C2 the user can select will be at least `minC` to `minC2Input`
        static let minC2Input: CGFloat = minC + minCRange

        static let minT1: CGFloat = 0
        static let minT2: CGFloat = 3
        static let maxT: CGFloat = 20
        static let minTRange: CGFloat = 2
        static let minT2Input: CGFloat = maxT - minTRange
    }

    static let initialC: CGFloat = 0.7
    static let initialT: CGFloat = 10

    /// Fixed rate constant for B reactions (i.e., the second reaction type which can be chosen on parts 1-3)
    static let reactionBRateConstant: CGFloat = 0.04

    /// Fixed rate constant for C reactions (i.e., the third reaction type which can be chosen on parts 1-3)
    static let reactionCRateConstant: CGFloat = 0.07
}
