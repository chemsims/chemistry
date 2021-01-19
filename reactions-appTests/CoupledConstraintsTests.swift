//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class CoupledConstraintsTests: XCTestCase {

    func testC1IsLimitedByC1() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 2, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(a0: 10, rateConstant: -1)
        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedC1 = InputLimits(min: 0, max: 10, smallerOtherValue: 1, largerOtherValue: nil)
        XCTAssertEqual(model.c1Limits, expectedC1)
    }

    func testC1IsLimitedByMinT2Range() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 2, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 1)
        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedC1 = InputLimits(min: 3, max: 10, smallerOtherValue: 1, largerOtherValue: nil)
        XCTAssertEqual(model.c1Limits, expectedC1)
    }

    func testT1IsLimitedByT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 2, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 1)
        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedT1 = InputLimits(
            min: 0,
            max: 8,
            smallerOtherValue: nil,
            largerOtherValue: 8
        )
        XCTAssertEqual(model.t1Limits, expectedT1)
    }

    func testT1IsLimitedByMinC2Range() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 0.5)
        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedT1 = InputLimits(
            min: 0,
            max: 6,
            smallerOtherValue: nil,
            largerOtherValue: 9
        )
        XCTAssertEqual(model.t1Limits, expectedT1)
    }

    func testC2Limits() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let concentration = ZeroOrderConcentration(c1: 5, t1: 0, rateConstant: 0.5)
        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 5,
            t1: 0,
            concentration: concentration
        )

        let expectedC2 = InputLimits(
            min: 0,
            max: 4.5,
            smallerOtherValue: nil,
            largerOtherValue: 5
        )
        XCTAssertEqual(model.c2Limits, expectedC2)
    }

    func testC2LimitedByT2() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 2)
        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 2)
        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedC2 = InputLimits(
            min: 0,
            max: 6,
            smallerOtherValue: nil,
            largerOtherValue: 10
        )
        XCTAssertEqual(model.c2Limits, expectedC2)
    }

    func testT2LimitedByMaxValue() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 0.5)

        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )

        let expectedT2 = InputLimits(
            min: 0, max: 10,
            smallerOtherValue: 0,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.t2Limits, expectedT2)
    }

    func testT2LimitedByC2() {
        let cRange = InputRange(min: 1, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 2)

        let model = CoupledConstraints(
            cRange: cRange,
            tRange: tRange,
            c1: 10,
            t1: 0,
            concentration: concentration
        )
        let expectedT2 = InputLimits(
            min: 0,
            max: 4.5,
            smallerOtherValue: 0,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.t2Limits, expectedT2)
    }

    func testT1LimitsForSecondOrderConcentration() {
        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
        let tRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)

        let concentration = SecondOrderConcentration(c1: 10, t1: 0, rateConstant: 0.01)

        let model = CoupledConstraints(
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

//    func testLimitsForConstantConcentration() {
//        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
//        let tRange = InputRange(min: 0, max: 10, minInputRange: 2, valueSpacing: 1)
//
//        let concentration = ZeroOrderConcentration(c1: 10, t1: 0, rateConstant: 1)
//        let model = CoupledConstraints(
//            cRange: cRange,
//            tRange: tRange,
//            c1: 10,
//            t1: 0,
//            concentration: concentration
//        )
//
//        let expectedC1 = InputLimits(min: 3, max: 10, smallerOtherValue: 1, largerOtherValue: nil)
//        XCTAssertEqual(model.c1Limits, expectedC1)
//
//        let expectedT1 = InputLimits(min: 0, max: 8, smallerOtherValue: nil, largerOtherValue: 8)
//        XCTAssertEqual(model.t1Limits, expectedT1)
//
//        let expectedC2 = InputLimits(min: 0, max: 10, smallerOtherValue: nil, largerOtherValue: 10)
//        XCTAssertEqual(model.c2Limits, expectedC2)
//
//        let expectedT2 = InputLimits(min: 0, max: 10, smallerOtherValue: 0, largerOtherValue: nil)
//        XCTAssertEqual(model.t2Limits, expectedT2)
//    }
//
//    func testLimitsForVaryingConcentration() {
//        let cRange = InputRange(min: 0, max: 10, minInputRange: 1, valueSpacing: 1)
//        let tRange = InputRange(min: 0, max: 10, minInputRange: 2, valueSpacing: 1)
//
//        var c1: CGFloat = 10
//        var concentration: ConcentrationEquation {
//            ZeroOrderConcentration(c1: c1, t1: 0, rateConstant: 1)
//        }
//        var model: CoupledConstraints {
//            CoupledConstraints(
//                cRange: cRange, tRange: tRange, c1: c1, t1: 0, concentration: concentration
//            )
//        }
//
//        let expectedC1 = InputLimits(min: 3, max: 10, smallerOtherValue: 1, largerOtherValue: nil)
//        XCTAssertEqual(model.c1Limits, expectedC1)
//
//        let expectedT1 = InputLimits(min: 0, max: 8, smallerOtherValue: nil, largerOtherValue: 8)
//        XCTAssertEqual(model.t1Limits, expectedT1)
//
//        let expectedC2 = InputLimits(min: 0, max: 10, smallerOtherValue: nil, largerOtherValue: c1)
//        XCTAssertEqual(model.c2Limits, expectedC2)
//
//        let expectedT2 = InputLimits(min: 0, max: 10, smallerOtherValue: 0, largerOtherValue: nil)
//        XCTAssertEqual(model.t2Limits, expectedT2)
//
//        c1 = 5
//
//        let expectedT2_2 = InputLimits(min: 0, max: 5, smallerOtherValue: 0, largerOtherValue: nil)
//        XCTAssertEqual(model.t2Limits, expectedT2_2)
//
//    }
}
