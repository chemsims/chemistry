//
// Reactions App
//

@testable import reactions_app

extension OrderedReactionScreenElement: Comparable {

    public static func < (lhs: OrderedReactionScreenElement, rhs: OrderedReactionScreenElement) -> Bool {
        let i1 = allCases.firstIndex(of: lhs)!
        let i2 = allCases.firstIndex(of: rhs)!
        return i1 < i2
    }

}
