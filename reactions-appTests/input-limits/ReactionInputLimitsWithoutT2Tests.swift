//
// Reactions App
//

import XCTest
@testable import reactions_app

class ReactionInputLimitsWithoutT2Test: XCTestCase {

    func testC1LimitsWithNoT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 2)
        let model = ReactionInputLimitsWithoutT2(
            cRange: cRange,
            tRange: tRange,
            t1: 0,
            c1: 10,
            concentration: concentration
        )

        let expectedC1 = InputLimits(
            min: 0,
            max: 10,
            smallerOtherValue: 1,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.c1Limits, expectedC1)
    }

//    func testC1LimitsWithNoT2WhereC1IsBoundByMaxT2AtC2MinimumInput() {
//        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
//        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
//
//        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.5)
//        let model = ReactionInputLimitsWithoutT2(
//            cRange: cRange,
//            tRange: tRange,
//            t1: 0,
//            c1: 10,
//            concentration: concentration
//        )
//
//        let expectedC1 = InputLimits(
//            min: 7,
//            max: 10,
//            smallerOtherValue: 1,
//            largerOtherValue: nil
//        )
//        XCTAssertEqual(model.c1Limits, expectedC1)
//    }

    func testT1LimitsNoT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.4)
        let model = ReactionInputLimitsWithoutT2(
            cRange: cRange,
            tRange: tRange,
            t1: 0,
            c1: 10,
            concentration: concentration
        )

        let expectedT1 = InputLimits(
            min: 0,
            max: 5,
            smallerOtherValue: nil,
            largerOtherValue: 9
        )
        XCTAssertEqual(model.t1Limits, expectedT1)
    }

    func testC2LimitsNoT2WhereC2IsBoundByMaxT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.4)
        let model = ReactionInputLimitsWithoutT2(
            cRange: cRange,
            tRange: tRange,
            t1: 0,
            c1: 10,
            concentration: concentration
        )

        let expectedC2 = InputLimits(
            min: 6,
            max: 10,
            smallerOtherValue: nil,
            largerOtherValue: 10
        )
        XCTAssertEqual(model.c2Limits, expectedC2)
    }
}
