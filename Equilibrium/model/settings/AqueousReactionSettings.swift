//
// Reactions App
//


import CoreGraphics

// TODO - make this use the reaction timing struct
struct AqueousReactionSettings {
    static let minRows = 6
    static let maxRows = 14

    static let initialRows = (minRows + maxRows) / 2

    static let firstReactionTiming = ReactionTiming.standard(reactionIndex: 0)
    static let secondReactionTiming = ReactionTiming.standard(reactionIndex: 1)

    /// The time at which the concentrations should converge
    static let timeForConvergence: CGFloat = ReactionTiming.equilibriumTime

    /// The total reaction time
    static let forwardReactionTime: CGFloat = ReactionTiming.totalReactionTime

    /// Time when the product is added
    static let timeToAddProduct: CGFloat = ReactionTiming.totalReactionTime + ReactionTiming.gapBetweenReactions

    /// The time convergence is reached in the reverse reaction
    static let timeForReverseConvergence: CGFloat = 35

    /// The time for the reverse reaction, including the time before product is added
    static let endOfReverseReaction: CGFloat = 40

    struct ConcentrationInput {
        static let minInitial: CGFloat = 0.15
        static let maxInitial: CGFloat = 0.3

        static let minFinal: CGFloat = 0.05

        static let cToIncrement: CGFloat = 0.05

        static let maxAxis: CGFloat = 0.5

        static let minProductIncrement: CGFloat = 0.15
    }

    struct Scales {
        /// The concentration sum at which the scales are at their maximum rotation
        /// The concentration sum is A + B - C - D
        ///
        /// So, if A + B equals this value, and C + D is zero, then the scales are at their maximum rotation to the left
        static let concentrationSumAtMaxScaleRotation: CGFloat = 2 * AqueousReactionSettings.ConcentrationInput.maxInitial

        /// The concentration at which the pile of molecules is at its max
        static let concentrationForMaxBasketPile: CGFloat = 0.4
    }
}
