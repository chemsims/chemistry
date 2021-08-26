//
// Reactions App
//

import Foundation

enum InAppPurchase: String, CaseIterable {

    case tipWithBadge1,
         tipWithBadge2,
         tipWithBadge3,
         tipWithBadge4,
         extraTip1,
         extraTip2,
         extraTip3,
         extraTip4

    var inAppPurchaseId: String {
        switch self {
        case .tipWithBadge1: return "tip_with_badge_1"
        case .tipWithBadge2: return "tip_with_badge_2"
        case .tipWithBadge3: return "tip_with_badge_3"
        case .tipWithBadge4: return "tip_with_badge_4"

        case .extraTip1: return "tip_1"
        case .extraTip2: return "tip_2"
        case .extraTip3: return "tip_3"
        case .extraTip4: return "tip_4"
        }
    }

    var isConsumableTip: Bool {
        switch self {
        case .extraTip1, .extraTip2, .extraTip3, .extraTip4: return true
        default: return false
        }
    }
}
