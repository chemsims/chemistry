//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionFilingViewModelTests: XCTestCase {

    func testThatReactionTypeIsSet() {
        let persistence = InMemoryReactionInputPersistence()
        let filingModel = ReactionFilingViewModel(persistence: persistence, order: .Zero)

        func doTest(_ reactionType: ReactionType) {
            persistence.save(input: ReactionInput(c1: 1, c2: 0.1, t1: 1, t2: 20), order: .Zero, reaction: reactionType)
            let reaction = ZeroOrderReactionViewModel()

            // Just need to get navigation model to apply the initial state
            let _ = filingModel.navigation(model: reaction, reactionType: reactionType)
            XCTAssertEqual(reaction.selectedReaction, reactionType)
        }

        doTest(.A)
        doTest(.B)
        doTest(.C)
    }
}
