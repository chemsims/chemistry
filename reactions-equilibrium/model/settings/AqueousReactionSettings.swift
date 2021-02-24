//
// Reactions App
//


import CoreGraphics

struct AqueousReactionSettings {
    static let minRows = 6
    static let maxRows = 14

    static let initialRows = (minRows + maxRows) / 2

    /// The number of molecules to increment when user is adding molecules
    static let moleculesToIncrement = 10

    /// The time at which the concentrations should converge
    static let timeForConvergence: CGFloat = 15

    /// The total reaction time
    static let totalReactionTime: CGFloat = 20
}
