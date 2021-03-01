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
}
