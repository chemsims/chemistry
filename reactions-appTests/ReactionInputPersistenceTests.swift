//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionInputPersistenceTests: XCTestCase {

    private func newModel() -> ReactionInputPersistence {
        InMemoryReactionInputPersistence()
    }

    func testCompletingScreens() {
        let model = newModel()
        AppScreen.allCases.forEach { screen in
            XCTAssertFalse(model.hasCompleted(screen: screen), "\(screen)")
            model.setCompleted(screen: screen)
            XCTAssertTrue(model.hasCompleted(screen: screen), "\(screen)")
        }
    }

    func testUsingCatalysts() {
        let model = newModel()
        Catalyst.allCases.forEach { catalyst in
            XCTAssertFalse(model.hasUsed(catalyst: catalyst), "\(catalyst)")
            model.setUsed(catalyst: catalyst)
            XCTAssertTrue(model.hasUsed(catalyst: catalyst), "\(catalyst)")
        }
    }

    func testSavingReactionInputs() {
        let model = newModel()
        let reactionOrders = ReactionOrder.allCases
        let reactionTypes = OrderedReactionSet.allCases
        reactionOrders.forEach { order in
            reactionTypes.forEach { type in
                let msg = "\(order) - \(type)"
                XCTAssertNil(model.get(order: order, reaction: type), msg)
                let newInput = randomReactionInput()
                model.save(input: newInput, order: order, reaction: type)
                let getInput = model.get(order: order, reaction: type)
                XCTAssertEqual(getInput, newInput, msg)
            }
        }
    }

    private func randomReactionInput() -> ReactionInput {
        ReactionInput(
            c1: .random(in: 0...1),
            c2: .random(in: 0...1),
            t1: .random(in: 0...1),
            t2: .random(in: 0...1)
        )
    }
}
