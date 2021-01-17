//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionInputModelTests: XCTestCase {

    func testZeroOrderReactionALimits() {
        var model = ReactionInputAllProperties(order: .Zero)

        let expected = FixedInputLimits(
            min: ReactionSettings.minCInput,
            max: ReactionSettings.maxCInput,
            smallerOtherValue: ReactionSettings.minC2Input,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.c1Limits as! FixedInputLimits, expected)

        var c2Expected: FixedInputLimits {
            FixedInputLimits(
                min: ReactionSettings.minCInput,
                max: ReactionSettings.maxCInput,
                smallerOtherValue: nil,
                largerOtherValue: model.inputC1
            )
        }

        XCTAssertEqual(model.c2Limits as! FixedInputLimits, c2Expected)
        model.inputC1 = 0.2
        XCTAssertEqual(model.c2Limits as! FixedInputLimits, c2Expected)
    }

}
