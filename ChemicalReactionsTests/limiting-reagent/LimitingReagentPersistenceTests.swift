//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class LimitingReagentPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSavingInput() {
        let model = UserDefaultsLimitingReagentPersistence(prefix: "test")
        let input = LimitingReagentComponents.ReactionInput(rows: 10, limitingReactantAdded: 20)
        let reaction = LimitingReagentReaction.availableReactions[1]

        XCTAssertNil(model.getInput(reaction: reaction))

        model.saveInput(reaction: reaction, input)

        let saved = model.getInput(reaction: reaction)
        XCTAssertEqual(saved?.rows, input.rows)
        XCTAssertEqual(saved?.limitingReactantAdded, input.limitingReactantAdded)
    }
}
