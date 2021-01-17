//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionInputModelTests: XCTestCase {

    func testZeroOrderInputAllPropertiesLimits() {
        var model = ReactionInputAllProperties(order: .Zero)

        let expected = InputLimits(
            min: minCInput,
            max: maxCInput,
            smallerOtherValue: minC2Input,
            largerOtherValue: nil
        )
        checkInputs(model.limitsNoSpacing.c1Limits, expected)

        var c2Expected: InputLimits {
            InputLimits(
                min: minCInput,
                max: maxCInput,
                smallerOtherValue: nil,
                largerOtherValue: model.inputC1
            )
        }

        checkInputs(model.limitsNoSpacing.c2Limits, c2Expected)
        model.inputC1 = 0.2
        checkInputs(model.limitsNoSpacing.c2Limits, c2Expected)

        let t1Expected = InputLimits(
            min: minT,
            max: maxT,
            smallerOtherValue: nil,
            largerOtherValue: ReactionSettings.Input.minT2Input
        )
        checkInputs(model.limitsNoSpacing.t1Limits, t1Expected)
    }

    func testZeroOrderReactionWithoutT2Limits() {
        var model = ReactionInputWithoutT2(order: .Zero)

        model.inputC1 = 1
        model.inputT1 = 15

        let expectedC2 = InputLimits(
            min: model.concentrationA!.getConcentration(at: maxT),
            max: maxCInput,
            smallerOtherValue: nil,
            largerOtherValue: 1
        )

        checkInputs(model.limitsNoSpacing.c2Limits, expectedC2)
    }

    func testZeroOrderReactionWithoutC2() {
        var model = ReactionInputWithoutC2(order: .Zero)
        model.inputC1 = 0.2
        model.inputT1 = 1

        let expectedT2 = InputLimits(
            min: ReactionSettings.Input.minT1,
            max: model.concentrationA!.time(for: minCInput)!,
            smallerOtherValue: 1,
            largerOtherValue: nil
        )
        checkInputs(model.limitsNoSpacing.t2Limits, expectedT2)
    }

    func testFirstOrderReactionInputAllPropertiesLimits() {
        let model = ReactionInputAllProperties(order: .First)
        let expectedT2 = InputLimits(
            min: ReactionSettings.Input.minT2,
            max: maxT,
            smallerOtherValue: nil,
            largerOtherValue: nil
        )
        checkInputs(model.limitsNoSpacing.t2Limits, expectedT2)
    }

    func testSecondOrderReactionWithoutT2() {
        var model = ReactionInputWithoutT2(order: .Second)
        model.inputT1 = 15

        let minC2 = model.concentrationA!.getConcentration(at: maxT)
        let upperC2 = minC2 + ReactionSettings.Input.minCRange
        let expectedC1 = InputLimits(
            min: minCInput,
            max: maxCInput,
            smallerOtherValue: upperC2,
            largerOtherValue: nil
        )

        checkInputs(model.limitsNoSpacing.c1Limits, expectedC1)

        let cSpacing: CGFloat = 0.1
        let lowerC1 = upperC2 + cSpacing
        let timeAtMinC1 = model.concentrationA!.time(for: lowerC1)!
        let expectedT1 = InputLimits(
            min: minT,
            max: timeAtMinC1,
            smallerOtherValue: nil,
            largerOtherValue: minT2Input
        )
        let limits = model.limits(cAbsoluteSpacing: cSpacing, tAbsoluteSpacing: 0)
        checkInputs(limits.t1Limits, expectedT1)
    }

    private func checkInputs(_ l: InputLimits, _ r: InputLimits) {
        let accuracy: CGFloat = 0.00001
        XCTAssertEqual(l.min, r.min, accuracy: accuracy)
        XCTAssertEqual(l.max, r.max, accuracy: accuracy)
        checkOptFloat(l.smallerOtherValue, r.smallerOtherValue)
        checkOptFloat(l.largerOtherValue, r.largerOtherValue)
    }

    private func checkOptFloat(_ l: CGFloat?, _ r: CGFloat?) {
        if (l == nil) {
            XCTAssertEqual(l, r)
        } else {
            XCTAssertNotNil(r)
            XCTAssertEqual(l!, r!, accuracy: 0.00001)
        }
    }

    private let minCInput = ReactionSettings.Input.minC
    private let maxCInput = ReactionSettings.Input.maxC
    private let minC2Input = ReactionSettings.Input.minC2Input
    private let maxT = ReactionSettings.Input.maxT
    private let minT = ReactionSettings.Input.minT1
    private let minT2Input = ReactionSettings.Input.minT2Input
}

fileprivate extension ReactionInputModel {
    var limitsNoSpacing: ReactionInputLimits {
        limits(cAbsoluteSpacing: 0, tAbsoluteSpacing: 0)
    }
}
