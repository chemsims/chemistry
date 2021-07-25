//
// Reactions App
//

import XCTest
@testable import APChemistry

class StoreManagerTests: XCTestCase {

    func testReactionsRateIsUnlockedAfterInitialisingModel() {
        let model = StoreManager(
            locker: InMemoryUnitLocker(allUnitsAreUnlocked: false),
            products: DebugProductLoader(),
            storeObserver: DebugStoreObserver()
        )

        model.initialiseStore()

        let firstUnit = model.units.first!
        XCTAssertEqual(firstUnit.unit, .reactionRates)
        XCTAssertEqual(firstUnit.state, .purchased)
    }
}
