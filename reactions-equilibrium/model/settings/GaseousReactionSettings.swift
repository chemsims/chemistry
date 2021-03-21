//
// Reactions App
//

import Foundation
import CoreGraphics

struct GaseousReactionSettings {
    static let minRows = 8
    static let maxRows = 15
    static let initialRows = (minRows + maxRows) / 2


    private static let equilibriumTime: CGFloat = AqueousReactionSettings.timeForConvergence
    private static let totalReactionTime: CGFloat = AqueousReactionSettings.forwardReactionTime
    private static let gapBetweenReactions: CGFloat = AqueousReactionSettings.timeToAddProduct - totalReactionTime

    static let forwardTiming = OffsetTiming(offset: 0)
    static let pressureTiming = OffsetTiming(offset: totalReactionTime)

    struct OffsetTiming {

        let offset: CGFloat
        let start: CGFloat
        let equilibrium: CGFloat
        let end: CGFloat

        init(offset: CGFloat) {
            self.offset = offset
            self.start = offset + GaseousReactionSettings.gapBetweenReactions
            self.equilibrium = offset + GaseousReactionSettings.equilibriumTime
            self.end = offset + GaseousReactionSettings.totalReactionTime
        }

    }

}
