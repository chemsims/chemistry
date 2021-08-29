//
// Reactions App
//

import ReactionsCore
import SwiftUI

class TippingViewModel: ObservableObject {

    init(storeManager: StoreManager, analytics: GeneralAppAnalytics) {
        self.storeManager = storeManager
        self.unitLocker = storeManager.locker
        self.analytics = analytics
        self.wasUnlockedOnInitialisation = UnlockBadgeTipLevel.allCases.contains { level in
            storeManager.locker.isUnlocked(level.product)
        }
    }

    @Published var selectedTipLevel = UnlockBadgeTipLevel.level2
    let storeManager: StoreManager
    let unitLocker: ProductLocker
    let analytics: GeneralAppAnalytics

    private let wasUnlockedOnInitialisation: Bool

    var studentsToShow: Int {
        if wasUnlockedOnInitialisation {
            return 5
        }
        switch selectedTipLevel {
        case .level1: return 1
        case .level2: return 2
        case .level3: return 3
        case .level4: return 5
        }
    }

    var tipButtonEnabled: Bool {
        if wasUnlockedOnInitialisation || isPurchasing || hasPurchased {
            return false
        }

        let currentProduct = selectedTipLevel.product
        guard let currentState = storeManager.products.first(where: {
            $0.type.inAppPurchaseId == currentProduct.inAppPurchaseId
        }) else {
            return false
        }

        return currentState.state.isReadyForPurchase
    }

    func makeTipPurchaseFromMenu() {
        guard tipButtonEnabled else {
            return
        }
        analytics.beganUnlockBadgePurchaseFromMenu(
            productId: selectedTipLevel.product.inAppPurchaseId
        )
        makeTipPurchase()
    }

    func makeTipPurchaseFromPrompt(promptCount: Int) {
        guard tipButtonEnabled else {
            return
        }
        analytics.beganUnlockBadgePurchaseFromTipPrompt(
            promptCount: promptCount,
            productId: selectedTipLevel.product.inAppPurchaseId
        )
        makeTipPurchase()
    }

    private func makeTipPurchase() {
        guard tipButtonEnabled else {
            return
        }
        storeManager.beginPurchase(of: selectedTipLevel.product)
    }

    private func state(forLevel level: UnlockBadgeTipLevel) -> InAppPurchaseWithState? {
        storeManager.products.first { products in
            products.type == level.product
        }
    }

    var isPurchasing: Bool {
        anyTipStateSatisfies {
            switch $0.state {
            case .deferred, .purchasing: return true
            default: return false
            }
        }
    }

    var hasPurchased: Bool {
        UnlockBadgeTipLevel.allCases.contains { level in
            unitLocker.isUnlocked(level.product)
        }
    }

    private func anyTipStateSatisfies(predicate: (InAppPurchaseWithState) -> Bool) -> Bool {
        UnlockBadgeTipLevel.allCases.contains { level in
            if let state = state(forLevel: level) {
                return predicate(state)
            }
            return false
        }
    }
}

enum UnlockBadgeTipLevel: Int, Identifiable, CaseIterable, Comparable {

    static func < (lhs: UnlockBadgeTipLevel, rhs: UnlockBadgeTipLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case level1, level2, level3, level4

    static let max = UnlockBadgeTipLevel.allCases.max()!

    var id: Int {
        rawValue
    }

    /// A user-facing index, which starts at 1
    var userFacingIndex: Int {
        id + 1
    }

    var next: UnlockBadgeTipLevel? {
        Self.withId(id + 1)
    }

    var previous: UnlockBadgeTipLevel? {
        Self.withId(id - 1)
    }

    private static func withId(_ id: Int) -> UnlockBadgeTipLevel? {
        Self.allCases.first { $0.id == id }
    }

    var product: InAppPurchase {
        switch self {
        case .level1: return .tipWithBadge1
        case .level2: return .tipWithBadge2
        case .level3: return .tipWithBadge3
        case .level4: return .tipWithBadge4
        }
    }
}

enum ExtraTipLevel: Int, Identifiable, CaseIterable {
    case level1, level2, level3, level4

    var id: Int {
        rawValue
    }

    var product: InAppPurchase {
        switch self {
        case .level1: return .extraTip1
        case .level2: return .extraTip2
        case .level3: return .extraTip3
        case .level4: return .extraTip4
        }
    }
}
