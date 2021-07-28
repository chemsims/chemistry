//
// Reactions App
//

import XCTest
@testable import APChemistry

class StoreManagerTests: XCTestCase {

    func testReactionsRateIsUnlockedAfterInitialisingModel() {
        let model = newModel()

        let firstUnit = model.units.first!
        XCTAssertEqual(firstUnit.unit, .reactionRates)
        XCTAssertEqual(firstUnit.state, .purchased)
    }

    func testInProgressPurchaseRemainsInProgressWhenModelReloadsProducts() {
        let model = newModel(actionDelay: 1)

        var equilibriumUnit: UnitWithState {
            model.units.first { $0.unit == .equilibrium }!
        }

        model.loadProducts()
        model.beginPurchase(of: .equilibrium)

        XCTAssertEqual(equilibriumUnit.state, .purchasing)

        model.loadProducts()

        XCTAssertEqual(equilibriumUnit.state, .purchasing)
    }

    private func newModel(actionDelay: Int? = 0) -> StoreManager {
        StoreManager(
            locker: InMemoryUnitLocker(allUnitsAreUnlocked: false),
            products: DebugProductLoader(loadDelay: nil),
            storeObserver: DebugStoreObserver(actionDelay: actionDelay)
        )
    }
}
