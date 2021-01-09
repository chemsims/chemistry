//
// Reactions App
//
  

import Foundation

import XCTest
@testable import reactions_app

class ReactionInputTests: XCTestCase {

    func testMakingZeroOrderReactionInputFromAFixedRateReaction() {
        testMakingSecondOrderReactionInputFromAFixedRateReaction(.Zero)
    }

    func testMakingFirstOrderReactionInputFromAFixedRateReaction() {
        testMakingSecondOrderReactionInputFromAFixedRateReaction(.First)
    }

    func testMakingSecondOrderReactionInputFromAFixedRateReaction() {
        testMakingSecondOrderReactionInputFromAFixedRateReaction(.Second)
    }


    private func testMakingSecondOrderReactionInputFromAFixedRateReaction(_ order: ReactionOrder) {
        let fixedReaction = ReactionInputWithoutC2(order: order)
        fixedReaction.inputC1 = 1
        fixedReaction.inputT1 = 10
        fixedReaction.inputT2 = 20

        let inputToSave = fixedReaction.reactionInput
        XCTAssertNotNil(inputToSave)

        let variedReaction = ReactionInputAllProperties(order: order)
        variedReaction.inputT1 = inputToSave!.t1
        variedReaction.inputT2 = inputToSave!.t2
        variedReaction.inputC1 = inputToSave!.c1
        variedReaction.inputC2 = inputToSave!.c2

        let k1 = fixedReaction.concentrationA?.rateConstant
        let k2 = variedReaction.concentrationA?.rateConstant

        XCTAssertNotNil(k1)
        XCTAssertNotNil(k2)
        XCTAssertEqual(k1!, k2!, accuracy: 0.0001)
    }

}
