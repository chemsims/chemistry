//
// Reactions App
//


import CoreGraphics

struct ReactionSettings {

    // Axis settings
    static let minConcentration: CGFloat = 0
    static let maxConcentration: CGFloat = 1
    static let minTime: CGFloat = 0
    static let maxTime: CGFloat = 20

    // Input settings
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

    /// The minimum value that concentration 2 may be. Concentration 1 is liited to ensure there is sufficient space
    static let minFinalConcentration: CGFloat = 0.15

    /// The minimum value that time 2 may be. Time 1 is liited to ensure there is sufficient space
    static let minFinalTime: CGFloat = 15
}
