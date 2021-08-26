//
// Reactions App
//

import XCTest
@testable import APChemistry

class StoreManagerTests: XCTestCase {

    func testInProgressPurchaseRemainsInProgressWhenModelReloadsProducts() {
        let model = newModel(actionDelay: 1)

        var tip1: InAppPurchaseWithState {
            model.products.first { $0.type == .tipWithBadge1 }!
        }

        model.loadProducts()
        model.beginPurchase(of: .tipWithBadge1)

        XCTAssertEqual(tip1.state, .purchasing)

        model.loadProducts()

        XCTAssertEqual(tip1.state, .purchasing)
    }

    func testRestoringPurchase() {
        let model = StoreManager(
            locker: InMemoryProductLocker(allProductsAreUnlocked: false),
            productLoader: DebugProductLoader(loadDelay: nil),
            storeObserver: RestoreTip1Observer(actionDelay: nil)
        )
        var tip1: InAppPurchaseWithState {
            model.products.first { $0.type == .tipWithBadge1 }!
        }

        model.loadProducts()
        model.restorePurchases()
        XCTAssertEqual(tip1.state, .purchased)
    }

    private func newModel(actionDelay: Int? = 0) -> StoreManager {
        StoreManager(
            locker: InMemoryProductLocker(allProductsAreUnlocked: false),
            productLoader: DebugProductLoader(loadDelay: nil),
            storeObserver: DebugStoreObserver(actionDelay: actionDelay)
        )
    }
}

private class RestoreTip1Observer: DebugStoreObserver {
    override init(actionDelay: Int?) {
        super.init(actionDelay: actionDelay)
    }

    override func restorePurchases() {
        delegate?.didRestore(productId: InAppPurchase.tipWithBadge1.inAppPurchaseId)
    }
}
