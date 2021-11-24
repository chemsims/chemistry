//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class PrecipitationInputPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSavingInput() {
        let model = UserDefaultsPrecipitationInputPersistence(prefix: "test")
        XCTAssertNil(model.getComponentInput(reactionIndex: 0))

        let input = PrecipitationComponents.Input(
            rows: 5,
            knownReactantAdded: 4,
            initialUnknownReactantAdded: 3,
            reactantMetal: .K
        )
        model.setComponentInput(reactionIndex: 0, input: input)
        let saved = model.getComponentInput(reactionIndex: 0)
        XCTAssertEqual(saved?.rows, input.rows)
        XCTAssertEqual(saved?.initialUnknownReactantAdded, input.initialUnknownReactantAdded)
        XCTAssertEqual(saved?.knownReactantAdded, input.knownReactantAdded)
    }

    func testSavingBeakerView() {
        let model = UserDefaultsPrecipitationInputPersistence(prefix: "test")
        XCTAssertNil(model.beakerView)

        model.setBeakerView(.macroscopic)
        XCTAssertEqual(model.beakerView, .macroscopic)
    }
}
