//
// Reactions App
//

import XCTest
@testable import reactions_app

class ReactionInputPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    private func newModel() -> ReactionInputPersistence {
        UserDefaultsReactionInputPersistence()
    }

    func testCompletingScreens() {
        let model = newModel()
        AppScreen.allCases.forEach { screen in
            XCTAssertFalse(model.hasCompleted(screen: screen), "\(screen)")
            model.setCompleted(screen: screen)
            XCTAssertTrue(model.hasCompleted(screen: screen), "\(screen)")
        }
    }

    func testSavingReactionInputs() {
        let model = newModel()
        let reactionOrders = ReactionOrder.allCases
        let reactionTypes = ReactionType.allCases
        reactionOrders.forEach { order in
            reactionTypes.forEach { type in
                let msg = "\(order) - \(type)"
                XCTAssertNil(model.get(order: order, reaction: type), msg)
                let newInput = randomReactionInput()
                model.save(input: newInput, order: order, reaction: type)
                let getInput = model.get(order: order, reaction: type)
                compareReactionInput(getInput, newInput, msg)
            }
        }
    }

    func testHasIdentifiedReactionOrder() {
        let model = newModel()
        XCTAssertFalse(model.hasIdentifiedReactionOrders())
        model.setHasIdentifiedReactionOrders()
        XCTAssertTrue(model.hasIdentifiedReactionOrders())
    }

    private func compareReactionInput(
        _ lhs: ReactionInput?,
        _ rhs: ReactionInput,
        _ msg: String
    ) {
        let accuracy: CGFloat = 0.00001
        XCTAssertNotNil(lhs)
        XCTAssertEqual(lhs!.c1, rhs.c1, accuracy: accuracy, msg)
        XCTAssertEqual(lhs!.c2, rhs.c2, accuracy: accuracy, msg)
        XCTAssertEqual(lhs!.t1, rhs.t1, accuracy: accuracy, msg)
        XCTAssertEqual(lhs!.t2, rhs.t2, accuracy: accuracy, msg)
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
