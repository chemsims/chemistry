//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionInputModelTests: XCTestCase {

    func testZeroOrderReactionALimits() {
        var model = ReactionInputAllProperties(order: .Zero)

        let expected = InputLimits(
            min: ReactionSettings.minCInput,
            max: ReactionSettings.maxCInput,
            smallerOtherValue: ReactionSettings.minC2Input,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.c1Limits, expected)

        var c2Expected: InputLimits {
            InputLimits(
                min: ReactionSettings.minCInput,
                max: ReactionSettings.maxCInput,
                smallerOtherValue: nil,
                largerOtherValue: model.inputC1
            )
        }

        XCTAssertEqual(model.c2Limits, c2Expected)
        model.inputC1 = 0.2
        XCTAssertEqual(model.c2Limits, c2Expected)
    }

}
