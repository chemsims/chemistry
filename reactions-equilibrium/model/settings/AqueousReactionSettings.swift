//
// Reactions App
//


import CoreGraphics

struct AqueousReactionSettings {
    static let minRows = 6
    static let maxRows = 14

    static let initialRows = (minRows + maxRows) / 2

    /// The time at which the concentrations should converge
    static let timeForConvergence: CGFloat = 15

    /// The total reaction time
    static let totalReactionTime: CGFloat = 20

    struct ConcentrationInput {
        static let minInitial: CGFloat = 0.15
        static let maxInitial: CGFloat = 0.3

        static let minFinal: CGFloat = 0.05

        static let cToIncrement: CGFloat = 0.05

        static let maxAxis: CGFloat = 0.5
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
