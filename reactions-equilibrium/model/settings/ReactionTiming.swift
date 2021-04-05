//
// Reactions App
//

import CoreGraphics

struct ReactionTiming {
    let offset: CGFloat
    let start: CGFloat
    let equilibrium: CGFloat
    let end: CGFloat
}

extension ReactionTiming {
    static let equilibriumTime: CGFloat = 15

    static let totalReactionTime: CGFloat = 20

    static let gapBetweenReactions: CGFloat = 3

    static func standard(reactionIndex: Int) -> ReactionTiming {
        let offset = CGFloat(reactionIndex) * totalReactionTime
        let start = offset == 0 ? 0 : offset + gapBetweenReactions
        return ReactionTiming(
            offset: offset,
            start: start,
            equilibrium: offset + equilibriumTime,
            end: offset + totalReactionTime
        )
    }
}
