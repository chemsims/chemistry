//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class EnergyProfilePersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSavingInput() throws {
        let model = newModel()
        XCTAssertNil(model.getInput())

        let input = EnergyProfileInput(catalysts: [.B, .A, .C], order: .Second)
        model.setInput(input)
        XCTAssertEqual(model.getInput(), input)
    }

    private func newModel() -> EnergyProfilePersistence {
        UserDefaultsEnergyProfilePersistence()
    }

}
