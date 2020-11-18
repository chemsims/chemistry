//
// Reactions App
//


import CoreGraphics

struct ReactionSettings {

    // Axis settings
    static let minConcentration: CGFloat = 0
    static let maxConcentration: CGFloat = 1
    static let minTime: CGFloat = 0
    static let maxTime: CGFloat = 17

    static let minLogConcentration: CGFloat = -4
    static let maxLogConcentration: CGFloat = 0

    /// The minimum value that concentration 2 may be. Concentration 1 is liited to ensure there is sufficient space
    static let minFinalConcentration: CGFloat = 0.15

    /// The minimum value that time 2 may be. Time 1 is liited to ensure there is sufficient space
    static let minFinalTime: CGFloat = 13
}
