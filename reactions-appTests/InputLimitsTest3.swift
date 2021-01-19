//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class InputLimitsTest2: XCTestCase {

    func testC1LimitsWithNoC2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 2, valueSpacing: 2)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 2)
        let model = Foo(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedC1 = InputLimits(
            min: 8,
            max: 10,
            smallerOtherValue: 1,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.c1Limits, expectedC1)
    }

    func testT1LimitsWithNoC2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.5)
        let model = Foo(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedT1 = InputLimits(
            min: 0,
            max: 10,
            smallerOtherValue: nil,
            largerOtherValue: 9
        )
        XCTAssertEqual(model.t1Limits, expectedT1)
    }

    func testT2LimitsWithNoC2WhereMinC2IsAboveMaxT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.5)
        let model = Foo(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedT2 = InputLimits(
            min: 0,
            max: 10,
            smallerOtherValue: 0,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.t2Limits, expectedT2)
    }

    func testT2LimitsWithNoC2WhereMinC2IsBelowMaxT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 2)
        let model = Foo(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedT2 = InputLimits(
            min: 0,
            max: 5,
            smallerOtherValue: 0,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.t2Limits, expectedT2)
    }

    func testC1LimitsWithNoT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 2)
        let model = Bar(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
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

    func testC1LimitsWithNoT2WhereC1IsBoundByMaxT2AtC2MinimumInput() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.5)
        let model = Bar(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedC1 = InputLimits(
            min: 7,
            max: 10,
            smallerOtherValue: 1,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.c1Limits, expectedC1)
    }

    func testT1LimitsNoT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: 0.4)
        let model = Bar(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
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
        let model = Bar(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
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
