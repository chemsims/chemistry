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
        XCTAssertNil(model.input)

        let input = PrecipitationComponents.Input(
            rows: 5,
            knownReactantAdded: 4,
            initialUnknownReactantAdded: 3
        )
        model.setComponentInput(input)
        XCTAssertEqual(model.input?.rows, input.rows)
        XCTAssertEqual(model.input?.initialUnknownReactantAdded, input.initialUnknownReactantAdded)
        XCTAssertEqual(model.input?.knownReactantAdded, input.knownReactantAdded)
    }

    func testSavingReaction() {
        let model = UserDefaultsPrecipitationInputPersistence(prefix: "test")
        XCTAssertNil(model.reaction)

        let reaction = PrecipitationReaction.availableReactionsWithRandomMetals().randomElement()!
        model.setReaction(reaction)

        XCTAssertEqual(model.reaction?.id, reaction.id)
        XCTAssertEqual(model.reaction?.unknownReactant.metal, reaction.unknownReactant.metal)
    }

    func testSavingBeakerView() {
        let model = UserDefaultsPrecipitationInputPersistence(prefix: "test")
        XCTAssertNil(model.beakerView)

        model.setBeakerView(.macroscopic)
        XCTAssertEqual(model.beakerView, .macroscopic)
    }
}
